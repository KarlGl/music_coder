# basically an array of data of a fully rendered down sound.
class WaveData
# the data points in an Array of Float. range -1 to 1 unless you like distortion.
attr_accessor :dps
# Array containing blanks frames at the start as Integer at [0], end at [1]
attr_accessor :blanks
attr_accessor :out_file
def initialize(dps=Array.new,file=nil)
    @dps = dps.dup
    @blanks = [0,0]
    @out_file=file
end

#TODO
def included_blanks
end


#return the datapoints within a range of indexs.
def get(start, final=nil)
  final ||= dps.count
  WaveData.new dps.slice(start..final)
end

# fit to the size of #dps to len by removing or adding tailing points 
# fade_frames:: stop the annoying popping at end of sound by fading out this many frames
def fit_to(len, fade_frames=250)
  meant_to_be = len
  self.dps.pop(dps.count- meant_to_be) if meant_to_be < dps.count
  while meant_to_be > dps.count # too short
    self.dps.push 0
  end
  # stop the annoying popping
  if dps.count > fade_frames
    fade_frames.times do |i|
      dps[dps.count-1-i] *= i.to_f / fade_frames
    end
  end
  self
end

#duplicate the current data n times.
def dup(n=1)
  n.times{dps.concat(dps)}
  self
end

#return the value of a wave at the specifed progress 0 to 1
def interpolate(progress)
  progress *= dps.count # range from 0 to wavedata length.
  val = dps[progress.to_i] # truncate progress.
  #puts progress.to_i
  # now add the interpolation to the next point
  if (progress < dps.count-1) # avoid error on last point
    dif_x = progress.to_i+1 - progress # how far to next datapoint? 0 to 1
    dif_y = dps[progress.to_i+1] - dps[progress.to_i]
    interpolation = dif_x * dif_y
    val += interpolation
  end
  return val
end

# return num of #dps
def count
  dps.count
end

def add(array)
  self.dps+= array
  self
end

#appends Array data to dps
def +(data)
  self.dps+= data.dps
  self
end

#append silence to #dps. 
#frames:: duration of the silence in seconds
#default: one beat.
#val:: constant middle value in buffer. 
#default: 0 Range: -1 to 1
def silence(frames, val = 0)
  d=WaveData.new(Array.new(frames, val))
  self+d if frames > 0
  self
end

# combine my dps with WaveData wave.
# adding length if necessary.
def mix(wave)
  other = wave.dps
  longest = dps.count > other.count ? dps : other
  longest.each_with_index do |a,i|
    my_v = (dps[i].nil? ? 0 : dps[i])
    oth_v = (other[i].nil? ? 0 : other[i])
    dps[i] = my_v + oth_v 
  end
  self
end

end