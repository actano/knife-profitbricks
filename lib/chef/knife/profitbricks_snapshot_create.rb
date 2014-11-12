require 'chef/knife'
require 'chef/json_compat'

require_relative 'profitbricks_base'
module ProfitbricksKnifePlugin
    class ProfitbricksSnapshotCreate < Chef::Knife
      require_relative 'profitbricks_base'
      deps do
        require 'profitbricks'
        require 'highline'
        Chef::Knife.load_deps
      end

      include ProfitbricksBase

      banner "knife profitbricks snapshot create OPTIONS"

      option :storage_id,
        :long => "--server-id server_id",
        :description => "The server of which the snapshot will be taken",
        :proc => Proc.new { |id| Chef::Config[:knife][:profitbricks_server_id] = id }

      option :name,
        :long => "--name SNAPSHOT_NAME",
        :description => "name for the newly created snapshot",
        :proc => Proc.new { |name| Chef::Config[:knife][:profitbricks_snapshot_name] = name }

      option :description,
        :long => "--description description",
        :description => "description for the snapshot",
        :proc => Proc.new { |desc| Chef::Config[:knife][:profitbricks_snapshot_description] = desc }

      def run
        configure

        unless Chef::Config[:knife][:profitbricks_server_id]
          ui.error("A server id must be specified")
          exit 1
        end

        unless Chef::Config[:knife][:profitbricks_snapshot_name]
          ui.error("You need to provide a name for the snapshot")
          exit 1
        end

        puts "#{ui.color("Locating Image", :magenta)}"
        server = Server.find(:id => locate_config_value(:profitbricks_server_id))

        if server.connected_storages == nil || server.connected_storages.length > 1
          ui.error("This currently only works with servers with just one storage.")
          exit 1
        end

        storage_id = server.connected_storages[0].id

        puts "#{ui.color("Creating snapshot", :magenta)}"
        Snapshot.create(:storage_id => storage_id, :name => locate_config_value(:profitbricks_snapshot_name), :description => locate_config_value(:profitbricks_snapshot_description))
        puts "#{ui.color("Snapshot creation started, it might take a few minutes to come available", :green)}"
      end
    end
end
