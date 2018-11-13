require 'rails_helper'

describe Jobs::MigrateMembershipsPlugin do
    before do 
        PluginStoreRow.create!(
            plugin_name: 'discourse_league',
            key: 'test',
            type_name: 'JSON',
            value: "[{\"name\":\"test data\"}]"
        )

        PluginStoreRow.create!(
            plugin_name: 'procourse_memberships',
            key: 'dont_touch_me_bro',
            type_name: 'JSON',
            value: "[{\"name\":\"test data\"}]"
        )
    end

    it 'should migrate old plugin rows correctly' do
        Jobs::MigrateMembershipsPlugin.new.execute_onceoff({})

        dl_row = PluginStoreRow.where(plugin_name: 'discourse_league')
        pc_row = PluginStoreRow.where(plugin_name: 'procourse_memberships', key: "test")
        untouched_row = PluginStoreRow.where(plugin_name: 'procourse_memberships', key: 'dont_touch_me_bro')

        expect(dl_row).to be_blank
        expect(pc_row).to exist
        
        expect(pc_row[0]["plugin_name"]).to eq('procourse_memberships')
        expect(pc_row[0]["key"]).to eq('test')
        expect(pc_row[0]["type_name"]).to eq('JSON')
        expect(pc_row[0]["value"]).to eq("[{\"name\":\"test data\"}]")

        expect(untouched_row[0]["plugin_name"]).to eq('procourse_memberships')
        expect(untouched_row[0]["key"]).to eq('dont_touch_me_bro')
        expect(untouched_row[0]["type_name"]).to eq('JSON')
        expect(untouched_row[0]["value"]).to eq("[{\"name\":\"test data\"}]")
    end
end