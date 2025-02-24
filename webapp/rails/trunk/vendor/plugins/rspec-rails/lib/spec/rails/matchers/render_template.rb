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
  module Rails
    module Matchers
    
      class RenderTemplate #:nodoc:
    
        def initialize(expected, controller)
          @controller = controller
          @expected = expected
        end
      
        def matches?(response)
          
          if response.respond_to?(:rendered_file)
            @actual = response.rendered_file
          else
            @actual = response.rendered_template.to_s
          end
          return false if @actual.blank?
          given_controller_path, given_file = path_and_file(@actual)
          expected_controller_path, expected_file = path_and_file(@expected)
          given_controller_path == expected_controller_path && given_file.match(expected_file)
        end
        
        def failure_message
          "expected #{@expected.inspect}, got #{@actual.inspect}"
        end
        
        def negative_failure_message
          "expected not to render #{@expected.inspect}, but did"
        end
        
        def description
          "render template #{@expected.inspect}"
        end
      
        private
          def path_and_file(path)
            parts = path.split('/')
            file = parts.pop
            controller = parts.empty? ? current_controller_path : parts.join('/')
            return controller, file
          end
        
          def controller_path_from(path)
            parts = path.split('/')
            parts.pop
            parts.join('/')
          end

          def current_controller_path
            @controller.class.to_s.underscore.gsub(/_controller$/,'')
          end
        
      end
      
      # :call-seq:
      #   response.should render_template(template)
      #   response.should_not render_template(template)
      #
      # For use in controller code examples (integration or isolation mode).
      #
      # Passes if the specified template (view file) is rendered by the
      # response. This file can be any view file, including a partial. However
      # if it is a partial it must be rendered directly i.e. you can't detect
      # that a partial has been rendered as part of a view using
      # render_template. For that you should use a message expectation
      # (mock) instead:
      #
      #   controller.should_receive(:render).with(:partial => 'path/to/partial')
      #
      # <code>template</code> can include the controller path. It can also
      # include an optional extension, which you only need to use when there
      # is ambiguity.
      #
      # Note that partials must be spelled with the preceding underscore.
      #
      # == Examples
      #
      #   response.should render_template('list')
      #   response.should render_template('same_controller/list')
      #   response.should render_template('other_controller/list')
      #
      #   # with extensions
      #   response.should render_template('list.rjs')
      #   response.should render_template('list.haml')
      #   response.should render_template('same_controller/list.rjs')
      #   response.should render_template('other_controller/list.rjs')
      #
      #   # partials
      #   response.should render_template('_a_partial')
      #   response.should render_template('same_controller/_a_partial')
      #   response.should render_template('other_controller/_a_partial')
      def render_template(path)
        RenderTemplate.new(path.to_s, @controller)
      end

    end
  end
end
