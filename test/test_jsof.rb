# frozen_string_literal: true

require_relative "./test_helper"

class TestJsof < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Jsof::VERSION
  end

  def test_implicit_write
    x = Jsof()
    x.a = 1
    x.b = 'b'
    x.c = [2]
    x.d = {aa: 3}
    assert_equal 1, x.a
    assert_equal 1, x[:a]
    assert_equal 'b', x.b
    assert_equal 2, x.c[0]
    assert_equal 3, x.d.aa
    assert_equal ({a: 1, b: 'b', c: [2], d: {aa: 3}}), x.to_h
  end

  def test_implicit_read
    x = Jsof({x: 1, y: 2, z: [{a: 'a', b: 'b'}, {a: 'aa', b: 'bb'}]})
    assert_equal 1, x.x
    assert_equal 2, x.y
    assert_equal 'a', x.z[0].a
    assert_equal 'bb', x.z[1].b
    assert_nil x.z[1].unknown
  end

  class Exp1 < Jsof::WrapObject
    define_attr :aaa
  end
  class ExpA < Jsof::WrapObject
    define_attr :a, type: Integer
    define_attr :b
    define_attr :c, type: Array
    define_attr :d, type: Jsof::WrapArrayType.new(typeof_element: Integer)
    define_attr :e, type: Exp1
    define_attr :f, type: ->{ Exp2 }
  end
  class Exp2 < Jsof::WrapObject
    define_attr :bbb
  end
  def test_explicit
    x = ExpA.new
    x.a = 2
    assert_raises(TypeError) { x.a = 'bad' }
    assert_raises(NoMethodError) { x.unknown = 'bad' }
    x.b = 1
    x.b = 'b'
    x.c = [1]
    x.c[1] = 'a'
    assert_raises(TypeError) { x.c = 0 }
    x.d = [2]
    assert_raises(TypeError) { x.d = 0 }
    x.d[1] = 0
    assert_raises(TypeError) { x.d[1] = 'bad' }
    x.e = {}
    x.e.aaa = 123
    assert_raises(NoMethodError) { x.e.unknown = 1 }
    assert_raises(TypeError) { x.e = 1 }
    x.f = {}
    assert_raises(TypeError) { x.f = 1 }
  end
end
