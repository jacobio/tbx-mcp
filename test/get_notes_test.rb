require_relative 'test_helper'

class GetNotesTest < TinderboxIntegrationTest

  def test_get_notes_by_path
    path = create_test_note("GetByPath")

    response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      notes: path,
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 1, data.length
    assert_match(/GetByPath/, data[0]["name"])
    assert_equal path, data[0]["path"]
  end

  def test_get_notes_with_attributes
    path = create_test_note("GetWithAttrs")

    # Set some text on the note
    script = <<~APPLESCRIPT
      tell application id "Cere"
        tell document "#{@test_document_name}"
          set noteRef to find note in it with path "#{path}"
          set text of noteRef to "Some test text content"
        end tell
      end tell
    APPLESCRIPT
    AppleScriptHelper.run_applescript(script)

    response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      notes: path,
      attributes: "Text;WordCount",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 1, data.length
    assert data[0].key?("Text"), "Expected Text attribute"
    assert data[0].key?("WordCount"), "Expected WordCount attribute"
    assert_match(/Some test text/, data[0]["Text"])
  end

  def test_get_notes_multiple_paths
    path1 = create_test_note("GetMulti1")
    path2 = create_test_note("GetMulti2")

    response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      notes: "#{path1};#{path2}",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 2, data.length
    assert_match(/GetMulti1/, data[0]["name"])
    assert_match(/GetMulti2/, data[1]["name"])
  end

  def test_get_notes_by_query
    create_test_note("QueryTarget")

    response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      query: '$Name.contains("QueryTarget")',
      server_context: nil
    )

    data = parse_response(response)
    assert data.length >= 1, "Expected at least one result from query"
    assert data.any? { |n| n["name"].include?("QueryTarget") }
  end

  def test_get_notes_requires_notes_or_query
    response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      server_context: nil
    )

    assert response.error?, "Expected error when neither notes nor query provided"
  end

  def test_get_notes_includes_parent_and_children
    path = create_test_note("ParentNote")
    create_test_note("ChildNote", container: path)

    response = TinderboxMCP::GetNotes.call(
      document: @test_document_name,
      notes: path,
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 1, data.length
    assert data[0]["child_count"] >= 1, "Expected at least one child"
    assert data[0]["children"].any? { |c| c.include?("ChildNote") }, "Expected child note in children list"
  end

end
