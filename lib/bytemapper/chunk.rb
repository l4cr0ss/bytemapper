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
  require 'bytemapper/flattenable'
  class Chunk < Hash
    include Flattenable
    attr_reader :bytes, :shape, :name

    def initialize(bytes, shape, name)
      @name = name
      @shape = shape
      @bytes = bytes.is_a?(StringIO) ? bytes : StringIO.new(bytes)
      @bytes.truncate(shape.size)
      replace(shape)
      each_pair do |k,v|
        self[k] = if v.is_a?(Hash)
                    Chunk.new(@bytes.read(v.size), v, k)
                  else
                    unpack(v)
                  end
        singleton_class.instance_eval { attr_reader k }
        instance_variable_set("@#{k.to_s}", self[k])
      end
    end

    def string
      bytes.string
    end

    def ord
      bytes.string.split(//).map(&:ord)
    end

    def chr
      bytes.string.split(//).map(&:chr)
    end

    def capacity
      shape.size
    end

    def size
      bytes.size
    end

    def consumed
      size
    end

    def remaining
      capacity - consumed
    end

    def unpack(value, endian = nil)
      num_bytes, flag = value
      _bytes = bytes.read(num_bytes >> 3)
      _bytes.unpack("#{flag}#{endian}")[0] unless _bytes.nil?
    end
  end
end
