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
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Spec
  module Example
    describe ExampleGroupFactory do
      describe "#get" do
        attr_reader :example_group
        before(:each) do
          @example_group_class = Class.new(ExampleGroup)
          ExampleGroupFactory.register(:registered_type, @example_group_class)
        end

        after(:each) do
          ExampleGroupFactory.reset
        end

        it "should return the default ExampleGroup type for nil" do
          ExampleGroupFactory.get(nil).should == ExampleGroup
        end

        it "should return the default ExampleGroup for an unregistered non-nil value" do
          ExampleGroupFactory.get(:does_not_exist).should == ExampleGroup
        end

        it "should return custom type if registered" do
          ExampleGroupFactory.get(:registered_type).should == @example_group_class
        end

        it "should return the actual type when that is what is submitted" do
          ExampleGroupFactory.get(@example_group_class).should == @example_group_class
        end

        it "should get the custom type after setting the default" do
          @alternate_example_group_class = Class.new(ExampleGroup)
          ExampleGroupFactory.default(@alternate_example_group_class)
          ExampleGroupFactory.get(:registered_type).should == @example_group_class
        end
      end

      describe "#create_example_group" do
        attr_reader :parent_example_group
        before do
          @parent_example_group = Class.new(ExampleGroup) do
            def initialize(*args, &block)
              ;
            end
          end
        end

        it "should create a uniquely named class" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group("example_group") {}
          example_group.name.should =~ /Spec::Example::ExampleGroup::Subclass_\d+/
        end

        it "should create a Spec::Example::Example subclass by default" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group("example_group") {}
          example_group.superclass.should == Spec::Example::ExampleGroup
        end

        it "should raise when no description is given" do
          lambda {
            Spec::Example::ExampleGroupFactory.create_example_group do; end
          }.should raise_error(ArgumentError)
        end
        
        it "should raise when no block is given" do
          lambda { Spec::Example::ExampleGroupFactory.create_example_group "foo" }.should raise_error(ArgumentError)
        end

        it "should run registered ExampleGroups" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group "The ExampleGroup" do end
          Spec::Runner.options.example_groups.should include(example_group)
        end

        it "should not run unregistered ExampleGroups" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group "The ExampleGroup" do unregister; end
          Spec::Runner.options.example_groups.should_not include(example_group)
        end

        describe "with :type => :default" do
          it "should create a Spec::Example::ExampleGroup" do
            example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "example_group", :type => :default
            ) {}
            example_group.superclass.should == Spec::Example::ExampleGroup
          end
        end

        describe "with :type => :something_other_than_default" do
          it "should create the specified type" do
            Spec::Example::ExampleGroupFactory.register(:something_other_than_default, parent_example_group)
            non_default_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
              "example_group", :type => :something_other_than_default
            ) {}
            non_default_example_group.superclass.should == parent_example_group
          end
        end

        it "should create a type indicated by :spec_path" do
          Spec::Example::ExampleGroupFactory.register(:something_other_than_default, parent_example_group)
          custom_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "example_group", :spec_path => "./spec/something_other_than_default/some_spec.rb"
          ) {}
          custom_example_group.superclass.should == parent_example_group
        end

        it "should create a type indicated by :spec_path (with spec_path generated by caller on windows)" do
          Spec::Example::ExampleGroupFactory.register(:something_other_than_default, parent_example_group)
          custom_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "example_group",
            :spec_path => "./spec\\something_other_than_default\\some_spec.rb"
          ) {}
          custom_example_group.superclass.should == parent_example_group
        end

        describe "with :shared => true" do
          def shared_example_group
            @shared_example_group ||= Spec::Example::ExampleGroupFactory.create_example_group(
              "name", :spec_path => '/blah/spec/models/blah.rb', :type => :controller, :shared => true
            ) {}
          end

          it "should create and register a Spec::Example::SharedExampleGroup" do
            shared_example_group.should be_an_instance_of(Spec::Example::SharedExampleGroup)
            SharedExampleGroup.should include(shared_example_group)
          end
        end

        it "should favor the :type over the :spec_path" do
          Spec::Example::ExampleGroupFactory.register(:something_other_than_default, parent_example_group)
          custom_example_group = Spec::Example::ExampleGroupFactory.create_example_group(
            "name", :spec_path => '/blah/spec/models/blah.rb', :type => :something_other_than_default
          ) {}
          custom_example_group.superclass.should == parent_example_group
        end

        it "should register ExampleGroup by default" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group("The ExampleGroup") do
          end
          Spec::Runner.options.example_groups.should include(example_group)
        end

        it "should enable unregistering of ExampleGroups" do
          example_group = Spec::Example::ExampleGroupFactory.create_example_group("The ExampleGroup") do
            unregister
          end
          Spec::Runner.options.example_groups.should_not include(example_group)
        end
        
        
        after(:each) do
          Spec::Example::ExampleGroupFactory.reset
        end
      end
      
      describe "#registered_or_ancestor_of_registered?" do
        before(:each) do
          @unregistered_parent = Class.new(ExampleGroup)
          @registered_child = Class.new(@unregistered_parent)
          @unregistered_grandchild = Class.new(@registered_child)
          Spec::Example::ExampleGroupFactory.register :registered_child, @registered_child
        end
        
        it "should return true for empty list" do
          Spec::Example::ExampleGroupFactory.registered_or_ancestor_of_registered?([]).should be_true
        end
        
        it "should return true for a registered example group class" do
          Spec::Example::ExampleGroupFactory.registered_or_ancestor_of_registered?([@registered_child]).should be_true
        end

        it "should return true for an ancestor of a registered example_group_classes" do
          Spec::Example::ExampleGroupFactory.registered_or_ancestor_of_registered?([@unregistered_parent]).should be_true
        end

        it "should return false for a subclass of a registered example_group_class" do
          Spec::Example::ExampleGroupFactory.registered_or_ancestor_of_registered?([@unregistered_grandchild]).should be_false
        end

        after(:each) do
          Spec::Example::ExampleGroupFactory.reset
        end
      end
    end
  end
end
