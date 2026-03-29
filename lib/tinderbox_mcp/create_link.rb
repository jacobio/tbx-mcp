require "apple_script_helper"

module TinderboxMCP

  class CreateLink < MCP::Tool

    extend AppleScriptHelper

    description "Link two related Tinderbox notes, a source and destination."
    input_schema(
      properties: {
        document: {
          type: "string",
          description: "The name of the Tinderbox document"
        },
        source: {
          type: "string",
          description: "The path (preferred) or name of the source note."
        },
        destination: {
          type: "string",
          description: "The path (preferred) or name of the destination note."
        },
        type: {
          type: "string",
          description: "The link type (optional)"
        }
      },
      required: ["document", "source", "destination"]
    )

    def self.call(document:, source:, destination:, type: nil, server_context:)
      script = <<~APPLESCRIPT
        #{script_functions}

        tell application id "Cere"
          tell #{doc_target(document)}
            set srcRef to find note in it with path "#{esc(source)}"
            set destRef to find note in it with path "#{esc(destination)}"

            -- Get actual paths for confirmation
            set srcPath to evaluate srcRef with "$Path"
            set destPath to evaluate destRef with "$Path"
            set srcName to evaluate srcRef with "$Name"
            set destName to evaluate destRef with "$Name"

            -- Create the link via action code
            set linkAction to "linkTo(" & quote & destPath & quote#{type ? ' & "," & quote & "' + esc(type) + '" & quote' : ""} & ")"
            act on srcRef with linkAction

            return my toJSON({source_name:srcName, source_path:srcPath, destination_name:destName, destination_path:destPath, link_type:"#{esc(type || "*untitled")}"})
          end tell
        end tell
      APPLESCRIPT

      result = run_applescript(script)
      MCP::Tool::Response.new([{ type: "text", text: result }])
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

  end

end
