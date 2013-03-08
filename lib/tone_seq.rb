# a sequence of TonePart that will play sequentially. These are highest level sounds without timing.
class ToneSeq
  #Array of TonePart
  attr_accessor :toneparts
  def initialize()
    @toneparts = []
    make(1)
  end
  def tonepart i=0
    @toneparts[i]
  end
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
  def len= set
    @toneparts.each {|tp|
      tp.max_frames = set / toneparts.count
      tp.frames = set / toneparts.count
    }
  end
  # add num TonePart to self, with it's max allowable frames as len.
  def make(num,len=0)
  #  puts "ToneSeq: making #{num} parts in tone"
    num.times { self.toneparts.push TonePart.new((len.to_f/num).round) }
  end

  def render(parent_hit_index=nil)
    files=FileList.new
    toneparts.each do |tp|
      files.write tp.out(parent_hit_index).out
    end
    files
  end

end