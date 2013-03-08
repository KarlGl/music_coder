require "./app.rb"
require "test/unit"

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
    assert_equal(20, s.t.tones.start.freq.start)
  end
  
  def test_def_hits
    d=Dist.new
    assert_equal(0, d.hits.count)
    assert_equal([0.0], d.dist.hits) #default
  end
  
  def test_def_tone
    d=10.Dist
    d.make_sound
    assert_equal(10, d.snd.t.max_frames)
  end
  
  def test_snd_f_def
    s=20.0.Snd
    assert_equal(20, s.t.freq)
  end
  
  def test_snd_len_dist
    snd = 155.Snd
    snd.length= beat
    assert_equal(beat, snd.t.tones.start.frames)
    assert_equal(0, snd.t.max_frames)
    snd.length= 0
    snd.length= beat
    @d3<<snd
    assert_equal(bar, snd.t.max_frames)
    assert_equal(beat, snd.t.tones.start.frames) # kept, not 0
  end
  def test_snd_len_def
    snd = 155.Snd
    @d3<<snd
    assert_equal(bar, snd.t.tones.start.frames) # if 0 uses full
  end
  def test_notes
    snd = Note.new(0,5).Snd
    assert_equal(440, snd.t.freq)
    assert_equal(Note.new(0,5).freq, snd.t.note.freq)
    snd = Note.new("c#",5)
    assert_equal(4, snd.note)
  end
end