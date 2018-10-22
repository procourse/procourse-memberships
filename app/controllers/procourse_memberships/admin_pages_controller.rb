module ProcourseMemberships
  class AdminPagesController < Admin::AdminController
    requires_plugin 'procourse-memberships'

    def create
      pages = PluginStore.get("procourse_memberships", "pages")
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
        active: params[:memberships_page][:active], 
        title: params[:memberships_page][:title], 
        slug: params[:memberships_page][:slug], 
        raw: params[:memberships_page][:raw], 
        cooked: params[:memberships_page][:cooked], 
        custom_slug: params[:memberships_page][:custom_slug]
      }

      pages.push(new_page)
      PluginStore.set("procourse_memberships", "pages", pages)

      render json: new_page, root: false
    end

    def update
      pages = PluginStore.get("procourse_memberships", "pages")
      memberships_page = pages.select{|page| page[:id] == id}

      if memberships_page.empty?
        render_json_error(memberships_page)
      else
        memberships_page[0][:active] = params[:memberships_page][:active] if !params[:memberships_page][:active].nil?
        memberships_page[0][:title] = params[:memberships_page][:title] if !params[:memberships_page][:title].nil?
        memberships_page[0][:slug] = params[:memberships_page][:slug] if !params[:memberships_page][:slug].nil?
        memberships_page[0][:raw] = params[:memberships_page][:raw] if !params[:memberships_page][:raw].nil?
        memberships_page[0][:cooked] = params[:memberships_page][:cooked] if !params[:memberships_page][:cooked].nil?
        memberships_page[0][:custom_slug] = params[:memberships_page][:custom_slug] if !params[:memberships_page][:custom_slug].nil?

        PluginStore.set("procourse_memberships", "pages", pages)

        render json: memberships_page, root: false
      end
    end

    def destroy
      pages = PluginStore.get("procourse_memberships", "pages")

      page = pages.select{|page| page[:id] == params[:memberships_page][:id]}

      pages.delete(page[0])

      PluginStore.set("procourse_memberships", "pages", pages)

      render json: success_json
    end

    def show
      pages = PluginStore.get("procourse_memberships", "pages")
      render_json_dump(pages)
    end


    private

    def memberships_page_params
      params.permit(memberships_page: [:active, :title, :slug, :raw, :cooked, :custom_slug])[:memberships_page]
    end

  end
end