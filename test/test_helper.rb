require 'minitest'
require 'minitest/autorun'
require 'bytemapper'
require 'byebug'

module TestHelpers
  BM_Type = ::Bytemapper::Classes::BM_Type
  BM_Shape = ::Bytemapper::Classes::BM_Shape
  BM_Wrappable = ::Bytemapper::Mixins::BM_Wrappable

  def setup
    @registry = BM_Wrappable.class_variable_get('@@registry')
    @registry.flush
  end

end
