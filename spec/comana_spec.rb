require "fileutils"
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

NOW = Time.now
CALC_DIR = "spec/dummy"
LOCKFILE = "#{CALC_DIR}/log"
OUTFILES = ["#{CALC_DIR}/output_a", "#{CALC_DIR}/output_b"]

class Comana
  public :latest_modified_time, :started?
end

class CalcFinished    < Comana
  def finished?         ; true      ; end
  def set_parameters
    @logfile    = "log"
    @alive_time =  500
    @outfiles   =  []
  end
end

describe Comana, "with not calculated" do
  class CalcYet < Comana
    def finished?         ; false     ; end
    def set_parameters
      @logfile    = "log"
      @alive_time = 3600
      @outfiles   =  []
    end
  end
  before do
    @calc = CalcYet .new(CALC_DIR)

    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    FileUtils.rm(LOCKFILE) if File.exist?(LOCKFILE)
  end

  it "should return the state" do
    @calc.state.should == :yet
  end

  it "should return latest modified time" do
    @calc.latest_modified_time.should == (NOW - 1000)
  end

  it "should return false without log." do
    @calc.started?.should_not == nil
    @calc.started?.should be_false
  end

  it "should return true with log." do
    File.open(LOCKFILE, "w")
    @calc.started?.should be_true
  end

  after do
    FileUtils.rm(LOCKFILE) if File.exist?(LOCKFILE)
  end
end

describe Comana, "with log" do
  class CalcStarted < Comana
    def finished?         ; false     ; end
    def set_parameters
      @logfile    = "log"
      @alive_time = 5000
      @outfiles   =  []
    end
  end

  before do
    @calc = CalcStarted   .new(CALC_DIR)
    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    File.open(LOCKFILE, "w")
  end

  it "should return :started" do
    @calc.state.should == :started
  end

  after do
    FileUtils.rm(LOCKFILE) if File.exist?(LOCKFILE)
  end
end

describe Comana, "with output, without lock" do
  class CalcStarted < Comana
    def finished?         ; false     ; end
    def set_parameters
      @logfile    = "log"
      @alive_time = 5000
      @outfiles   =  []
      @outfiles = ["output_a", "output_b"]
    end
  end

  before do
    @calc = CalcStarted   .new(CALC_DIR)
    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    File.open(OUTFILES[0], "w")
  end

  it "should return :started" do
    @calc.state.should == :started
  end

  after do
    FileUtils.rm(OUTFILES[0]) if File.exist?(OUTFILES[0])
  end
end

describe Comana, "with terminated" do
  class CalcTerminated < Comana
    def finished?         ; false     ; end
    def set_parameters
      @logfile    = "log"
      @alive_time = 500
      @outfiles   =  []
    end
  end

  before do
    @calc_terminated   = CalcTerminated.new(CALC_DIR)

    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    File.open(LOCKFILE, "w")
  end

  it "should return the state" do
    File.open(LOCKFILE, "w")
    File.utime(NOW - 1000 ,NOW - 1000, LOCKFILE)
    @calc_terminated  .state.should == :terminated
  end

  after do
    FileUtils.rm(LOCKFILE) if File.exist?(LOCKFILE)
  end
end

describe Comana, "with finished" do
  before do
    @calc_finished     = CalcFinished  .new(CALC_DIR)

    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    #FileUtils.rm(LOCKFILE) if File.exist?(LOCKFILE)
    File.open(LOCKFILE, "w")
  end

  it "should return the state" do

    File.open(LOCKFILE, "w")
    File.utime(NOW - 1000 ,NOW - 1000, LOCKFILE)
    @calc_finished    .state.should == :finished
  end

  after do
    FileUtils.rm(LOCKFILE) if File.exist?(LOCKFILE)
  end
end
