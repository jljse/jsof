# Wrapper class for Object(Hash).
class Jsof::WrapObject
  # Create wrapper for Hash.
  # @param [Hash] obj  Wrap target hash
  # @param [Boolean] allow_implicit_attr
  #     Allow to use undefined properties or not.
  #     If nil, assume true if it's instance of WrapObject,
  #     and assume false if it's instance of derived classes.
  def initialize(obj = {}, allow_implicit_attr: nil)
    unless self.class.initialized?
      self.class.resolve_typeof_properties
      self.class.initialize()
      self.class.initialized = true
    end

    @internal_object = obj
    @wrapped = {}
    @is_allow_implicit_attr = allow_implicit_attr
    if @is_allow_implicit_attr == nil
      @is_allow_implicit_attr = self.class.typeof_properties.empty?
    end
  end

  @typeof_properties = {}
  def self.inherited(subclass)
    subclass.instance_variable_set(:@typeof_properties, @typeof_properties.dup)
  end
  # Explicitly defined properties.
  # @return [Hash{Symbol => Class, Jsof::WrapArrayType, Proc}]
  def self.typeof_properties
    @typeof_properties
  end
  def self.resolve_typeof_properties
    @typeof_properties.keys.each do |sym|
      if @typeof_properties[sym].is_a? Proc
        @typeof_properties[sym] = @typeof_properties[sym].call
      end
    end
  end
  @initialized = false
  # Whether self.initialize was already called or not.
  def self.initialized?
    @initialized
  end
  def self.initialized=(val)
    @initialized = val
  end
  # Place to define properties by define_attr.
  # Override this for derived class.
  # This method will be called when the first instace is created.
  def self.initialize
    # override
  end

  # Define explicit accessor methods for attribute(property).
  # @param [Symbol] sym  Attribute name.
  # @param [Class, Jsof::WrapArrayType, Proc] type
  #    If nil, the property is untyped.
  #    Usually, pass Class to specify the type of the property.
  #    If you want to specify typed Array, then pass instance of Jsof::WrapArrayType.
  #    If you want to use the class not defined yet (defined later) , then wrap with Proc like `->{ YourClass }`.
  def self.define_attr(sym, type: nil)
    @typeof_properties[sym] = type
    self.define_method(sym) do
      self[sym]
    end
    self.define_method((sym.to_s + "=").to_sym) do |val|
      self[sym] = val
    end
  end

  # Check value can be wrapped by this type.
  # TODO: Currently, will not check properties's types,
  # but this behavior might be changed in future version.
  # @return [Boolean]
  def self.assignable?(val)
    # TODO:
    return true if val == nil
    return true if val.is_a? Hash
    false
  end

  # Return reference to wrapped array.
  def internal_object
    @internal_object
  end

  def [](key)
    sym = key.to_sym
    return @wrapped[sym] if @wrapped.key?(sym)

    elem = @internal_object[sym]
    boxed = Jsof::WrapHelper.boxing(elem, self.class.typeof_properties[sym])
    @wrapped[sym] = boxed if elem != boxed
    return boxed
  end

  def []=(key, val)
    sym = key.to_sym
    if type = self.class.typeof_properties[sym]
      raise TypeError unless Jsof::WrapHelper.assignable?(type, val)
    end
    boxed = Jsof::WrapHelper.boxing(val, self.class.typeof_properties[sym])
    @wrapped[sym] = boxed if Jsof::WrapHelper.wrapped_value?(boxed)
    @internal_object[sym] = Jsof::WrapHelper.unboxing(val)
    val
  end

  # Clean internal cache.
  # Call this after you changed wrapped object directly.
  def clear_internal
    @wrapped.clear
  end

  def method_missing(name, *args)
    raise NoMethodError.new("", name) unless @is_allow_implicit_attr

    if name.to_s.end_with?('=')
      self[name.to_s[0...-1].to_sym] = args.first
    else
      self[name]
    end
  end

  # Return reference to wrapped array.
  def to_hash
    @internal_object
  end

  # Return reference to wrapped array.
  def to_h
    @internal_object
  end
end
