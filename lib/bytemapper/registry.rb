# Bytemapper - Model arbitrary bytestrings as Ruby objects.  
# Copyright (C) 2020 Jefferson Hudson
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

module Bytemapper
  class Registry
    require 'bytemapper/nameable'

    attr_reader :names
    attr_reader :objects

    def initialize(with_basic_types = true)
      @objects = {}
      @names = {}
      register_basic_types unless with_basic_types == false
    end

    def empty?
      @objects.size.zero? && @names.size.zero?
    end

    def flush
      @objects = {}
      @names = {}
    end

    def registered?(obj)
      names.key?(obj) || objects.key?(obj.hash)
    end

    def get(obj, name = nil)
      if (obj.is_a?(String) || obj.is_a?(Symbol))
        # Object assumed to be a registered name
        obj = @objects.fetch(@names[obj])
        register_alias(obj, name) unless name.nil?
      elsif (obj.is_a?(Array) || obj.is_a?(Hash))
        obj = put(obj, name)
      else
        raise ArgumentError "Invalid obj"
      end
      obj
    end

    def put(obj, name = nil)
      obj = register_obj(obj)
      register_name(obj, name)
      obj
    end

    def registered_name?(name)
      @names.key?(name) 
    end

    def registered_obj?(obj)
      @objects.key?(obj.hash) 
    end

    def register_obj(obj)
      unless registered_obj?(obj)
        obj.extend(Nameable)
        obj.names = Set.new
      end
      @objects[obj.hash] ||= obj
    end

    def register_name(obj, name)
      unless name.nil?
        if registered_name?(name) && get(name) != obj
          raise ArgumentError.new 'Name is already registered' 
        else
          name = name.to_sym
          @names[name] ||= obj.hash
          obj.names << name
        end
      end
      obj
    end
    alias :register_alias :register_name

    def print
      puts to_s
    end

    def to_s
      return "" if @objects.empty?

      # Buffer to build up output.
      buf = StringIO.new

      # Calculate the width of each column.
      widths = [
        @names.keys.size.zero? ? 0 : @names.keys.map(&:size).max + 1, # add space for the `:`
        7, # length of ID to print
        @objects.values.map { |o| o.class.to_s.size }.max,
        @objects.values.map { |v| v.to_s.size }.max
      ]

      # Add an extra space at the beginning and end of each column.
      widths = widths.map { |p| p += 2 }

      buf << "+"
      # Build the header line.
      widths.each do |w|
        buf << "#{'-' * w}+"
      end
      buf << "\n"

      # Build the rows of the table.
      @objects.each do |id, obj|
        names = @names.filter { |k,v| v == id }.keys
        names << '' if names.empty?
        # Create an entry for each object alias.
        names.each do |name|
          buf << "|"

          # Fixup the id string so it pads nicely
          idstr = id.positive? ? id.to_s[..5] : id.to_s[..6]
          idstr = id.positive? ? "  #{idstr}" : " #{idstr}"

          # Wrap each column value with whitespace.
          values = [
          name.empty? ? name : " :#{name} ",
          idstr,
          " #{obj.class.to_s} ",
          " #{obj.to_s} "
          ]

          # Calculate padding for each column.
          pads = widths.zip(values).map { |a,b| a - b.size }

          values.size.times do |i|
            buf << "#{values[i]}#{' '*pads[i]}|"
          end
          buf << "\n"
        end
      end

      # Build the trailing line.
      buf << "+"
      widths.each do |w|
        buf << "#{'-' * w}+"
      end
      buf << "\n"
      buf.string
    end

    def reset(with_basic_types = true)
      flush
      register_basic_types unless with_basic_types == false
    end

    private
    def register_basic_types
      [
        [:char, [8,'c']],
        [:uchar, [8,'C']],
        [:uint8_t, [8,'C']],
        [:bool, [8,'C']],
        [:uint16_t, [16,'S']],
        [:uint32_t, [32,'L']],
        [:uint64_t, [64,'Q']],
        [:int8_t, [8,'c']],
        [:int16_t, [16,'s']],
        [:int32_t, [32,'l']],
        [:int64_t, [64,'q']]
      ].each { |name, type| put(type, name) }
    end
  end
end
