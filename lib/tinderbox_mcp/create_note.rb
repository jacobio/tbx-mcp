require "apple_script_helper"
require "json"

module TinderboxMCP

  class CreateNote < MCP::Tool

    extend AppleScriptHelper

    description "Create a new note in Tinderbox"
    input_schema(
      properties: {
        document: {
          type: "string",
          description: "The name of the Tinderbox document"
        },
        name: {
          type: "string",
          description: "Note title, or a list of note titles separated by semicolons"
        },
        container: {
          type: "string",
          description: "Path (preferred) or name of parent container (optional)"
        },
        kind: {
          type: "string",
          description: "One of 'note', 'adornment', or 'agent'. Defaults to 'note'."
        },
        text: {
          type: "string",
          description: "Note content"
        }
      },
      required: ["document", "name"]
    )

    def self.call(document:, name:, container: nil, kind: "note", text: nil, server_context:)
      names = split_list(name)
      results = []

      names.each do |note_name|
        # Determine the kind of note to create
        kind_class = case kind.downcase
          when "agent" then "agent"
          when "adornment" then "adornment"
          else "note"
        end

        # Build the creation target
        target = if container
          "set containerRef to find note in it with path \"#{esc(container)}\"\n" +
          "            set newNote to make new #{kind_class} at containerRef with properties {name:\"#{esc(note_name)}\"}"
        else
          "set newNote to make new #{kind_class} with properties {name:\"#{esc(note_name)}\"}"
        end

        # Build text setting if provided
        text_line = text ? "\n            set text of newNote to \"#{esc(text)}\"" : ""

        script = <<~APPLESCRIPT
          tell application id "Cere"
            tell #{doc_target(document)}
              #{target}#{text_line}
              return my evalPath(newNote)
            end tell
          end tell

          on evalPath(noteRef)
            tell application id "Cere"
              return evaluate noteRef with "$Path"
            end tell
          end evalPath
        APPLESCRIPT

        path = run_applescript(script)
        results << { "name" => note_name, "path" => path }
      end

      json = JSON.generate(results)
      MCP::Tool::Response.new([{ type: "text", text: json }])
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

  end

end
