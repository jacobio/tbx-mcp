require "apple_script_helper"

module TinderboxMCP

  class Evaluate < MCP::Tool

    extend AppleScriptHelper

    description "Evaluate a Tinderbox expression in the context of a Tinderbox note."
    input_schema(
      properties: {
        document: {
          type: "string",
          description: "The name of the Tinderbox document"
        },
        expression: {
          type: "string",
          description: "A Tinderbox expression to evaluate. Examples: $Name, $WordCount, $Width*$Height, $Name(parent)+':'+$Name"
        },
        note: {
          type: "string",
          description: "A name or path (preferred), or a semicolon-delimited list, of the note(s) to evaluate against. If omitted, evaluates against the first note in the document."
        }
      },
      required: ["document", "expression"]
    )

    def self.call(document:, expression:, note: nil, server_context:)
      note_refs = note ? split_list(note) : [nil]
      results = []

      note_refs.each do |note_ref|
        find_note = if note_ref
          "set noteRef to find note in it with path \"#{esc(note_ref)}\""
        else
          "set noteRef to note 1"
        end

        script = <<~APPLESCRIPT
          tell application id "Cere"
            tell #{doc_target(document)}
              #{find_note}
              set exprStr to "#{esc(expression)}"
              return evaluate noteRef with exprStr
            end tell
          end tell
        APPLESCRIPT

        result = run_applescript(script)
        results << { "note" => note_ref || "(first note)", "result" => result }
      end

      if results.length == 1
        MCP::Tool::Response.new([{ type: "text", text: results.first["result"] }])
      else
        json = JSON.generate(results)
        MCP::Tool::Response.new([{ type: "text", text: json }])
      end
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

  end

end
