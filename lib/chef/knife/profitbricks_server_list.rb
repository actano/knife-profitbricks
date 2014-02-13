require 'chef/knife'
require 'chef/json_compat'

require_relative 'profitbricks_base'
class Chef
  class Knife
    class ProfitbricksServerList < Knife
      require_relative 'profitbricks_base'
      deps do
        require 'profitbricks'
        require 'highline'        
        Chef::Knife.load_deps
      end

      include Chef::Knife::ProfitbricksBase

      banner "knife profitbricks server list OPTIONS"

      option :datacenter_name,
        :short => "-d DATACENTER_NAME",
        :long => "--datacenter-name DATACENTER_NAME",
        :description => "The datacenter of which to list the servers",
        :proc => Proc.new { |datacenter| Chef::Config[:knife][:profitbricks_datacenter] = datacenter }

      def run
        configure
        validate!

        server_list = [
            ui.color('ID', :bold),
            ui.color('Name', :bold),
            ui.color('Datacenter', :bold),
            ui.color('CPUs', :bold),
            ui.color('RAM', :bold),
            ui.color('IPs', :bold)

        ]
        puts "#{ui.color("Locating Datacenter", :magenta)}"
        if locate_config_value(:profitbricks_datacenter)
        	datacenters = []
        	datacenters << Profitbricks::DataCenter.find(:name => Chef::Config[:knife][:profitbricks_datacenter])
        else
        	datacenters = Profitbricks::DataCenter.all
        end
        
        datacenters.each do |dc|
        puts ui.color("Servers in Datacenter #{dc.name} : ", :blue)
        if dc.servers
          dc.servers.each do |s|
            server_list << s.id
            server_list << s.name
            server_list << dc.name
            server_list << s.cores.to_s
            server_list << s.ram.to_s
            server_list << (s.respond_to?("ips") ? s.ips : "")
          end
           puts ui.list(server_list, :uneven_columns_across, 6)
        else
          puts "#{ui.color("Sorry! No Servers Found.", :magenta)}"
        end
        end
      end
    end
  end
end
