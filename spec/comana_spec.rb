require "fileutils"
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

NOW = Time.now
CALC_DIR = "spec/dummy"
LOG = "#{CALC_DIR}/log"
#OUTFILES = ["output_a"]

class Comana
  public :latest_modified_time, :started?
end

class CalcFinished    < Comana
  def normal_ended?     ; true      ; end
  def finished?         ; true      ; end
  def send_command      ;           ; end
  def prepare_next      ;           ; end
  def initial_state     ;           ; end
  def latest_state      ;           ; end
  def teardown          ;           ; end
  def set_parameters
    @logfile    = "log"
    @alive_time =  500
  end
end

describe Comana, "with not calculated" do
  class CalcYet < Comana
    def normal_ended?     ; false     ; end
    def finished?         ; false     ; end
    def send_command      ;           ; end
    def prepare_next      ;           ; end
    def initial_state     ;           ; end
    def latest_state      ;           ; end
    def teardown          ;           ; end
    def set_parameters
      @logfile    = "log"
      @alive_time = 3600
    end
  end
  before do
    @calc = CalcYet .new(CALC_DIR)

    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    FileUtils.rm(LOG) if File.exist?(LOG)
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
    File.open(LOG, "w")
    @calc.started?.should be_true
  end

  after do
    FileUtils.rm(LOG) if File.exist?(LOG)
  end
end

describe Comana, "with log" do
  class CalcStarted < Comana
    def normal_ended?     ; false     ; end
    def finished?         ; false     ; end
    def send_command      ;           ; end
    def prepare_next      ;           ; end
    def initial_state     ;           ; end
    def latest_state      ;           ; end
    def teardown          ;           ; end
    def set_parameters
      @logfile    = "log"
      @alive_time = 5000
    end
  end

  before do
    @calc = CalcStarted   .new(CALC_DIR)
    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    File.open(LOG, "w")
  end

  it "should return :started" do
    @calc.state.should == :started
  end

  after do
    FileUtils.rm(LOG) if File.exist?(LOG)
  end
end

#describe Comana, "with output" do
#  class CalcStarted < Comana
#    def normal_ended?     ; false     ; end
#    def finished?         ; false     ; end
#    def send_command      ;           ; end
#    def prepare_next      ;           ; end
#    def initial_state     ;           ; end
#    def latest_state      ;           ; end
#    def teardown          ;           ; end
#    def set_parameters
#      @logfile    = "log"
#      @alive_time = 5000
#    end
#  end
#
#  before do
#    @calc = CalcStarted   .new(CALC_DIR)
#    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
#    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
#    #File.open(OUTPUT, "w")
#  end
#
#  it "should return :started"
#
#  after do
#    FileUtils.rm(LOG) if File.exist?(LOG)
#  end
#end

describe Comana, "with terminated" do
  class CalcTerminated < Comana
    def normal_ended?     ; false     ; end
    def finished?         ; false     ; end
    def send_command      ;           ; end
    def prepare_next      ;           ; end
    def initial_state     ;           ; end
    def latest_state      ;           ; end
    def teardown          ;           ; end
    def set_parameters
      @logfile    = "log"
      @alive_time = 500
    end
  end

  before do
    @calc_terminated   = CalcTerminated.new(CALC_DIR)

    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    File.open(LOG, "w")
  end

  it "should return the state" do
    File.open(LOG, "w")
    File.utime(NOW - 1000 ,NOW - 1000, LOG)
    @calc_terminated  .state.should == :terminated
  end

  after do
    FileUtils.rm(LOG) if File.exist?(LOG)
  end
end

describe Comana, "with next" do
  class CalcNext < Comana
    def normal_ended?     ; true      ; end
    def finished?         ; false     ; end
    def send_command      ;           ; end
    def prepare_next      ;           ; end
    def initial_state     ;           ; end
    def latest_state      ;           ; end
    def teardown          ;           ; end
    def set_parameters
      @logfile    = "log"
      @alive_time =  500
    end
  end

  before do
    @calc_next         = CalcNext      .new(CALC_DIR)

    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    File.open(LOG, "w")
  end

  it "should return the state" do

    File.open(LOG, "w")
    File.utime(NOW - 1000 ,NOW - 1000, LOG)
    @calc_next        .state.should == :next
  end

  after do
    FileUtils.rm(LOG) if File.exist?(LOG)
  end
end

describe Comana, "with finished" do
  before do
    @calc_finished     = CalcFinished  .new(CALC_DIR)

    File.utime(NOW - 1000 ,NOW - 1000, "#{CALC_DIR}/input_a")
    File.utime(NOW - 2000 ,NOW - 2000, "#{CALC_DIR}/input_b")
    #FileUtils.rm(LOG) if File.exist?(LOG)
    File.open(LOG, "w")
  end

  it "should return the state" do

    File.open(LOG, "w")
    File.utime(NOW - 1000 ,NOW - 1000, LOG)
    @calc_finished    .state.should == :finished
  end

  after do
    FileUtils.rm(LOG) if File.exist?(LOG)
  end
end
