require "apple_script_helper"
require "base64"
require "tempfile"

module TinderboxMCP

  class GetView < MCP::Tool

    extend AppleScriptHelper

    description "Return an image of the user's current view, typically a 2-dimensional diagram of the notes within a Tinderbox container. Optionally navigate into a specific container before capturing."
    input_schema(
      properties: {
        document: {
          type: "string",
          description: "The name of the Tinderbox document"
        },
        container: {
          type: "string",
          description: "Path to a container to navigate into before capturing. The view will drill into this container and show its contents."
        }
      },
      required: ["document"]
    )

    def self.call(document:, container: nil, server_context:)
      # Navigate into the container if requested
      if container
        navigate_to_container(document, container)
      end

      # Get the window ID for the target document.
      # Windows are at the application level, not the document level.
      script = <<~APPLESCRIPT
        tell application id "Cere"
          set docWindow to missing value
          repeat with w in (every window)
            try
              if name of document of w is "#{esc(document)}" then
                set docWindow to w
                exit repeat
              end if
            end try
          end repeat
          if docWindow is missing value then
            error "No window found for document: #{esc(document)}"
          end if
          return id of docWindow
        end tell
      APPLESCRIPT

      window_id = run_applescript(script)

      # Capture the window to a temporary file
      tmpfile = File.join(Dir.tmpdir, "tbx_view_#{Process.pid}_#{Time.now.strftime('%s%N')}.png")
      begin
        system("screencapture", "-l", window_id.to_s, tmpfile)
        raise "screencapture failed" unless File.exist?(tmpfile) && File.size(tmpfile) > 0

        image_data = File.binread(tmpfile)
        base64_image = Base64.strict_encode64(image_data)

        MCP::Tool::Response.new([{ type: "image", data: base64_image, mimeType: "image/png" }])
      ensure
        File.delete(tmpfile) if File.exist?(tmpfile)
      end
    rescue StandardError => e
      MCP::Tool::Response.new([{ type: "text", text: "Error: #{e.message}" }], error: true)
    end

    private

    # Navigate into a container by selecting a child note within it.
    # select(this) on a child causes Tinderbox to drill into the container's view.
    def self.navigate_to_container(document, container)
      script = <<~APPLESCRIPT
        tell application id "Cere"
          tell #{doc_target(document)}
            set containerRef to find note in it with path "#{esc(container)}"
            set childNotes to every note of containerRef
            if (count of childNotes) > 0 then
              set childRef to item 1 of childNotes
              act on childRef with "select(this)"
            else
              act on containerRef with "select(this)"
            end if
          end tell
        end tell
      APPLESCRIPT
      run_applescript(script)
      sleep 0.5
    end

  end

end
