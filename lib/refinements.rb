module Refinements
  refine StringIO do
    def peek
      string[pos]
    end

    def extract(offset, length)
      prev = pos
      seek(offset)
      bytes = read(length)
      seek(prev)
      bytes
    end
  end

  refine StringIO.singleton_class do
    def from(obj)
      obj = obj.nil? ? '' : obj
      obj = obj.is_a?(StringIO) ? obj : new(obj)
      obj.string.force_encoding(Encoding::ASCII_8BIT)
      obj
    end
  end
end
