

# Helper methods.
module Jsof::WrapHelper
  # @return [Boolean]  Already wrapped or not
  def self.wrapped_value?(val)
    return true if val.is_a?(Jsof::WrapObject)
    return true if val.is_a?(Jsof::WrapArray)
    return false
  end

  # @return [Boolean]  Wrappable by Jsof::WrapObject or not
  def self.require_wrap_value?(val)
    return true if val.is_a?(Hash)
    return false
  end

  # @return [Boolean]  Wrappable by Jsof::WrapArray or not
  def self.require_array_wrap_value?(val)
    return true if val.is_a?(Array)
    return false
  end

  # Wrap value if wrappable.
  # @param [Object] val  Wrap target object
  # @param [Class, Jsof::WrapArrayType]  Wrapper type. if nil, use WrapObject/WrapArray.
  def self.boxing(val, wrapper_type)
    if require_wrap_value?(val)
      return wrapper_type.new(val) if wrapper_type
      return Jsof::WrapObject.new(val)
    end
    if require_array_wrap_value?(val)
      return wrapper_type.new(val) if wrapper_type
      return Jsof::WrapArray.new(val)
    end
    return val
  end

  # Take internal object if wrapped.
  # @param [Object] val   Unwrap target object
  def self.unboxing(val)
    if wrapped_value?(val)
      return val.internal_object
    end
    return val
  end

  # Check value can be wrapped by specific type.
  # @param [Class, Jsof::WrapArrayType] type  Expected type
  # @param [Object] val  Check target object
  # @return [Boolean]
  def self.assignable?(type, val)
    return true unless val

    if type.is_a? Jsof::WrapArrayType
      return type.assignable?(val)
    end
    if type == Jsof::BooleanType
      return val == true || val == false
    end
    if type < Jsof::WrapObject
      return type.assignable?(val)
    end
    if type.is_a? Class
      return val.is_a? type
    end
    true
  end
end
