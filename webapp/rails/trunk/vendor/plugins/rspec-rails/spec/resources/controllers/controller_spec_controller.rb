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
class ControllerSpecController < ActionController::Base
  before_filter :raise_error, :only => :action_with_skipped_before_filter
  
  def raise_error
    raise "from a before filter"
  end
  
  skip_before_filter :raise_error
  
  if ['edge','2.0.0'].include?(ENV['RSPEC_RAILS_VERSION'])
    set_view_path [File.join(File.dirname(__FILE__), "..", "views")]
  else
    set_view_path File.join(File.dirname(__FILE__), "..", "views")
  end
  
  def some_action
    render :template => "template/that/does/not/actually/exist"
  end
  
  def action_with_template
    render :template => "controller_spec/action_with_template"
  end
  
  def action_which_sets_flash
    flash[:flash_key] = "flash value"
    render :text => ""
  end
  
  def action_which_gets_session
    raise "expected #{params[:session_key].inspect}\ngot #{session[:session_key].inspect}" unless (session[:session_key] == params[:expected])
    render :text => ""
  end
  
  def action_which_sets_session
    session[:session_key] = "session value"
  end
      
  def action_which_gets_cookie
    raise "expected #{params[:expected].inspect}, got #{cookies[:cookie_key].inspect}" unless (cookies[:cookie_key] == params[:expected])
    render :text => ""
  end
      
  def action_which_sets_cookie
    cookies['cookie_key'] = params[:value]
    render :text => ""
  end
      
  def action_with_partial
    render :partial => "controller_spec/partial"
  end
  
  def action_with_partial_with_object
    render :partial => "controller_spec/partial", :object => params[:thing]
  end
  
  def action_with_partial_with_locals
    render :partial => "controller_spec/partial", :locals => {:thing => params[:thing]}
  end
  
  def action_with_errors_in_template
    render :template => "controller_spec/action_with_errors_in_template"
  end

  def action_setting_the_assigns_hash
    @indirect_assigns_key = :indirect_assigns_key_value
  end
  
  def action_setting_flash_after_session_reset
    reset_session
    flash[:after_reset] = "available"
  end
  
  def action_setting_flash_before_session_reset
    flash[:before_reset] = 'available'
    reset_session
  end
  
  def action_with_render_update
    render :update do |page|
      page.replace :bottom, 'replace_me',
                            :partial => 'non_existent_partial'
    end
  end
  
  def action_with_skipped_before_filter
    render :text => ""
  end
  
  def action_that_assigns_false_to_a_variable
    @a_variable = false
    render :text => ""
  end
end

class ControllerInheritingFromApplicationControllerController < ApplicationController
  def action_with_inherited_before_filter
    render :text => ""
  end
end