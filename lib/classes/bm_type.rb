require 'mixins/wrappable'
require 'classes/bm_registry'

module Bytemapper
  module Classes
    class BM_Type < Array
      include Wrappable
    end
  end
end
