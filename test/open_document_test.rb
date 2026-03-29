require_relative 'test_helper'

class OpenDocumentTest < TinderboxIntegrationTest

  def test_open_document_requires_path
    assert_raises(ArgumentError) do
      TinderboxMCP::OpenDocument.call(server_context: nil)
    end
  end

  def test_open_document_errors_on_nonexistent_file
    response = TinderboxMCP::OpenDocument.call(
      path: "/nonexistent/path/fake.tbx",
      server_context: nil
    )

    assert response.error?, "Expected error for nonexistent file"
  end

end
