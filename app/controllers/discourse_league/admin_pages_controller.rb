module DiscourseLeague
  class AdminPagesController < Admin::AdminController
    requires_plugin 'discourse-league'

    def create
      pages = PluginStore.get("discourse_league", "pages")
      id = SecureRandom.random_number(10000)

      if pages.nil?
        pages = []
      else
        until pages[id].nil?
          id = SecureRandom.random_number(10000)
        end
      end

      new_page = { 
        id: id, 
        active: params[:league_page][:active], 
        title: params[:league_page][:title], 
        slug: params[:league_page][:slug], 
        raw: params[:league_page][:raw], 
        cooked: params[:league_page][:cooked], 
        custom_slug: params[:league_page][:custom_slug]
      }

      pages[id] = new_page
      PluginStore.set("discourse_league", "pages", pages)

      render json: new_page, root: false
    end

    def update
      pages = PluginStore.get("discourse_league", "pages")
      league_page = pages[params[:league_page][:id]]

      league_page[:active] = params[:league_page][:active] if !params[:league_page][:active].nil?
      league_page[:title] = params[:league_page][:title] if !params[:league_page][:title].nil?
      league_page[:slug] = params[:league_page][:slug] if !params[:league_page][:slug].nil?
      league_page[:raw] = params[:league_page][:raw] if !params[:league_page][:raw].nil?
      league_page[:cooked] = params[:league_page][:cooked] if !params[:league_page][:cooked].nil?
      league_page[:custom_slug] = params[:league_page][:custom_slug] if !params[:league_page][:custom_slug].nil?

      pages[params[:league_page][:id]] = league_page

      PluginStore.set("discourse_league", "pages", pages)

      render json: league_page, root: false
    end

    def destroy
      pages = PluginStore.get("discourse_league", "pages")

      pages[params[:league_page][:id]] = nil
      PluginStore.set("discourse_league", "pages", pages)

      render json: success_json
    end

    def show
      pages = PluginStore.get("discourse_league", "pages")
      render_json_dump(pages.compact)
    end


    private

    def league_page_params
      params.permit(league_page: [:active, :title, :slug, :raw, :cooked, :custom_slug])[:league_page]
    end

  end
end