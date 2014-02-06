require 'chef/knife'

class Chef
  class Knife
    module ProfitbricksBase
      def configure
        Profitbricks.configure do |config|
          config.username = profitbricks_user
          config.password = profitbricks_password
        end
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          ui.info "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate!
        if (!profitbricks_password || !profitbricks_user)
          ui.error "You did not configure your Profitbricks credentials"
          ui.error "either export PROFITBRICKS_USER and PROFITBRICKS_PASSWORD"
          ui.error "or configure profitbricks_user and profitbricks_password in your chef.rb"
          exit 1
        end
      end

      def profitbricks_user
        locate_config_value(:profitbricks_user) || ENV['PROFITBRICKS_USER']
      end

      def profitbricks_password
        locate_config_value(:profitbricks_password) || ENV['PROFITBRICKS_PASSWORD']
      end

      def wait_for msg, &block
        print msg
        while !block.call
          print '.'
          sleep 1
        end
        print "\n"
      end

      def ssh(command)
        ssh = Chef::Knife::Ssh.new
        ssh.ui = ui
        ssh.name_args = [ @server.ips, command ]
        ssh.config[:ssh_user] = "root"
        ssh.config[:ssh_password] = @password
        ssh.config[:ssh_port] = 22
        #ssh.config[:ssh_gateway] = Chef::Config[:knife][:ssh_gateway] || config[:ssh_gateway]
        ssh.config[:identity_file] = locate_config_value(:identity_file)
        ssh.config[:manual] = true
        ssh.config[:host_key_verify] = false
        ssh.config[:on_error] = :raise
        ssh
      end

      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end

    end
  end
end
