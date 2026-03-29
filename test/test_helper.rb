require 'minitest/autorun'
require 'json'
require 'open3'

# Minimal stubs for MCP classes used by the tools.
module MCP
  class Tool
    def self.description(_desc); end
    def self.input_schema(_schema); end
    def self.tool_name(_name = nil); end

    class Response
      attr_reader :content

      def initialize(content = nil, error: false)
        @content = content || []
        @error = error
      end

      def error?
        !!@error
      end
    end
  end
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'tinderbox_mcp'

# Base test class that provides Tinderbox integration test helpers.
class TinderboxIntegrationTest < Minitest::Test
  # Prefix for test notes, easily identifiable for cleanup.
  TEST_NOTE_PREFIX = "[MCP-TEST]"

  def setup
    @test_note_paths = []
    @test_document_name = discover_test_document
  end

  def teardown
    cleanup_test_notes
  end

  # Discover the name of an open Tinderbox document to use for testing.
  # Raises if no documents are open.
  def discover_test_document
    script = <<~APPLESCRIPT
      tell application id "Cere"
        if (count of documents) is 0 then
          error "No Tinderbox documents are open. Please open a document for testing."
        end if
        return name of document 1
      end tell
    APPLESCRIPT
    AppleScriptHelper.run_applescript(script)
  end

  # Create a test note and track its path for cleanup.
  def create_test_note(name, container: nil)
    full_name = "#{TEST_NOTE_PREFIX} #{name}"
    doc = AppleScriptHelper.esc(@test_document_name)

    script = if container
      <<~APPLESCRIPT
        tell application id "Cere"
          tell document "#{doc}"
            set containerRef to find note in it with path "#{AppleScriptHelper.esc(container)}"
            set newNote to make new note at containerRef with properties {name:"#{AppleScriptHelper.esc(full_name)}"}
            return my evalPath(newNote)
          end tell
        end tell

        on evalPath(noteRef)
          tell application id "Cere"
            return evaluate noteRef with "$Path"
          end tell
        end evalPath
      APPLESCRIPT
    else
      <<~APPLESCRIPT
        tell application id "Cere"
          tell document "#{doc}"
            set newNote to make new note with properties {name:"#{AppleScriptHelper.esc(full_name)}"}
            return my evalPath(newNote)
          end tell
        end tell

        on evalPath(noteRef)
          tell application id "Cere"
            return evaluate noteRef with "$Path"
          end tell
        end evalPath
      APPLESCRIPT
    end

    path = AppleScriptHelper.run_applescript(script)
    @test_note_paths << path
    path
  end

  # Clean up all test notes in reverse creation order.
  def cleanup_test_notes
    doc = AppleScriptHelper.esc(@test_document_name)

    @test_note_paths.reverse.each do |path|
      script = <<~APPLESCRIPT
        tell application id "Cere"
          tell document "#{doc}"
            try
              set noteRef to find note in it with path "#{AppleScriptHelper.esc(path)}"
              delete noteRef
            end try
          end tell
        end tell
      APPLESCRIPT
      AppleScriptHelper.run_applescript(script) rescue nil
    end

    # Also clean up any orphaned test notes from previous runs
    cleanup_orphaned_test_notes
  end

  # Remove any notes whose name starts with the test prefix.
  def cleanup_orphaned_test_notes
    doc = AppleScriptHelper.esc(@test_document_name)

    script = <<~APPLESCRIPT
      tell application id "Cere"
        tell document "#{doc}"
          set noteRef to note 1
          set orphanPaths to evaluate noteRef with "collect(find($Name.beginsWith(\\"#{TEST_NOTE_PREFIX}\\")),$Path)"
        end tell
      end tell
    APPLESCRIPT
    result = AppleScriptHelper.run_applescript(script) rescue ""
    return if result.nil? || result.empty?

    # Parse semicolon-delimited path list (may be wrapped in brackets)
    paths = AppleScriptHelper.split_list(result.sub(/\A\[/, '').sub(/\]\z/, ''))
    paths.each do |path|
      script = <<~APPLESCRIPT
        tell application id "Cere"
          tell document "#{doc}"
            try
              set noteRef to find note in it with path "#{AppleScriptHelper.esc(path)}"
              delete noteRef
            end try
          end tell
        end tell
      APPLESCRIPT
      AppleScriptHelper.run_applescript(script) rescue nil
    end
  end

  # Parse a text tool response as JSON.
  def parse_response(response)
    refute response.error?, "Expected no error, but got: #{response.content.first[:text]}"
    JSON.parse(response.content.first[:text])
  end

  # Assert that a response is an image.
  def assert_image_response(response)
    refute response.error?, "Expected no error"
    output = response.content.first
    assert_equal "image", output[:type]
    assert output[:data].is_a?(String), "Expected base64 image data"
    assert output[:data].length > 0, "Expected non-empty image data"
  end
end
