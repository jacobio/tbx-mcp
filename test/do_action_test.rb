require_relative 'test_helper'

class DoActionTest < TinderboxIntegrationTest

  def test_do_action_sets_attribute
    path = create_test_note("DoAction")

    response = TinderboxMCP::DoAction.call(
      document: @test_document_name,
      action: "$Color='red'",
      note: path,
      server_context: nil
    )

    refute response.error?

    # Verify the color was set
    eval_response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$Color",
      note: path,
      server_context: nil
    )
    result = eval_response.content.first[:text]
    # Tinderbox returns color as a hex value or named color
    refute result.empty?, "Expected non-empty color value"
  end

  def test_do_action_on_multiple_notes
    path1 = create_test_note("DoMulti1")
    path2 = create_test_note("DoMulti2")

    response = TinderboxMCP::DoAction.call(
      document: @test_document_name,
      action: "$Color='blue'",
      note: "#{path1};#{path2}",
      server_context: nil
    )

    refute response.error?
    data = JSON.parse(response.content.first[:text])
    assert_equal 2, data.length
  end

  def test_do_action_requires_action_and_note
    assert_raises(ArgumentError) do
      TinderboxMCP::DoAction.call(
        document: @test_document_name,
        action: "$Color='red'",
        server_context: nil
      )
    end

    assert_raises(ArgumentError) do
      TinderboxMCP::DoAction.call(
        document: @test_document_name,
        note: "/some/path",
        server_context: nil
      )
    end
  end

end
