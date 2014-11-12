require 'chef/knife'
require 'chef/json_compat'

require_relative 'profitbricks_base'

module ProfitbricksKnifePlugin
    class ProfitbricksSnapshotList < Chef::Knife
      require_relative 'profitbricks_base'
      deps do
        require 'profitbricks'
        require 'highline'
        Chef::Knife.load_deps
      end

      include ProfitbricksBase

      banner "knife profitbricks snapshot list OPTIONS"

      def run
        configure
        snapshots = Profitbricks::Snapshot.all

        snapshot_list = [
            ui.color('ID', :bold),
            ui.color('Name', :bold),
            ui.color('Memory hotplug', :bold),
            ui.color('CPU hotplug', :bold),
            ui.color('Size', :bold),
            ui.color('Region', :bold),
        ]

        snapshots.each do |i|
          snapshot_list << i.id
          snapshot_list << i.name
          snapshot_list << i.ram_hot_plug.to_s
          snapshot_list << i.cpu_hot_plug.to_s
          snapshot_list << i.size.to_s
          snapshot_list << i.region.to_s
        end

        puts ui.list(snapshot_list, :uneven_columns_across, 6)
      end
    end
end
