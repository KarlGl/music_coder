# one tone or two tones that can be morphed between eachother
class TonePart
#Fader
attr_accessor :tones
attr_accessor :max_frames
attr_accessor :tone_single
attr_accessor :tone_count
def initialize(m=0,t1=Tone.new,t2=Tone.new)
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

# set #max_frames and frames on each Tone if 0.
def max_frames= m
  @max_frames = m
  # set if none
  is_frames_set = true
  is_frames_set = false if tone_count == 1 && tone.frames == 0
  is_frames_set = false if tone_count > 1 && tone(0).frames == 0 && tone(1).frames == 0
  self.frames = m if !is_frames_set
end

def frames= val
  tone(0).frames = val
  tone(1).frames = val
end

# get main freq
def freq
  tone.freq.start
end
#get main note
def note
  tone.note
end

#set freq of start and final to val
def freq= val
  tone(0).freq.start = val
  tone(1).freq.start = val
end

#set freq of start and final to Note.freq
#val:: the note to call freq on
def note= val
  tone(0).freq.start = val.freq
  tone(1).freq.start = val.freq
end

# multiply all amplitudes (Tone.amp) by factor.
def amp_mult(factor)
  tone(0).amp.start *= factor
  #puts "amp: #{tone.tones.start.amp.start}"
  tone(0).amp.final *= factor
  if tone_count > 1
    tone(1).amp.start *= factor
    tone(1).amp.final *= factor
  end
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
