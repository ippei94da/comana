#! /usr/bin/env ruby
# coding: utf-8

require "fileutils"
#require "comana/computationmanager.rb"
#require "comana/clustersetting.rb"
#
#For Torque. This class will be obsoleted.

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
  #   :command => executable command line written in script.
  #   :cluster => name of cluster.
  #   :target => calculation as ComputationManager subclass.
  #     Note that this is not target name, to check calculatable.
  def initialize(opts)
    [:target, :command].each do |symbol|
      raise InitializeError, "No '#{symbol}' in argument 'opts'"  unless opts.has_key?(symbol)
      #raise InitializeError unless opts.has_key?(symbol)
    end

    super(opts[:target].dir)

    @command    = opts[:command]
    @cluster    = opts[:cluster]
    @num_nodes  = opts[:num_nodes]
    @priority   = opts[:priority]
    @lockdir    = "lock_queuesubmitter"
  end

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
    lines = []
    lines << "#! /bin/sh"
    lines << "#PBS -N #{@dir}"

    if @num_nodes || @cluster
      tmp = []
      @num_nodes ||= 1
      tmp << "nodes=#{@num_nodes}"
      tmp << "ppn=1"
      #pp @cluster
      tmp << @cluster if @cluster
      lines << "#PBS -l #{tmp.join(":")},walltime=#{WALLTIME}"
    else
      lines << "#PBS -l walltime=#{WALLTIME}"
    end

    lines << "#PBS -p #{@priority}" if @priority

    lines << "#PBS -j oe"
    lines << ""
    lines << "cd ${PBS_O_WORKDIR} && \\"
    lines << "#{@command}"

    str = lines.join("\n")

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

