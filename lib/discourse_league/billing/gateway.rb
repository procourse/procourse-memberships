require 'net/http'
require 'net/https'
require_relative '../posts_data'
require_relative 'credit_card_formatting'
require_relative '../country'

module DiscourseLeague
  module Billing
    class Gateway
      include PostsData
      include CreditCardFormatting

      DEBIT_CARDS = [ :switch, :solo ]

      # == Standardized Error Codes
      #
      # :incorrect_number - Card number does not comply with ISO/IEC 7812 numbering standard
      # :invalid_number - Card number was not matched by processor
      # :invalid_expiry_date - Expiry date does not match correct formatting
      # :invalid_cvc - Security codes does not match correct format (3-4 digits)
      # :expired_card - Card number is expired
      # :incorrect_cvc - Security code was not matched by the processor
      # :incorrect_zip - Zip code is not in correct format
      # :incorrect_address - Billing address info was not matched by the processor
      # :incorrect_pin - Card PIN is incorrect
      # :card_declined - Card number declined by processor
      # :processing_error - Processor error
      # :call_issuer - Transaction requires voice authentication, call issuer
      # :pickup_card - Issuer requests that you pickup the card from merchant
      # :test_mode_live_card - Card was declined. Request was in test mode, but used a non test card.
      # :unsupported_feature - Transaction failed due to gateway or merchant
      #                        configuration not supporting a feature used, such
      #                        as network tokenization.

      STANDARD_ERROR_CODE = {
        :incorrect_number => 'incorrect_number',
        :invalid_number => 'invalid_number',
        :invalid_expiry_date => 'invalid_expiry_date',
        :invalid_cvc => 'invalid_cvc',
        :expired_card => 'expired_card',
        :incorrect_cvc => 'incorrect_cvc',
        :incorrect_zip => 'incorrect_zip',
        :incorrect_address => 'incorrect_address',
        :incorrect_pin => 'incorrect_pin',
        :card_declined => 'card_declined',
        :processing_error => 'processing_error',
        :call_issuer => 'call_issuer',
        :pickup_card => 'pick_up_card',
        :config_error => 'config_error',
        :test_mode_live_card => 'test_mode_live_card',
        :unsupported_feature => 'unsupported_feature',
      }

      cattr_reader :implementations
      @@implementations = []

      def self.inherited(subclass)
        super
        @@implementations << subclass
      end

      def generate_unique_id
        SecureRandom.hex(16)
      end

      # The format of the amounts used by the gateway
      # :dollars => '12.50'
      # :cents => '1250'
      class_attribute :money_format
      self.money_format = :dollars

      # The default currency for the transactions if no currency is provided
      class_attribute :default_currency

      # The supported card types for the gateway
      class_attribute :supported_cardtypes
      self.supported_cardtypes = []

      class_attribute :currencies_without_fractions
      self.currencies_without_fractions = %w(BIF BYR CLP CVE DJF GNF HUF ISK JPY KMF KRW PYG RWF UGX VND VUV XAF XOF XPF)

      class_attribute :homepage_url
      class_attribute :display_name

      class_attribute :test_url, :live_url

      class_attribute :abstract_class

      self.abstract_class = false

      # The application making the calls to the gateway
      # Useful for things like the PayPal build notation (BN) id fields
      class_attribute :application_id, instance_writer: false
      self.application_id = nil

      attr_reader :options

      # Use this method to check if your gateway of interest supports a credit card of some type
      def self.supports?(card_type)
        supported_cardtypes.include?(card_type.to_sym)
      end

      def self.card_brand(source)
        result = source.respond_to?(:brand) ? source.brand : source.type
        result.to_s.downcase
      end

      def self.supported_countries=(country_codes)
        country_codes.each do |country_code|
          unless DiscourseLeague::Country.find(country_code)
            raise DiscourseLeague::InvalidCountryCodeError, "No country could be found for the country #{country_code}"
          end
        end
        @supported_countries = country_codes.dup
      end

      def self.supported_countries
        @supported_countries ||= []
      end

      def supported_countries
        self.class.supported_countries
      end

      def card_brand(source)
        self.class.card_brand(source)
      end

      # Initialize a new gateway.
      #
      # See the documentation for the gateway you will be using to make sure there are no other
      # required options.
      def initialize(options = {})
        @options = options
      end

      # Are we running in test mode?
      def test?
        (@options.has_key?(:test) ? @options[:test] : Base.test?)
      end

      # Does this gateway know how to scrub sensitive information out of HTTP transcripts?
      def supports_scrubbing?
        false
      end

      def scrub(transcript)
        raise RuntimeError.new("This gateway does not support scrubbing.")
      end

      def supports_network_tokenization?
        false
      end

      protected # :nodoc: all

      def normalize(field)
        case field
          when "true"   then true
          when "false"  then false
          when ""       then nil
          when "null"   then nil
          else field
        end
      end

      def user_agent
        @@ua ||= JSON.dump({
          :lang => 'ruby',
          :lang_version => "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})",
          :platform => RUBY_PLATFORM,
          :publisher => 'discourse_league'
        })
      end

      def strip_invalid_xml_chars(xml)
        begin
          REXML::Document.new(xml)
        rescue REXML::ParseException
          xml = xml.gsub(/&(?!(?:[a-z]+|#[0-9]+|x[a-zA-Z0-9]+);)/, '&amp;')
        end

        xml
      end

      private # :nodoc: all

      def name
        self.class.name.scan(/\:\:(\w+)Gateway/).flatten.first
      end

      def amount(money)
        return nil if money.nil?
        cents = if money.respond_to?(:cents)
          money.cents
        else
          money
        end

        if money.is_a?(String)
          raise ArgumentError, 'money amount must be a positive Integer in cents.'
        end

        if self.money_format == :cents
          cents.to_s
        else
          sprintf("%.2f", cents.to_f / 100)
        end
      end

      def non_fractional_currency?(currency)
        self.currencies_without_fractions.include?(currency.to_s)
      end

      def localized_amount(money, currency)
        amount = amount(money)

        return amount unless non_fractional_currency?(currency)

        if self.money_format == :cents
          sprintf("%.0f", amount.to_f / 100)
        else
          amount.split('.').first
        end
      end

      def currency(money)
        money.respond_to?(:currency) ? money.currency : self.default_currency
      end

      def truncate(value, max_size)
        return nil unless value
        value.to_s[0, max_size]
      end

      def split_names(full_name)
        names = (full_name || "").split
        return [nil, nil] if names.size == 0

        last_name  = names.pop
        first_name = names.join(" ")
        [first_name, last_name]
      end

      def requires_start_date_or_issue_number?(credit_card)
        return false if card_brand(credit_card).blank?
        DEBIT_CARDS.include?(card_brand(credit_card).to_sym)
      end

      def requires!(hash, *params)
        params.each do |param|
          if param.is_a?(Array)
            raise ArgumentError.new("Missing required parameter: #{param.first}") unless hash.has_key?(param.first)

            valid_options = param[1..-1]
            raise ArgumentError.new("Parameter: #{param.first} must be one of #{valid_options.to_sentence(:words_connector => 'or')}") unless valid_options.include?(hash[param.first])
          else
            raise ArgumentError.new("Missing required parameter: #{param}") unless hash.has_key?(param)
          end
        end
      end
    end
  end
end