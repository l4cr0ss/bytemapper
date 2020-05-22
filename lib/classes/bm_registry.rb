require 'singleton'
module Bytemapper
  module Classes
    class BM_Registry
      include Singleton

      attr_reader :names
      attr_reader :objects

      def initialize
        @objects = {}
        @names = {}
      end

      def empty?
        @objects.size.zero? && @names.size.zero?
      end

      def flush
        @objects = {}
        @names = {}
      end

      def registered_name?(name)
        @names.key?(name)
      end

      def registered_obj?(obj)
        @objects.key?(obj.hash)
      end

      def register(obj, name = nil)
        register_obj(obj)
        @names[name] ||= obj.hash unless name.nil?
      end

      def register_obj(obj)
        @objects[obj.hash] ||= obj
      end

      def retrieve_by_name(name)
        obj = @objects.fetch(@names[name])
        {
          obj: obj,
          aliases: @names.filter { |k,v| k !=name && v == obj.hash }.keys,
          name: name
        }
      end

      def retrieve_by_obj(obj)
        {
          obj: @objects[obj.hash],
          aliases: @names.filter { |_,v| v == obj.hash }.keys,
          name: nil
        }
      end
    end
  end
end
