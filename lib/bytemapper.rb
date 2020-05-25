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

  def self.wrap(shape, name)
    return nil unless shape.is_a?(Hash)
    self._wrap(shape, name)
  end

  def self._wrap(obj, name, wrapper = {})
    if (obj.is_a?(Array) || obj.is_a?(String) || obj.is_a?(Symbol))
      return registry.get(obj, name)
    else obj.is_a?(Hash)
      obj.each do |k, v|
        wrapper[k] = _wrap(v, k)
        wrapper.define_singleton_method(k) { self.send(:fetch, k) }
      end
    end
    wrapper.extend(Flattenable)
    registry.put(wrapper, name)
    wrapper
  end

  def self.map(bytes, shape, name = nil)
    bytes = StringIO.new(bytes)
    wrapper = self.wrap(shape, name)
    Chunk.new(bytes, wrapper, name)
  end

  def self.registry
    @@registry
  end
end
