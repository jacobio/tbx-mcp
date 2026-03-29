require "apple_script_helper"
require "json"

module TinderboxMCP

  class DoAction < MCP::Tool

    extend AppleScriptHelper

    tool_name "do"

    description "Perform a Tinderbox action on a Tinderbox note."
    input_schema(
      properties: {
        document: {
          type: "string",
          description: "The name of the Tinderbox document"
        },
        action: {
          type: "string",
          description: "A Tinderbox action to perform. Examples: $Color='red', $Badge='flag', createAgent(/path/to/agent)"
        },
        note: {
          type: "string",
          description: "A semicolon-delimited list of one or more names or paths (preferred) of notes on which the action is to be performed."
        }
      },
      required: ["document", "action", "note"]
    )

    def self.call(document:, action:, note:, server_context:)
      note_refs = split_list(note)
      results = []

      note_refs.each do |note_ref|
        # Pass the action string via an AppleScript variable to avoid
        # double-escaping issues (Tinderbox action code has no quote escaping).
        script = <<~APPLESCRIPT
          tell application id "Cere"
            tell #{doc_target(document)}
              set noteRef to find note in it with path "#{esc(note_ref)}"
              set actionStr to "#{esc(action)}"
              set actionResult to act on noteRef with actionStr
              return actionResult
            end tell
          end tell
        APPLESCRIPT

        result = run_applescript(script)
        results << { "note" => note_ref, "result" => result }
      end

      if results.length == 1
        json = JSON.generate(results.first)
      else
        json = JSON.generate(results)
      end

      MCP::Tool::Response.new([{ type: "text", text: json }])
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

  end

end
