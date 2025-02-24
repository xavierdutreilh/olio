#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Spec
  module Story
    module Runner
      class ScenarioRunner
        def initialize
          @listeners = []
        end
        
        def run(scenario, world)
          @listeners.each { |l| l.scenario_started(scenario.story.title, scenario.name) }
          run_story_ignoring_scenarios(scenario.story, world)
          
          world.start_collecting_errors

          unless scenario.body
            @listeners.each { |l| l.scenario_pending(scenario.story.title, scenario.name, '') }
            return true
          end
          
          world.instance_eval(&scenario.body)
          if world.errors.empty?
            @listeners.each { |l| l.scenario_succeeded(scenario.story.title, scenario.name) }
          else
            if Spec::Example::ExamplePendingError === (e = world.errors.first)
              @listeners.each { |l| l.scenario_pending(scenario.story.title, scenario.name, e.message) }
            else
              @listeners.each { |l| l.scenario_failed(scenario.story.title, scenario.name, e) }
              return false
            end
          end
          true
        end
        
        def add_listener(listener)
          @listeners << listener
        end
        
        private
        
        def run_story_ignoring_scenarios(story, world)
          class << world
            def Scenario(name, &block)
              # do nothing
            end
          end
          story.run_in(world)
          class << world
            remove_method(:Scenario)
          end
        end
      end
    end
  end
end
