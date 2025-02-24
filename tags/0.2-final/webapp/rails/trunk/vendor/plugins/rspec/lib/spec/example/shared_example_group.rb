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
  module Example
    class SharedExampleGroup < Module
      module ClassMethods
        def register(*args, &block)
          new_example_group = new(*args, &block)
          shared_example_groups << new_example_group unless already_registered?(new_example_group)
          new_example_group
        end
        
        def find(example_group_description)
          shared_example_groups.find {|b| b.description == example_group_description}
        end

        def clear
          shared_example_groups.clear
        end
        
        def include?(group)
          shared_example_groups.include?(group)
        end
        
        def count
          shared_example_groups.length
        end

      private
      
        def shared_example_groups
          @shared_example_groups ||= []
        end
      
        def already_registered?(new_example_group)
          existing_example_group = find(new_example_group.description)
          return false unless existing_example_group
          return true if new_example_group.equal?(existing_example_group)
          return true if spec_path(new_example_group) == spec_path(existing_example_group)
          raise ArgumentError.new("Shared Example '#{existing_example_group.description}' already exists")
        end

        def spec_path(example_group)
          File.expand_path(example_group.spec_path)
        end
      end

      extend ClassMethods
      include ExampleGroupMethods

      def initialize(*args, &example_group_block)
        set_description(*args)
        @example_group_block = example_group_block
      end

      def included(mod) # :nodoc:
        mod.module_eval(&@example_group_block)
      end

      def each_ancestor_example_group_class(superclass_last=false)
        yield self
      end
    end
  end
end
