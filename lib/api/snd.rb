# a consecutave sequence of morphable tones (TonePart)
# of varying lengths, and rate of morphs, played without gaps.
class Snd < Api
  def initialize
    @snd=ToneSeq.new
    super
  end
  
  #assumes one tone only
  def freq= val
    tone.set_freq val
  end
  
  #freq of first tone only
  def freq
    tone.freq.start
  end
  
  def amp= val
    toneseq.do_all {|tp| 
      tp.do_all {|tone| 
        tone.amp.start = val
        tone.amp.final = 0.0
        }
      }
  end
  
  # return its TonePart.
  def tonepart i=0
    child = @snd.tonepart i
    raise "This Snd has no tone at index #{i}. " +
      "It has #{count} tones." if child.nil?
    child
  end  
    
  # return its TonePart at j and thats Tone at i.
  def tone i=0, j=0
    @snd.tonepart(j).tone(i)
  end
  # set length
  def length= val
    @snd.frames=val
    self
  end
  # get length
  def length
    @snd.frames end
  # number of tones
  def count
    toneseq.toneparts.count
  end
  #ensure all tones fade out to 0 as the final volume. 
  #note: re-run after changing amp.
  def fade
    toneseq.fade
  end
  #return my ToneSeq
  def toneseq
    @snd
  end
  private   
  # Add hits, sounds or other dists to me.
  def add_single toadd
    case toadd
    when Snd
      @snd = toadd.toneseq
    when ToneSeq
      @snd = toadd
    else
      return false
    end
    true
  end
  
end

class Integer
  #same as Float#Snd.
  def Snd
    a = Snd.new
    a.tonepart.freq = self
    a
  end
end
class Float
  #return a new Snd with its frequency set to the value. 
  #e.g. 500.4.Snd
  def Snd
    a = Snd.new
    a.tonepart.freq = self
    a
  end
end