# An initial value, a 
class Fader
# The initial value.
attr_accessor :start
# The final value.
attr_accessor :final
# The exponential rate it fades from initial to final.
# range:: +0
# 0 is linear.
# higher than 1 means it reachs the final later than linear.
# less than 1 means it reachs the final sooner than linear.
attr_accessor :exp
def initialize(start=nil,final=nil,exp=0)
  @start = start
  @final = final
  @exp = exp
end
# randomize the exp with good values.
def rand_exp below_linear =[true,false].sample
  self.exp = below_linear ? 0.1 + 0.9 * rand : 1+rand(20)
end
# set #final to a percentage of start
def %(percent)
  self.final = start.to_f*(percent/100.0)
end
# operate on both start and final
def *(mul=0.5)
  self.start *= mul
  self.final *= mul
end
# getter
def exp
  @exp==0 ? nil : @exp
end
def exp_no_nil
  @exp.nil? ? 0 : @exp
end
def is_eql(other)
  vars_eql?(other)
end
end