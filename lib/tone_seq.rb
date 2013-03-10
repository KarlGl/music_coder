# a sequence of TonePart that will play sequentially. These are highest level sounds without timing.
class ToneSeq
  #Array of TonePart
  attr_accessor :toneparts
  def initialize()
    @toneparts = []
    make(1)
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
      tp.tones.start.fade
      tp.tones.final.fade
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

end