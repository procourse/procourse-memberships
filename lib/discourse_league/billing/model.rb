require_relative '../empty'

module DiscourseLeague
  module Billing
    class Model
      include DiscourseLeague::Empty

      def initialize(attributes = {})
        attributes.each do |key, value|
          send("#{key}=", value)
        end
      end

      def validate
        {}
      end

      private

      def errors_hash(array)
        array.inject({}) do |hash, (attribute, error)|
          (hash[attribute] ||= []) << error
          hash
        end
      end
    end
  end
end