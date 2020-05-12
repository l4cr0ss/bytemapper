require 'minitest'
require 'minitest/autorun'
require 'bytemapper'
require 'byebug'

module TestHelpers
  BM_Type = ::ByteMapper::Classes::BM_Type
  BM_Shape = ::ByteMapper::Classes::BM_Shape
  BM_Wrappable = ::ByteMapper::Mixins::BM_Wrappable

  def setup
    @registry = BM_Wrappable.class_variable_get('@@registry')
    @registry.flush
  end
end
