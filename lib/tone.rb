# a sound to be played.
# * a Chord is made of these.
class Tone
# duration of the tone in seconds.
attr_accessor :frames
# Wave for one single wave in the tone. (Repeated for #frames)
attr_accessor :wave
# Fader for amplitude or volume (loudness), 0 to 1. 0 is silent.
# Fader.final is relative to Fader.start.
attr_accessor :amp
# Fader for tone frequency (HZ, cycles/second).
# Fader.final is relative to Fader.start.
attr_accessor :freq

# args:: a Hash containing attributes
def initialize(args = nil)
  @frames = 0
  @wave = Wave.new
  @amp = Fader.new(0.5,0,MathUtils::GR)
  @freq = Fader.new(220,0,MathUtils::GR)
  init_hash(args)
end

def saturation= val
  wave.saturation= val
end
def saturations
  wave.saturations
end
def detail
  wave.detail
end
# returns a buffer with a chord (collection of Tone whos collective amplitude equals
# the amplitude set in tone) in #wd. one tone on each element
# name:: String containing the chord name. Range, strings in Composer.chords
# tone:: Tone settings to use for each tone within the chord. Tone#freq#start
# will be ignored since we are using the note.
# element:: Element to save the used tones and notes to.
def chord(note, name, element)
  out=Buffer.new
  chrs=Composer.chord_notes note.note, name
  notes_total = chrs.count
  chrs.each_with_index do |v,i|
    ltone = deep_copy
    lamp = 1.0/notes_total # lower vol of each tone
    ltone.amp.start *= lamp # lower vol of each tone
    ltone.amp.final *= lamp # lower range of vol
      # use a reduced amplitude. (by tones in chord).
      # mulitplied by givin amplitude
    realnote = note+v
    ltone.note= realnote # set to right freq
    
    out.push ltone.out(i,notes_total)
    element.add_t ltone
    element.notes.push realnote
  end
  out
end

# output the WaveData for a full tone (chirp). All sound created flows into this atm.
# freq_exp:: default 0. 0 means linear. higher means it reachs the frequency at the end of it's range later.
def out
  # puts "out amp: #{amp.start}"
  buffer_len = frames
  inc_x = 0.0
  data = WaveData.new
  lfreq = freq.start
  lamp = amp.start
  wave_exp = wave.detail.exp
  freq_exp = freq.exp
  amp_exp = amp.exp
  wave_into=0
  while data.dps.count < buffer_len do
    wave_data = wave.out(lfreq, lamp, wave_into)
    data + wave_data
    inc_x += wave_data.count
    x = (inc_x.to_f / buffer_len)

    #freq
    freq_multiplier = x # when exp is off
    #fade exponentially if on.
    freq_multiplier = x ** (1.0 /((1.0/freq_exp)*x)) if freq_exp
    lfreq = freq.start + freq_multiplier*freq.final

    #amp
    amp_multiplier = x # when exp is off
    #fade exponentially if on.
    amp_multiplier = x ** (1.0 /((1.0/amp_exp)*x)) if amp_exp
    lamp = amp.start + amp_multiplier*amp.final

    #wave
    wave_into = x # when exp is off
    #fade exponentially if on.
    wave_into = x ** (1.0 /((1.0/wave_exp)*x)) if wave_exp

  end
  data.fit_to buffer_len
  data
end

# setting it absolute
def set_freq_final_no_relative(final)
  dif=final - freq.start
  freq.final=dif
end

# set #freq based off a Note
def note=(note)
  freq.start = note.freq
end
def note_end=(note)
  # freq.final = note.freq
end

# return the note closest to the set frequency
def note
  out = Note.new
  fre = freq.start
  linear_frequency = Math.log(fre/220.0,2.0) + 4
  # puts "linear_frequency #{linear_frequency}"
  out.octave= ( linear_frequency ).floor
  cents = 1200.0 * (linear_frequency - out.octave)
  not_wrap = (cents / 99.0)
  # puts "note no wrap #{not_wrap}"
  out.note = not_wrap.floor % 12
  out
end

# make it end with an amlitute of 0 (complete fade out). 
def fade
  amp.final = -amp.start
  self
end


end