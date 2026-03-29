#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Force UTF-8 encoding for all external operations
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'mcp'
require 'logger'

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path("./lib", __dir__))

require "tinderbox_mcp"
require "tinderbox_mcp/instructions"

# Dynamically discover all tool classes in the TinderboxMCP module
# This automatically includes any class that inherits from MCP::Tool
tools = TinderboxMCP.constants
  .map { |const| TinderboxMCP.const_get(const) }
  .select { |const| const.is_a?(Class) && const < MCP::Tool }

# Build resources from reference markdown files
ref_dir = File.expand_path("references", __dir__)
resources = Dir.glob("#{ref_dir}/*.md").sort.map do |path|
  name = File.basename(path, ".md")
  MCP::Resource.new(
    uri: "tinderbox://ref/#{name}",
    name: name,
    description: "Tinderbox reference: #{name.tr('-', ' ')}",
    mime_type: "text/markdown"
  )
end

server = MCP::Server.new(
  name:  'tinderbox-mcp',
  tools: tools,
  resources: resources,
  instructions: TinderboxMCP::Instructions.text,
  version: '0.1.0',
)

# Handle resource reads — serve reference files by URI
server.resources_read_handler do |params|
  uri = params[:uri]
  name = uri.sub("tinderbox://ref/", "")
  path = File.join(ref_dir, "#{name}.md")
  if File.exist?(path)
    [MCP::Resource::TextContents.new(uri: uri, text: File.read(path), mime_type: "text/markdown")]
  else
    []
  end
end

# Create and start the transport
transport = MCP::Server::Transports::StdioTransport.new(server)
transport.open
