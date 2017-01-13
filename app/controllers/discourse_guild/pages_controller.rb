module DiscourseGuild
  class PagesController < ApplicationController

    def show
      if params[:id]
        @page = Page.find(params[:id])
      end

      if @page.valid? && @page.active?
        render_json_dump(@page)
      else
        render nothing: true, status: 404
      end

    end

    def all
      pages = Page.all
      render_json_dump(pages)
    end

  end
end