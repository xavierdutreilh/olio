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
require File.dirname(__FILE__) + '/../../../spec_helper.rb'

describe Object, "#should" do
  before(:each) do
    @target = "target"
    @matcher = mock("matcher")
    @matcher.stub!(:matches?).and_return(true)
    @matcher.stub!(:failure_message)
  end
  
  it "should accept and interact with a matcher" do
    @matcher.should_receive(:matches?).with(@target).and_return(true)    
    @target.should @matcher
  end
  
  it "should ask for a failure_message when matches? returns false" do
    @matcher.should_receive(:matches?).with(@target).and_return(false)
    @matcher.should_receive(:failure_message).and_return("the failure message")
    lambda {
      @target.should @matcher
    }.should fail_with("the failure message")
  end
  
  it "should raise error if it receives false directly" do
    lambda {
      @target.should false
    }.should raise_error(Spec::Expectations::InvalidMatcherError)
  end
  
  it "should raise error if it receives false (evaluated)" do
    lambda {
      @target.should eql?("foo")
    }.should raise_error(Spec::Expectations::InvalidMatcherError)
  end
  
  it "should raise error if it receives true" do
    lambda {
      @target.should true
    }.should raise_error(Spec::Expectations::InvalidMatcherError)
  end
  
  it "should raise error if it receives no argument and it is not used as a left side of an operator" do
    pending "Is it even possible to catch this?"
    lambda {
      @target.should
    }.should raise_error(Spec::Expectations::InvalidMatcherError)
  end
end

describe Object, "#should_not" do
  before(:each) do
    @target = "target"
    @matcher = mock("matcher")
  end
  
  it "should accept and interact with a matcher" do
    @matcher.should_receive(:matches?).with(@target).and_return(false)
    @matcher.stub!(:negative_failure_message)
    
    @target.should_not @matcher
  end
  
  it "should ask for a negative_failure_message when matches? returns true" do
    @matcher.should_receive(:matches?).with(@target).and_return(true)
    @matcher.should_receive(:negative_failure_message).and_return("the negative failure message")
    lambda {
      @target.should_not @matcher
    }.should fail_with("the negative failure message")
  end

  it "should raise error if it receives false directly" do
    lambda {
      @target.should_not false
    }.should raise_error(Spec::Expectations::InvalidMatcherError)
  end
  
  it "should raise error if it receives false (evaluated)" do
    lambda {
      @target.should_not eql?("foo")
    }.should raise_error(Spec::Expectations::InvalidMatcherError)
  end
  
  it "should raise error if it receives true" do
    lambda {
      @target.should_not true
    }.should raise_error(Spec::Expectations::InvalidMatcherError)
  end

  it "should raise error if it receives no argument and it is not used as a left side of an operator" do
    pending "Is it even possible to catch this?"
    lambda {
      @target.should_not
    }.should raise_error(Spec::Expectations::InvalidMatcherError)
  end
end
