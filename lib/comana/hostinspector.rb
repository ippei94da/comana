#s! /usr/bin/env ruby
# coding: utf-8
#
require "yaml"

class Comana::HostInspector
  PING_MIN_INTERVAL = 1
  CACHE_DIR = "#{ENV['HOME']}/var/comana"

  class NoUpdateFile < Exception; end

  attr_reader :hostname

  #
  def initialize(hostname, cache_dir = CACHE_DIR)
    @hostname = hostname
    @cache_dir = "#{cache_dir}/#{@hostname}"
  end


  ##Try ping three times.
  ##Return true if at least one time responds.
  ##def ping3
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
    str = ssh_str('ls -l /proc/\*/cwd 2> /dev/null')
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
  #auxw だと、
  #ippei     2948  198 11.8 4495708 3884740 pts/3 Rl   Apr01 173494:26 /opt/bin/vasp5212openmpi で桁が崩れることがある。
  def update_ps
    str = ssh_str('ps auxw')
    results = {}
    lines = str.split("\n")
    lines.shift  # titles of items
    lines.each do |line|
      items = line.split
      user    = items[0]
      pid     = items[1]
      cpu     = items[2]
      mem     = items[3]
      command = items[10]

      results[pid] = {
        "user"    => user,
        "cpu"     => cpu,
        "mem"     => mem,
        "command" => command
      }
    end
    write_cache('ps', results)
  end

  # dmesg ログ形式でつらい。
  # /proc/cpuinfo コアごとにでるのでパースめんどう。
  # lscpu これだと思ったら、CPU MHz がずれてる。ハードウェアで想定される値ではなく、
  # 実際の速度で書かれるらしい。
  # 負荷の有無で値がかわる。
  def update_cpuinfo
    #str = `ssh #{@hostname} 'cat /proc/cpuinfo'`
    str = ssh_str('cat /proc/cpuinfo')
    results = []
    cur_index = 0
    results[cur_index] = {}
    lines = str.split("\n")
    lines.each do |line|
      if line =~ /^\s*$/
        cur_index += 1
        results[cur_index] = {}
        next
      end
      key, value = line.split(/\s*:\s*/)
      results[cur_index][key] = value
    end
    write_cache('cpuinfo', results)
  end

  def update_meminfo
    str = ssh_str('cat /proc/meminfo')
    results = {}
    lines = str.split("\n")
    lines.each do |line|
      key, value = line.split(/\s*:\s*/)
      results[key] = value
    end
    write_cache('meminfo', results)
  end

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

  # 先に ping を打ち、返事がなければ 空文字列 を返す。
  def ssh_str(command)
    update_ping
    if fetch('ping')
      return `ssh #{@hostname} #{command}`
    else
      return ''
    end
  end

  def write_cache(name, value)
    FileUtils.mkdir_p @cache_dir
    File.open("#{@cache_dir}/#{name}.yaml", "w") do |io|
      YAML.dump(value, io)
    end
  end

  def load_cache(name)
    cache_file = "#{@cache_dir}/#{name}.yaml"
    unless File.exist? cache_file
      raise NoUpdateFile, "#{cache_file} not found."
    end

    YAML.load_file("#{@cache_dir}/#{name}.yaml")
  end

end

