require_relative 'test_helper'

class CreateTextLinkTest < TinderboxIntegrationTest

  def test_create_text_link_basic
    src_path = create_test_note("TLSource")
    dest_path = create_test_note("TLDest")

    # Set text on source
    TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: src_path,
      attribute: "Text",
      value: "This note discusses Vienna and European philosophy.",
      server_context: nil
    )

    response = TinderboxMCP::CreateTextLink.call(
      document: @test_document_name,
      source: src_path,
      destination: dest_path,
      regex: "Vienna",
      server_context: nil
    )

    data = parse_response(response)
    assert_match(/TLSource/, data["source_name"])
    assert_match(/TLDest/, data["destination_name"])
    assert_equal "Vienna", data["regex_pattern"]
    assert data["links_after"].to_i > data["links_before"].to_i, "Expected link count to increase"
  end

  def test_create_text_link_with_type
    src_path = create_test_note("TLTypeSrc")
    dest_path = create_test_note("TLTypeDest")

    TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: src_path,
      attribute: "Text",
      value: "A note about music and composers.",
      server_context: nil
    )

    response = TinderboxMCP::CreateTextLink.call(
      document: @test_document_name,
      source: src_path,
      destination: dest_path,
      regex: "music",
      type: "references",
      server_context: nil
    )

    refute response.error?, "Expected no error, but got: #{response.content.first[:text]}"
    data = JSON.parse(response.content.first[:text])
    assert_equal "references", data["link_type"]
    assert data["links_after"].to_i > data["links_before"].to_i, "links_before=#{data['links_before']} links_after=#{data['links_after']}"
  end

  def test_create_text_link_with_regex_pattern
    src_path = create_test_note("TLRegexSrc")
    dest_path = create_test_note("TLRegexDest")

    TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: src_path,
      attribute: "Text",
      value: "The intellectual thought of the era was remarkable.",
      server_context: nil
    )

    response = TinderboxMCP::CreateTextLink.call(
      document: @test_document_name,
      source: src_path,
      destination: dest_path,
      regex: "intellect.*thought",
      server_context: nil
    )

    data = parse_response(response)
    assert data["links_after"].to_i > data["links_before"].to_i, "Expected regex pattern to match and create link"
  end

  def test_create_text_link_no_match_no_link
    src_path = create_test_note("TLNoMatch")
    dest_path = create_test_note("TLNoMatchDest")

    TinderboxMCP::SetValue.call(
      document: @test_document_name,
      notes: src_path,
      attribute: "Text",
      value: "Simple text with no special words.",
      server_context: nil
    )

    response = TinderboxMCP::CreateTextLink.call(
      document: @test_document_name,
      source: src_path,
      destination: dest_path,
      regex: "ZZZNOMATCH",
      server_context: nil
    )

    data = parse_response(response)
    assert_equal data["links_before"], data["links_after"], "Expected no link when regex doesn't match"
  end

  def test_create_text_link_requires_all_params
    assert_raises(ArgumentError) do
      TinderboxMCP::CreateTextLink.call(
        document: @test_document_name,
        source: "/some/path",
        destination: "/other/path",
        server_context: nil
      )
    end
  end

end
