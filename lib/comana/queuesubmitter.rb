#! /usr/bin/env ruby
# coding: utf-8

require "comana/computationmanager.rb"
require "comana/machineinfo.rb"
require "optparse"

#
#
#
class QueueSubmitter < ComputationManager
  QSUB_SCRIPT = "script.qsub"
  WALLTIME = "7:00:00:00" # day:hour:minute:second

  class PrepareNextError < Exception; end
  class InitializeError < Exception; end
  class InvalidArgumentError < Exception; end

  # opts is a hash includes data belows:
  #   :command => command line.
  #   :cluster => name of cluster.
  #   :machineinfo => MachineInfo class instance.
  #   :directory => calculation as ComputationManager subclass.
  #     Note that this is not directory name, to check to be calculatable.
  def initialize(opts)
    [:directory, :command, :number,  :cluster, :fileserver].each do |symbol|
      raise InitializeError, "No #{symbol}"  unless opts.has_key?(symbol)
    end

    super(opts[:directory].dir)
    @command    = opts[:command]
    @cluster    = opts[:cluster]
    @number     = opts[:number]
    @fileserver = opts[:fileserver]
    @lockdir    = "lock_queuesubmitter"
  end

  def self.parse_options(ary, machineinfo)
    ## option analysis
    opts = {}
    op = OptionParser.new
    op.on("-c cluster", "--cluster" , "Cluster name."){|v| opts[:cluster] = v }
    op.on("-n number", "--number", "Indicate node number, or key in ~/.machineinfo."){|v|
      opts[:number] = v
    }
    op.parse!(ary)

    unless ary.size == 1
      raise InitializeError, "Not one directory indicated: #{ary.join(", ")}."
    end

    opts[:fileserver] = machineinfo.get_info("fileserver")

    unless opts[:cluster]
      raise InvalidArgumentError,
      "-c option not set."
    end

    # Number of nodes: number, key string, or default value(1).
    if opts[:number].to_i > 0
      opts[:number] = opts[:number].to_i 
    else
      number = machineinfo.get_info(opts[:cluster])[opts[:number]]
      if number
        opts[:number] = number
      else
        raise InvalidArgumentError,
        "No entry '#{opts[:number]}' in machineinfo: #{machineinfo.inspect}."
      end
    end
    opts[:number] ||= 1

    opts
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
    str = [
      "#! /bin/sh",
      "#PBS -N #{@dir}",
      "#PBS -l nodes=#{@number}:ppn=1:#{@cluster},walltime=#{WALLTIME}",
      "#PBS -j oe",
      "mkdir -p ${PBS_O_WORKDIR} && \\",
      "rsync -azq --delete #{@fileserver}:${PBS_O_WORKDIR}/ ${PBS_O_WORKDIR} && \\",
      "cp ${PBS_NODEFILE} ${PBS_O_WORKDIR}/pbs_nodefile && \\",
      "cd ${PBS_O_WORKDIR} && \\",
      "#{@command} && \\",
      "rsync -azq --delete ${PBS_O_WORKDIR}/ #{@fileserver}:${PBS_O_WORKDIR} && \\",
      "#rm -rf ${PBS_O_WORKDIR}",
      "mv ${PBS_O_WORKDIR} ~/.trash/`date '+%Y%m%d-%H%M%S'`",
    ].join("\n")

    if io
      io.puts str
    else
      return str
    end
  end
end


