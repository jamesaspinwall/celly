class State
  include StateNetwork

  attr_accessor :data

  def initialize
    super
    associate('a', :a)
    associate('b', :b)
    associate('c', :c)
  end

  def a(data)
    @output = ['a',data]
    nil
  end

  def b(data)
    @output = ['b',data]
    nil
  end

  def c(data)
    @output = ['c',data]
    nil
  end

end

