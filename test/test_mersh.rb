require 'test/unit'
require 'mersh'

class MershTest < Test::Unit::TestCase
  def setup
    @current_dir = File.dirname(__FILE__)
    @ascii_stl = @current_dir + "/box_ascii.stl"
    @binary_stl = @current_dir + "/box_binary.stl"
    @threejs_json = @current_dir + "/box_threejs.json"
    @plain_json = @current_dir + "/box_plain.json"
    @capitalized_ascii_stl = @current_dir + "/capitalized_ascii.stl"
  end
  
  def test_ascii_stl
    box = Mersh.new(@ascii_stl)
    box_plain_json = box.to_json
    box_threejs_json = box.to_json('threejs')
    
    assert_equal String, box_threejs_json.class
    assert_equal JSON.parse(File.open(@threejs_json).read), JSON.parse(box_threejs_json)

    assert_equal String, box_plain_json.class
    assert_equal JSON.parse(File.open(@plain_json).read), JSON.parse(box_plain_json)
  end

  def test_binary_stl
    box = Mersh.new(@binary_stl)
    box_plain_json = box.to_json
    box_threejs_json = box.to_json('threejs')
  
    assert_equal String, box_threejs_json.class
    assert_equal JSON.parse(File.open(@threejs_json).read), JSON.parse(box_threejs_json)

    assert_equal String, box_plain_json.class
    assert_equal JSON.parse(File.open(@plain_json).read), JSON.parse(box_plain_json)
  end

  def test_min_max
    box = Mersh.new(@binary_stl)

    assert_equal [-10, -10, 0], box.min
    assert_equal [10, 10, 10], box.max
  end
  
  def test_properties
    box = Mersh.new(@binary_stl)
    
    assert_equal 8, box.vertices.size
    assert_equal 12, box.faces.size
    assert_equal 12, box.normals.size
  end
  
  def test_capitalized_ascii_stl
    stl = Mersh.new(@capitalized_ascii_stl)
    
    assert stl.vertices.size > 0
  end
end