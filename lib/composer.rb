# contains the functions a music composer needs.
# all functions are related to music instead of audio.
class Composer
class << self
  #beats per minute of the track. (Set this first thing in your input file)
  attr_accessor :bpm
  #fames per second
  attr_accessor :samplerate
end
def self.chords
  all = Hash.new
  #Triads
  all["maj"] = [4, 7] # major
  all["min"] = [3, 7] # minor
  all["aug"] = [4, 8] # augmented
  all["dim"] = [3, 6] # diminished

  #Seventh chords
  all["dim7"] = [3, 6, 9] # diminished 7th
  all["mm7"] = [3, 7, 11] # major minor 7th
  all["min7"] = [3, 7, 10] # minor 7th
  all["dom7"] = [4, 7, 10] # dominant 7th
  all["maj7"] = [4, 7, 11] # major 7th
  # half diminished
  # augmented
  # augmented major

  all["sus4"] = [5, 7]
  all["sus2"] = [2, 7]
  all["6"] = [4, 7, 9]
  all["m13"] = [2, 4, 7, 9, 11]
  all["9#11"] = [2, 4, 6, 7, 10]
  all["tonic"] = [6]
  all
end

def self.scales
  all = Hash.new
  all["major"] = [2,4,5,7,9,11] # 7 total
  all["minor"] = [2,3,5,7,8,10]
  all["chromatic"] = *(1..10) #splat
  #all["ionian"] = [2,4,5,7,9,11]
  all["dorian"] = [2,3,5,7,9,10]
  all["phygian"] = [1,3,5,7,8,10]
  all["lydian"] = [2,4,6,7,9,11]
  all["mixolydian"] = [2,4,5,7,9,10]
  #all["aeolian"] = [2,3,5,7,8,10]
  all["locrian"] = [1,3,5,6,8,10]
  all
end

#return an array of notes from a array of notes with an offset, adding the root note at the start.
#e.g. ([1,10,2],2) outputs [2,3,0,4] (root note is 2, 10 + 2 becomes 0, 1 + 2 is 3 etc)
def self.get_notes(notes_ar, offset = 0)
  notes = [0] + notes_ar
  #offset
  notes.collect! do |val|
    if offset >= 0
      val+offset>11 ? val+offset-12 : val+offset
    else
      val+offset<0 ? val+offset+12 : val+offset
    end
  end
  notes
end

# convert beats to seconds
# @beat: the beat denominator. ie 4 means 4 beats, .125 means 1 8th beat.
def self.beat(beats)
  bps = (self.bpm/60.0)
  return (beats) * (1.0/bps) * self.samplerate.to_f
end

#return set of chord names of chords that fit in the scale, offset upward by offset notes.
def self.matching_chords(scale = "major", offset = 0)
  all = Composer.chords
  scale_n = [0] + Composer.scales[scale] # not offset at all
  out = []
  all.each do |chord|
    name = chord[0]
    notes=Composer.get_notes all[name], offset # lookup chord with name and offset
    out.push name if (scale_n&notes).sort==notes.sort # if all notes are in scale
  end
  out
end

#convert a note as a string to midi value
#note:: range: "A" to "G#". No a flats.
def self.note_m(note)
  val=nil
  note.upcase!
  case note
  when 'A'
    val=0
  when 'A#'
    val=1
  when 'B'
    val=2
  when 'C'
    val=3
  when 'C#'
    val=4
  when 'D'
    val=5
  when 'D#'
    val=6
  when 'E'
    val=7
  when 'F'
    val=8
  when 'F#'
    val=9
  when 'G'
    val=10
  when 'G#'
    val=11
  else
    raise "Unknown note name recieved."
  end
  val
end

end