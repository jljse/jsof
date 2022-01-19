
# Wrap JSON like object
# @pram [Hash] obj  Wrap target object
# @return [Jsof::WrapObject, Jsof::WrapArray]
def Jsof(obj = {})
  if obj.is_a? Hash
    return Jsof::WrapObject.new(obj)
  end
  if obj.is_a? Array
    return Jsof::WrapArray.new(obj)
  end
  obj
end
