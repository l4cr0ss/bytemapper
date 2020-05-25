module Bytemapper
  module BM_Wrappable

    # Classes including BM_Wrappable get registered here.
    @@wrappers = []

    def self.included(klass)
      @@wrappers << klass
    end

    # Wrap the given object as the concrete type.
    #
    # @param obj [Hash, Array] the object to be wrapped.
    # @param name [String, Symbol] the name to register the obj.
    def self.wrap(obj, name = nil)

    end
  end
end
