require 'classes/registration'
require 'mixins/wrappable'
module Bytemapper
  module Classes
    class Registry
      class << self

        # Container holding name/object_id registrations
        attr_reader :names

        # Container holding object_id/object registrations
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

        def register(obj, name = nil)
          register_obj(obj)
          register_name(obj, name)
          retrieve(obj, name)
        end

        def registered?(obj)
          names.key?(obj) || objects.key?(obj.hash)
        end

        def retrieve(obj)
          name = nil
          if namelike?(obj)
            name = obj
            obj = objects.fetch(names[name])
          elsif obj.respond_to?(:name)
            name = obj.name
            obj = @objects.fetch(@names[name])
          elsif obj.is_a? Hash
            obj = @objects[obj.hash]
          elsif obj.is_a? Array
            obj = @objects[obj.hash]
          else
            obj = @objects[obj.object_id]
          end
          wrap(obj, name)
        end

        def print
          puts to_s
        end

        def to_s
          return "" if @objects.empty?

          # Buffer to build up output.
          buf = StringIO.new

          # Calculate the width of each column.
          widths = [
            @names.keys.map(&:size).max + 1, # add space for the `:`
            7, # length of ID to print
            @objects.values.map { |o| o.class.to_s.size }.max,
            @objects.values.map { |v| v.to_s.size }.max
          ]

          # Add an extra space at the beginning and end of each column.
          widths = widths.map { |p| p += 2 }

          buf << "+"
          # Build the header line.
          widths.each do |w|
            buf << "#{'-' * w}+"
          end
          buf << "\n"

          # Build the rows of the table.
          @objects.each do |id, obj|
            names = @names.filter { |k,v| v == id }.keys
            names << '' if names.empty?
            # Create an entry for each object alias.
            names.each do |name|
              buf << "|"

              # Fixup the id string so it pads nicely
              idstr = id.positive? ? id.to_s[..5] : id.to_s[..6]
              idstr = id.positive? ? "  #{idstr}" : " #{idstr}"

              # Wrap each column value with whitespace.
              values = [
              name.empty? ? name : " :#{name} ",
              idstr,
              " #{obj.class.to_s} ",
              " #{obj.to_s} "
              ]
              
              # Calculate padding for each column.
              pads = widths.zip(values).map { |a,b| a - b.size }

              values.size.times do |i|
                buf << "#{values[i]}#{' '*pads[i]}|"
              end
              buf << "\n"
            end
          end

          # Build the trailing line.
          buf << "+"
          widths.each do |w|
            buf << "#{'-' * w}+"
          end
          buf << "\n"
          buf.string
        end

        private

        def registered_name?(name)
          @names.key?(name) 
        end

        def registered_obj?(obj)
          @objects.key?(obj.hash) 
        end

        def register_obj(obj)
          @objects[obj.hash] ||= obj
        end

        def register_name(obj, name)
          @names[name] ||= obj.hash unless name.nil?
          name
        end

        def retrieve_by_name(name)
          obj = @objects.fetch(@names[name])
          retrieve_registration(obj, name)
        end

        def retrieve_by_obj(obj)
          retrieve_registration(obj)
        end

        def namelike?(obj)
          obj.is_a?(Symbol) || obj.is_a?(String)
        end

        # Return registration information for the given object and name.
        #
        # @param obj [Hash, Array, Shape, Type] the object to query.
        # @param name [String, Symbol] the name to use.
        #
        # @return [Registration] 
        def registration(obj, name = nil)
          Classes::Registration.new(
            @objects[obj.hash],
            name,
            retrieve_aliases(obj, name),
            obj.nil? ? false : obj.is_a?(Wrappable)
          )
        end

        def retrieve_aliases(obj, name = nil)
          @names.filter { |k,v| k != name && v == obj.hash }.keys
        end
      end
    end
  end
end
