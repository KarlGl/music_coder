# a consecutave sequence of morphable tones (TonePart)
# of varying lengths, and rate of morphs, played without gaps.
class Snd < Api
  def initialize
    @snd=ToneSeq.new
    super
  end
  
  def tonepart i=0
    @snd.tonepart i
  end  
    
  def tone i=0, j=0
    @snd.tonepart(j).tone(i)
  end
  # set length
  def length= val
    @snd.frames=val
    self
  end
  def t i=0
    child = @snd.toneparts[i]
    raise "This Snd has no tone at index #{i}. " +
      "It has #{count} tones." if child.nil?
    child
  end
  # number of tones
  def count
    snd.toneparts.count
  end
  def fade
    snd.fade
  end
  attr_accessor :snd
  private   
  # Add hits, sounds or other dists to me.
  def add_single toadd
    case toadd
    when Snd
      @snd = toadd.instance_variable_get(:@snd)
    else
      return false
    end
    true
  end
  
end

class Fixnum
  def Snd
    a = Snd.new
    a.t.freq = self
    a
  end
end
class Float
  def Snd
    a = Snd.new
    a.t.freq = self
    a
  end
end