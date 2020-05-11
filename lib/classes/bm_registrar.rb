require 'singleton'
require 'classes/bm_registry'

module ByteMapper
  module Classes
    class BM_Registrar
      include Singleton

      def initialize
        @registry = BM_Registry.new
      end

      def register(obj)
        registry.register(obj)
      end

      def retrieve(key)
        registry.retrieve(key)
      end
      alias_method :find, :retrieve

      def registered_name?(key)
        registry.registered_name?(key)
      end
      alias_method :registered?, :registered_name?

    end
  end
end
