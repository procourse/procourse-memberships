module DiscourseGuild
  class Engine < ::Rails::Engine
    isolate_namespace DiscourseGuild

    config.after_initialize do
		Discourse::Application.routes.append do
			mount ::DiscourseGuild::Engine, at: "/guild"
		end
    end
  end
end