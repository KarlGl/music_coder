# the distribution of a ToneSeq, or multiple other SndDists
class SndDist
  #Array of floats containing the delays for each time a bar played. 0 to 1.
  attr_accessor :hits
  #Array of SndDist
  attr_accessor :snd
  #Array of ToneSeq
  attr_accessor :tss
  attr_accessor :len

  def initialize
    @hits = []
    @snd = []
    @tss = []
    @len = 0
  end
  
  def get_children
    @snd
  end

# get pointer to the first end node.
def end_node
  if !tss.empty?
    return self
  else
    return snd.first.end_node
  end
end

# me and all children. not frames, hits
  def tally_frames(old=0)
    if !tss.empty?
      # puts "returning hits count #{hits.count}"
      return hits.count
    else
      result=0
      snd.each do |sn|
        result += hits.count*sn.tally_frames(old)
      end
      # puts "all in result #{result}"
      return result
    end
  end

  def add sn
    self.snd<<sn
  end

  #recursivly create children with 4 hits, or a toneseq with 1 tonepart
  def populate(depth=0)
    raise "Error, you ran Dist.populate before seting hits and length first." if hits.count.to_f < 1 || len < 1
    puts "==|Dep: #{depth}| populating distributed sounds "
    max_child_len=(len/hits.count.to_f).round
    if depth==0
      t=ToneSeq.new
      self.tss<<t
      t.make(1,max_child_len)
    else#not 0 yet, recurse
      sn=SndDist.new
      add sn
      sn.len = max_child_len
      sn.disperse_hits(4)
      sn.populate depth-1
    end
  end

  # write children
  def render(parent_hit_index=0)
    # parent_into = (parent_hit_index+1) / hits.count.to_f #DEP
    # puts "==#{parent_hit_index} rendering sound #{hits.count} times. (#{App.time_since} secs)"
    files=FileList.new
    raise "forgot to put a length of this sound dist" if len.nil?
    log "Warning: one of your sound distributions have no hits. on purpose? ", 3 if hits.empty?
    hits.each_with_index do |delay,i|
      delay_in_frames= (delay*len).round
      into=(i+1).to_f/hits.count
      snd.each do |sn| 
        # puts "another snd dist "
        files.addlist sn.render(into), delay_in_frames
      end
      tss.each {|sn| files.addlist sn.render(into), delay_in_frames} 
      App.done += 1 if !tss.empty?
      App.logger.print_loading_bar(App.done, App.total)
    end
    files.child_len = (len)
    files
  end
#dep
  #Adds into #hits.
  #possible_hits:: number of hits that can occur. Must be int
  #chance:: chance a hit will be included. range: 0 to 1
  #ignore_first:: skip the first n possible hits
  #ignore_first:: skip the last n possible hits
  #e.g. disperse_hits(16,1,4,4) makes this pattern [-|-|-|-|+|+|+|+|+|+|+|+|-|-|-|-|]
  def disperse_hits(possible_hits = 4, chance = 1, ignore_first=0, ignore_last=0)
    possible_hits.times do |i|
      if ignore_first <= i && possible_hits - ignore_last > i
        delay = i/possible_hits.to_f
        hits.push delay if (rand + chance >= 1)
      end
    end
  end 
end