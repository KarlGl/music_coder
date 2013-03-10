# a consecutave sequence of morphable tones (TonePart)
# of varying lengths, and rate of morphs, played without gaps.
class Dist < Api 
  attr_accessor :dist
  def initialize    
    super
    @dist=SndDist.new
    @hits=HitSq.new
    @hits.add_parent self
    persist_hits
  end
  
  #add num TonePart to Snd at i's ToneSeq, with my #length as max.
  def make(num=1, i=0)
    snd(i).toneseq.make(num)
  end
  
  # delete another Dist
  def del todel
    @dist.snd.delete todel.dist
    self
  end
  # set the total length in frames
  def length= set
    @dist.len = set
    @dist.tss.each {|tss| tss.len = set }
    self
  end
  # get the total length in frames
  def length
    @dist.len
  end
  # delete all hits
  def clear_hits
    @hits.hits = []
    persist_hits
    self
  end
  # get a child
  def [] i
    child=@dist.get_children[i]
    raise "This Dist has no child at index #{i}. " +
      "It has #{branches} children." if child.nil?
    d=Dist.new
    d.dist=child
    d.make_hits
    d
  end
  # count children
  def branches
    @dist.get_children.count
  end 
  # getter for HitSq. Will persist any changes you make to it.
  def hits
    @hits
  end
  # getter for Snd. Will persist any changes you make to it.
  def snd i=0
    snd=Snd.new
    snd.add_parent self
    new=@dist.tss[i]
    raise "Dist has no sound at index #{i}. It has #{sounds} sounds." if new.nil?
    snd<< new
    snd
  end
  # make a new sound with len
  def make_sound
    snd=Snd.new
    snd.toneseq.len = @dist.len
    self<<snd
    self
  end
  # count sounds
  def sounds
    @dist.tss.count
  end
  # (internal use only) copy our hits down to the underlining object
  def persist_hits
    @dist.hits = hits.hits
    @dist.hits = [0.0] if hits.hits.count == 0
    self
  end
  protected
  # (internal use only) create our hits from the underlining object
  def make_hits
    @hits.hits = @dist.hits
    self
  end

  private  
  # adds a sound if it's valid to do so.
  def validate_snd! val
    raise "This Dist can't have sounds, it has children. " if branches > 0
    @dist.tss << val
    val.toneparts.each {|tp|
#      puts "RUNNING #{length / val.toneparts.count.to_f}"
      tp.max_frames = length / val.toneparts.count 
      
      }
  end
  # adds a dist if it's valid to do so
  def validate_dist! val
    raise "This Dist can't have children, it has sounds. " if sounds > 0
    @dist.add val
  end 
  # Add hits, sounds or other Dist to me.
  def add_single toadd
    case toadd
    when HitSq, Float, Integer
      @hits << toadd
      persist_hits
    when Snd
      validate_snd! toadd.toneseq
    when Dist
      validate_dist! toadd.dist
    else
      return false
    end
    true
  end
  # Delete hits, sounds or other dists from my lists.
  def del_single todel
    case todel
    when HitSq, Float, Integer
      @hits >> todel
      persist_hits
    when Snd
      @dist.tss.delete todel.snd
    when Dist
      @dist.snd.delete (todel.dist)
    else
      return false
    end
    true
  end
end

class Integer
  #shortcut to create a Dist with length. e.g. 10.Dist returns a new Dist with length of 10 frames already set.
  def Dist
    h=Dist.new
    h.length = self.to_i
    h
  end
end
class Float
  #shortcut to create a Dist with one hit in its #hits.
  #e.g. 0.1.Dist returns a new Dist with, a single hit at 0.1.
  def Dist
    h=Dist.new
    h<<self
    h
  end
end