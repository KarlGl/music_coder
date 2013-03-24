#a mapper is a collection of Dist all as long as a Dist being mapped too,
#each of these Dist have a child who is getting "mapped" with hits across that length.
#everything that you need a mapper for can be
#done without one but it is handy, since it is a common patten.
class Mapper < Api
  #the main Dist containing all mappings
  attr_accessor :dist
  def initialize(map_to_dist=nil)
    @dist=Dist.new 
    @len=0
    self.map_to= map_to_dist if !map_to_dist.nil?
  end
  #so that no mapees are a Dist, they are only Snd. it flattens the tree of Dist
  def flatten
    todel = []
    count.times do |i|
      mpe = mapee(i)
      mpe.branches.times do |j|
        self << mapee(i).copy
        mapee_last << mpe[j].snd
      end
      todel << mapee(i)
    end
    dist >> todel
  end
  
  # trim some hits
  def reduce_hits
#    mapee(0).hits.delete_random(0.08) no work
    mapee(0).hits.trim_both(0.10)
    mapee(1).hits.trim_both(0.25) if count > 1
    mapee(2).hits.trim_start(0.34) if count > 2
  end
  
  def random_melody min_b_len, reps =4, oct = 3, chance = 0.75, amp=0.5, seqs=0, max_b_mult = 4
    self.length = length.to_f / reps
    random_melody_hits(min_b_len, max_b_mult)
  #  map.random_melody_hits(beat(1.0).to_f, 0, 1.0) # max len is beat
    delete_rand_dist 1.0 - chance
    random_melody_notes(oct,rand(scale_notes.count))

    count.times do |i|
      freq = mapee(i).snd.tone.freq.start
      mapee(i).snd.toneseq.random(seqs, true, 0, amp)
      mapee(i).snd.toneseq.toneparts.each do |tp|

        tp.tone(0).set_freq freq
        tp.tone(1).set_freq freq
        tp.tone(0).set_freq_final 0
        tp.tone(1).set_freq_final 0

#        tp.max_frames = len
        # rand len
        extra = 0.5 + rand
        extra = 1.0 if extra > 1
        tp.tone(0).frames = tp.tone.frames * extra
        extra = 0.5 + rand
        extra = 1.0 if extra > 1
        tp.tone(1).frames = tp.tone.frames * extra
     end
    end

    extend(reps)
    transfer_hits
  end

  def random_melody_hits(min_inc, max_inc_mult)
    upto = 0
    len = @len
    while upto < len
      next_len =(min_inc*(2**(rand(max_inc_mult).to_i))).round# next len
      if upto + next_len > len # limit to len
        next_len = len - upto
      end

      self << next_len.Dist
      last.clear_hits
      last << upto.to_f / len
      upto += next_len #inc
    end
  end
  
  #call #random_melody_hits first.
  def random_melody_notes(start_oct = 3, start_note = 0, increments = [1,0,-1])
    keys = scale_notes()
    note_index = start_note
    first_note = Note.new(keys[note_index % keys.count], start_oct)
    count.times do |i|
      key = keys[note_index % keys.count]
      used_note = first_note + note_index
      mapee(i) << Note.new(key, used_note.octave).Snd
#      puts Note.new(key, used_note.octave).inspect

      #inc
      dinc = increments.sample
      note_index += dinc
    end
  end
  
  
  #extend length by mult and repeat all childs hits.
  def extend mult
    self.length = @len*mult
    dist.branches.times do |i|
      hits = self[i].hits
      self[i].clear_hits
      mult.times do |j|
        new_hits = HitSq.new
        new_hits << hits
        new_hits * (1.0/mult)
        new_hits + (j.to_f / mult)
        self[i] << new_hits
      end
    end
  end
  
  def transfer_hits
    dist.branches.times do |i|
#      hits = mapee(i).hits
#      len = mapee(i).length
#      
      mapee(i).clear_hits
      mapee(i).length = @len
      mapee(i) << self[i].hits
      self[i].clear_hits
      self[i] << 0.0
#      mapee(i).ph
    end
  end
  
  def delete_rand_dist chance
    del = []
    each_dist do |d|
      del << d if chance >= rand
    end
    del.each {|d| dist >> d}
  end
  
  #if no reps given, will use length to determin it.
  def fully_extend_all reps=nil
    dist.branches.times do |i|
      hits = mapee(i).hits
      len = mapee(i).length
      mapee(i).clear_hits
      reps = (@len.to_f / len).round if reps.nil?
      mapee(i).length = @len
      reps.times do |j|
        new_hits = HitSq.new
        new_hits << hits
        new_hits * (1.0/reps)
        new_hits + (j.to_f / reps)
#        puts new_hits.hits.inspect
        mapee(i) << new_hits
      end
#      puts mapee(i).hits.hits.inspect
    end
  end
  
  def do_mapee
    count.times {|i| yield(mapee(i))}
  end
  
  
  #make all drum sounds
  #always will be an extra layer anyway
  def drum_sounds max_amp=0.5, layers =1
    tot = count
    amp = max_amp.to_f / tot #out of total drums
    tot.times do |i| 
      this_amp = amp
      wei = (i+1).to_f/(tot+1)
#      this_amp = max_amp if wei < 0.4 # if bass-ish
      range = 0.0
      seqs= 1
      if wei > 0.7 # if hihat-ish
        this_amp /= 3 
        mapee(i).drum(wei, this_amp, 0.04, 1, layers)
        mapee(i)[0].snd.toneseq.tonepart(0).do_all {|tone| tone.saturations.start = 0.5 + rand(3).to_f/10}
        mapee(i)[0].snd.toneseq.do_all{|tp| tp.do_all {|tone|
            tone.detail = 10000
            tone.amp.exp = 0.12
          } }
      else
        if wei > 0.35 && wei < 0.65
          range = 0.5
          seqs= 2+rand(2)
        end
        mapee(i).drum(wei, this_amp, range, seqs, layers)
      end
    end
  end
  
  #add dists with the hits you need for a bar of techno percussion.
  #len:: length of bar
  #3 children, in order: bass drum, snare, hi hat
  def techno_percussion len
    self << len.Dist # bass drum
    mapee_last.clear_hits
    mapee_last << 4.eqly_spaced
    # max len is full, min quarter
    h_num = mapee_last.hits.count
    h_num = 1 if h_num == 0
    mapee_last.length= rand_range(len*0.666/h_num, len*0.11/h_num) 

    self << len.Dist # snare
    mapee_last.clear_hits
    mapee_last << [0.25,0.75]
    h_num = mapee_last.hits.count
    h_num = 1 if h_num == 0
    mapee_last.length= rand_range(len/h_num, len/h_num/2) 
    
    self << len.Dist # hi
    mapee_last.clear_hits
    mapee_last << 4.eqly_spaced
    mapee_last.hits.move(0.125) # offbeats
    h_num = mapee_last.hits.count
     h_num = 1 if h_num == 0
   mapee_last.length= rand_range(len*0.666/h_num, len*0.666/h_num/2) 
    
    self
  end
  
  #evenly disperse each child across length  
  def fillout
    count.times do |j|
      self[j].clear_hits
      reps = (@len.to_f / (mapee(j).length)).round
      self[j] << reps.eqly_spaced
    end
  end
  #set the right hits to mix all children one after eachother.
  #(this can create a dj mix)
  #mixed_ammount:: the ammount of overlap between children
  def mix mixed_ammount = 0.25
    last_start = 0.0
    dist.branches.times do |i|
      self[i].clear_hits
      self[i] << last_start
      last_start = last_start + (1.0 - mixed_ammount) * (1.0/dist.branches)
    end
  end
  def count
    dist.branches
  end
  
  #set length
  def length= val
    @len=val.round
    dist.set_child_len @len
  end
  #get length
  def length
    @len
  end
  
  #length of each child is set to length of val, and we get added to val
  #val:: a Dist
  def map_to= val
    self.length= val.length
    val << dist #add me to him
  end
  #get a mapper at i from #dist
  def [] i=0
    dist[i]
  end
  #return last child
  def last
    dist.last_born
  end
  #return last #mapee
  def mapee_last
    last[0]
  end
  #get the child of a mapper (the dist to being mapped) at i
  def mapee i=0
    dist[i][0]
  end
    
  #add dist with the hits you need for a bar of dubstep percussion
  #this dist has 5 children, in order: bass drum, secondary bass drum, snare, hi hat, second hi hat
  def dubstep_percussion len
    self << len.Dist # bass drum
    mapee_last.clear_hits
    mapee_last << [0.0]
    self << len.Dist # 2nd bass drum
    mapee_last.clear_hits
    mapee_last << [0.75, 0.875] #two last drum hits
    self << len.Dist # snare
    mapee_last.clear_hits
    mapee_last << [0.5] # third beat
    self << len.Dist # hi hat
    mapee_last.clear_hits
    mapee_last << [0.375,0.625] # off beats
    self << len.Dist # 2nd hi hat
    mapee_last.clear_hits
    mapee_last << [0.125,0.875] # offbeats
    self
  end  


  #pass a block to be run on each dist
  def each_dist
    count.times do |i|
      yield( self[i])
    end
  end
  private
  # Add Dist to me.
  def add_single toadd
    case toadd
    when Dist
      dist << @len.Dist
      dist.last_born << toadd
    else
      return false
    end
    true
  end
end