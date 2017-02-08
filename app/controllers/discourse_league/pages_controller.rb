module DiscourseLeague
  class PagesController < ApplicationController

    def show
      if params[:id]
        pages = PluginStore.get("discourse_league", "pages")
        page = pages[params[:id].to_i]
      end

      if page && page[:active]
        render_json_dump(page)
      else
        render nothing: true, status: 404
      end

    end

  end
end