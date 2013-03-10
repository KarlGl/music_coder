# a pattern of hits to time a Snd
class HitSq < Api
  attr_accessor :hits
  def initialize
    @hits=[]    
    super
  end
  private   
  # delete value
  def del_single todel
    @hits.delete todel.to_f
    self
  end
  def validate! input
    val = input.to_f
    raise "Hit is too high #{input}. Range is 0 to 1." if val > 1.0
    raise "Hit is too low #{input}. Range is 0 to 1." if val < 0.0
    
    #dup?
    a = hits.dup
    a << val
    if a.uniq.length != a.length
      log "Warning: skipping duplicate hit.", 3
    else
      @hits << val
    end
    @parents.each {|par| par.persist_hits}
  end
  # Add hits.
  def add_single toadd
    case toadd
    when Float, Integer
      validate! toadd
    when HitSq
      toadd.hits.each { |val| validate! val }
    else
      false
    end
  end
  public
  #Adds into #hits.
  #possible_hits:: number of hits that can occur. Must be int
  #chance:: chance a hit will be included. range: 0 to 1
  #ignore_first:: skip the first n possible hits
  #ignore_first:: skip the last n possible hits
  #e.g. disperse_hits(16,1,4,4) makes this pattern [-|-|-|-|+|+|+|+|+|+|+|+|-|-|-|-|]
  def eqly_spaced(possible_hits = 4, chance = 1, ignore_first=0, ignore_last=0)
    possible_hits.times do |i|
      if ignore_first <= i && possible_hits - ignore_last > i
        delay = i/possible_hits.to_f
        @hits.push delay if (rand + chance >= 1)
      end
    end
    self
  end 
  #return number of hits
  def count
    hits.count
  end
  # Shift all hits by val, no validation atm
  def move(val=0.5)
    self.hits.collect! {|x| 
      z = (x+val)
      z = (z*1000).round / 1000.0 # rounding
      x = z
    } # delay all
    self
  end
end
# shortcut e.g. 0.HitSq for the most used, a single hit at 0
class Integer
  def HitSq
    h=HitSq.new
    h<<self
    h
  end
end
# shortcut e.g. 0.5.HitSq
class Float
  def HitSq
    h=HitSq.new
    h<<self
    h
  end
end
class Array
  def HitSq
    h=HitSq.new
    h<<self
    h
  end

  #return a new HitSq. a shortcut for HitSq.new.move(val)
  def move(val)
    self.collect! {|x| x=x+val} # delay all
    h=HitSq.new
    h<<self
    h
  end
end
class Integer
  #a shortcut. e.g. 4.eqly_spaced gives you HitSq#eqly_spaced(4)
  def eqly_spaced(chance = 1, ignore_first=0, ignore_last=0)
    h=HitSq.new
    possible_hits=self
    h.eqly_spaced(possible_hits, chance, ignore_first, ignore_last)
  end
end