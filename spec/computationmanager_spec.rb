require "fileutils"
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

NOW = Time.now

class ComputationManager
  public :latest_modified_time, :started?
end

describe ComputationManager, "not started" do
  class CalcYet < ComputationManager
    def finished?         ; false     ; end
  end
  before do
    calc_dir = "spec/not_started"
    @calc = CalcYet.new(calc_dir)

    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    @lockdir = "#{calc_dir}/lock_comana"
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

describe ComputationManager, "with lock" do
  class CalcStarted < ComputationManager
    def finished?         ; false     ; end
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

describe ComputationManager, "with output, without lock" do
  class CalcStarted < ComputationManager
    def finished?         ; false     ; end
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

describe ComputationManager, "terminated" do
  class CalcTerminated < ComputationManager
    def finished?         ; false     ; end
    def initialize(dir)
      @dir = dir
      @lockdir   = "lock_comana"
      @alive_time = 500
    end
  end

  before do
    calc_dir = "spec/locked_outputted"
    @calc_terminated   = CalcTerminated.new(calc_dir)

    File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    File.utime(NOW - 9000 ,NOW - 9000, "#{calc_dir}/output")
    File.utime(NOW - 9000 ,NOW - 9000, "#{calc_dir}/lock_comana")
  end

  it "should return the state" do
    @calc_terminated  .state.should == :terminated
  end
end

describe ComputationManager, "finished" do
  class CalcFinished    < ComputationManager
    def finished?         ; true      ; end
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

describe ComputationManager, "cannot execute" do
  class CalcNotExecutable    < ComputationManager
    def calculate
      system "" # notExistCommand
    end

    def finished?
      return false
    end

    def prepare_next
      #return false
      raise
    end
  end

  before do
    calc_dir = "spec/not_executable"
    @calc     = CalcNotExecutable  .new(calc_dir)
    #File.utime(NOW - 1000 ,NOW - 1000, "#{calc_dir}/input_a")
    #File.utime(NOW - 2000 ,NOW - 2000, "#{calc_dir}/input_b")
    @lockdir = calc_dir + "/lock_comana"

    Dir.rmdir(@lockdir) if File.exist?(@lockdir)
  end

  it "should raise error" do
    lambda{@calc.start}.should raise_error(ComputationManager::ExecuteError)
  end
end

