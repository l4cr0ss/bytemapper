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
  require 'bytemapper/registry'
  require 'bytemapper/shape'
  require 'bytemapper/type'
  require 'bytemapper/nameable'
  require 'bytemapper/chunk'
  require 'bytemapper/table'

  @@registry = Registry.new

  class << self

    def register(obj, name, fqname = [])
      return if obj.nil?
      name = name.downcase.to_sym unless name.nil?
      fqname << name unless name.nil?
      if is_a_type?(obj)
        name = fqname.size > 1 ? fqname.join('.') : fqname.first
        obj = Type.new(obj)
        put(obj, name)
      elsif is_a_name?(obj)
        register(get(obj), nil, fqname)
      elsif is_a_shape?(obj)
        if registered?(obj)
          obj = get(obj)
          put(obj, name)
        else
          shape = Shape.new
          obj.each do |k,v|
            shape[k] = register(v, k, [].concat(fqname))
          end
          put(shape, name)
        end
      else
        put(obj, name)
      end
    end
    alias :wrap :register

    def is_a_type?(obj)
      obj.is_a?(Type) ||
      obj.is_a?(Array) &&
      obj.size == 2 &&
      obj.first.is_a?(Integer) &&
      obj.last.is_a?(String)
    end

    def is_a_shape?(obj)
      obj.is_a?(Hash)
    end

    def is_a_name?(obj)
      obj.is_a?(String) || obj.is_a?(Symbol)
    end

    def map(bytes, shape, name = nil)
      bytes.force_encoding(Encoding::ASCII_8BIT)
      bytes = StringIO.new(bytes)
      if shape.is_a?(Array)
        chunks = []
        shape.each { |s| chunks << Chunk.new(bytes.read(s.size), s, name) }
        chunks
      else
        shape = wrap(shape, name)
        Chunk.new(bytes, shape, name)
      end
    end

    def repeat(obj, times = nil)
      Table.new(obj, times)
    end

    def registered?(obj)
      registry.registered?(obj)
    end

    def get(obj)
      registry.get(obj)
    end

    def put(obj, name)
      registry.put(obj, name)
    end

    def names(filter_key = nil)
      registry.names.keys
    end

    def print
      registry.print
    end

    def registry
      @@registry
    end

    def reset(with_basic_types = true)
      @@registry = Registry.new(with_basic_types)
    end
  end
end
