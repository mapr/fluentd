#
# Fluent
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

module Fluent
  module PluginId
    @@configured_ids = {}

    def configure(conf)
      @id = conf['@id'] || conf['id']
      @_id_configured = !!@id # plugin id is explicitly configured by users (or not)
      if @@configured_ids[@id] && !plugin_id_for_test?
        raise Fluent::ConfigError, "Duplicated plugin id `#{@id}`. Check whole configuration and fix it."
      end
      @@configured_ids[@id] = self

      super
    end

    def plugin_id_for_test?
      caller_locations.each do |location|
        # test-unit has a bug to break Thread::Backtrace::Location#path
        # https://github.com/test-unit/test-unit/issues/118
        if location.absolute_path =~ /\/test_[^\/]+\.rb$/ # location.path =~ /test_.+\.rb$/
          return true
        end
      end
      false
    end

    def plugin_id_configured?
      @_id_configured
    end

    def plugin_id
      @id ? @id : "object:#{object_id.to_s(16)}"
    end
  end
end
