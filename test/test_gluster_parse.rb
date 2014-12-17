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

require 'simplecov'

SimpleCov.start

require 'test/unit'
require "glusterfs_newrelic_agent/gluster"

class GlusterParseTest < Test::Unit::TestCase
    def this_method()
        caller[0][/`([^']*)'/, 1]
    end

    def test_Version()
        puts("\n-- Test Start: #{this_method()}")

        output = ""
        output = output+"glusterfs 3.6.0beta3 built on Oct 16 2014 02:01:53\n"
        output = output+"Repository revision: git://git.gluster.com/glusterfs.git\n"
        output = output+"Copyright (c) 2006-2013 Red Hat, Inc. <http://www.redhat.com/>\n"
        output = output+"GlusterFS comes with ABSOLUTELY NO WARRANTY.\n"
        output = output+"It is licensed to you under your choice of the GNU Lesser\n"
        output = output+"General Public License, version 3 or any later version (LGPLv3\n"
        output = output+"or later), or the GNU General Public License, version 2 (GPLv2),\n"
        output = output+"in all cases as published by the Free Software Foundation.\n"

        version = GlusterFSAgent::parse_version(output)
        assert_equal('3.6.0beta3',version)

        puts("--Test Finish:#{this_method()}")
    end
        
    def test_VolumeStatus()
        puts("\n-- Test Start: #{this_method()}")
        
        output = ""
        output = output+"Gluster process                                         Port    Online  Pid\n"
        output = output+"------------------------------------------------------------------------------\n"
        output = output+"Brick ahost:/export/sdc1/data                           49152   Y       1932\n"
        output = output+"NFS Server on localhost                                 2049    Y       1945\n"
        output = output+"\n"         
        output = output+"Task Status of Volume filer\n"
        output = output+"------------------------------------------------------------------------------\n"
        output = output+"There are no active volume tasks\n"

        result = GlusterFSAgent::parse_volume_status(output)
        assert_equal(1,result.count)
        assert_equal('ahost:/export/sdc1/data',result[0]['brick'])
        assert_equal(49152,result[0]['port'])
        assert_equal(1932,result[0]['pid'])
        assert(result[0]['online'])
        
        puts("--Test Finish:#{this_method()}")
    end
    
    def test_VolumeGeoStatus()
        puts("\n-- Test Start: #{this_method()}")
         
        output = "\n"
        output = output+"MASTER NODE      MASTER VOL    MASTER BRICK         SLAVE                      STATUS     CHECKPOINT STATUS    CRAWL STATUS\n"           
        output = output+"-------------------------------------------------------------------------------------------------------------------------------\n"
        output = output+"testnode1        filer         /export/sdd1/data    remotenode::filer          Passive    N/A                  N/A                    \n"
        output = output+"testnode2        filer         /export/sdd1/data    remotenode::filer          Active     N/A                  Changelog Crawl\n"
        
        result = GlusterFSAgent::parse_volume_geo_status(output)        
        assert_equal(2,result.count)
        
        assert_equal('testnode1',result[0]['masterNode'])
        assert_equal('filer',result[0]['masterVol'])
        assert_equal('/export/sdd1/data',result[0]['masterBrick'])
        assert_equal('remotenode::filer',result[0]['slave'])
        assert_equal('Passive',result[0]['status'])
        assert_equal('N/A',result[0]['checkpointStatus'])
        assert_equal('N/A',result[0]['crawlStatus'])
        
        assert_equal('testnode2',result[1]['masterNode'])
        assert_equal('filer',result[1]['masterVol'])
        assert_equal('/export/sdd1/data',result[1]['masterBrick'])
        assert_equal('remotenode::filer',result[1]['slave'])
        assert_equal('Active',result[1]['status'])
        assert_equal('N/A',result[1]['checkpointStatus'])
        assert_equal('Changelog Crawl',result[1]['crawlStatus'])
            
        puts("--Test Finish:#{this_method()}")
    end
    
    def test_VolumeGeoStatusNoVolumes()
        puts("\n-- Test Start: #{this_method()}")
                 
        output = "No active geo-replication sessions\n"        
        
        result = GlusterFSAgent::parse_volume_geo_status(output)        
        assert_equal(0,result.count)
        
        puts("--Test Finish:#{this_method()}")
    end
        
    
    def test_PoolList()
        puts("\n-- Test Start: #{this_method()}")
        
        output = ""
        output = output+"UUID                                    Hostname        State\n"
        output = output+"11111111-2222-2222-2222-222222222222    10.1.1.1        Connected\n" 
        output = output+"33333333-2222-2222-2222-444444444444    localhost       Connected\n"
        
        result = GlusterFSAgent::parse_pool_list(output)        
        assert_equal(2,result.count)
        
        assert_equal('11111111-2222-2222-2222-222222222222',result[0]['UUID'])
        assert_equal('10.1.1.1',result[0]['hostname'])
        assert_equal('Connected',result[0]['state'])
                
        assert_equal('33333333-2222-2222-2222-444444444444',result[1]['UUID'])
        assert_equal('localhost',result[1]['hostname'])
        assert_equal('Connected',result[1]['state'])
        
        puts("--Test Finish:#{this_method()}")
    end
end
