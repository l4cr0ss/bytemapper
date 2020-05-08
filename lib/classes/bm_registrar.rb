require 'singleton'
require 'classes/bm_registry'

module ByteMapper
  module Classes
    class BM_Registrar
      include Singleton

      def initialize
        @registries = {}
      end

      def register(obj)
        klass = obj.class
        registry = (@registries[klass] ||= BM_Registry.new(klass))
        registry.register(obj)
      end

      def retrieve(obj, klass)
        @registries[klass].retrieve(obj)
      end
    end
  end
end
