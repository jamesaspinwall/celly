module StateNetwork
  attr_accessor :labels, :base, :associations, :meths, :network, :output

  def initialize
    @labels = []
    @base = 0
    @associations = []
    @meths = []
    @network = 0
    @data = []
    @output = []
  end

  def to_fun(label)
    bin = to_bin(label)
    pos = @associations.index(bin)
    @meths[pos]
  end

  def to_bin(label)
    case label
      when Array
        compose =0
        label.each do |label|
          compose |= to_bin(label)
        end
        compose
      when String
        pos = @labels.index(label)
        if pos.nil?
          pos = @labels.length
          @labels << label
        end
        1 << pos
    end

  end


  def associate(label, meth=nil)
    @associations << to_bin(label)
    @meths << meth
  rescue => e
    raise e
  end

  def mark(label, data=nil)
    case label
      when String
        pos = @labels.index label
        @data[pos] = data
        @network |= to_bin(label)
      when Array
        if data.nil?
          label.each do |label, data|
            mark(label, data)
          end
        end
    end
    self
  end

  def unmark(label)
    pos = @labels.index label
    @network &= ~to_bin(label)

  end

  def fire
    @output = []
    changed = true
    returns = []
    while changed do
      changed = false

      to_run = []
      new_network = @network
      pos = 0
      @associations.each do |association|
        if (@network & association) == association
          new_network &= ~association
          i = 0
          to_data = []
          @labels.length.times do
            if (association & 1) == 1
              to_data << @data[i]
            end
            i += 1
            association >>= 1
          end
          to_run << [@meths[pos], to_data]
        end
        pos += 1
      end
      to_run.each do |fun, data|
        ret = fun.is_a?(Proc) ? fun.call(data) : send(fun, *data)
        unless ret.nil?
          returns << ret
          changed = true
        end
      end
      @network = new_network
      returns.each do |label, data|
        mark label, data
      end
      returns = []
    end
    @output
  end

  def assert(a, b)
    unless a == b
      puts "Error: #{a} != #{b}"
    else
      puts "OK #{a.inspect}"
    end
  end


  def fire_old
    fired = []
    size = @associations.size
    i=0
    while i < size
      if get(@associations[i][0]) # if the inputs satisfies
        fired << @associations[i][1] #fire
        send(@associations[i][1])
        reset(@associations[i][0])
        i=0 # restart scan
      else
        i += 1
      end
    end
    fired
  rescue => e
    raise e
  end

  def set(label)
    case label
      when Symbol
        @base |= (2 ** pos(label))
      when Array
        label.each do |s|
          @base |= (2 ** pos(s))
        end
    end
  rescue => e
    raise e
  end


  def reset(label=nil)
    case label
      when Symbol
        @base &= (~(2 ** pos(label)))
      when Array
        label.each do |s|
          @base &= (~(2 ** pos(s)))
        end
      when NilClass
        @base = 0
    end
  rescue => e
    raise e
  end

  def get(label=nil)
    case label
      when Symbol
        @base & (2 ** pos(label)) > 0
      when Array
        label.all? do |s|
          @base & (2 ** pos(s)) > 0
        end
      when NilClass
        ret = []
        @labels.each_with_index do |label, i|
          ret << label if @base & (2 ** i) > 0
        end
        ret
    end
  rescue => e
    raise e
  end

  def pos(label)
    ret = (@labels.index(label))
    if ret.nil?
      raise "#{label} not found"
    end
    ret
  end

end

if true

  class X
    include StateNetwork

    def initialize
      super
    end

    def a(data)
      @output << ['a', data]
      ['b', 777]
    end

    def b(data)
      @output << ['b', data]
      ['c', 888]
    end

    def c(data)
      @output << ['c', data]
      nil
    end

    def test
      associate('a', :a)
      associate('b', :b)
      associate('c', :c)
      associate('buffer', :buffer)
      mark('a', 666)

      assert [["a", 666], ["b", 777], ["c", 888]], fire
    end
  end

  class Y
    include StateNetwork

    def initialize
      super
    end

    def a(data)
      @output << ['a', data]
      nil
    end

    def b(data)
      @output << ['b', data]
      nil
    end

    def c(data)
      @output <<['c', data]
      nil
    end

    def test
      associate('a', :a)
      associate('b', :b)
      associate('c', :c)
      associate('buffer', :buffer)
      mark('a', 666)
      mark('b', 777)
      mark('c', 888)

      assert [["a", 666], ["b", 777], ["c", 888]], fire
    end
  end

  class Z
    include StateNetwork

    def initialize
      super
    end

    def a(data)
      ['c', data]
    end

    def b(data)
      ['d', data]
    end

    def cd(c, d)
      @output << [['c', c], ['d', d]]
      nil
    end

    def test
      associate('a', 'a')
      associate('b', ->(data){['d', data]})
      associate(['c', 'd'], :cd)
      mark([['b', 777],['a', 666]])
      assert [[["c", 666], ["d", [777]]]], fire
    end
  end

  class V
    include StateNetwork

    def initialize
      super
    end

    def a(data)
      ['b', data]
    end

    def b1(data)
      @output << ['b1', data]
      nil
    end

    def b2(data)
      @output << ['b2', data]
      nil
    end

    def test
      associate('a', :a)
      associate('b', :b1)
      associate('b', :b2)

      assert [["b1", 666], ["b2", 666]], mark('a', 666).fire
    end
  end


  X.new.test
  Y.new.test
  Z.new.test
  V.new.test
end
