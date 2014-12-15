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
end