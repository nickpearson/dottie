require 'dottie/methods'
require 'dottie/freckle'
require 'dottie/helper'
require 'dottie/version'
require 'strscan'

module Dottie
  
  ##
  # Creates a new Dottie::Freckle from a standard Ruby Hash or Array.
  
  def self.[](obj)
    if obj.is_a?(Dottie::Freckle)
      obj
    else
      Dottie::Freckle.new(obj)
    end
  end
  
  ##
  # Gets a value from an object. Does not assume the object has been extended
  # with Dottie methods.
  
  def self.get(obj, key)
    Dottie.key_parts(key).each do |k|
      obj = case obj
      when Hash, Array
        # use an array index if it appears that's what was intended
        k = k.to_i if obj.is_a?(Array) && k.to_i.to_s == k
        obj[k]
      else
        nil
      end
    end
    obj
  end
  
  ##
  # Sets a value in an object, creating missing nodes (Hashes and Arrays) as
  # needed. Does not assume the object has been extended with Dottie methods.
  
  def self.set(obj, key, value)
    key_parts = Dottie.key_parts(key)
    key_parts.each_with_index do |k, i|
      # set the value if this is the last key part
      if i == key_parts.size - 1
        case obj
        when Hash
          obj[k] = value
        when Array
          case k
          when '-', 'prepend', '>>'
            obj.unshift(value)
          when '+', 'append', '<<'
            obj << value
          else
            obj[k] = value
          end
        else
          raise TypeError.new("expected Hash or Array but got #{obj.class.name}")
        end
      # otherwise, walk down the tree, creating missing nodes along the way
      else
        obj = case obj
        when Hash, Array
          # look ahead at the next key to see if an array should be created
          if key_parts[i + 1].is_a?(Integer) ||
             key_parts[i + 1] =~ /\A(-|\+|prepend|append|>>|<<)\z/
            obj[k] ||= []
          else
            obj[k] ||= {}
          end
        when nil
          # look at the key to see if an array should be created
          case k
          when Integer, '-', '+', 'prepend', 'append', '>>', '<<'
            obj[k] = []
          else
            obj[k] = {}
          end
        else
          raise TypeError.new("expected Hash, Array, or nil but got #{obj.class.name}")
        end
      end
    end
    # return the value that was set
    value
  end
  
  ##
  # Checks whether a Hash or Array contains the last part of a Dottie-style key.
  
  def self.has_key?(obj, key)
    key_parts = Dottie.key_parts(key)
    key_parts.each_with_index do |k, i|
      # look for the key if this is the last key part
      if i == key_parts.size - 1
        if obj.is_a?(Array) && k.is_a?(Integer)
          return obj.size > k
        elsif obj.is_a?(Hash)
          return obj.has_key?(k)
        else
          return false
        end
      else
        obj = case obj
        when Hash, Array
          obj[k]
        else
          return false
        end
      end
    end
  end
  
  ##
  # Mimics the behavior of Hash#fetch, raising an error if a key does not exist
  # and no default value or block is provided.
  
  def self.fetch(obj, key, default = :_fetch_default_)
    if Dottie.has_key?(obj, key)
      Dottie.get(obj, key)
    elsif block_given?
      yield(key)
    elsif default != :_fetch_default_
      default
    else
      raise KeyError.new(%{key not found: "#{key}"})
    end
  end
  
  ##
  # Deletes the value at the specified key and returns it.
  
  def self.delete(obj, key)
    if Dottie.has_key?(obj, key)
      key_parts = Dottie.key_parts(key)
      if key_parts.size > 1
        key = Dottie.build_key(key_parts[0..-2])
        obj = Dottie.get(obj, key)
      end
      if obj.is_a?(Array) && key_parts.last.is_a?(Fixnum)
        obj.delete_at(key_parts.last)
      else
        obj.delete(key_parts.last)
      end
    else
      nil
    end
  end
  
  ##
  # Flattens a Hash or Array to a single-depth Hash with Dottie-style keys.
  
  def self.flatten(obj, options = {}, path = nil, flat = nil)
    path ||= []
    flat ||= {}
    case obj
    when Hash
      obj.each do |k, v|
        this_path = path + [k]
        case v
        when Hash, Array
          flat[this_path.join('.')] = options[:keys_only] ? nil : v if options[:intermediate]
          Dottie.flatten(v, options, this_path, flat)
        else
          flat[this_path.join('.')] = options[:keys_only] ? nil : v
        end
      end
    when Array
      obj.each_with_index do |v, i|
        this_path = path.dup
        if this_path.any?
          this_path[-1] = this_path[-1].to_s + "[#{i}]"
        else
          this_path = ["[#{i}]"]
        end
        case v
        when Hash, Array
          flat[this_path.join('.')] = options[:keys_only] ? nil : v if options[:intermediate]
          Dottie.flatten(v, options, this_path, flat)
        else
          flat[this_path.join('.')] = options[:keys_only] ? nil : v
        end
      end
    end
    flat
  end
  
  ##
  # Gets an array of the Dottie-style keys that exist in a Hash or Array.
  
  def self.keys(obj, options = {})
    Dottie.flatten(obj, { keys_only: true }.merge(options)).keys
  end
  
  ##
  # Checks whether a key looks like a key Dottie understands.
  
  def self.dottie_key?(key)
    !!(key.is_a?(String) && key =~ /[.\[]/) || key.is_a?(Array)
  end
  
  ##
  # Parses a Dottie key into an Array of strings and integers.
  
  def self.key_parts(key)
    if key.is_a?(String)
      parts = []
      s = StringScanner.new(key)
      loop do
        if s.scan(/\./)
          next
        elsif (p = s.scan(/[^\[\].]+/))
          parts << p
        elsif (p = s.scan(/\[-?\d+\]/))
          parts << p.scan(/-?\d+/).first.to_i
        elsif (p = s.scan(/\[(first|last)\]/))
          parts << (p[1..-2] == 'first' ? 0 : -1)
        elsif (p = s.scan(/\[.+?\]/))
          parts << p[1..-2] # remove '[' and ']'
        else
          break
        end
      end
      parts
    elsif key.is_a?(Array)
      key
    else
      raise TypeError.new("expected String or Array but got #{key.class.name}")
    end
  end
  
  ##
  # Builds a Dottie key from an Array of strings and integers.
  
  def self.build_key(parts)
    key = ''
    parts.each_with_index do |part, i|
      case part
      when String
        key << '.' unless i == 0
        key << part
      when Fixnum
        key << "[#{part}]"
      end
    end
    key
  end
  
end
