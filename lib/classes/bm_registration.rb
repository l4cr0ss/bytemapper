module Bytemapper
  module Classes
    class BM_Registration < Hash

      def initialize(obj = nil, name = nil, aliases = [], wrapped = false)
        super()
        self[:obj] = obj
        self[:name] = name
        self[:aliases] = aliases
        self[:wrapped] = wrapped
      end

      def obj
        self[:obj] 
      end

      def name
        self[:name]
      end

      def aliases
        self[:aliases]
      end

      def wrapped?
        self[:wrapped] = obj.nil? ? false : obj.is_a?(BM_Wrappable)
      end

      def inspect
        wrapped?
        super
      end
    end
  end
end
