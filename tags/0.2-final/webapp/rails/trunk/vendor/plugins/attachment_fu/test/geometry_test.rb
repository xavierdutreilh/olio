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
require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/geometry')) unless Object.const_defined?(:Geometry)

class GeometryTest < Test::Unit::TestCase
  def test_should_resize
    assert_geometry 50, 64,
      "50x50"   => [39, 50],
      "60x60"   => [47, 60],
      "100x100" => [78, 100]
  end
  
  def test_should_resize_no_width
    assert_geometry 50, 64,
      "x50"  => [39, 50],
      "x60"  => [47, 60],
      "x100" => [78, 100]
  end
  
  def test_should_resize_no_height
    assert_geometry 50, 64,
      "50"  => [50, 64],
      "60"  => [60, 77],
      "100" => [100, 128]
  end
  
  def test_should_resize_no_height_with_x
    assert_geometry 50, 64,
      "50x"  => [50, 64],
      "60x"  => [60, 77],
      "100x" => [100, 128]
  end
  
  def test_should_resize_with_percent
    assert_geometry 50, 64,
      "50x50%"   => [25, 32],
      "60x60%"   => [30, 38],
      "120x112%" => [60, 72]
  end
  
  def test_should_resize_with_percent_and_no_width
    assert_geometry 50, 64,
      "x50%"  => [50, 32],
      "x60%"  => [50, 38],
      "x112%" => [50, 72]
  end
  
  def test_should_resize_with_percent_and_no_height
    assert_geometry 50, 64,
      "50%"  => [25, 32],
      "60%"  => [30, 38],
      "120%" => [60, 77]
  end
  
  def test_should_resize_with_less
    assert_geometry 50, 64,
      "50x50<"   => [50, 64],
      "60x60<"   => [50, 64],
      "100x100<" => [78, 100],
      "100x112<" => [88, 112],
      "40x70<"   => [50, 64]
  end
  
  def test_should_resize_with_less_and_no_width
    assert_geometry 50, 64,
      "x50<"  => [50, 64],
      "x60<"  => [50, 64],
      "x100<" => [78, 100]
  end
  
  def test_should_resize_with_less_and_no_height
    assert_geometry 50, 64,
      "50<"  => [50, 64],
      "60<"  => [60, 77],
      "100<" => [100, 128]
  end

  def test_should_resize_with_greater
    assert_geometry 50, 64,
      "50x50>"   => [39, 50],
      "60x60>"   => [47, 60],
      "100x100>" => [50, 64],
      "100x112>" => [50, 64],
      "40x70>"   => [40, 51]
  end
  
  def test_should_resize_with_greater_and_no_width
    assert_geometry 50, 64,
      "x40>"  => [31, 40],
      "x60>"  => [47, 60],
      "x100>" => [50, 64]
  end
  
  def test_should_resize_with_greater_and_no_height
    assert_geometry 50, 64,
      "40>"  => [40, 51],
      "60>"  => [50, 64],
      "100>" => [50, 64]
  end

  protected
    def assert_geometry(width, height, values)
      values.each do |geo, result|
        # run twice to verify the Geometry string isn't modified after a run
        geo = Geometry.from_s(geo)
        2.times { assert_equal result, [width, height] / geo }
      end
    end
end