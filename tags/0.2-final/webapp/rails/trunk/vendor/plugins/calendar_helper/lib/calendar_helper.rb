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
require 'date'

# CalendarHelper allows you to draw a databound calendar with fine-grained CSS formatting
module CalendarHelper

  VERSION = '0.2.2'

  # Returns an HTML calendar. In its simplest form, this method generates a plain
  # calendar (which can then be customized using CSS) for a given month and year.
  # However, this may be customized in a variety of ways -- changing the default CSS
  # classes, generating the individual day entries yourself, and so on.
  # 
  # The following options are required:
  #  :year  # The  year number to show the calendar for.
  #  :month # The month number to show the calendar for.
  # 
  # The following are optional, available for customizing the default behaviour:
  #   :table_class       => "calendar"        # The class for the <table> tag.
  #   :month_name_class  => "monthName"       # The class for the name of the month, at the top of the table.
  #   :other_month_class => "otherMonth" # Not implemented yet.
  #   :day_name_class    => "dayName"         # The class is for the names of the weekdays, at the top.
  #   :day_class         => "day"             # The class for the individual day number cells.
  #                                             This may or may not be used if you specify a block (see below).
  #   :abbrev            => (0..2)            # This option specifies how the day names should be abbreviated.
  #                                             Use (0..2) for the first three letters, (0..0) for the first, and
  #                                             (0..-1) for the entire name.
  #   :first_day_of_week => 0                 # Renders calendar starting on Sunday. Use 1 for Monday, and so on.
  #   :accessible        => true              # Turns on accessibility mode. This suffixes dates within the
  #                                           # calendar that are outside the range defined in the <caption> with 
  #                                           # <span class="hidden"> MonthName</span>
  #                                           # Defaults to false.
  #                                           # You'll need to define an appropriate style in order to make this disappear. 
  #                                           # Choose your own method of hiding content appropriately.
  #
  #   :show_today        => false             # Highlights today on the calendar using the CSS class 'today'. 
  #                                           # Defaults to true.
  #
  # For more customization, you can pass a code block to this method, that will get one argument, a Date object,
  # and return a values for the individual table cells. The block can return an array, [cell_text, cell_attrs],
  # cell_text being the text that is displayed and cell_attrs a hash containing the attributes for the <td> tag
  # (this can be used to change the <td>'s class for customization with CSS).
  # This block can also return the cell_text only, in which case the <td>'s class defaults to the value given in
  # +:day_class+. If the block returns nil, the default options are used.
  # 
  # Example usage:
  #   calendar(:year => 2005, :month => 6) # This generates the simplest possible calendar.
  #   calendar({:year => 2005, :month => 6, :table_class => "calendar_helper"}) # This generates a calendar, as
  #                                                                             # before, but the <table>'s class
  #                                                                             # is set to "calendar_helper".
  #   calendar(:year => 2005, :month => 6, :abbrev => (0..-1)) # This generates a simple calendar but shows the
  #                                                            # entire day name ("Sunday", "Monday", etc.) instead
  #                                                            # of only the first three letters.
  #   calendar(:year => 2005, :month => 5) do |d| # This generates a simple calendar, but gives special days
  #     if listOfSpecialDays.include?(d)          # (days that are in the array listOfSpecialDays) one CSS class,
  #       [d.mday, {:class => "specialDay"}]      # "specialDay", and gives the rest of the days another CSS class,
  #     else                                      # "normalDay". You can also use this highlight today differently
  #       [d.mday, {:class => "normalDay"}]       # from the rest of the days, etc.
  #     end
  #   end
  #
  # An additional 'weekend' class is applied to weekend days. 
  #
  # For consistency with the themes provided in the calendar_styles generator, use "specialDay" as the CSS class for marked days.
  # 
  def calendar(options = {}, &block)
    raise(ArgumentError, "No year given")  unless options.has_key?(:year)
    raise(ArgumentError, "No month given") unless options.has_key?(:month)

    block                        ||= Proc.new {|d| nil}

    defaults = {
      :table_class => 'calendar',
      :month_name_class => 'monthName',
      :other_month_class => 'otherMonth',
      :day_name_class => 'dayName',
      :day_class => 'day',
      :abbrev => (0..2),
      :first_day_of_week => 0,
      :accessible => false,
      :show_today => true
    }
    options = defaults.merge options

    first = Date.civil(options[:year], options[:month], 1)
    last = Date.civil(options[:year], options[:month], -1)

    first_weekday = first_day_of_week(options[:first_day_of_week])
    last_weekday = last_day_of_week(options[:first_day_of_week])
    
    day_names = Date::DAYNAMES.dup
    first_weekday.times do
      day_names.push(day_names.shift)
    end
    
    ### Added by Arthur Klepchukov
    
    cur_controller = controller.controller_name
    cur_action = controller.action_name
    this_month = options[:month]
    prev_month = (options[:month] == 1) ? 12 : options[:month] - 1 
    next_month = (options[:month] == 12) ? 1 : options[:month] + 1
    prev_year_for_month = (options[:month] == 1) ? options[:year] - 1 : options[:year]
    next_year_for_month = (options[:month] == 12) ? options[:year] + 1 : options[:year]
    prev_year = options[:year] - 1
    next_year = options[:year] + 1
    
    prev_month = link_to_remote '&lt;', 
      {:url => {:controller => 'events', :action => 'update_calendar'}, 
       :method => :get, 
       :with => "'month=#{prev_month}&year=#{prev_year_for_month}'"
      }, 
      :href => url_for(:controller => cur_controller, :action => cur_action, 
        :month => prev_month, :year => prev_year_for_month),
      :class => 'prev_month'
    prev_year = link_to_remote '&lt;', 
      {:url => {:controller => 'events', :action => 'update_calendar'}, 
       :method => :get, 
       :with => "'month=#{this_month}&year=#{prev_year}'"
      },
      :href => url_for(:controller => cur_controller, :action => cur_action, 
        :month => this_month, :year => prev_year),
      :class => 'prev_year'
    
    next_month = link_to_remote '&gt;', 
      {:url => {:controller => 'events', :action => 'update_calendar'}, 
       :method => :get, 
       :with => "'month=#{next_month}&year=#{next_year_for_month}'"
      }, 
      :href => url_for(:controller => cur_controller, :action => cur_action, 
        :month => next_month, :year => next_year_for_month),
      :class => 'next_month'
    next_year = link_to_remote '&gt;', 
      {:url => {:controller => 'events', :action => 'update_calendar'}, 
       :method => :get, 
       :with => "'month=#{this_month}&year=#{next_year}'"
      }, 
      :href => url_for(:controller => cur_controller, :action => cur_action, 
        :month => this_month, :year => next_year),
      :class => 'next_year'
    
    calendar_heading = ""
    calendar_heading << prev_year << " "
    calendar_heading << prev_month << " "
    calendar_heading << Date::MONTHNAMES[options[:month]].slice(0..2) << " #{options[:year]}"
    calendar_heading << " " << next_month
    calendar_heading << " " << next_year
    
    ### End added by Arthur Klepchukov
    
    cal = %(<table class="#{options[:table_class]}" border="0" cellspacing="0" cellpadding="0">) 
    cal << %(<caption class="#{options[:month_name_class]}"></caption>)
    cal << %(<thead><tr><th colspan="7">#{calendar_heading}</th></tr><tr class="#{options[:day_name_class]}">)
    day_names.each do |d|
      unless d[options[:abbrev]].eql? d
        cal << "<th scope='col'><abbr title='#{d}'>#{d[options[:abbrev]]}</abbr></th>"
      else
        cal << "<th scope='col'>#{d[options[:abbrev]]}</th>"
      end
    end
    cal << "</tr></thead><tbody><tr>"
    beginning_of_week(first, first_weekday).upto(first - 1) do |d|
      cal << %(<td class="#{options[:other_month_class]})
      cal << " weekendDay" if weekend?(d)
      if options[:accessible]
        cal << %(">#{d.day}<span class="hidden"> #{Date::MONTHNAMES[d.month]}</span></td>)
      else
        cal << %(">#{d.day}</td>)
      end
    end unless first.wday == first_weekday
    first.upto(last) do |cur|
      cell_text, cell_attrs = block.call(cur)
      cell_text  ||= cur.mday
      cell_attrs ||= {:class => options[:day_class]}
      cell_attrs[:class] += " weekendDay" if [0, 6].include?(cur.wday) 
      cell_attrs[:class] += " today" if (cur == Date.today) and options[:show_today]  
      cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
      cal << "<td #{cell_attrs}>#{cell_text}</td>"
      cal << "</tr><tr>" if cur.wday == last_weekday
    end
    (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
      cal << %(<td class="#{options[:other_month_class]})
      cal << " weekendDay" if weekend?(d)
      if options[:accessible]
        cal << %(">#{d.day}<span class='hidden'> #{Date::MONTHNAMES[d.mon]}</span></td>)
      else
        cal << %(">#{d.day}</td>)        
      end
    end unless last.wday == last_weekday
    cal << "</tr></tbody></table>"
  end
  
  private
  
  def first_day_of_week(day)
    day
  end
  
  def last_day_of_week(day)
    if day > 0
      day - 1
    else
      6
    end
  end
  
  def days_between(first, second)
    if first > second
      second + (7 - first)
    else
      second - first
    end
  end
  
  def beginning_of_week(date, start = 1)
    days_to_beg = days_between(start, date.wday)
    date - days_to_beg
  end
  
  def weekend?(date)
    [0, 6].include?(date.wday)
  end
    
end
