#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class Comana::HostInspector::Ping
  PING_MIN_INTERVAL = 1

  #
  def initialize(hostname)
    @hostname = hostname
    @alive = ping
  end

  #Return true  if    ping respond from the host.
  #Return false if no ping respond from the host.
  def alive?
    @alive
  end

  private

  #Try ping three times.
  #Return true if at least one time responds.
  #def ping3
  def ping
    3.times do
      return true if system("ping -c 1 -W #{PING_MIN_INTERVAL} #{@hostname} 2> /dev/null 1> /dev/null")
    end
    return false
  end
end

