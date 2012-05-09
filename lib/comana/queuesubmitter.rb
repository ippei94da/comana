#! /usr/bin/env ruby
# coding: utf-8

require "comana/computationmanager.rb"
require "comana/machineinfo.rb"

#
#
#
class QueueSubmitter < ComputationManager
  QSUB_SCRIPT = "script.qsub"
  WALLTIME = "7:00:00:00" # day:hour:minute:second

  class PrepareNextError < Exception; end
  class InitializeError < Exception; end

  # opts is a hash includes data belows:
  #   :d => calculation as comana subclass.
  #   :c => command line.
  #   :n => name of cluster.
  #   :s => flag for speed prior mode (option).
  #   :machineinfo => MachineInfo class instance.
  # NOTE:
  #   :d is a comana subclass not directory name to check to be calculatable.
  def initialize(opts)
    raise InitializeError unless opts.has_key?(:d)
    raise InitializeError unless opts.has_key?(:c)
    raise InitializeError unless opts.has_key?(:n)
    raise InitializeError unless opts.has_key?(:machineinfo)

    super(opts[:d].dir)
    @command = opts[:c]
    @nodes   = opts[:n]
    @speed   = opts[:s]
    @machineinfo = opts[:machineinfo]
    @lockdir = "lock_queuesubmitter"
  end

  def calculate
    script_path = "#{@dir}/#{QSUB_SCRIPT}"
    File.open(script_path, "w") { |io| dump_qsub_str(io) }

    system("cd #{@dir}; qsub #{script_path} > #{@dir}/#{@lockdir}/stdout")
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

  def dump_qsub_str(io = nil)
    fs = @machineinfo.get_info("fileserver") #fileserver
    node_info = @machineinfo.get_info(@nodes)
    num = node_info["economy_nodes"]
    num = node_info["speed_nodes"] if @speed

    str = [
      "#! /bin/sh",
      "#PBS -N #{@dir}",
      "#PBS -l nodes=#{num}:ppn=1:#{@nodes},walltime=#{WALLTIME}",
      "#PBS -j oe",
      "mkdir -p ${PBS_O_WORKDIR}",
      "cp ${PBS_NODEFILE} ${PBS_O_WORKDIR}/pbs_nodefile",
      "rsync -azq --delete #{fs}:${PBS_O_WORKDIR}/ ${PBS_O_WORKDIR}",
      "cd ${PBS_O_WORKDIR}",
      "#{@command}",
      "rsync -azq --delete ${PBS_O_WORKDIR}/ #{fs}:${PBS_O_WORKDIR}",
      "#rm -rf ${PBS_O_WORKDIR}",
      "mv ${PBS_O_WORKDIR} ~/.trash",
    ].join("\n")

    if io
      io.puts str
    else
      return str
    end
  end
end


