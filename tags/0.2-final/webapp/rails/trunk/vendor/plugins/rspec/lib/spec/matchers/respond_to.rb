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
  module Matchers
    
    class RespondTo #:nodoc:
      def initialize(*names)
        @names = names
        @names_not_responded_to = []
      end
      
      def matches?(given)
        @given = given
        @names.each do |name|
          unless given.respond_to?(name)
            @names_not_responded_to << name
          end
        end
        return @names_not_responded_to.empty?
      end
      
      def failure_message
        "expected #{@given.inspect} to respond to #{@names_not_responded_to.collect {|name| name.inspect }.join(', ')}"
      end
      
      def negative_failure_message
        "expected #{@given.inspect} not to respond to #{@names.collect {|name| name.inspect }.join(', ')}"
      end
      
      def description
        # Ruby 1.9 returns the same thing for array.to_s as array.inspect, so just use array.inspect here
        "respond to #{@names.inspect}"
      end
    end
    
    # :call-seq:
    #   should respond_to(*names)
    #   should_not respond_to(*names)
    #
    # Matches if the target object responds to all of the names
    # provided. Names can be Strings or Symbols.
    #
    # == Examples
    # 
    def respond_to(*names)
      Matchers::RespondTo.new(*names)
    end
  end
end
