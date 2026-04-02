require "apple_script_helper"

module TinderboxMCP

  class CreateTextLink < MCP::Tool

    extend AppleScriptHelper

    description "Create a text link between two Tinderbox notes. Unlike create_link which creates a note-level link, this anchors the link to specific text in the source note's $Text that matches a regex pattern."
    input_schema(
      properties: {
        document: {
          type: "string",
          description: "The name of the Tinderbox document"
        },
        source: {
          type: "string",
          description: "The path (preferred) or name of the source note"
        },
        destination: {
          type: "string",
          description: "The path (preferred) or name of the destination note"
        },
        regex: {
          type: "string",
          description: "A regex pattern to match in the source note's $Text. The first match becomes the link anchor."
        },
        type: {
          type: "string",
          description: "The link type (optional). Auto-created if it doesn't exist."
        }
      },
      required: ["document", "source", "destination", "regex"]
    )

    def self.call(document:, source:, destination:, regex:, type: nil, server_context:)
      # Build the createTextLink arguments using AppleScript's quote constant
      # to avoid nested escaping issues with Tinderbox action code
      type_arg = if type
        " & \",\" & quote & \"#{esc(type)}\" & quote"
      else
        ""
      end

      script = <<~APPLESCRIPT
        #{script_functions}

        tell application id "Cere"
          tell #{doc_target(document)}
            set srcRef to find note in it with path "#{esc(source)}"
            set destRef to find note in it with path "#{esc(destination)}"

            set srcName to evaluate srcRef with "$Name"
            set srcPath to evaluate srcRef with "$Path"
            set destName to evaluate destRef with "$Name"
            set destPath to evaluate destRef with "$Path"

            set linksBefore to evaluate srcRef with "$OutboundLinkCount"

            set q to quote
            set actionStr to "createTextLink(" & q & srcPath & q & "," & q & destPath & q & "," & q & "#{esc(regex)}" & q#{type_arg} & ")"
            act on srcRef with actionStr

            set linksAfter to evaluate srcRef with "$OutboundLinkCount"

            return my toJSON({source_name:srcName, source_path:srcPath, destination_name:destName, destination_path:destPath, link_type:"#{esc(type || "*untitled")}", regex_pattern:"#{esc(regex)}", links_before:linksBefore, links_after:linksAfter})
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
