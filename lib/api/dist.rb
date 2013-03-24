# a consecutave sequence of morphable tones (TonePart)
# of varying lengths, and rate of morphs, played without gaps.
class Dist < Api 
  attr_accessor :dist
  # will have a defult hit at 0 if it has a sound and no hits have been made.
  def initialize    
    super
    @dist=SndDist.new
    @hits=HitSq.new
    @hits.add_parent self
    persist_hits(true)
  end
  
  #return a new Dist with the same hits and length but not children or sounds.
  def copy
    out=Dist.new
    out.length = length
    out.clear_hits
    out.hits << hits
    out
  end
  
  #add children who have sounds that make a drum like sound
  #weight:: 0 is lowest drum, 1 is highest
  def drum weight, amp, f_range=0.0, tone_num = 1, layers=1
    layers.times do |i|
      self << Dist.new
      flay = last_born
      min_oc = 1
      max_oc = 5
      oran = max_oc - min_oc
      pos_num = scale_notes.count * oran #possible
      ind = (pos_num * weight).round
      oct_ind =  min_oc + ind / scale_notes.count
      log "drum notes #{ind % scale_notes.count} #{oct_ind}, weight #{weight}", 3
      freq = Note.new(scale_notes[ind % scale_notes.count], oct_ind).freq
      flay.drumify freq, amp/layers/2, f_range, tone_num #test
      
    end
    flay = self[0]
    self << flay.copy
    under_sound = last_born
    under_sound << Snd.new
    under_sound.snd.length = flay.snd.length
    under_sound.snd.freq = flay.snd.freq
    under_sound.snd.amp = amp/2.0
    under_sound.snd.fade
    under_sound.snd.tone.amp.exp = flay.snd.tone.amp.exp
    under_sound.clear_hits # to test
#     branches.times do |i| 
#       self[i].snd.amp=0 if i !=branches-1 # to test
#     end
  end
  
  #assumes an already existing Snd and HitSq, just makes the Snd more like a percussive instrument
  def drumify freq, amp, f_range, tone_num
    random_sound(freq, f_range, tone_num, amp)
    snd.toneseq.toneparts.last.do_all {|tone| 
      tone.fade
      tone.amp.rand_exp true #below linear
      }
  end
  #print hits for debugging
  def ph
    puts hits.hits.inspect
  end
  
  #add an Snd to self with some random properties
  def random_sound root_f, f_range, parts, amp, max_delay = 0.0
#    tone_num.times do |i|
      self << Snd.new
      delay = rand*max_delay
      1.times {delay*=rand}
      snd.toneseq.random(rand(parts).to_i, [true,false].sample, delay, amp, root_f+f_range*root_f, root_f-f_range*root_f)
      snd.toneseq.toneparts.each do |tp|
#        tp.do_all {|tone| tone.set_freq root_f}
#        range = root_f * f_range
#        tp.do_all {|tone| tone.set_freq_final root_f - range/2.0 + rand*range}
      end
#      last_born.clear_hits
#      last_born << delay
#    end
  end

  #give mel_layers children each with a unique melody in incrementing octaves.
  def random_melodies min_b_len, reps, mel_layers = 4, start_octave = 2, max_amp = 0.5, 
      seqs_max =0, chance = 0.4, random_del_chance = 0.25, max_b_mult=4
    mel_layers.times do |i|
      self << Dist.new 
      melody = last_born
      map = melody.Mapper
      map.random_melody min_b_len, reps, start_octave+i, chance, max_amp/mel_layers, rand(seqs_max).to_i, max_b_mult
      
      # each layer picks a few bars to delete every note from.
      to_del = []
      map.mapee(0).hits.count.times do |h|
        if rand < random_del_chance
          to_del << h
        end
      end
#      to_del = [1] #test
      map.each_dist do |d| 
        d[0].hits.delete_arr to_del
#        d[0].ph
      end
#      puts to_del
#      map.dist.branches.times {|j| todel << map[j] if j!=0 }
#      map.dist >> todel
    end
  end
    
  #sets the length of all children Dist to val
  def set_child_len val
    branches.times do |i|
      self[i].length = val
    end
  end
  
  #add num TonePart to Snd at i's ToneSeq, with my #length as max.
  def make(num=1, i=0)
    snd(i).toneseq.make(num)
  end
  
  #shortcut to create a Mapper, with Mapper#map_to= me
  def Mapper
    Mapper.new(self)
  end
  # delete another Dist at index ind
  def del ind
    @dist.snd.delete_at ind
    self
  end
  # set the total length in frames
  def length= set
    @dist.len = set.round
#    @dist.tss.each {|tss| tss.len = set }
    self
  end
  # get the total length in frames
  def length
    @dist.len
  end
  # delete all hits
  def clear_hits
    @hits.hits = []
    persist_hits
    self
  end
  # get a Dist child
  def [] i
    child=@dist.get_children[i]
    raise "This Dist has no child at index #{i}. " +
      "It has #{branches} children." if child.nil?
    d=Dist.new
    d.dist=child
    d.make_hits
    d
  end
  # get last child
  def last_born
    child=@dist.get_children.last
    d=Dist.new
    d.dist=child
    d.make_hits
    d
  end
  # get first child
  def first_born
    child=@dist.get_children.first
    d=Dist.new
    d.dist=child
    d.make_hits
    d
  end
  # count children (Dists only)
  def branches
    @dist.get_children.count
  end 
  # getter for HitSq. Will persist any changes you make to it.
  def hits
    @hits
  end
  # getter for Snd. Will persist any changes you make to it.
  def snd i=0
    snd=Snd.new
    snd.add_parent self
    new=@dist.tss[i]
    raise "Dist has no sound at index #{i}. It has #{sounds} sounds." if new.nil?
    snd<< new
    snd
  end
  # getter for Snd. Will persist any changes you make to it.
  def snd i=0
    snd=Snd.new
    snd.add_parent self
    new=@dist.tss[i]
    raise "Dist has no sound at index #{i}. It has #{sounds} sounds." if new.nil?
    snd<< new
    snd
  end
  # delete all Snd attached to this Dist
  def clear_snd
    @dist.tss = []
    self
  end
  # run on all sounds
  def snd_each
    sounds.times {|i|
      yield(snd i)
    }
    self
  end
  # count sounds
  def sounds
    @dist.tss.count
  end
  # (internal use only) copy our hits down to the underlining object
  def persist_hits(is_def = false)
    @dist.hits = hits.hits
    @dist.hits = [0.0] if is_def && hits.hits.count == 0
    self
  end
  protected
  # (internal use only) create our hits from the underlining object
  def make_hits
    @hits.hits = @dist.hits
    self
  end

  private  
  # adds a sound if it's valid to do so.
  def validate_snd! val
    raise "This Dist can't have sounds, it has children. " if branches > 0
    @dist.tss << val
    val.toneparts.each {|tp|
#      puts "RUNNING #{length / val.toneparts.count.to_f}"
      tp.max_frames = length / val.toneparts.count 
      
      }
  end
  # adds a dist if it's valid to do so. 
  def validate_dist! val
    raise "This Dist can't have children, it has sounds. " if sounds > 0
    @dist.add val
  end 
  # Add hits, sounds or other Dist to me.
  def add_single toadd
    case toadd
    when HitSq, Float, Integer
      @hits << toadd
      persist_hits
    when Snd
      validate_snd! toadd.toneseq
    when Dist
      if toadd.length == 0 #sets his length to mine if his is 0.
        toadd.length = length
      end
      validate_dist! toadd.dist
    else
      return false
    end
    true
  end
  # Delete hits, sounds or other dists from my lists.
  def del_single todel
    case todel
    when HitSq, Float
      @hits >> todel
      persist_hits
    when Snd
      @dist.tss.delete todel.snd
    when Dist
      @dist.snd.delete (todel.dist)
    when Integer
      del todel
    else
      return false
    end
    true
  end
end

class Integer
  #shortcut to create a Dist with length. e.g. 10.Dist returns a new Dist with length of 10 frames already set.
  def Dist
    h=Dist.new
    h.length = self.to_i
    h
  end
end
class Float
  #shortcut to create a Dist with one hit in its #hits.
  #e.g. 0.1.Dist returns a new Dist with, a single hit at 0.1.
  def Dist
    h=Dist.new
    h<<self
    h
  end
end