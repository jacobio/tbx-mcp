require_relative 'test_helper'

class CreateLinkTest < TinderboxIntegrationTest

  def test_create_link_between_notes
    src_path = create_test_note("LinkSource")
    dest_path = create_test_note("LinkDest")

    response = TinderboxMCP::CreateLink.call(
      document: @test_document_name,
      source: src_path,
      destination: dest_path,
      server_context: nil
    )

    data = parse_response(response)
    assert_match(/LinkSource/, data["source_name"])
    assert_match(/LinkDest/, data["destination_name"])

    # Verify the link exists
    eval_response = TinderboxMCP::Evaluate.call(
      document: @test_document_name,
      expression: "$OutboundLinkCount",
      note: src_path,
      server_context: nil
    )
    assert eval_response.content.first[:text].to_i >= 1, "Expected at least one outbound link"
  end

  def test_create_link_with_type
    src_path = create_test_note("TypedLinkSrc")
    dest_path = create_test_note("TypedLinkDest")

    response = TinderboxMCP::CreateLink.call(
      document: @test_document_name,
      source: src_path,
      destination: dest_path,
      type: "agree",
      server_context: nil
    )

    data = parse_response(response)
    assert_match(/TypedLinkSrc/, data["source_name"])
    assert_match(/TypedLinkDest/, data["destination_name"])
  end

  def test_create_link_requires_source_and_destination
    assert_raises(ArgumentError) do
      TinderboxMCP::CreateLink.call(
        document: @test_document_name,
        source: "/some/path",
        server_context: nil
      )
    end

    assert_raises(ArgumentError) do
      TinderboxMCP::CreateLink.call(
        document: @test_document_name,
        destination: "/some/path",
        server_context: nil
      )
    end
  end

end
