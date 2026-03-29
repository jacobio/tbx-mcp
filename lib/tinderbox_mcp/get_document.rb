require "apple_script_helper"

module TinderboxMCP

  class GetDocument < MCP::Tool

    extend AppleScriptHelper

    description "Get information on the current Tinderbox document, and a list of other available documents."
    input_schema(
      properties: {}
    )

    def self.call(server_context:)
      script = <<~APPLESCRIPT
        #{script_functions}

        tell application id "Cere"
          set docList to {}
          repeat with d in every document
            set docName to name of d
            -- Convert boolean to string for safe JSON serialization
            if modified of d then
              set docModified to "true"
            else
              set docModified to "false"
            end if
            set docFile to ""
            try
              set f to file of d
              if f is not missing value then
                set docFile to (f as text)
              end if
            end try
            set end of docList to {doc_name:docName, is_modified:docModified, file_path:docFile}
          end repeat
          return my toJSONArray(docList)
        end tell
      APPLESCRIPT

      result = run_applescript(script)
      MCP::Tool::Response.new([{ type: "text", text: result }])
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

  end

end
