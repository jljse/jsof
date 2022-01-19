
# Used with define_attr to define typed array property.
class Jsof::WrapArrayType
  # @param [Class, WrapArrayType] typeof_element  Type of each element
  def initialize(typeof_element: nil)
    @typeof_element = typeof_element
  end

  # Create wrapper instance.
  # @return [Jsof::WrapArray]
  def new(obj)
    Jsof::WrapArray.new(obj, typeof_element: @typeof_element)
  end

  # Check value can be wrapped by this type.
  # @return [Boolean]
  def assignable?(val)
    if @typeof_element && val
      return false unless val.is_a? Array
      return val.all?{|elem| Jsof::WrapHelper.assignable?(@typeof_element, elem)}
    end
    true
  end
end
