# a sequence of TonePart that will play sequentially. These are highest level sounds without timing.
class ToneSeq
  #Array of TonePart
  attr_accessor :toneparts
  #when joined, a tone sequence makes the end of each tone 
  #the same as the start of the next one.
  #this creates a smooth sound.
  #todo
  def join
    toneparts.count.times do |i|
      # if more after me, do it
      if i+1 < toneparts.count
        me = toneparts[i].tone(0)
        nxt = toneparts[i+1].tone(0)
        me.detail.final = nxt.detail.start
        me.saturations.final = nxt.saturations.start
        me.set_freq_final( nxt.freq.start, false)
        me.set_amp_final( nxt.amp.start, false)
        
        me = toneparts[i].tone(1)
        nxt = toneparts[i+1].tone(1)
        me.detail.final = nxt.detail.start
        me.saturations.final = nxt.saturations.start
        me.set_freq_final( nxt.freq.start, false)
        me.set_amp_final( nxt.amp.start, false)
      end
    end
  end
  
  def initialize()
    @toneparts = []
    make(1)
  end
  
  def do_all
    toneparts.each do |tp|
      yield tp
    end
  end
  
  #random everything
  def random extra_detail = 5, even = false, delay=0, start_amp = 0.5, 
             max_f = 2000, min_f = 120, max_sat=0.8, min_detail=20
    make(extra_detail) # sets the lens evenly.
    frames_left = self.frames - self.frames.to_f*delay #- extra_detail+1 #minus a little so it must have 1 frame
    toneparts.count.times do |i|
      # sets the lens randomly.
      portion = frames_left * rand
#      puts "portion #{portion}"
      if i == toneparts.count
        portion = frames_left
      end
      frames_left -= 1+portion
      toneparts[i].tone.frames = 1+portion if !even
      #
      toneparts[i].tone.rand_sat_both 3, max_sat
      toneparts[i].tone.rand_freq_both(min_f, max_f)
      toneparts[i].tone.rand_detail_both min_detail
      max_amp = start_amp
      if i>0 # it can't be higher than the last amp
        max_amp = toneparts[i-1].tone.amp.start
      end
      toneparts[i].tone.rand_amp_both max_amp, max_amp * 0.75 # not much lower
      
      tp = toneparts[i]
      tp.two_tones
      tp.tone(1).rand_sat_both 3, max_sat
      tp.tone(1).rand_freq_both(min_f, max_f)
      tp.tone(1).rand_detail_both min_detail
      
    end
    join
  end
  
  #return the total frames of all toneparts combined.
  def frames
    total=0
    toneparts.each {|tp| total+=tp.tone.frames}
    total
  end
  def tonepart i=0
    @toneparts[i]
  end
  #set the frames of each tonepart to val.
  def frames= val
    @toneparts.each {|tp| tp.frames = val}
  end
  
  def fade
    @toneparts.each {|tp| 
      tp.tone(0).fade
      tp.tone(1).fade
      }
    self
  end
  #set length of all toneparts to equally add to set when combined.
  def len= set
    @toneparts.each {|tp|
      tp.max_frames = set / toneparts.count
      tp.frames = set / toneparts.count
    }
  end
  #add num TonePart to self, with it's max allowable frames as #frames.
  def make(num)
  #  puts "ToneSeq: making #{num} parts in tone"
    num.times { self.toneparts.push TonePart.new }
    self.len= (frames.to_f).round
  end

  #compile all data on all #toneparts, then write it to file(s)
  def render(parent_hit_index=nil)
    data = WaveData.new
    toneparts.each do |tp|
      data + tp.out(parent_hit_index).out
    end
    files= FileList.new
    files.write data
    files
  end
  
  #reduce amp of all tones by this val
  def amp_reduce val
    toneparts.each { |tp| tp.amp_mult(1.0/val) }
  end

end