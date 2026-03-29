require_relative 'test_helper'

class GetDocumentTest < TinderboxIntegrationTest

  def test_get_document_returns_list
    response = TinderboxMCP::GetDocument.call(server_context: nil)

    refute response.error?, "Expected no error"
    data = JSON.parse(response.content.first[:text])
    assert data.is_a?(Array), "Expected an array of documents"
    assert data.length > 0, "Expected at least one open document"
  end

  def test_get_document_includes_doc_name
    response = TinderboxMCP::GetDocument.call(server_context: nil)
    data = JSON.parse(response.content.first[:text])

    first_doc = data.first
    assert first_doc.key?("doc_name"), "Expected doc_name key"
    assert first_doc["doc_name"].is_a?(String)
    refute first_doc["doc_name"].empty?
  end

  def test_get_document_includes_modified_flag
    response = TinderboxMCP::GetDocument.call(server_context: nil)
    data = JSON.parse(response.content.first[:text])

    first_doc = data.first
    assert first_doc.key?("is_modified"), "Expected is_modified key"
    assert ["true", "false"].include?(first_doc["is_modified"]), "Expected boolean string value"
  end

  def test_get_document_includes_file_path
    response = TinderboxMCP::GetDocument.call(server_context: nil)
    data = JSON.parse(response.content.first[:text])

    first_doc = data.first
    assert first_doc.key?("file_path"), "Expected file_path key"
  end

end
