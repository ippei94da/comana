#! /usr/bin/env ruby
# coding: utf-8

require "nokogiri"

#
#
#
class Comana::HostInspector::Pbsnodes
  attr_reader :name, :state, :np, :properties, :ntype, :gpus, :status

  def initialize(hostname, pbs_server = nil)
    @hostname = hostname
    command = "pbsnodes -x #{hostname}"
    command = "pbsnodes -x -s #{pbs_server} #{hostname}" if pbs_server
    command = "cat spec/pbsnodes/#{hostname}.xml" if $DEBUG
    parse `#{command}`
  end

  private

  def parse(str)
    doc = Nokogiri::XML.parse(str)
    #pp doc.methods(true).sort
    #pp doc.xpath("/document")
    @name       = doc.xpath("/Data/Node/name"      ).children.to_s
    @state      = doc.xpath("/Data/Node/state"     ).children.to_s
    @np         = doc.xpath("/Data/Node/np"        ).children.to_s
    @properties = doc.xpath("/Data/Node/properties").children.to_s
    @ntype      = doc.xpath("/Data/Node/ntype"     ).children.to_s
    @gpus       = doc.xpath("/Data/Node/gpus"      ).children.to_s

    #status
    @status = {}
    doc.xpath("/Data/Node/status"    ).children.to_s.split(",").each do |equation|
      left = equation.split("=")[0]
      right = equation.split("=")[1].to_s
      @status[left] = right
    end
  end
end

