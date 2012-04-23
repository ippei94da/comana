require "fileutils"
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

NOW = Time.now

class Comana
  public :latest_modified_time, :started?
end

describe Comana, "not calculated" do
  class CalcYet < Comana
    def finished?         ; false     ; end
    def set_parameters
      @lockdir   = "lock"
      @alive_time = 3600
      @outfiles   = ["output"]
    end
  end
  before do
    calc_dir = "spec/not_calculated"
    @calc = CalcYet.new(calc_dir)

    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    @lockdir = "#{calc_dir}/lockdir"
    FileUtils.rm(@lockdir) if File.exist?(@lockdir)
  end

  it "should return the state" do
    @calc.state.should == :yet
  end

  it "should return latest modified time" do
    @calc.latest_modified_time.should == (NOW - 1000)
  end

  it "should return false without lock." do
    @calc.started?.should_not == nil
    @calc.started?.should be_false
  end

  it "should return true with lock." do
    @calc.started?.should be_false
  end

  #after do
  #  FileUtils.rm(@lockdir) if File.exist?(@lockdir)
  #end
end

describe Comana, "with lock" do
  class CalcStarted < Comana
    def finished?         ; false     ; end
    def set_parameters
      @lockdir   = "lock"
      @alive_time = 5000
      @outfiles   = ["output"]
    end
  end

  before do
    calc_dir = "spec/locked"
    @calc = CalcStarted   .new(calc_dir)
    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
  end

  it "should return :started" do
    @calc.state.should == :started
  end
end

describe Comana, "with output, without lock" do
  class CalcStarted < Comana
    def finished?         ; false     ; end
    def set_parameters
      @lockdir   = "lock"
      @alive_time = 5000
      @outfiles   = ["output"]
    end
  end

  before do
    calc_dir = "spec/outputted"
    @calc = CalcStarted   .new(calc_dir)
    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/output")
    #File.utime(NOW - 9000 ,NOW - 9000, "#{calc_dir}/lock")
    #File.open(OUTFILES[0], "w")
  end

  it "should return :started" do
    @calc.state.should == :yet
  end

end

describe Comana, "terminated" do
  class CalcTerminated < Comana
    def finished?         ; false     ; end
    def set_parameters
      @lockdir   = "lock"
      @alive_time = 500
      @outfiles   = ["output"]
    end
  end

  before do
    calc_dir = "spec/locked_outputted"
    @calc_terminated   = CalcTerminated.new(calc_dir)

    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    File.utime(NOW - 9000 ,NOW - 9000, "#{calc_dir}/output")
    File.utime(NOW - 9000 ,NOW - 9000, "#{calc_dir}/lock")
  end

  it "should return the state" do
    @calc_terminated  .state.should == :terminated
  end
end

describe Comana, "finished" do
  class CalcFinished    < Comana
    def finished?         ; true      ; end
    def set_parameters
      @lockdir    = "lock"
      @alive_time =  500
      @outfiles   = ["output"]
    end
  end

  before do
    calc_dir = "spec/locked_outputted"
    @calc_finished     = CalcFinished  .new(calc_dir)

    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
  end

  it "should return the state" do
    @calc_finished    .state.should == :finished
  end
end
