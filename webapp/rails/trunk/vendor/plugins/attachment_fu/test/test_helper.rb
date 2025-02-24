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
$:.unshift(File.dirname(__FILE__) + '/../lib')

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
require 'active_record/fixtures'
require 'action_controller/test_process'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

db_adapter = ENV['DB']

# no db passed, try one of these fine config-free DBs before bombing.
db_adapter ||= 
  begin
    require 'rubygems'
    require 'sqlite'
    'sqlite'
  rescue MissingSourceFile
    begin
      require 'sqlite3'
      'sqlite3'
    rescue MissingSourceFile
    end
  end

if db_adapter.nil?
  raise "No DB Adapter selected.  Pass the DB= option to pick one, or install Sqlite or Sqlite3."
end

ActiveRecord::Base.establish_connection(config[db_adapter])

load(File.dirname(__FILE__) + "/schema.rb")

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase #:nodoc:
  include ActionController::TestProcess
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end

  def setup
    Attachment.saves = 0
    DbFile.transaction { [Attachment, FileAttachment, OrphanAttachment, MinimalAttachment, DbFile].each { |klass| klass.delete_all } }
    attachment_model self.class.attachment_model
  end
  
  def teardown
    FileUtils.rm_rf File.join(File.dirname(__FILE__), 'files')
  end

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  def self.attachment_model(klass = nil)
    @attachment_model = klass if klass 
    @attachment_model
  end

  def self.test_against_class(test_method, klass, subclass = false)
    define_method("#{test_method}_on_#{:sub if subclass}class") do
      klass = Class.new(klass) if subclass
      attachment_model klass
      send test_method, klass
    end
  end

  def self.test_against_subclass(test_method, klass)
    test_against_class test_method, klass, true
  end

  protected
    def upload_file(options = {})
      use_temp_file options[:filename] do |file|
        att = attachment_model.create :uploaded_data => fixture_file_upload(file, options[:content_type] || 'image/png')
        att.reload unless att.new_record?
        return att
      end
    end

    def upload_merb_file(options = {})
      use_temp_file options[:filename] do |file|
        att = attachment_model.create :uploaded_data => {"size" => file.size, "content_type" => options[:content_type] || 'image/png', "filename" => file, 'tempfile' => fixture_file_upload(file, options[:content_type] || 'image/png')}
        att.reload unless att.new_record?
        return att
      end
    end
    
    def use_temp_file(fixture_filename)
      temp_path = File.join('/tmp', File.basename(fixture_filename))
      FileUtils.mkdir_p File.join(fixture_path, 'tmp')
      FileUtils.cp File.join(fixture_path, fixture_filename), File.join(fixture_path, temp_path)
      yield temp_path
    ensure
      FileUtils.rm_rf File.join(fixture_path, 'tmp')
    end

    def assert_created(num = 1)
      assert_difference attachment_model.base_class, :count, num do
        if attachment_model.included_modules.include? DbFile
          assert_difference DbFile, :count, num do
            yield
          end
        else
          yield
        end
      end
    end
    
    def assert_not_created
      assert_created(0) { yield }
    end
    
    def should_reject_by_size_with(klass)
      attachment_model klass
      assert_not_created do
        attachment = upload_file :filename => '/files/rails.png'
        assert attachment.new_record?
        assert attachment.errors.on(:size)
        assert_nil attachment.db_file if attachment.respond_to?(:db_file)
      end
    end
    
    def assert_difference(object, method = nil, difference = 1)
      initial_value = object.send(method)
      yield
      assert_equal initial_value + difference, object.send(method)
    end
    
    def assert_no_difference(object, method, &block)
      assert_difference object, method, 0, &block
    end
    
    def attachment_model(klass = nil)
      @attachment_model = klass if klass 
      @attachment_model
    end
end

require File.join(File.dirname(__FILE__), 'fixtures/attachment')
require File.join(File.dirname(__FILE__), 'base_attachment_tests')