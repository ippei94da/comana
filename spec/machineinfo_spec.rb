#! /usr/bin/env ruby
# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require "comana/machineinfo.rb"

describe Machineinfo do
  before { @k00 = Machineinfo.new("spec/machineinfo")}

  describe "#initialize" do
    context "not exist machineinfo file" do
      it ？
      lambda{ Machineinfo.new("") }.should raise_error(Errno::ENOENT)
    end

  end

  #describe "#initialize" do
  #  subject { @k00.method }

  #  context "Case A" do
  #    it { should be_nil }
  #  end

  #  context "Case B" do
  #    before {}
  #    it { should eq "value2" }
  #  end
  #end
end

