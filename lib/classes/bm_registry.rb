module ByteMapper
  module Classes
    class BM_Registry
      attr_reader :is_wrapped

      def initialize()
        @objstore = {}
        @namestore = {}
      end

      def register(obj)
        @objstore[obj.hash] ||= obj
        @namestore[obj.name] ||= obj.hash unless @namestore.keys.include?(obj.name)
        obj
      end

      def retrieve(key, name = nil)
        obj = @objstore[key&.hash]
        return register_alias(obj, name) if valid_name?(name) && obj
        @objstore[@namestore[format_name(key)]]
      end

      # Check the namestore to see if the given key exists. If it does you can
      # assume that it points to a valid BM_Shape or BM_Type registration.
      def registered_name?(key)
        @namestore.key?(format_name(key))
      end

      def flush
        @objstore = {}
        @namestore = {}
      end

      private
      
      def register_alias(obj, name)
        @namestore[format_name(name)] ||= obj.hash
        obj
      end

      def format_name(name)
        return nil unless valid_name?(name)
        name.upcase.to_sym 
      end

      def valid_key?(key)
        [
          valid_name?(key),
          valid_obj?(key)
        ].reduce(:|)
      end

      def valid_name?(name)
        [ 
          name.respond_to?(:upcase),
          name.respond_to?(:to_sym)
        ].reduce(:&)
      end

      def invalid_name_error(name)
        "'#{name.class}' is not a valid type of name" 
      end

      def invalid_key_error(key)
        "Unable to use '#{key.class}' as a registry index"
      end
    end
  end
end
