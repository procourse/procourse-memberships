module DiscourseLeague
  class Engine < ::Rails::Engine
    isolate_namespace DiscourseLeague

    config.after_initialize do
		Discourse::Application.routes.append do
			mount ::DiscourseLeague::Engine, at: "/league"
		end
    end
  end
end