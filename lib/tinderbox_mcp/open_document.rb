require "apple_script_helper"

module TinderboxMCP

  class OpenDocument < MCP::Tool

    extend AppleScriptHelper

    description "Open a Tinderbox document from a file path on disk."
    input_schema(
      properties: {
        path: {
          type: "string",
          description: "The file path to a .tbx document on disk"
        }
      },
      required: ["path"]
    )

    def self.call(path:, server_context:)
      script = <<~APPLESCRIPT
        #{script_functions}

        tell application id "Cere"
          set theDoc to open POSIX file "#{esc(path)}"
          set docName to name of theDoc
          set docFile to ""
          try
            set docFile to (file of theDoc) as text
          end try
          return my toJSON({document:docName, file_path:docFile})
        end tell
      APPLESCRIPT

      result = run_applescript(script)
      MCP::Tool::Response.new([{ type: "text", text: result }])
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

  end

end
