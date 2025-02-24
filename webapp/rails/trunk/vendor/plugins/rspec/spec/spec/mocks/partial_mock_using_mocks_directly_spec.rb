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
require File.dirname(__FILE__) + '/../../spec_helper.rb'

module Spec
module Mocks
describe "PartialMockUsingMocksDirectly" do
    before(:each) do
      
        klass=Class.new
        klass.class_eval do
          def existing_method
            :original_value
          end
        end
        @obj = klass.new
      
    end
    
    # See http://rubyforge.org/tracker/index.php?func=detail&aid=10263&group_id=797&atid=3149
    # specify "should clear expectations on verify" do
    #     @obj.should_receive(:msg)
    #     @obj.msg
    #     @obj.rspec_verify
    #     lambda do
    #       @obj.msg
    #     end.should raise_error(NoMethodError)
    #   
    # end
    it "should fail when expected message is not received" do
        @obj.should_receive(:msg)
        lambda do
          @obj.rspec_verify
        end.should raise_error(MockExpectationError)
      
    end
    it "should fail when message is received with incorrect args" do
        @obj.should_receive(:msg).with(:correct_arg)
        lambda do
          @obj.msg(:incorrect_arg)
        end.should raise_error(MockExpectationError)
        @obj.msg(:correct_arg)
      
    end
    it "should pass when expected message is received" do
        @obj.should_receive(:msg)
        @obj.msg
        @obj.rspec_verify
      
    end
    it "should pass when message is received with correct args" do
        @obj.should_receive(:msg).with(:correct_arg)
        @obj.msg(:correct_arg)
        @obj.rspec_verify
      
    end
    it "should revert to original method if existed" do
        @obj.existing_method.should equal(:original_value)
        @obj.should_receive(:existing_method).and_return(:mock_value)
        @obj.existing_method.should equal(:mock_value)
        @obj.rspec_verify
        @obj.existing_method.should equal(:original_value)
      
    end
  
end
end
end
