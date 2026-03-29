require "apple_script_helper"
require "json"

module TinderboxMCP

  class SetValue < MCP::Tool

    extend AppleScriptHelper

    description "Change the value of an attribute of one or more notes from the current Tinderbox document"
    input_schema(
      properties: {
        document: {
          type: "string",
          description: "The name of the Tinderbox document"
        },
        notes: {
          type: "string",
          description: "A semicolon-delimited list of $Paths of the note or notes to be changed"
        },
        attribute: {
          type: "string",
          description: "The name of the attribute to be set"
        },
        value: {
          type: "string",
          description: "The new value of the attribute"
        }
      },
      required: ["document", "notes", "attribute", "value"]
    )

    # Direct AppleScript properties that can be set without action code.
    DIRECT_PROPERTIES = %w[name text color].freeze

    def self.call(document:, notes:, attribute:, value:, server_context:)
      note_paths = split_list(notes)
      results = []

      note_paths.each do |path|
        if DIRECT_PROPERTIES.include?(attribute.downcase)
          # Use direct AppleScript property setting
          script = <<~APPLESCRIPT
            tell application id "Cere"
              tell #{doc_target(document)}
                set noteRef to find note in it with path "#{esc(path)}"
                set #{attribute.downcase} of noteRef to "#{esc(value)}"
                return "ok"
              end tell
            end tell
          APPLESCRIPT
        else
          # Use the attribute API to bypass Tinderbox action code quoting issues
          script = <<~APPLESCRIPT
            tell application id "Cere"
              tell #{doc_target(document)}
                set noteRef to find note in it with path "#{esc(path)}"
                set attrObj to attribute of noteRef named "#{esc(attribute)}"
                set value of attrObj to "#{esc(value)}"
                return "ok"
              end tell
            end tell
          APPLESCRIPT
        end

        run_applescript(script)
        results << { "path" => path, "attribute" => attribute, "value" => value }
      end

      json = JSON.generate(results)
      MCP::Tool::Response.new([{ type: "text", text: json }])
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

  end

end
