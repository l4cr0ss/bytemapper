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
  module Flattenable
    def flatten(flattened = {}, prefix = nil)
      each do |k,v|
        k = prefix.nil? ?  k : "#{prefix}_#{k}".to_sym
        if v.is_a?(Hash)
          v.flatten(flattened, k)
        else
          flattened[k] = v
        end
      end
      flattened
    end

    def size
      flatten.values.map(&:first).reduce(:+) >> 3
    end
  end
end
