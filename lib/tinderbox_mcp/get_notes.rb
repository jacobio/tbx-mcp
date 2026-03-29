require "apple_script_helper"
require "json"

module TinderboxMCP

  class GetNotes < MCP::Tool

    extend AppleScriptHelper

    description "Get information about notes from the current Tinderbox document, including their parent, children, prototype, and the values of any attributes of interest, such as Path or Text. Aliases of notes, indicated by _italics_, share most attributes of the original note but have their own values of Container, Height, Width, Xpos and Ypos."
    input_schema(
      properties: {
        document: {
          type: "string",
          description: "The name of the Tinderbox document"
        },
        notes: {
          type: "string",
          description: "An optional semicolon-delimited list of one or more note names or paths. Specifying a list of notes is much faster than using a query if the identity of the notes is known. Either query or notes must be specified; if notes are specified, query is ignored."
        },
        query: {
          type: "string",
          description: 'An optional search query for notes, e.g. "$Name.contains(pattern) | $Text.contains(pattern)". Use | for logical or, & for logical and, and ! for logical negation.'
        },
        attributes: {
          type: "string",
          description: "An optional semicolon-delimited list of additional Tinderbox attributes of interest. Include Text to request the text of the note."
        }
      },
      required: ["document"]
    )

    def self.call(document:, notes: nil, query: nil, attributes: nil, server_context:)
      unless notes || query
        return MCP::Tool::Response.new(
          [{ type: "text", text: "Error: Either 'notes' or 'query' must be specified." }],
          error: true
        )
      end

      attr_list = attributes ? split_list(attributes) : []

      # Resolve note paths
      paths = if notes
        split_list(notes)
      else
        resolve_query(document, query)
      end

      # Gather info for each note
      results = paths.map { |path| gather_note_info(document, path, attr_list) }

      json = JSON.generate(results)
      MCP::Tool::Response.new([{ type: "text", text: json }])
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

    private

    # Use Tinderbox's find() designator to resolve a query to paths.
    def self.resolve_query(document, query)
      script = <<~APPLESCRIPT
        tell application id "Cere"
          tell #{doc_target(document)}
            set noteRef to note 1
            set queryStr to "collect(find(#{esc(query)}),$Path)"
            return evaluate noteRef with queryStr
          end tell
        end tell
      APPLESCRIPT

      result = run_applescript(script)
      return [] if result.nil? || result.strip.empty?

      # Result is semicolon-delimited, possibly wrapped in brackets
      split_list(result.sub(/\A\[/, '').sub(/\]\z/, ''))
    end

    # Gather note info (name, path, parent, children, prototype, + requested attributes).
    def self.gather_note_info(document, path, attr_list)
      # Build the list of expressions to evaluate
      exprs = ["$Name", "$Path", "$Name(parent)", "$Prototype", "$ChildCount"]
      attr_list.each { |a| exprs << "$#{a}" unless exprs.include?("$#{a}") }

      # Build AppleScript that evaluates all expressions in one call
      eval_lines = exprs.each_with_index.map do |expr, i|
        "set val#{i} to evaluate noteRef with \"#{esc(expr)}\""
      end

      result_parts = exprs.each_with_index.map do |_, i|
        "val#{i}"
      end

      script = <<~APPLESCRIPT
        tell application id "Cere"
          tell #{doc_target(document)}
            set noteRef to find note in it with path "#{esc(path)}"
            #{eval_lines.join("\n            ")}

            -- Get children names
            set childNames to ""
            set childCount to #{result_parts[4]} as integer
            if childCount > 0 then
              set childNames to evaluate noteRef with "collect(children,$Name)"
            end if

            set delim to "#{DELIM}"
            return #{result_parts.join(' & delim & ')} & delim & childNames
          end tell
        end tell
      APPLESCRIPT

      result = run_applescript(script)
      parts = result.split(DELIM, -1)

      info = {
        "name" => parts[0],
        "path" => parts[1],
        "parent" => parts[2],
        "prototype" => parts[3],
        "child_count" => parts[4].to_i,
      }

      # Map requested attributes
      attr_list.each_with_index do |attr, i|
        info[attr] = parts[5 + i]
      end

      # Children names (last part)
      children_str = parts[5 + attr_list.length] || ""
      info["children"] = if children_str.empty?
        []
      else
        split_list(children_str.sub(/\A\[/, '').sub(/\]\z/, ''))
      end

      info
    end

    DELIM = "%%DELIM%%"

  end

end
