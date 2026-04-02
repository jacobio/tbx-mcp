require_relative 'test_helper'

class EvaluateTest < TinderboxIntegrationTest

  def test_evaluate_attribute_expression
    path = create_test_note("EvalAttr")

    response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Name",
      note: path,
      server_context: nil
    )

    refute response.error?
    assert_match(/\[MCP-TEST\] EvalAttr/, response.content.first[:text])
  end

  def test_evaluate_computed_expression
    path = create_test_note("EvalComputed")

    response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$ChildCount",
      note: path,
      server_context: nil
    )

    refute response.error?
    assert_equal "0", response.content.first[:text]
  end

  def test_evaluate_on_multiple_notes
    path1 = create_test_note("EvalMulti1")
    path2 = create_test_note("EvalMulti2")

    response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Name",
      note: "#{path1};#{path2}",
      server_context: nil
    )

    refute response.error?
    data = JSON.parse(response.content.first[:text])
    assert_equal 2, data.length
    assert_match(/EvalMulti1/, data[0]["result"])
    assert_match(/EvalMulti2/, data[1]["result"])
  end

  def test_evaluate_without_note_uses_first_note
    # Ensure at least one note exists
    create_test_note("EvalDefault")

    response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Name",
      server_context: nil
    )

    refute response.error?
    # Should return a name string (whatever the first note is)
    assert response.content.first[:text].is_a?(String)
    refute response.content.first[:text].empty?
  end

  def test_evaluate_requires_expression
    assert_raises(ArgumentError) do
      TinderboxMCP::Evaluate.call(
        document: @test_document_name,
        server_context: nil
      )
    end
  end

  def test_evaluate_requires_document
    assert_raises(ArgumentError) do
      TinderboxMCP::Evaluate.call(
        expression: "$Name",
        server_context: nil
      )
    end
  end

end
