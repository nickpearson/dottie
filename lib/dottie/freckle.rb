module Dottie
  class Freckle
    include Methods
    
    ##
    # Creates a new Freckle to wrap the supplied object.
    
    def initialize(obj)
      case obj
      when Hash, Array
        @_wrapped_object = obj
      else
        raise TypeError, 'must be a Hash or Array'
      end
    end
    
    ##
    # Returns the wrapped Hash, and raises an error if the wrapped object is
    # not a Hash.
    
    def hash
      wrapped_object(Hash)
    end
    
    ##
    # Returns the wrapped Array, and raises an error if the wrapped object is
    # not an Array.
    
    def array
      wrapped_object(Array)
    end
    
    ##
    # Returns the wrapped object, and raises an error if a type class is
    # provided and the wrapped object is not of that type.
    
    def wrapped_object(type = nil)
      if type.nil? || @_wrapped_object.is_a?(type)
        @_wrapped_object
      else
        raise TypeError.new("expected #{type.name} but got #{@_wrapped_object.class.name}")
      end
    end
    
    def inspect
      "<Dottie::Freckle #{wrapped_object.inspect}>"
    end
    
    def method_missing(method, *args)
      wrapped_object.send(method, *args)
    end
    
  end
end
