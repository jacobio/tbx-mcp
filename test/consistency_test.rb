require_relative 'test_helper'

# These tests compare our tbx-mcp tool outputs against the existing
# built-in Tinderbox MCP server to ensure consistent behavior.
#
# The built-in MCP tools are called via their tool_name prefixed with
# mcp__tinderbox__, which is handled by calling them through the
# Tinderbox application's own evaluate/act on AppleScript commands.
#
# Since we can't directly call the built-in MCP server from here,
# we compare our AppleScript-based implementation against the same
# Tinderbox AppleScript APIs that both implementations rely on.
class ConsistencyTest < TinderboxIntegrationTest

  # Test that evaluate returns the same result as direct AppleScript evaluate
  def test_evaluate_matches_direct_applescript
    path = create_test_note("ConsistEval")

    # Our tool
    response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Name",
      note: path,
      server_context: nil
    )
    our_result = response.content.first[:text]

    # Direct AppleScript
    script = <<~APPLESCRIPT
      tell application id "Cere"
        tell document "#{@test_document_name}"
          set noteRef to find note in it with path "#{path}"
          return evaluate noteRef with "$Name"
        end tell
      end tell
    APPLESCRIPT
    direct_result = AppleScriptHelper.run_applescript(script)

    assert_equal direct_result, our_result
  end

  # Test that our get_notes returns consistent info with direct evaluate
  def test_get_notes_path_matches_evaluate
    path = create_test_note("ConsistGetNotes")

    response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      notes: path,
      attributes: "Text;WordCount",
      server_context: nil
    )
    data = parse_response(response)
    note = data.first

    # Verify path matches
    assert_equal path, note["path"]

    # Verify name matches what evaluate returns
    eval_response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Name",
      note: path,
      server_context: nil
    )
    assert_equal eval_response.content.first[:text], note["name"]
  end

  # Test that create_note + get_notes round-trips correctly
  def test_create_then_get_round_trip
    response = TinderboxMCP::CreateNote.call(
      document: @test_document_name,
      name: "#{TEST_NOTE_PREFIX} RoundTrip",
      text: "Round trip content",
      server_context: nil
    )
    created = parse_response(response)
    path = created.first["path"]
    @test_note_paths << path

    # Fetch via get_notes
    get_response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      notes: path,
      attributes: "Text",
      server_context: nil
    )
    fetched = parse_response(get_response)

    assert_equal created.first["name"], fetched.first["name"]
    assert_match(/Round trip content/, fetched.first["Text"])
  end

  # Test that set_value + evaluate round-trips correctly
  def test_set_value_then_evaluate_round_trip
    path = create_test_note("ConsistSetVal")

    TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: path,
      attribute: "Text",
      value: "Consistency test value",
      server_context: nil
    )

    response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Text",
      note: path,
      server_context: nil
    )

    assert_match(/Consistency test value/, response.content.first[:text])
  end

  # Test that do_action and evaluate are consistent
  def test_do_action_then_evaluate_consistent
    path = create_test_note("ConsistDoEval")

    TinderboxMCP::DoAction.call(
      document: @test_document_name,
      action: "$Color='red'",
      note: path,
      server_context: nil
    )

    response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Color",
      note: path,
      server_context: nil
    )

    result = response.content.first[:text]
    # Color should be non-empty after setting
    refute result.empty?, "Expected non-empty color after setting via do_action"
  end

  # Test that create_link is detectable via evaluate
  def test_create_link_detectable_via_evaluate
    src_path = create_test_note("ConsistLinkSrc")
    dest_path = create_test_note("ConsistLinkDest")

    TinderboxMCP::CreateLink.call(
      document: @test_document_name,
      source: src_path,
      destination: dest_path,
      server_context: nil
    )

    # Verify via evaluate
    response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$OutboundLinkCount",
      note: src_path,
      server_context: nil
    )

    assert response.content.first[:text].to_i >= 1
  end

  # Test that get_notes query returns same results as path-based lookup
  def test_query_vs_path_consistency
    path = create_test_note("QueryConsist")

    # Get via path
    path_response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      notes: path,
      server_context: nil
    )
    path_data = parse_response(path_response)

    # Get via query
    query_response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      query: '$Name.contains("QueryConsist")',
      server_context: nil
    )
    query_data = parse_response(query_response)

    # Find our note in query results
    match = query_data.find { |n| n["path"] == path }
    assert match, "Expected to find note in query results"
    assert_equal path_data.first["name"], match["name"]
  end

end
