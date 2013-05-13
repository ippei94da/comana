#! /usr/bin/env ruby
# coding: utf-8

require 'rexml/document'
#
#
#
class Comana::HostInspector::Pbsnodes
  attr_reader :name, :state, :np, :properties, :ntype, :gpus, :status

  class UnknownNodeError < Exception; end

  def initialize(hostname, pbs_server = nil)
    @hostname = hostname
    command = "pbsnodes -x #{hostname}"
    command = "pbsnodes -x -s #{pbs_server} #{hostname}" if pbs_server
    command = "cat test/pbsnodes/#{hostname}.xml" if $TEST
    #command = "cat test/pbsnodes/#{hostname}.xml"
    parse `#{command} 2> /dev/null`
  end

  private

  def parse(str)
    doc = REXML::Document.new(str)
    #pp doc.elements["/Data/Node/name"      ] == nil
    if doc.elements["/Data/Node/name"      ] == nil
      raise UnknownNodeError
    end

    @name       = doc.elements["/Data/Node/name"      ].text
    @state      = doc.elements["/Data/Node/state"     ].text
    @np         = doc.elements["/Data/Node/np"        ].text
    @properties = doc.elements["/Data/Node/properties"].text
    @ntype      = doc.elements["/Data/Node/ntype"     ].text
    @gpus       = doc.elements["/Data/Node/gpus"      ].text

    #status
    @status = {}
    elem = doc.elements["/Data/Node/status"]
    if elem
      #doc.elements["/Data/Node/status"].text.to_s.split(",").each do |equation|
      elem.text.split(",").each do |equation|
        left = equation.split("=")[0]
        right = equation.split("=")[1].to_s
        @status[left] = right
      end
    end
  end
end

