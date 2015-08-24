module Dottie
  module Methods
    
    ##
    # Reads from the Hash or Array with special handling for Dottie-style keys.
    
    def [](key)
      if Dottie.dottie_key?(key)
        Dottie.get(wrapped_object_or_self, key)
      else
        super
      end
    end
    
    ##
    # Writes to the Hash or Array with special handling for Dottie-style keys,
    # adding missing Hash nodes or Array elements where necessary.
    
    def []=(key, value)
      if Dottie.dottie_key?(key)
        Dottie.set(wrapped_object_or_self, key, value)
      else
        super
      end
    end
    
    ##
    # Checks whether the Hash has the specified key with special handling for
    # Dottie-style keys.
    
    def has_key?(key)
      if Dottie.dottie_key?(key)
        Dottie.has_key?(wrapped_object_or_self, key)
      else
        super
      end
    end
    
    ##
    # Fetches a value from the Hash with special handling for Dottie-style keys.
    # Handles the optional default value and block the same as Hash#fetch.
    
    def fetch(key, default = :_fetch_default_, &block)
      if Dottie.dottie_key?(key)
        if default != :_fetch_default_
          Dottie.fetch(wrapped_object_or_self, key, default, &block)
        else
          Dottie.fetch(wrapped_object_or_self, key, &block)
        end
      else
        if default != :_fetch_default_
          wrapped_object_or_self.fetch(key, default, &block)
        else
          wrapped_object_or_self.fetch(key, &block)
        end
      end
    end
    
    ##
    # Deletes the value at the specified key and returns it.
    
    def delete(key)
      if Dottie.dottie_key?(key)
        Dottie.delete(wrapped_object_or_self, key)
      else
        super
      end
    end
    
    ##
    # 
    
    def dottie_flatten
      Dottie.flatten(wrapped_object_or_self)
    end
    
    ##
    # 
    
    def dottie_keys(intermediate = false)
      Dottie.keys(wrapped_object_or_self, intermediate: intermediate)
    end
    
    private
      
      ##
      # Gets the Hash or Array, whether it is a wrapped object (a
      # Dottie::Freckle) or this object (self).
      
      def wrapped_object_or_self
        if is_a?(Hash) || is_a?(Array)
          self
        elsif respond_to?(:wrapped_object)
          wrapped_object || self
        else
          self
        end
      end
    
  end
end
