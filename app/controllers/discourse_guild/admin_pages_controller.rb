require 'pretty_text'

module DiscourseGuild
  class AdminPagesController < Admin::AdminController
    requires_plugin 'discourse-guild'

    before_filter :fetch_guild_page, only: [:update, :destroy]

    def create
      guild_page = Page.create(guild_page_params)
      if guild_page.valid?
        render json: guild_page, root: false
      else
        render_json_error(guild_page)
      end
    end

    def update
      @guild_page.active = params[:guild_page][:active] if !params[:guild_page][:active].nil?
      @guild_page.title = params[:guild_page][:title] if !params[:guild_page][:title].nil?
      @guild_page.slug = params[:guild_page][:slug] if !params[:guild_page][:slug].nil?
      @guild_page.raw = params[:guild_page][:raw] if !params[:guild_page][:raw].nil?
      @guild_page.cooked = params[:guild_page][:cooked] if !params[:guild_page][:cooked].nil?
      @guild_page.save

      if @guild_page.valid?
        render json: @guild_page, root: false
      else
        render_json_error(@guild_page)
      end
    end

    def destroy
      @guild_page.destroy
      render json: success_json
    end

    def show
      @page = params[:page]
      render_json_dump(page: @page)
    end

    def all
      pages = Page.all
      render_json_dump(pages: pages)
    end


    private

    def fetch_guild_page
      @guild_page = Page.find(params[:guild_page][:id])
    end

    def guild_page_params
      params.permit(guild_page: [:active, :title, :slug, :raw, :cooked])[:guild_page]
    end

  end
end