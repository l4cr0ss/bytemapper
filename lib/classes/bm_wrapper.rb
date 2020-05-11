require 'singleton'
require 'mixins/helpers'
require 'classes/bm_registrar'
require 'classes/bm_type'
require 'classes/bm_shape'
require 'classes/bm_chunk'

module ByteMapper
  module Classes
    class BM_Wrapper
      extend Mixins::Helpers
      include Singleton

      def self.wrap(obj, name = nil)
        # check if the obj is already registered and if it is return it
        obj.each do |k,v|
          if is_stringlike?(v)
          elsif BM_Type.can_wrap?(obj) # wrap it
          elsif v.is_a? Hash # Recurse
            wrap_shape(obj, k)
          else
            raise "error"
          end
        end
      end

      private

      def wrap_df(obj, wrapped, name = nil)

        type = BM_Registrar.instance.retrieve(obj, BM_Type) if obj.is_a? Symbol
        
        return BM_Type.wrap(obj, name) if BM_Type.can_wrap?(obj)
        obj.each do |k,v|
        end
      end
    end
  end
end

