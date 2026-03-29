require_relative 'test_helper'

class AppleScriptHelperTest < Minitest::Test

  def test_esc_escapes_double_quotes
    assert_equal 'He said \\"hello\\"', AppleScriptHelper.esc('He said "hello"')
  end

  def test_esc_handles_nil
    assert_equal "", AppleScriptHelper.esc(nil)
  end

  def test_esc_handles_symbols
    assert_equal "test", AppleScriptHelper.esc(:test)
  end

  def test_esc_escapes_backslashes
    assert_equal "path\\\\to\\\\file", AppleScriptHelper.esc('path\\to\\file')
  end

  def test_doc_target_returns_document_reference
    assert_equal 'document "MyDoc"', AppleScriptHelper.doc_target("MyDoc")
  end

  def test_doc_target_escapes_quotes_in_name
    assert_equal 'document "My \\"Doc\\""', AppleScriptHelper.doc_target('My "Doc"')
  end

  def test_script_functions_includes_toJSON
    assert_match(/on toJSON/, AppleScriptHelper.script_functions)
  end

  def test_script_functions_includes_toJSONArray
    assert_match(/on toJSONArray/, AppleScriptHelper.script_functions)
  end

  def test_script_functions_uses_foundation_framework
    assert_match(/use framework "Foundation"/, AppleScriptHelper.script_functions)
  end

  def test_run_applescript_returns_output
    result = AppleScriptHelper.run_applescript('return "hello"')
    assert_equal "hello", result
  end

  def test_run_applescript_raises_on_error
    assert_raises(RuntimeError) do
      AppleScriptHelper.run_applescript('error "test error"')
    end
  end

end
