module ByteMapper
  module Classes
    class BM_Registry
      attr_reader :klass

      def initialize(klass = nil)
        @klass = klass
        @objstore = {}
        @namestore = {}
      end

      # name <-*---1-> obj
      #w Registering a name/obj pair
      # 1. store the object in the objstore if it's not already there
      # 2. make sure the name isn't already registered in the names list
      # 3. register the obj hash to the name in the names list
      def register(obj)
        raise obj_error(obj) unless valid_obj?(obj)
        @objstore[obj.hash] ||= obj
        @namestore[obj.name] ||= obj.hash unless @namestore.keys.include?(obj.name)
        obj
      end

      def retrieve(key)
        raise ArgumentError.new(invalid_key_error(key)) unless valid_key?(key)
        return @objstore[key.hash] if @objstore.key?(key.hash)
        @objstore[@namestore[format_name(key)]]
      end
      alias_method :find, :retrieve

      private

      def by_name(name)
        name = format_name(name)
        hash = @namestore[name]
        @objstore[hash]
      end

      def by_hash(hashable)
        obj = @objstore[hashable.hash]
        obj.name = @namestore.values.filter { |v| v == hashable.hash }
        obj
      end

      def format_name(name)
        return nil unless name
        name = name.shift while name.respond_to?(:shift)
        raise ArgumentError.new(invalid_name_error(name)) unless valid_name?(name)
        name.upcase.to_sym 
      end

      def valid_name?(name)
        [ 
          name.respond_to?(:upcase),
          name.respond_to?(:to_sym)
        ].reduce(:&)
      end

      def valid_obj?(obj)
        klass = ::ByteMapper::Mixins::BM_Wrappable
        modules = obj.class.singleton_class.included_modules
        modules.include?(klass)
      end

      def valid_key?(key)
        [
          valid_name?(key),
          valid_obj?(key)
        ].reduce(:|)
      end

      def obj_error(obj)
        klass = obj.class
        err = klass.nil? ? nil_obj_error : unwrapped_obj_error(klass)
        raise ArgumentError.new(err)
      end

      def nil_registration_error
        "nil is not a registerable value" 
      end

      def unwrapped_obj_error(klass)
        "'#{klass}' must be wrapped before it can be registered"
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
