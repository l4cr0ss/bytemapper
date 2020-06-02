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
  require 'bytemapper/nameable'
  class Shape < Hash
    include Flattenable
    include Nameable

    def []=(k,v)
      super
      singleton_class.instance_eval { attr_reader k }
      instance_variable_set("@#{k.to_s}", self[k])
    end
  end
end
