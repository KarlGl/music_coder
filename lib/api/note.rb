# A musical note. 
# E.g. A sharp in octave 3.
class Note
  # note without octave. from 0 to 11 starting at A ending in G#
  attr_accessor :note
  # octave, starts at 0, an 'A' in '5' is 440 hz
  attr_accessor :octave
  def initialize(note = 0, octave = 4)
    if note.class == String
      @note = Composer.note_m(note)
    else
      @note = note
    end
    @octave = octave
  end
  
  # returns a value up n semitones. (changes octave where necessary)
  def +(n = 1)
    i=0
    out = deep_copy
    while i < n do
      out = Note.new(out.note+1, out.octave)
      out = Note.new(0, out.octave+1) if out.note==12
      i+=1
    end
    out
  end
  # returns a value down n semitones. (changes octave where necessary)
  def -(n = 1)
    i=0
    out = deep_copy
    while i < n do
      out = Note.new(out.note-1, out.octave)
      out = Note.new(11, out.octave-1) if out.note==-1
      i+=1
    end
    out
  end

  #return the frequency (HZ) of a note.
  def freq
    raise "no note or oct given" if (!note || !octave)
    a=2 ** (octave.to_f-1)
    b=1.059463 ** note.to_f
    out = 27.5*a*b
    return out
  end

  # return true if this note has the same values as another note.
  def is_eql(other)
    vars_eql? other
  end

  #return a new Snd with its frequency set to this note.
  def Snd
    s=freq.Snd
    s
  end
end