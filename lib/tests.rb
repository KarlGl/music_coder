load File.dirname(__FILE__) + "/music_coder.rb"
require "test/unit"

class TestTones < Test::Unit::TestCase
  
  def test_setters
    t= Tone.new
    t.freq.start = (200)
    assert_equal(200, t.freq.start)
    t.freq.final = (20)
    assert_equal(20, t.freq.final)
    t.set_freq_final (30)
    assert_equal(30, t.freq.final)
    t.set_freq_final(20, false)
    assert_equal(-180, t.freq.final)
    assert_equal(-180, t.freq_final)
    assert_equal(20, t.freq_final(false))
    t.set_freq(250)
    assert_equal(-230, t.freq_final)
    t.set_freq(240)
    assert_equal(-220, t.freq_final)
    t.set_freq_final (0)
    assert_equal(0, t.freq.final)
    t.set_freq(10)
    assert_equal(0, t.freq_final)
  end
end
class TestNotes < Test::Unit::TestCase
  def test_ops
    n=Note.new(1,5) + (-3)
    assert_equal(true, Note.new(10,4).is_eql(n))
    assert_equal(true, Note.new(3,5).is_eql(n+5))
  end
  def test_inc
    Composer.scale = "major"
    n=Note.new(0,5)
    assert_equal([0, 2, 4, 5, 7, 9, 11], scale_notes)
    b=n.inc 2
    assert_equal 4, b.note
    b=n.inc 7
    assert_equal 0, b.note
    assert_equal 6, b.octave
    b=n.inc 0
    assert_equal 0, b.note
    assert_equal 5, b.octave
    b=n.inc -2
    assert_equal 9, b.note
    assert_equal 4, b.octave
    b=n.inc -9
    assert_equal 9, b.note
    assert_equal 3, b.octave
  end
end

class TestHitSq < Test::Unit::TestCase
  def setup
    @h=[0.2,0.3,0.4].HitSq
    @h2=[0,1].HitSq
  end
  def test_loaded
    assert_equal(3, @h.count)
    assert_equal(true, @h2.hits.eql?([0.0,1.0]))
  end
  def test_bounds
    assert_raise(RuntimeError) {[1.1].HitSq}
    assert_raise(RuntimeError) {[-0.1].HitSq}
    assert_raise(RuntimeError) {@h2<<8}
  end

  def test_ops
    @h<<1
    assert_equal(4, @h.count)
    @h<<@h2
    assert_equal(5, @h.count)
    # without the duplicate now
    @h>>1
    assert_equal(4, @h.count)
    
    #
    assert_equal(2, @h2.count)
    @h2>>1.0
    assert_equal(1, @h2.count)
    # Not chaged
    assert_equal(4, @h.count)
  end
  
  def test_hits_trim
    h=HitSq.new
    h.eqly_spaced(8)
    h.trim_end(0.25)
    assert_equal(([0.0, 0.125, 0.25, 0.375, 0.5, 0.625]), h.hits)
    h.trim_start(0.25)
    assert_equal(([0.25, 0.375, 0.5, 0.625]), h.hits)
    
    
    h.hits = []
    h << 4.eqly_spaced
    assert_equal([0.0,0.25,0.5,0.75], h.hits)
    h.trim_start(0.25)
    assert_equal([0.25,0.5,0.75], h.hits)
    h.trim_end(0.34)
    assert_equal([0.25,0.5], h.hits)
  end
  
  def test_hits_move
    assert_equal(([0.2,0.3,0.4]), @h.hits)
    @h.move(0.1)
    assert_equal(([0.3,0.4,0.5]), @h.hits)
  end
end

class TestDists < Test::Unit::TestCase
  def setup
    @d=Dist.new
    @d2=Dist.new
    @d3=Dist.new
    @d3.length = bar
  end
 
  def test_dist_child_getters
     @d << (8.Dist << 0.5 << 300.Snd)
     @d.last_born.snd.length= 10
     assert_equal([0.5], @d.last_born.hits.hits)
     assert_equal(1, @d.last_born.snd.count)
     # persist?
     @d.last_born << 0.6
     assert_equal([0.5,0.6], @d.last_born.hits.hits)
  end
  def test_dist_default_hit_0
    dist = 50_000.Dist
    assert_equal(1, dist.dist.hits.count)
    assert_equal(0, dist.hits.count)
  end
  def test_add_dist
    assert_equal(0, @d.branches)
    @d<<@d2
    assert_equal(1, @d.branches)
    d=0.0.Dist
    assert_equal([0.0], d.hits.hits)
  end

  def test_del_dist
    assert_equal(0, @d.branches)
    @d<<@d2
    @d>>@d2
    assert_equal(0, @d.branches)
  end
 
  def test_add_dist_arr
    assert_equal(0, @d.branches)
    @d<<[@d3,@d2]
    assert_equal(2, @d.branches)
  end
  
  def test_del_dist_arr
    assert_equal(0, @d.branches)
    @d<<[@d3,@d2]
    assert_equal(2, @d.branches)
    @d>>[@d3,@d2]
    assert_equal(0, @d.branches)
  end
  
  def test_persistence
    assert_equal(0, @d2.hits.count)
    @d2<<1
    assert_equal(1, @d2.hits.count)
    @d2<<[0.7,0.8]
    assert_equal(3, @d2.hits.count)
    h=@d2.hits
    h<<0.1
    assert_equal(4, @d2.hits.count)
    h<<0.2
    assert_equal(5, @d2.hits.count)
    h>>0.2
    assert_equal(4, @d2.hits.count)
    @d2>>[0.1,0.8]
    # still persists
    assert_equal(2, @d2.hits.count)
  end
  
  def test_children
    @d2<<1
    @d<<[@d2]
    assert_equal(1, @d.branches)
    assert_equal(1, @d[0].hits.count)
    # can't have a snd
    assert_raise(RuntimeError) {@d<<Snd.new}
    assert_raise(RuntimeError) {@d.snd}
    @d>>[@d2]
    assert_raise(RuntimeError) {@d[0].hits.count}
  end
  
  def test_snd
    assert_equal(0, @d.sounds)
    @d<<Snd.new
    assert_equal(1, @d.sounds)
  end
  
  def test_len
    d=10.Dist
    assert_equal(10, d.length)
    d.length = 100
    assert_equal(100, d.length)
  end
  
  def test_snddefs
    s=20.Snd
    assert_equal(20, s.tone.freq.start)
  end
  
  def test_def_hits
    d=Dist.new
    assert_equal(0, d.hits.count)
    assert_equal([0.0], d.dist.hits) #default
  end
  
  def test_def_tone_len
    d=10.Dist
    d<< Snd.new
    assert_equal(10, d.snd.tonepart.max_frames)
  end
  
  def test_snd_f_def
    s=20.0.Snd
    assert_equal(20, s.tonepart.freq)
  end
  
  def test_snd_len_dist
    snd = 155.Snd
    snd.length= beat
    assert_equal(beat, snd.tone.frames)
    assert_equal(0, snd.tonepart.max_frames)
    snd.length= 0
    snd.length= beat
    @d3<<snd
    assert_equal(bar, snd.tonepart.max_frames)
    assert_equal(beat, snd.tone.frames) # kept, not 0
  end
  def test_snd_len_def
    snd = 155.Snd
    @d3<<snd
    assert_equal(bar, snd.tone.frames) # if 0 uses full
  end
  def test_notes
    snd = Note.new(0,5).Snd
    assert_equal(440, snd.tonepart.freq)
    assert_equal(Note.new(0,5).freq, snd.tonepart.note.freq)
    snd = Note.new("c#",5)
    assert_equal(4, snd.note)
  end
  def test_toneseq_pushing
    @d3 << Note.new(0,5).Snd
    @d3.snd.length= beat
    assert_equal(beat, @d3.snd.tone.frames)
    @d3.make(1)
    assert_equal(2, @d3.snd.toneseq.toneparts.count)
    assert_equal(beat/2, @d3.snd.tone.frames) # made 2, frames should be half
    @d3.make(2)
    assert_equal(4, @d3.snd.toneseq.toneparts.count)
    assert_equal(beat/4, @d3.snd.tone.frames) # made 4, frames should be 1/4
  end
  def test_scale
    Composer.scale = "mixolydian"
    notes = scale_notes
    assert_equal(7, notes.count)
    assert_equal([0,2,4,5,7,9,10], notes)
    
    snd = Snd.new
    snd.length= beat
    @d3<< snd
    @d3.make(6)
    7.times do |i|
      newn = Note.new(notes[i], 4)
      @d3.snd.tonepart(i).note= newn
    end
    assert_equal(392, @d3.snd.tonepart(6).freq.round)
    assert_equal(277, @d3.snd.tonepart(2).freq.round)
  end
end