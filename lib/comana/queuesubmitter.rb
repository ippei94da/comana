#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
#require "comana/computationmanager.rb"
#require "comana/clustersetting.rb"

#
#
#
class Comana::QueueSubmitter < Comana::ComputationManager
  SCRIPT = "script.sh"
  PROLOGUE = "prologue_script.sh"
  EPILOGUE = "epilogue_script.sh"
  WALLTIME = "7:00:00:00" # day:hour:minute:second

  class PrepareNextError < Exception; end
  class InitializeError < Exception; end
  class InvalidArgumentError < Exception; end

  # opts is a hash includes data belows:
  #   "command" => executable command line written in script.
  #   "cluster" => name of cluster.
  #   "target" => calculation as ComputationManager subclass.
  #     Note that this is not target name, to check calculatable.
  def initialize(opts)
    #opts = self.class.correct_options(opts)
    ["target", "command", "number", "cluster"].each do |symbol|
      raise InitializeError, "No #{symbol} in argument 'opts'"  unless opts.has_key?(symbol)
    end

    super(opts["target"].dir)

    @command    = opts["command"]
    @cluster    = opts["cluster"]
    @number     = opts["number"]
    @lockdir    = "lock_queuesubmitter"
  end

  ## Check and correct options given as hash, 'opts', using clustersetting.
  ## Return hash corrected.
  ## 'opts' must have keys of
  ##   "number"
  ##   "cluster"
  ##   "target"
  ## clustersetting is a ClusterSetting class instance.
  #def self.correct_options(opts, clustersetting)
  #  # option analysis
  #  ["target", "number", "cluster"].each do |symbol|
  #    raise InitializeError, "No #{symbol} in argument 'opts'"  unless opts.has_key?(symbol)
  #  end


  #  #unless ary.size == 1
  #  #  raise InitializeError, "Not one target indicated: #{ary.join(", ")}."
  #  #end

  #  #unless opts["cluster"]
  #  #  raise InvalidArgumentError,
  #  #  "-c option not set."
  #  #end

  #  ## Number of nodes: number, key string, or default value(1).
  #  #if opts["number"].to_i > 0
  #  #  opts["number"] = opts["number"].to_i 
  #  #else
  #  #  number = clustersetting.get_info(opts["cluster"])[opts["number"]]
  #  #  if number
  #  #    opts["number"] = number
  #  #  else
  #  #    raise InvalidArgumentError,
  #  #    "No entry '#{opts["number"]}' in clustersetting: #{clustersetting.inspect}."
  #  #  end
  #  #end
  #  #opts["number"] ||= 1


  #  opts
  #end

  def calculate
    # prologue
    prologue_path = "#{@dir}/#{PROLOGUE}"
    File.open(prologue_path, "w") { |io| dump_prologue(io) }
    FileUtils.chmod(0700, prologue_path)

    # epilogue
    epilogue_path = "#{@dir}/#{EPILOGUE}"
    File.open(epilogue_path, "w") { |io| dump_epilogue(io) }
    FileUtils.chmod(0700, epilogue_path)

    # script
    script_path = "#{@dir}/#{SCRIPT}"
    File.open(script_path, "w") { |io| dump_script(io) }

    # run
    system("cd #{@dir}; qsub -l prologue=#{prologue_path} -l epilogue=#{epilogue_path} #{script_path} > jobid.log")
  end

  # Raise QueueSubmitter::PrepareNextError when called.
  def prepare_next
    raise PrepareNextError
  end

  # Return true after qsub executed.
  def finished?
    Dir.exist? @dir + "/" +@lockdir
  end

  private

  def dump_prologue(io = nil)
    str = [
      '#! /bin/sh',
      'LOGFILE="${PBS_O_WORKDIR}/prologue_script.log"',
      'echo "hostname                         : `hostname`" >> $LOGFILE',
      'echo "job id                           : $1" >> $LOGFILE',
      'echo "job execution user name          : $2" >> $LOGFILE',
      'echo "job execution group name         : $3" >> $LOGFILE',
      'echo "job name                         : $4" >> $LOGFILE',
      'echo "list of requested resource limits: $5" >> $LOGFILE',
      'echo "job execution queue              : $6" >> $LOGFILE',
      'echo "job account                      : $7" >> $LOGFILE',
      'echo "PBS_O_WORKDIR                    : ${PBS_O_WORKDIR}" >> $LOGFILE',
      'echo "nodes in pbs_nodefile            : " >> $LOGFILE',
      'cat ${PBS_NODEFILE} >> $LOGFILE',
      'exit 0',
    ].join("\n")

    if io
      io.puts str
    else
      return str
    end
  end

  def dump_script(io = nil)
    str = [
      "#! /bin/sh",
      "#PBS -N #{@dir}",
      "#PBS -l nodes=#{@number}:ppn=1:#{@cluster},walltime=#{WALLTIME}",
      "#PBS -j oe",
      "",
      "cd ${PBS_O_WORKDIR} && \\",
      "#{@command}",
    ].join("\n")

    if io
      io.puts str
    else
      return str
    end
  end

  def dump_epilogue(io = nil)
    str = [
      '#! /bin/sh',
      'LOGFILE="${PBS_O_WORKDIR}/epilogue_script.log"',
      'echo "job id                           : $1" >> $LOGFILE',
      'echo "job execution user name          : $2" >> $LOGFILE',
      'echo "job execution group name         : $3" >> $LOGFILE',
      'echo "job name                         : $4" >> $LOGFILE',
      'echo "session id                       : $5" >> $LOGFILE',
      'echo "list of requested resource limits: $6" >> $LOGFILE',
      'echo "list of resources used by job    : $7" >> $LOGFILE',
      'echo "job execution queue              : $8" >> $LOGFILE',
      'echo "job account                      : $9" >> $LOGFILE',
      'echo "job exit code                    : $10" >> $LOGFILE',
      'exit 0',
    ].join("\n")

    if io
      io.puts str
    else
      return str
    end
  end
end

