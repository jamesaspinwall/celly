load 'state_network.rb'

class X
  include StateNetwork

  def t1
    associate('a', :a)
    associate('b', :b)
    mark('a',123)
  end

  def a(p)
    puts p
    ['b','bbb']
  end

  def b(p)
    puts p
    nil
  end

end