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
  module Matchers
    describe "be_close" do
      it "should match when value == target" do
        be_close(5.0, 0.5).matches?(5.0).should be_true
      end
      it "should match when value < (target + delta)" do
        be_close(5.0, 0.5).matches?(5.49).should be_true
      end
      it "should match when value > (target - delta)" do
        be_close(5.0, 0.5).matches?(4.51).should be_true
      end
      it "should not match when value == (target - delta)" do
        be_close(5.0, 0.5).matches?(4.5).should be_false
      end
      it "should not match when value < (target - delta)" do
        be_close(5.0, 0.5).matches?(4.49).should be_false
      end
      it "should not match when value == (target + delta)" do
        be_close(5.0, 0.5).matches?(5.5).should be_false
      end
      it "should not match when value > (target + delta)" do
        be_close(5.0, 0.5).matches?(5.51).should be_false
      end
      it "should provide a useful failure message" do
        #given
          matcher = be_close(5.0, 0.5)
        #when
          matcher.matches?(5.51)
        #then
          matcher.failure_message.should == "expected 5.0 +/- (< 0.5), got 5.51"
      end
      it "should describe itself" do
        matcher = be_close(5.0, 0.5)
        matcher.matches?(5.1)
        matcher.description.should == "be close to 5.0 (within +- 0.5)"
      end
    end
  end
end
