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

module GlusterFSAgent
    def GlusterFSAgent.get_gluster_version
        output = `glusterfsd --version`
        result=$?.success?
        if result
            result = parse_version(output)
            if result
                return result
            else
                raise "Unable to get gluster version: #{output}"
            end
        else
            raise "Unable to get gluster version: #{output}"
        end
    end
    
    def GlusterFSAgent.get_volume_status
            output = `gluster volume status`
            result=$?.success?
            if result
                result = parse_version(output)
                if result
                    return result
                else
                    raise "Unable to get gluster version: #{output}"
                end
            else
                raise "Unable to get gluster version: #{output}"
            end
        end

    def GlusterFSAgent.parse_version(output)
        output = output.lines()        
        if (output[0] =~ /^(.+?) (.+?) .*$/)
            version=$2
            return version
        end
        return nil
    end

    def GlusterFSAgent.parse_volume_status(output)
        result = []
        output.lines().each { | line |           
            if (line =~ /^Brick +(.+?) +(\d+) +(.) +(\d+).*$/)
                online = false
                if $3=='Y'
                    online = true
                end                
                result << { 'brick'=>$1, 'port'=>$2.to_i, 'online'=>online, 'pid'=>$4.to_i}
            end
        }

        return result
    end

end