module DiscourseLeague
  class AdminPagesController < Admin::AdminController
    requires_plugin 'discourse-league'

    def create
      pages = PluginStore.get("discourse_league", "pages")
      id = SecureRandom.random_number(10000)

      if pages.nil?
        pages = []
      else
        until pages.select{|page| page[:id] == id}.empty?
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

      pages.push(new_page)
      PluginStore.set("discourse_league", "pages", pages)

      render json: new_page, root: false
    end

    def update
      pages = PluginStore.get("discourse_league", "pages")
      league_page = pages.select{|page| page[:id] == id}

      if league_page.empty?
        render_json_error(league_page)
      else
        league_page[0][:active] = params[:league_page][:active] if !params[:league_page][:active].nil?
        league_page[0][:title] = params[:league_page][:title] if !params[:league_page][:title].nil?
        league_page[0][:slug] = params[:league_page][:slug] if !params[:league_page][:slug].nil?
        league_page[0][:raw] = params[:league_page][:raw] if !params[:league_page][:raw].nil?
        league_page[0][:cooked] = params[:league_page][:cooked] if !params[:league_page][:cooked].nil?
        league_page[0][:custom_slug] = params[:league_page][:custom_slug] if !params[:league_page][:custom_slug].nil?

        PluginStore.set("discourse_league", "pages", pages)

        render json: league_page, root: false
      end
    end

    def destroy
      pages = PluginStore.get("discourse_league", "pages")

      page = pages.select{|page| page[:id] == params[:league_page][:id]}

      pages.delete(page[0])

      PluginStore.set("discourse_league", "pages", pages)

      render json: success_json
    end

    def show
      pages = PluginStore.get("discourse_league", "pages")
      render_json_dump(pages)
    end


    private

    def league_page_params
      params.permit(league_page: [:active, :title, :slug, :raw, :cooked, :custom_slug])[:league_page]
    end

  end
end