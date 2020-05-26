# Bytemapper - Model arbitrary bytestrings as Ruby objects.  
# Copyright (C) 2020 Jefferson Hudson
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

module Bytemapper
  require 'bytemapper/registry'
  require 'bytemapper/nameable'
  require 'bytemapper/flattenable'
  require 'bytemapper/chunk'

  @@registry = Registry.new

  def self.wrap(obj, name = nil, wrapper = {})
    if (obj.is_a?(Array) || obj.is_a?(String) || obj.is_a?(Symbol))
      obj = registry.get(obj, name)
      raise ArgumentError.new "Failed to resolve symbol #{name}" if obj.nil?
    elsif obj.is_a?(Hash)
      obj.each do |k, v|
        wrapper[k] = wrap(v, k)
        wrapper.define_singleton_method(k) { self.send(:fetch, k) }
      end
      wrapper.extend(Flattenable)
      obj = registry.put(wrapper, name)
    else
      raise ArgumentError.new "Invalid object"
    end
    obj
  end

  def self.map(bytes, shape, name = nil)
    bytes = StringIO.new(bytes)
    wrapper = self.wrap(shape, name)
    Chunk.new(bytes, wrapper, name)
  end

  def self.registry
    @@registry
  end

  def reset(with_basic_types = true)
    [
      [:uint8_t, [8,'C']],
      [:bool, [8,'C']],
      [:uint16_t, [16,'S']],
      [:uint32_t, [32,'L']],
      [:uint64_t, [64,'Q']],
      [:int8_t, [8,'c']],
      [:int16_t, [16,'s']],
      [:int32_t, [32,'l']],
      [:int64_t, [64,'q']]
    ].each do |name, type|
      @@registry.put(type, name)
    end
    @@registry
  end
end
