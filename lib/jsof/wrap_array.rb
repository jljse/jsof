
# Wrapper class for Array.
class Jsof::WrapArray
  # Create wrapper for Array
  # @param [Array] obj  Wrap target array
  # @param [Class, Jsof::WrapArrayType] typeof_element  Type of each element
  def initialize(obj = [], typeof_element: nil)
    @internal_object = obj
    @wrapped = []
    @typeof_element = typeof_element
  end

  # Return reference to wrapped array.
  def internal_object
    @internal_object
  end

  def typeof_element
    @typeof_element
  end

  def [](index)
    raise ArgumentError unless index.is_a? Integer

    return @wrapped[index] if @wrapped[index]

    elem = @internal_object[index]
    boxed = Jsof::WrapHelper.boxing(elem, typeof_element)
    @wrapped[index] = boxed if elem != boxed
    return boxed
  end

  def []=(index, val)
    raise ArgumentError unless index.is_a? Integer

    if typeof_element
      raise TypeError unless Jsof::WrapHelper.assignable?(typeof_element, val)
    end

    boxed = Jsof::WrapHelper.boxing(val, typeof_element)
    @wrapped[index] = boxed if Jsof::WrapHelper.wrapped_value?(boxed)
    @internal_object[index] = Jsof::WrapHelper.unboxing(val)
    val
  end

  # Clean internal cache.
  # Call this after you changed wrapped object directly.
  def clear_internal
    @wrapped.clear
  end

  # @return [Integer]
  def size
    @internal_object.size
  end

  # Delete element. (Same as Array#delete_at)
  # @param [Integer] pos  Element index to delete
  def delete_at(pos)
    @internal_object.delete_at(pos)
    @wrapped.delete_at(pos)
  end

  include Enumerable
  def each
    if block_given?
      for i in 0...@internal_object.size
        yield self[i]
      end
    else
      Enumerator.new(self, :each)
    end
  end

  # Return reference to wrapped array.
  def to_ary
    @internal_object
  end

  # Return reference to wrapped array.
  def to_a
    @internal_object
  end
end
