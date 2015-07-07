#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_QueueManager < Test::Unit::TestCase
  def setup
    @qm00 = Comana::QueueManager.new
  end

  def test_qhost
    @qm00.qhost

  end

end

