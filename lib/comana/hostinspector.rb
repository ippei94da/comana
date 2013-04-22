#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class Comana::HostInspector
  PING_MIN_INTERVAL = 0.2
  #ping: cannot flood; minimal interval, allowed for user, is 200ms


  #
  def initialize(hostname)
    @hostname = hostname
  end

  #Return true  if    ping respond from the host.
  #Return false if no ping respond from the host.
  def ping
    ping3
  end

  private

  #Try ping three times.
  #Return true if at least one time responds.
  def ping3
    3.times do
      return true if system("ping -c 1 -i #{PING_MIN_INTERVAL} #{@hostname} 2> /dev/null 1> /dev/null")
    end
    return false
  end
end

