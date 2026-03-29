require_relative 'test_helper'

class CreateNoteTest < TinderboxIntegrationTest

  def test_create_note_at_root
    response = TinderboxMCP::CreateNote.call(
      document: @test_document_name,
      name: "#{TEST_NOTE_PREFIX} RootNote",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 1, data.length
    assert_match(/RootNote/, data[0]["name"])
    assert data[0]["path"].is_a?(String)
    @test_note_paths << data[0]["path"]
  end

  def test_create_note_in_container
    container_path = create_test_note("Container")

    response = TinderboxMCP::CreateNote.call(
      document: @test_document_name,
      name: "#{TEST_NOTE_PREFIX} InContainer",
      container: container_path,
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 1, data.length
    assert data[0]["path"].start_with?(container_path), "Expected note to be inside container"
    @test_note_paths << data[0]["path"]
  end

  def test_create_note_with_text
    response = TinderboxMCP::CreateNote.call(
      document: @test_document_name,
      name: "#{TEST_NOTE_PREFIX} WithText",
      text: "This is the note body",
      server_context: nil
    )

    data = parse_response(response)
    path = data[0]["path"]
    @test_note_paths << path

    # Verify the text was set
    eval_response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Text",
      note: path,
      server_context: nil
    )
    assert_match(/This is the note body/, eval_response.content.first[:text])
  end

  def test_create_note_batch
    response = TinderboxMCP::CreateNote.call(
      document: @test_document_name,
      name: "#{TEST_NOTE_PREFIX} Batch1;#{TEST_NOTE_PREFIX} Batch2;#{TEST_NOTE_PREFIX} Batch3",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 3, data.length
    data.each { |n| @test_note_paths << n["path"] }
  end

  def test_create_agent
    response = TinderboxMCP::CreateNote.call(
      document: @test_document_name,
      name: "#{TEST_NOTE_PREFIX} TestAgent",
      kind: "agent",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 1, data.length
    @test_note_paths << data[0]["path"]

    # Verify it's an agent by checking $IsAgent
    eval_response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$IsAgent",
      note: data[0]["path"],
      server_context: nil
    )
    assert_match(/true/i, eval_response.content.first[:text])
  end

  def test_create_adornment
    response = TinderboxMCP::CreateNote.call(
      document: @test_document_name,
      name: "#{TEST_NOTE_PREFIX} TestAdorn",
      kind: "adornment",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 1, data.length
    @test_note_paths << data[0]["path"]
  end

  def test_create_note_requires_name
    assert_raises(ArgumentError) do
      TinderboxMCP::CreateNote.call(
        document: @test_document_name,
        server_context: nil
      )
    end
  end

  def test_create_note_requires_document
    assert_raises(ArgumentError) do
      TinderboxMCP::CreateNote.call(
        name: "#{TEST_NOTE_PREFIX} NoDoc",
        server_context: nil
      )
    end
  end

end
