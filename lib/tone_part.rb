# two tones that can be faded between
class TonePart
#Fader
attr_accessor :tones
attr_accessor :max_frames
attr_accessor :tone_single
attr_accessor :tone_count
def initialize(m,t1=Tone.new,t2=Tone.new)
  @tones = Fader.new(t1,t2,0)
  @max_frames = m
  self.frames = m
  @tone_count = 1
  @tone_single = t1
end

def tone i=0
  return tone_single if tone_count == 1
  i==1 ? @tones.final : @tones.start
end

def max_frames= m
  @max_frames = m
  # set if none
  self.frames = m if @tones.start.frames == 0 && @tones.final.frames == 0
end

def frames= val
  @tones.start.frames = val
  @tones.final.frames = val
end

# get main freq
def freq
  tones.start.freq.start
end
#get main note
def note
  tones.start.note
end

def freq= val
  @tones.start.freq.start = val
  @tones.final.freq.start = val
end

def amp_mult(factor)
  tones.start.amp.start *= factor
  #puts "amp: #{tone.tones.start.amp.start}"
  tones.start.amp.final *= factor
  tones.final.amp.start *= factor
  tones.final.amp.final *= factor
end


#return tone with mixed settings of tones#start with tones#final.
#into:: how much of the final tone is mixed in. 0 is none. Range: 0 to 1
def out(into)  
  return tone_single if tone_count == 1
  
  out = tones.start.deep_copy

  #wave
  range = tones.final.wave.detail.start - tones.start.wave.detail.start
  out.wave.detail.start += range*into
  range = tones.final.wave.detail.final - tones.start.wave.detail.final
  out.wave.detail.final += range*into
  range = tones.final.wave.saturations.start - tones.start.wave.saturations.start
  out.wave.saturations.start += range*into
  range = tones.final.wave.saturations.final - tones.start.wave.saturations.final
  out.wave.saturations.final += range*into
  
  #frames
  range = tones.final.frames - tones.start.frames 
  out.frames += range*into
  # puts "frames range #{out.frames}"

  #freq
  range = tones.final.freq.start - tones.start.freq.start
  out.freq.start += range*into
  range = tones.final.freq.final - tones.start.freq.final
  out.freq.final += range*into
  range = tones.final.freq.exp_no_nil - tones.start.freq.exp_no_nil
  out.freq.exp = out.freq.exp_no_nil + range*into

  #amp
  range = tones.final.amp.start - tones.start.amp.start
  out.amp.start += range*into
  range = tones.final.amp.final - tones.start.amp.final
  out.amp.final += range*into
  range = tones.final.amp.exp_no_nil - tones.start.amp.exp_no_nil
  out.amp.exp = out.amp.exp_no_nil + range*into

  out
end

end
