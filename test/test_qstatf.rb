#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_QstatF < Test::Unit::TestCase
  def setup
    io = File.open('test/qstatf/qstat_f.xml', 'r')
    @q00 = QstatF.new(io)
  end

  def test_a
    pp @q00
  end

end

