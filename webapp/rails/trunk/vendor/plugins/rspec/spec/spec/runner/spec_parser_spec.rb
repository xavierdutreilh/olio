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

describe "SpecParser" do
  with_sandboxed_options do    
    attr_reader :parser, :file
    
    before do
      @parser = Spec::Runner::SpecParser.new
      @file = "#{File.dirname(__FILE__)}/spec_parser/spec_parser_fixture.rb"
      load file
    end

    it "should find spec name for 'specify' at same line" do
      parser.spec_name_for(file, 5).should == "c 1"
    end

    it "should find spec name for 'specify' at end of spec line" do
      parser.spec_name_for(file, 6).should == "c 1"
    end

    it "should find context for 'context' above all specs" do
      parser.spec_name_for(file, 4).should == "c"
    end

    it "should find spec name for 'it' at same line" do
      parser.spec_name_for(file, 15).should == "d 3"
    end

    it "should find spec name for 'it' at end of spec line" do
      parser.spec_name_for(file, 16).should == "d 3"
    end

    it "should find context for 'describe' above all specs" do
      parser.spec_name_for(file, 14).should == "d"
    end

    it "should find nearest example name between examples" do
      parser.spec_name_for(file, 7).should == "c 1"
    end

    it "should find nothing outside a context" do
      parser.spec_name_for(file, 2).should be_nil
    end

    it "should find context name for type" do
      parser.spec_name_for(file, 26).should == "SpecParserSubject"
    end

    it "should find context and spec name for type" do
      parser.spec_name_for(file, 28).should == "SpecParserSubject 5"
    end

    it "should find context and description for type" do
      parser.spec_name_for(file, 33).should == "SpecParserSubject described"
    end

    it "should find context and description and example for type" do
      parser.spec_name_for(file, 36).should == "SpecParserSubject described 6"
    end

    it "should find context and description for type with modifications" do
      parser.spec_name_for(file, 40).should == "SpecParserSubject described"
    end

    it "should find context and described and example for type with modifications" do
      parser.spec_name_for(file, 43).should == "SpecParserSubject described 7"
    end

    it "should find example group" do
      parser.spec_name_for(file, 47).should == "described"
    end

    it "should find example" do
      parser.spec_name_for(file, 50).should == "described 8"
    end

    it "should find nested example" do
      parser.spec_name_for(file, 63).should == "e f 11"
    end

    it "should handle paths which contain colons" do
      fixture =
         { "c:/somepath/somefile.rb:999:in 'method'" => "c:/somepath/somefile.rb",
           "./somepath/somefile:999"                 => "./somepath/somefile" }
      fixture.each_pair do |input, expected|
        parser.send(:parse_backtrace, input ).should == [[expected, 999]]
      end
    end

  end
end
