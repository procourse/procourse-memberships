module Jobs
    class MigrateMembershipsPlugin < Jobs::Onceoff
      # Migrate content from discourse_league name to procourse_memberships
      def execute_onceoff(args)
          dl_row_presence = PluginStoreRow.where(plugin_name: "discourse_league").exists?
          if dl_row_presence
              # Migrate the page content rows
              PluginStoreRow.where(plugin_name: 'discourse_league')
              .find_each do |row|
                  PluginStore.set("procourse_memberships", row.key, PluginStore.cast_value("JSON", row.value))
                  row.destroy # clean up discourse_league row
              end
          end
      end
    end
  end
