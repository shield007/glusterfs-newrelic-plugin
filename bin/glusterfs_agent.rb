#! /usr/bin/env ruby
#
# The MIT License (MIT)
#
# Copyright (c) 2014 John-Paul Stanford <dev@stanwood.org.uk>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011-2014  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: The MIT License (MIT) <http://opensource.org/licenses/MIT>
#

this_dir = File.dirname(__FILE__)
lib_dir  = File.join(this_dir,  '..', 'lib')
$: << lib_dir

begin
    require 'glusterfs_newrelic_agent'
rescue LoadError
    require 'rubygems'
    require 'glusterfs_newrelic_agent'
end

require "bundler/setup"
require "newrelic_plugin"
require "glusterfs_newrelic_agent/version"
require "glusterfs_newrelic_agent/gluster"

module GlusterFSAgent
 
  # Find the configuration file to use
  def GlusterFSAgent.findConfig()
      
      this_dir = File.dirname(__FILE__)
      config_file = ""
      
      location = File.join(this_dir,  '..','config/glusterfs_agent.yml')
      puts "Looking for config file at #{location}"
      if config_file = "" && File.file?(location)
      config_file = location
      end
    
      location = '/etc/newrelic_plugins/glusterfs_agent.yml'
      puts "Looking for config file at #{location}"
      if config_file = "" && File.file?(location)
      config_file = location
      end
    
      if config_file == ""
          STDERR.puts "Unable to find a valid config file"
          exit(1)
      end
    
      puts "Using config file at location #{config_file}"
      return config_file
  end
    
  NewRelic::Plugin::Config.config_file = GlusterFSAgent::findConfig()  

  class Agent < NewRelic::Plugin::Agent::Base

  
    agent_guid "org.mbed.gluster"
    agent_version VERSION
    agent_human_labels("GlusterFS Agent") { "Gluster #{ENV['HOSTNAME']}" }

    def send_metric(title,value_type,value)
        report_metric title, value_type, value
        # puts "Sent metic '#{title}', '#{value_type}', '#{value}'"
    end

    def poll_cycle
        begin               
            connectedPeers = 0
            peers = GlusterFSAgent::get_gluster_pool_list()
            peers.each { | peer |
              if peer['state']=='Connected'
                connectedPeers = connectedPeers+1
              end
            }
            send_metric "NumberOfPeersConnected/Count", "Value", connectedPeers
            send_metric "NumberOfPeers/Count", "Value", peers.count()
    
            geoVolumes = GlusterFSAgent::get_gluster_volume_geo_status()
            working = 0
            geoVolumes.each { | volume |
                if geoVolumes['status'] == 'Passive' or geoVolumes['status'] == 'Active'
                    working = working+1
                end
            }
            send_metric "NumberOfWorkingGeoReplicationPeers/Count","Value", working
            send_metric "NumberOfGeoReplicationPeers/Count","Value", geoVolumes.count()
    
            volumes = GlusterFSAgent::get_gluster_volume_status()
            offline = 0
            volumes.each { | volume |
                if !volume['online']
                    offline = offline+1
                end
            }
            send_metric "OfflineBricks/Count","Value", offline
            send_metric "OnlineBricks/Count","Value", (volumes.count()-offline)
        rescue => exception
            puts("#{exception.class.name}: "+exception.message)
            exception.backtrace.each do | trace |
              STDERR.puts("  * " + trace)
            end
            exit(2)
        end
      end
  end

  #
  # Register this agent with the component.
  # The ExampleAgent is the name of the module that defines this
  # driver (the module must contain at least three classes - a
  # PollCycle, a Metric and an Agent class, as defined above).
  #
  NewRelic::Plugin::Setup.install_agent :glusterfs, GlusterFSAgent

  #
  # Launch the agent; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run

end
