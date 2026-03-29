require_relative 'test_helper'

class GetViewTest < TinderboxIntegrationTest

  def test_get_view_returns_image
    response = TinderboxMCP::GetView.call(
      document: @test_document_name,
      server_context: nil
    )

    assert_image_response(response)
  end

  def test_get_view_returns_png_mime_type
    response = TinderboxMCP::GetView.call(
      document: @test_document_name,
      server_context: nil
    )

    refute response.error?
    output = response.content.first
    assert_equal "image", output[:type]
    assert_equal "image/png", output[:mimeType]
  end

  def test_get_view_requires_document
    assert_raises(ArgumentError) do
      TinderboxMCP::GetView.call(server_context: nil)
    end
  end

end
