module Bytemapper
  # As part of wrapping process type/shape definitions are added here
  module Registry
    # Definitions wrapped without a name go here
    ANONYMOUS = Set[]

    class << self
      def register(obj)
        # The registry doesn't wrap stuff for you.
        # It only works with wrapped objects.
        raise "Only wrapped objects can be registered" unless wrapper?(obj)
        return anonymous(obj) if nameless?(obj)
        # When you register an object delist it from the anon list.
        ANONYMOUS.delete(obj) 
        const_set(obj.name, obj) unless registered?(obj.name)
      end

      def registered?(obj)
        return anonymous?(obj) if nameless?(obj)
        name = wrapper?(obj) ? obj.name : obj
        name = format_name(name)
        _registered?(name)
      end

      private

      def _registered?(name)
        return false unless valid_name?(name)
        const_get(name) if const_defined?(name)
      end

      def wrapper?(obj)
        # Check if your object is wrapper class
        obj.respond_to?(:name)
      end

      def nameless?(obj)
        # Check if your object has a name
        return false if valid_name?(obj)
        return true unless wrapper?(obj)
        obj.name.nil?
      end
      
      def anonymous(obj)
        # Search the registry first to see if it already exists under some name
        matches = constants.filter { |c| const_get(c).hash == obj.hash }
        if matches.any?
          obj.aliases = matches
        else
          ANONYMOUS.add(obj)
        end
        obj
      end

      def anonymous?(obj)
        # An anonymous object is one you wrapped but didn't name
        obj = ANONYMOUS.filter { |s| s == obj }
        obj.any? ? obj.first : false
      end

      def format_name(name)
        # Transform your name so Ruby will treat it as a constant
        name.upcase.to_sym if valid_name?(name)
      end

      def format_obj(obj)
        return obj if valid_shape?(obj)
        obj
      end

      def validate(obj, name)
        [
          format_obj(obj),
          format_name(name)
        ]
      end

      def valid_obj?(obj)
        # Your object is valid iff it can be turned into a wrapper 
        valid_type?(obj) || valid_shape?(obj) || valid_name?(obj)
      end

      def valid_shape?(obj)
        obj.is_a?(Hash)
      end

      def valid_type?(obj)
        obj.is_a?(Array)
      end

      def valid_name?(name)
        # A good name is any object that can be upcased and symbolized
        [
          name.respond_to?(:upcase),
          name.respond_to?(:to_sym)
        ].reduce(:&)
      end
    end
  end
end
