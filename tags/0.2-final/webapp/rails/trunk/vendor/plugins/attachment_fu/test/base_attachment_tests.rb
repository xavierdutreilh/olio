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
module BaseAttachmentTests
  def test_should_create_file_from_uploaded_file
    assert_created do
      attachment = upload_file :filename => '/files/foo.txt'
      assert_valid attachment
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert !attachment.size.zero?
      #assert_equal 3, attachment.size
      assert_nil      attachment.width
      assert_nil      attachment.height
    end
  end
  
  def test_should_create_file_from_merb_temp_file
    assert_created do
      attachment = upload_merb_file :filename => '/files/foo.txt'
      assert_valid attachment
      assert !attachment.db_file.new_record? if attachment.respond_to?(:db_file)
      assert  attachment.image?
      assert !attachment.size.zero?
      #assert_equal 3, attachment.size
      assert_nil      attachment.width
      assert_nil      attachment.height
    end
  end
  
  def test_reassign_attribute_data
    assert_created 1 do
      attachment = upload_file :filename => '/files/rails.png'
      assert_valid attachment
      assert attachment.size > 0, "no data was set"
      
      attachment.set_temp_data 'wtf'
      assert attachment.save_attachment?
      attachment.save!
      
      assert_equal 'wtf', attachment_model.find(attachment.id).send(:current_data)
    end
  end
  
  def test_no_reassign_attribute_data_on_nil
    assert_created 1 do
      attachment = upload_file :filename => '/files/rails.png'
      assert_valid attachment
      assert attachment.size > 0, "no data was set"
      
      attachment.set_temp_data nil
      assert !attachment.save_attachment?
    end
  end
  
  def test_should_overwrite_old_contents_when_updating
    attachment   = upload_file :filename => '/files/rails.png'
    assert_not_created do # no new db_file records
      use_temp_file 'files/rails.png' do |file|
        attachment.filename = 'rails2.png'
        attachment.temp_paths.unshift File.join(fixture_path, file)
        attachment.save!
      end
    end
  end
  
  def test_should_save_without_updating_file
    attachment = upload_file :filename => '/files/foo.txt'
    assert_valid attachment
    assert !attachment.save_attachment?
    assert_nothing_raised { attachment.save! }
  end
  
  def test_should_handle_nil_file_upload
    attachment = attachment_model.create :uploaded_data => ''
    assert_raise ActiveRecord::RecordInvalid do
      attachment.save!
    end
  end
end