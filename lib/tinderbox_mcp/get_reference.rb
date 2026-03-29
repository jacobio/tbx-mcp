require "apple_script_helper"

module TinderboxMCP

  class GetReference < MCP::Tool

    extend AppleScriptHelper

    REF_DIR = File.expand_path("../../references", __dir__)

    AVAILABLE = Dir.glob("#{REF_DIR}/*.md").sort.map { |p| File.basename(p, ".md") }.freeze

    description "Get Tinderbox reference documentation. Available topics: #{AVAILABLE.join(', ')}. Use this to look up action code syntax, functions, attributes, export codes, system containers, or adornments."
    input_schema(
      properties: {
        topic: {
          type: "string",
          description: "The reference topic to retrieve. One of: #{AVAILABLE.join(', ')}"
        }
      },
      required: ["topic"]
    )

    def self.call(topic:, server_context:)
      path = File.join(REF_DIR, "#{topic}.md")

      unless File.exist?(path)
        return MCP::Tool::Response.new(
          [{ type: "text", text: "Unknown topic '#{topic}'. Available: #{AVAILABLE.join(', ')}" }],
          error: true
        )
      end

      content = File.read(path)
      MCP::Tool::Response.new([{ type: "text", text: content }])
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

  end

end
