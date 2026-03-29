require_relative 'test_helper'

class SetValueTest < TinderboxIntegrationTest

  def test_set_value_direct_property_name
    path = create_test_note("SetNameOrig")

    response = TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: path,
      attribute: "Name",
      value: "#{TEST_NOTE_PREFIX} SetNameChanged",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 1, data.length
    assert_equal "Name", data[0]["attribute"]

    # Update tracked path since name changed
    new_path = path.sub("SetNameOrig", "SetNameChanged")
    @test_note_paths << new_path

    # Verify the name changed
    eval_response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Name",
      note: new_path,
      server_context: nil
    )
    assert_match(/SetNameChanged/, eval_response.content.first[:text])
  end

  def test_set_value_direct_property_text
    path = create_test_note("SetText")

    response = TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: path,
      attribute: "Text",
      value: "Updated text content",
      server_context: nil
    )

    refute response.error?

    # Verify the text changed
    eval_response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Text",
      note: path,
      server_context: nil
    )
    assert_match(/Updated text content/, eval_response.content.first[:text])
  end

  def test_set_value_direct_property_color
    path = create_test_note("SetColor")

    response = TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: path,
      attribute: "Color",
      value: "red",
      server_context: nil
    )

    refute response.error?
  end

  def test_set_value_arbitrary_attribute
    path = create_test_note("SetWidth")

    response = TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: path,
      attribute: "Width",
      value: "8",
      server_context: nil
    )

    refute response.error?

    # Verify
    eval_response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Width",
      note: path,
      server_context: nil
    )
    assert_equal "8", eval_response.content.first[:text].strip
  end

  def test_set_value_multiple_notes
    path1 = create_test_note("SetMulti1")
    path2 = create_test_note("SetMulti2")

    response = TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: "#{path1};#{path2}",
      attribute: "Color",
      value: "blue",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal 2, data.length
  end

  def test_set_value_requires_all_params
    assert_raises(ArgumentError) do
      TinderboxMCP::SetValue.call(
        document: @test_document_name,
        notes: "/some/path",
        attribute: "Name",
        server_context: nil
      )
    end
  end

end
