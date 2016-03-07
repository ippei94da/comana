#! /usr/bin/env ruby
# coding: utf-8

# This class provides a framework of scientific computation.
# Users have to redefine some methods in subclasses for various computation.
# 
class Comana::ComputationManager
  class NotImplementedError < Exception; end
  class AlreadyStartedError < Exception; end
  class AlreadySubmittedError < Exception; end
  class ExecuteError < Exception; end

  QSUB_SCRIPT_NAME = 'qsub.sh'
  QSUB_LOG_NAME    = 'qsub.log'

  attr_reader :dir

  # You can redefine in subclass to modify from default values.
  def initialize(dir)
    @dir = dir # redefine in subclass. 
    @lockdir    = "lock_comana"
    @alive_time = 3600
  end

  def self.execute(args)
    targets = args
    targets = [ENV['PWD']] if targets.size == 0

    targets.each do |dir|
      print "#{dir}..."
      begin
        calc_dir = self.new(dir)
      rescue => exc
        puts "Not suitable directory, due of an exception: #{exc}"
        next
      end

      begin
        calc_dir.start
      rescue Comana::ComputationManager::AlreadyStartedError
        puts "Already started."
        next
      end
    end
  end

  def self.write_qsub_script(q_name:, pe_name:, ppn:, ld_library_path: , command:, io:)
    io.puts "#! /bin/sh"
    io.puts "#$ -S /bin/sh"
    io.puts "#$ -cwd"
    io.puts "#$ -o stdout"
    io.puts "#$ -e stderr"
    io.puts "#$ -q #{q_name}"
    io.puts "#$ -pe #{pe_name} #{ppn}"
    io.puts "MACHINE_FILE='machines'"
    io.puts "LD_LIBRARY_PATH=#{ld_library_path}"
    io.puts "export LD_LIBRARY_PATH"
    io.puts "cd $SGE_O_WORKDIR"
    io.puts "printenv | sort > printenv.log"
    io.puts "cut -d ' ' -f 1,2 $PE_HOSTFILE | sed 's/ / cpu=/' > $MACHINE_FILE"
    io.puts "#{command}"
    #{__FILE__} execute
  end


  # Return a symbol which indicate state of calculation.
  #   :yet           not started
  #   :started       started, but not ended, including short time from last output
  #   :terminated    started, but long time no output
  #   :finished      started, normal ended and not need next calculation
  def state
    return :finished   if finished?
    return :yet        unless started?
    return :terminated if (Time.now - latest_modified_time > @alive_time)
    return :started    
  end

  # Execute calculation.
  # If log of ComputationManager exist, raise ComputationManager::AlreadyStartedError,
  # because the calculation has been done by other process already.
  # This method is aliased to 'start'.
  def execute
    begin
      Dir.mkdir "#{@dir}/#{@lockdir}"
    rescue Errno::EEXIST
      raise AlreadyStartedError, "Exist #{@dir}/#{@lockdir}"
    end

    while true
      calculate
      break if finished?
      prepare_next
    end
  end
  alias start execute

  # Return latest modified time of files in calc dir recursively.
  # require "find"
  def latest_modified_time
    tmp = Dir.glob("#{@dir}/**/*").max_by do |file|
      File.mtime(file)
    end
    File.mtime(tmp)
  end

  def queue_submit(q_name:, pe_name:, ppn:, ld_library_path: , command:)
    if FileTest.exist? "#{@dir}/#{QSUB_SCRIPT_NAME}"
      raise AlreadySubmittedError, "Already exist #{@dir}/#{QSUB_SCRIPT_NAME}."
    end
    File.open(QSUB_SCRIPT_NAME, "w") do |io|
      self.class.write_qsub_script(q_name:            q_name,
                                   pe_name:           pe_name,
                                   ppn:               ppn,
                                   ld_library_path:   ld_library_path,
                                   command:           command,
                                   io:                io
                                  )
    end
    Dir.chdir @dir
    system("qsub #{QSUB_SCRIPT_NAME} > #{QSUB_LOG_NAME}")
  end

  private

  # Redefine in subclass, e.g., 
  #   end_status = system "command"
  #   raise ExecuteError unless end_status
  def calculate
    raise NotImplementedError, "#{self.class}::calculate need to be redefined"
  end

  def prepare_next
    raise NotImplementedError, "#{self.class}::prepare_next need to be redefined"
  end

  def started?
    return true if File.exist?( "#{@dir}/#{@lockdir}" )
    return false
  end

  # Return true if the condition is satisfied.
  def finished?
    raise NotImplementedError, "#{self.class}::finished? need to be redefined"
  end

end

