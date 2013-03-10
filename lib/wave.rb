#a waveform. this is looped to create a Tone.
class Wave
# stores the detail amount in a #Fader.start. nil means use sin wave during generation.
# Fader.start is the main 
# Fader.final is at the end. nil means same as wave start
attr_accessor :detail
#saturation effect (a random fluctuation on each data point to the cycle).
#degree:: The ammount of saturation. Higher is more, 0 is none. range: 0 to 1
attr_accessor :saturations
# hack to dramatically speed it up when on.
attr_accessor :cache_wave, :old_wave

def initialize(start=512,final=512,exp=0)
  @detail = Fader.new(start, final, exp)
  @saturations = Fader.new(0,0,0)
  @cache_wave=Array.new(2)
  @old_wave = nil#Wave.new # so false first time with is_eql
end

def saturation= val
  saturations.start = val
  saturations.final = val
end

#return WaveData of data for a single wave cycle
#len:: length in frames
#amp:: amplitude or volume (loudness), 0 to 1. 0 is silent
#wave_into:: how much of the final wave data is used this time. range: 0 to 1.
# 
def out(freq, amp = 1, wave_into = 1)
  final=WaveData.new
  start=WaveData.new
  if is_eql old_wave
#    puts "using cahce"
    start = cache_wave[0]
    final = cache_wave[1]
  else
#    puts "not using cahce"
    self.cache_wave=[nil,nil]
    self.old_wave=self.dup
    self.cache_wave[0] =WaveData.new(MathUtils.sinwave(detail.start, saturations.start))
    self.cache_wave[1] =WaveData.new(MathUtils.sinwave(detail.final, saturations.final))
    start = cache_wave[0]
    final = cache_wave[1]
  end

  data = []
  len = Composer.samplerate / freq
  
  len.to_i.times do |i|
    progress=i.to_f/len  # from 0 to 1
    if (detail.start > 0)
      val = start.interpolate progress
      # merging two waveforms
      if (detail.final > 0)
        val2 = final.interpolate progress
        val_range = val2-val
        val = val + val_range*wave_into
      end
    else # normal sign wave
      raise "Error, wave detail isn't > 0"
      # val = Math.sin(2.0*Math::PI*progress)
    end
    # puts "amp #{amp}, val #{val}"
    val *= amp # reduce volume by this
    data[i] = val
  end
  # puts "--> values: #{data.join(', ')}"
  result=WaveData.new(data)
  return result
end

def is_eql(other)
  vars_eql?(other, ['@detail','@saturations'])
end

end