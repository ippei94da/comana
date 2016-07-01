#! /usr/bin/env ruby
# coding: utf-8

# This class provides a framework of scientific computation.
# Users have to redefine some methods in subclasses for various computation.
# 
class Comana::ComputationManager
  class InitializeError < StandardError; end
  class NotImplementedError < StandardError; end
  class AlreadyStartedError < StandardError; end
  class AlreadySubmittedError < StandardError; end
  class ExecuteError < StandardError; end

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
    targets = [ENV['PWD']] if targets.empty?

    targets.each do |dir|
      print "#{dir}..."
      begin
        calc_dir = self.new(dir)
      rescue
        puts "Not #{self}: #{dir}"
        next
      end

      begin
        calc_dir.start
      rescue self::AlreadyStartedError
        puts "Already started: #{dir}"
        next
      end
    end
  end

  def self.qsub(args, options)
    if options[:auto] || options[:load_group]
      # OK
    elsif !(options[:q_name] && options[:pe_name] && options[:ppn] && options[:command])
      puts "Lack of required options."
      puts "Need (--auto) or (--load-group) or (--q-name && --pe-name && --ppn && --command )"
      puts "E.g., OK: #{File.basename($0)} --auto"
      puts "      OK: #{File.basename($0)} --load-group=cluster_name"
      puts "      OK: #{File.basename($0)} --q-name=a --pe-name=b --ppn=1 --command=c"
      puts "      NG: #{File.basename($0)} --q-name=a --pe-name=b --ppn=1"
      puts "Exit."
      exit
    end

    tgts = args
    tgts = [ENV['PWD']] if tgts.empty?

    tgts.each do |dir|
      cs = Comana::ClusterSetting.load_file
      if options[:load_group]
        q_name = options[:load_group]
      elsif options[:auto]
        queues = Comana::GridEngine.queues
        jobs = {}
        hosts = {}
        benchmarks = {}
        queues.each do |q|
          jobs[q] = Comana::GridEngine.queue_jobs(q).size
          hosts[q] = Comana::GridEngine.queue_alive_nums[q] || 0
          benchmarks[q] = Comana::ClusterSetting.load_file.settings_queue(q)['benchmark']
        end
        #pp queues, jobs, hosts, benchmarks
        q_name =  self.effective_queue(queues, jobs, hosts, benchmarks)
      end

      if options[:load_group] || options[:auto]
        gs = cs.settings_queue(q_name)
        q_name          ||= gs['queue']
        pe_name         ||= gs['pe']
        ppn             ||= gs['ppn']
        ld_library_path ||= gs['ld_library_path']
      end

      q_name          = options[:q_name]          if options[:q_name]
      pe_name         = options[:pe_name]         if options[:pe_name]
      ppn             = options[:ppn]             if options[:ppn]
      ld_library_path = options[:ld_library_path] if options[:ld_library_path]
      command = options[:command] || "#{`which #{__FILE__}`.chomp} execute"

      begin
        calc_dir = self.new(dir)
        calc_dir.queue_submit(
          q_name:           q_name,
          pe_name:          pe_name,
          ppn:              ppn,
          ld_library_path:  ld_library_path,
          command:          command
        )
      rescue self::InitializeError
        puts "Not #{self} : #{dir}"
      rescue Comana::ComputationManager::AlreadySubmittedError
        puts "Already started: #{dir}"
      end
    end
  end

  ## jobs < hosts のキューがあれば(空きホストがあれば)、その中で bench が最小のもの
  ## なければ、self.guess_end_time の値が最小のもの。
  def self.effective_queue(queues, jobs, hosts, benchmarks)
    candidates = queues.select do |q|
      jobs[q] < hosts[q] 
    end
    if candidates.empty?
      result = queues.min_by{|q| self.guess_end_time(jobs[q], hosts[q], benchmarks[q]) }
    else
      result = candidates.min_by {|q| benchmarks[q]}
    end
    result
  end

  # 新しく1個ジョブを追加した場合の終了見込み時間
  # ジョブの終了時刻がランダムであり、ジョブの実行時間は等しいと仮定して算出。
  # 空きホストがあれば benchmark 通りの見込み。
  # 空きホストがなければ、ホストがあくまでの見込み時間を加算。
  def self.guess_end_time(num_jobs , num_hosts, benchmark)
    if num_jobs < num_hosts
      unit = 1.0 #unit 
    else
      unit = (num_jobs.to_f + 1.0) / (num_hosts.to_f)
    end
    result = unit * benchmark
    result
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

  def queue_submit(q_name:, pe_name:, ppn:, ld_library_path: , command:, submit: true)

    qsub_path = "#{@dir}/#{QSUB_SCRIPT_NAME}"
    if FileTest.exist? qsub_path
      raise AlreadySubmittedError,
        "Already exist #{qsub_path}."
    end
    File.open(qsub_path, "w") do |io|
      Comana::GridEngine.write_qsub_script(
        q_name:          q_name,
        pe_name:         pe_name,
        ppn:             ppn,
        ld_library_path: ld_library_path,
        command:         command,
        io:              io
      )
    end
    cur_dir = Dir.pwd
    Dir.chdir @dir
    print   "Submitting #{qsub_path}..."
    system("qsub #{QSUB_SCRIPT_NAME} > #{QSUB_LOG_NAME}") if submit
    puts   "Done."
    Dir.chdir cur_dir
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

