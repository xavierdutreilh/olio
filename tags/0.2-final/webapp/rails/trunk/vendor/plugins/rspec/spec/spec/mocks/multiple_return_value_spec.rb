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
require File.dirname(__FILE__) + '/../../spec_helper'

module Spec
  module Mocks
    describe "a Mock expectation with multiple return values and no specified count" do
      before(:each) do
        @mock = Mock.new("mock")
        @return_values = ["1",2,Object.new]
        @mock.should_receive(:message).and_return(@return_values[0],@return_values[1],@return_values[2])
      end
      
      it "should return values in order to consecutive calls" do
        @mock.message.should == @return_values[0]
        @mock.message.should == @return_values[1]
        @mock.message.should == @return_values[2]
        @mock.rspec_verify
      end

      it "should complain when there are too few calls" do
        third = Object.new
        @mock.message.should == @return_values[0]
        @mock.message.should == @return_values[1]
        lambda { @mock.rspec_verify }.should raise_error(MockExpectationError, "Mock 'mock' expected :message with (any args) 3 times, but received it twice")
      end

      it "should complain when there are too many calls" do
        third = Object.new
        @mock.message.should == @return_values[0]
        @mock.message.should == @return_values[1]
        @mock.message.should == @return_values[2]
        @mock.message.should == @return_values[2]
        lambda { @mock.rspec_verify }.should raise_error(MockExpectationError, "Mock 'mock' expected :message with (any args) 3 times, but received it 4 times")
      end
    end

    describe "a Mock expectation with multiple return values with a specified count equal to the number of values" do
      before(:each) do
        @mock = Mock.new("mock")
        @return_values = ["1",2,Object.new]
        @mock.should_receive(:message).exactly(3).times.and_return(@return_values[0],@return_values[1],@return_values[2])
      end

      it "should return values in order to consecutive calls" do
        @mock.message.should == @return_values[0]
        @mock.message.should == @return_values[1]
        @mock.message.should == @return_values[2]
        @mock.rspec_verify
      end

      it "should complain when there are too few calls" do
        third = Object.new
        @mock.message.should == @return_values[0]
        @mock.message.should == @return_values[1]
        lambda { @mock.rspec_verify }.should raise_error(MockExpectationError, "Mock 'mock' expected :message with (any args) 3 times, but received it twice")
      end

      it "should complain when there are too many calls" do
        third = Object.new
        @mock.message.should == @return_values[0]
        @mock.message.should == @return_values[1]
        @mock.message.should == @return_values[2]
        @mock.message.should == @return_values[2]
        lambda { @mock.rspec_verify }.should raise_error(MockExpectationError, "Mock 'mock' expected :message with (any args) 3 times, but received it 4 times")
      end
    end

    describe "a Mock expectation with multiple return values specifying at_least less than the number of values" do
      before(:each) do
        @mock = Mock.new("mock")
        @mock.should_receive(:message).at_least(:twice).with(no_args).and_return(11, 22)
      end
      
      it "should use last return value for subsequent calls" do
        @mock.message.should equal(11)
        @mock.message.should equal(22)
        @mock.message.should equal(22)
        @mock.rspec_verify
      end

      it "should fail when called less than the specified number" do
        @mock.message.should equal(11)
        lambda { @mock.rspec_verify }.should raise_error(MockExpectationError, "Mock 'mock' expected :message with (no args) twice, but received it once")
      end
    end
    describe "a Mock expectation with multiple return values with a specified count larger than the number of values" do
      before(:each) do
        @mock = Mock.new("mock")
        @mock.should_receive(:message).exactly(3).times.and_return(11, 22)
      end
      
      it "should use last return value for subsequent calls" do
        @mock.message.should equal(11)
        @mock.message.should equal(22)
        @mock.message.should equal(22)
        @mock.rspec_verify
      end

      it "should fail when called less than the specified number" do
        @mock.message.should equal(11)
        lambda { @mock.rspec_verify }.should raise_error(MockExpectationError, "Mock 'mock' expected :message with (any args) 3 times, but received it once")
      end

      it "should fail when called greater than the specified number" do
        @mock.message.should equal(11)
        @mock.message.should equal(22)
        @mock.message.should equal(22)
        @mock.message.should equal(22)
        lambda { @mock.rspec_verify }.should raise_error(MockExpectationError, "Mock 'mock' expected :message with (any args) 3 times, but received it 4 times")
      end
    end
  end
end

