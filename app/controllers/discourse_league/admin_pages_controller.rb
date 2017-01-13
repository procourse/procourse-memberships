require 'pretty_text'

module DiscourseLeague
  class AdminPagesController < Admin::AdminController
    requires_plugin 'discourse-league'

    before_filter :fetch_league_page, only: [:update, :destroy]

    def create
      league_page = Page.create(league_page_params)
      if league_page.valid?
        render json: league_page, root: false
      else
        render_json_error(league_page)
      end
    end

    def update
      @league_page.active = params[:league_page][:active] if !params[:league_page][:active].nil?
      @league_page.title = params[:league_page][:title] if !params[:league_page][:title].nil?
      @league_page.slug = params[:league_page][:slug] if !params[:league_page][:slug].nil?
      @league_page.raw = params[:league_page][:raw] if !params[:league_page][:raw].nil?
      @league_page.cooked = params[:league_page][:cooked] if !params[:league_page][:cooked].nil?
      @league_page.custom_slug = params[:league_page][:custom_slug] if !params[:league_page][:custom_slug].nil?
      @league_page.save

      if @league_page.valid?
        render json: @league_page, root: false
      else
        render_json_error(@league_page)
      end
    end

    def destroy
      @league_page.destroy
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

    def fetch_league_page
      @league_page = Page.find(params[:league_page][:id])
    end

    def league_page_params
      params.permit(league_page: [:active, :title, :slug, :raw, :cooked, :custom_slug])[:league_page]
    end

  end
end