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
      # Registering a name/obj pair
      # 1. store the object in the objstore if it's not already there
      # 2. make sure the name isn't already registered in the names list
      # 3. register the obj hash to the name in the names list
      def register(name, obj)
        name = name.upcase.to_sym
        if valid_obj?(obj)
          @objstore[obj.hash] ||= obj
          @namestore[name] ||= obj.hash unless @namestore.keys.include?(name)
          return true
        end
        raise ArgumentError.new("#{inspect} only accepts objects of type #{klass}")
      end
      
      def find_by_name(name)
        name = name.upcase.to_sym
        hash = @namestore[name]
        @objstore[hash]
      end

      def find_by_hash(hashable)
        @objstore[hashable.hash]
      end

      private

      def valid_obj?(obj)
        klass.nil? or obj.is_a? klass
      end

      def valid_name?(name)
        [ name.respond_to?(:upcase),
          name.respond_to?(:to_sym)
        ].reduce(:&)
      end

      def error(key, *args)
        @@errors[key.to_sym].call(*args) 
      end
    end
  end
end
