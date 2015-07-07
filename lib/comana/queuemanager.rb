#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class Comana::QueueManager
  #
  def initialize()
  end

  #
  def queues
    `qconf -sql`.split("\n")
  end

  # return a queue name with less tasks.
  def light_queue
    queues.each do |queue|
      hostlist(queue)
    end

  end

  def qhost
    
  end

  private



end

