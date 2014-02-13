require 'chef/knife'
require 'chef/json_compat'

# These two are needed for the '--purge' deletion case
require 'chef/node'
require 'chef/api_client'

require_relative 'profitbricks_base'
class Chef
  class Knife
    class ProfitbricksServerDelete < Knife
      require_relative 'profitbricks_base'
      deps do
        require 'profitbricks'
        require 'highline'        
        Chef::Knife.load_deps
      end

      include Chef::Knife::ProfitbricksBase

      banner "knife profitbricks server delete SERVERNAME OPTIONS"

      option :datacenter_name,
        :short => "-d DATACENTER_NAME",
        :long => "--datacenter-name DATACENTER_NAME",
        :description => "The datacenter of which to list the servers",
        :proc => Proc.new { |datacenter| Chef::Config[:knife][:profitbricks_datacenter] = datacenter }
        
      option :purge,
        :short => "-P",
        :long => "--purge",
        :boolean => true,
        :default => false,
        :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the HP node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node and client to delete, if it differs from the server name. Only has meaning when used with the '--purge' option."


      # Extracted from Chef::Knife.delete_object, because it has a
      # confirmation step built in... By specifying the '--purge'
      # flag (and also explicitly confirming the server destruction!)
      # the user is already making their intent known.  It is not
      # necessary to make them confirm two more times.
      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name}")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end
      
      
      def run
        configure
        validate!
        
        unless Chef::Config[:knife][:profitbricks_datacenter]
          ui.error("A Datacenter must be specified")
          exit 1
        end

        if @name_args.length < 1
          ui.error("You need to provide a name for the server")
          exit 1
        end
        ui.warn("Storages connected to this server will be deleted.")
        puts "#{ui.color("Locating Datacenter", :magenta)}"
        @dc = DataCenter.find(:name => Chef::Config[:knife][:profitbricks_datacenter])
        @dc.wait_for_provisioning

        if @dc.servers
        puts ui.color("Locating Server : ", :blue)
        
        
         @name_args.each do |server_name|

          @dc.servers.each do |ser|
		if ser.name.to_s == "#{server_name}"
		
			ser.connected_storages.each do |storage|
        msg_pair("Storage Size", storage.size)
        confirm("Do you really want to delete this Storage")
			Profitbricks.request :delete_storage, storage_id: "#{storage.id}"
			end

        msg_pair("Name", ser.name)
        msg_pair("Cores", ser.cores)
        msg_pair("RAM", ser.ram)
        msg_pair("IP", ser.ips)
                confirm("Do you really want to delete this Server")
        Profitbricks.request :delete_server, server_id: "#{ser.id}"
        
                    ui.warn("Deleted server #{ser.id}")

            if config[:purge]
              thing_to_delete = config[:chef_node_name] || ser.name
              destroy_item(Chef::Node, thing_to_delete, "node")
              destroy_item(Chef::ApiClient, thing_to_delete, "client")
            else
              ui.warn("Corresponding node and client for the #{ser.name} server were not deleted and remain registered with the Chef Server")
            end
            
            
		end 
          end
         end
        else
          puts ui.error("Oops! No server found! ")
        end
      end
      
    end
  end
end
