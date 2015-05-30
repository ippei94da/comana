#s! /usr/bin/env ruby
# coding: utf-8
#
require "yaml"

class Comana::HostInspector
  PING_MIN_INTERVAL = 1

  CACHE_DIR = "#{ENV['HOME']}/var/comana"

  attr_reader :hostname

  #
  def initialize(hostname)
    @hostname = hostname
    @cache_dir = "#{CACHE_DIR}/#{@hostname}"
  end


  ##ping
  #Try ping three times.
  #Return true if at least one time responds.
  #def ping3
  def update_ping
    result = false
    3.times do
      command =
        "ping -c 1 -W #{PING_MIN_INTERVAL} #{@hostname} 2> /dev/null 1> /dev/null"
      if system(command)
        result = true
        break
      end
    end

    write_cache("ping", result)
  end

  ##cwd
  ##readlink コマンドが使えるかとも思ったが、シムリンク自体の名前が不明瞭になる。
  def update_cwd
    str = `ssh #{@hostname} 'ls -l /proc/*/cwd'`
    results = {}
    str.split("\n").each do |line|
      items = line.split
      pid = items[8].sub(/^\/proc\//, '').sub(/\/cwd$/, '')
      results[pid] = items[10]
    end

    write_cache('cwd', results)
  end

  ##processes
  #%ps auxw
  #USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
  #ippei    28971  0.0  0.0 103684  3764 ?        S    15:19   0:00 sshd: ippei@pts/19
  #root         1  0.0  0.0  33876  2280 ?        Ss    5月17   0:22 /sbin/init
  #0---------1---------2---------3---------4---------5---------6---------7
  #0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0
  #
  #% ps -o 'user pid %cpu %mem command'
  #USER       PID %CPU %MEM COMMAND
  #ippei    19991  0.0  0.2 zsh
  #ippei    23217  0.0  0.0 ps -o user pid %cpu %mem command
  #0---------1---------2---------3---------4---------5---------6---------7
  #0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0-2-4-6-8-0
  #
  def update_ps
    str = `ssh #{@hostname} 'ps auxw'`
    #str = `ssh #{@hostname} "ps axw -o 'user pid %cpu %mem command'"`
    results = {}
    lines = str.split("\n")
    lines.shift  # titles of items
    lines.each do |line|
      user     = line[0..7]
      pid      = line[9..13]
      cpu      = line[15..18]
      mem      = line[20..23]
      #vsz      = line[25..30]
      #rss      = line[32..36]
      #tty      = line[38..45]
      #stat     = line[47..50]
      #start    = line[52..56]
      #time     = line[58..63]
      command  = line[65..-1]

      #user    = line[0..7]
      #pid     = line[9..13].to_i
      #cpu     = line[15..18].to_f
      #mem     = line[20..23].to_f
      #command = line[25..-1]

      results[pid] = {
        "user"    => user,
        "cpu"     => cpu,
        "mem"     => mem,
        "command" => command
      }
    end
    pp results

    write_cache('ps', results)
  end

  #def update_cpuinfo
  #def update_meminfo
  #def update_lspci


  ############################################################
  ## common
  #Return from cached ping data.
  def fetch(name)
    load_cache(name)
  end

  def time_updated(name)
    ping_file = "#{@cache_dir}/#{name}.yaml"
    if File.exist?  ping_file
      return File.mtime(ping_file)
    else
      return nil
    end
  end

  private

  def write_cache(name, value)
    FileUtils.mkdir_p @cache_dir
    File.open("#{@cache_dir}/#{name}.yaml", "w") do |io|
      YAML.dump(value, io)
    end
  end

  def load_cache(name)
    return nil unless File.exist? "#{@cache_dir}/#{name}.yaml"
    YAML.load_file("#{@cache_dir}/#{name}.yaml")
  end

end

