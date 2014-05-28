require 'semi_semantic/parse_error'

module SemiSemantic
  class VersionSegment
    include Comparable

    #TODO: immutable?
    attr_reader :components

    # Converts a string into a VersionCluster
    # Raises a ParseError if the string format is invalid
    # Raises an ArgumentError if version_string is nil
    def self.parse(component_string)
      raise ArgumentError.new 'Invalid Version Component String: nil' if component_string.nil?
      self.new(component_string.split('.').map do |v|
        if v.match(/\A[0-9]+\z/)
          v.to_i
        elsif v.match(/\A[0-9A-Za-z_\-]+\z/)
          v
        else
          raise ParseError.new 'Invalid Version Component Format: Requires alphanumerics and hyphens only'
        end
      end)
    end

    # Construction can throw ArgumentError, but does no parsing or type-conversion
    def initialize(components)
      raise ArgumentError.new 'Invalid Version Components: nil' if components.nil?
      raise ArgumentError.new "Invalid Version Components: #{components}" if components.empty? || components.include?('')
      @components = components
    end

    def <=>(other)
      a = @components
      b = other.components
      if a.size > b.size
        comparison = a[0...b.size] <=> b
        return comparison unless comparison == 0
        a[b.size..-1].each {|v| return 1 unless v == 0 }
        0
      elsif a.size < b.size
        comparison = a <=> b[0...a.size]
        return comparison unless comparison == 0
        b[a.size..-1].each {|v| return -1 unless v == 0 }
        0
      else
        a <=> b
      end
    end

    # Returns a copy of the VersionCluster with the integer at the provided index incremented by one.
    # Raises a TypeError if the value at that index is not an integer.
    def increment(index=-1)
      value = @components[index]
      raise TypeError.new "'#{value}' is not an integer" unless value.is_a? Integer

      copy = Array.new @components
      copy[index] = value + 1

      while index < copy.size && index != -1
        index += 1
        value = copy[index]
        if value.is_a? Integer
          copy[index] = 0
        end
      end

      self.class.new copy
    end

    # Returns a copy of the VersionCluster with the integer at the provided index decremented by one.
    # Raises a TypeError if the value at that index is not an integer.
    # Raises a RangeError if the value is zero or less
    def decrement(index=-1)
      value = @components[index]
      raise TypeError.new "'#{value}' is not an integer" unless value.is_a? Integer
      raise RangeError.new "'#{value}' is zero or less" unless value > 0

      copy = Array.new @components
      copy[index] = value - 1
      self.class.new copy
    end

    def to_s
      @components.join('.')
    end
  end
end
