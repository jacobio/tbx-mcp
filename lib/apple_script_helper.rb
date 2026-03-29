require "open3"

module AppleScriptHelper

  # Runs an AppleScript string via the `osascript` command and returns the
  # trimmed standard output. Raises an error when the script fails.
  def run_applescript(script)
    stdout, stderr, status = Open3.capture3("osascript", "-e", script)
    raise "AppleScript error: #{stderr}" unless status.success?
    stdout.strip
  end

  # Escapes double quotes in the given string so it can be safely interpolated
  # into an AppleScript snippet.
  def esc(str)
    str.to_s.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
  end

  # Returns an AppleScript `tell` target for a named document.
  # Always targets a specific document by name — no `front document` fallback.
  def doc_target(document_name)
    "document \"#{esc(document_name)}\""
  end

  # Returns a block of AppleScript helper functions used by multiple tools,
  # including a utility for converting AppleScript records to JSON.
  def script_functions
    <<~APPLESCRIPT
      use framework "Foundation"
      use scripting additions

      -- Convert an AppleScript record to JSON using Foundation framework
      on toJSON(recordValue)
        if class of recordValue is not record then
          error "toJSON requires a record, but received: " & (class of recordValue as text)
        end if
        set nsDict to current application's NSDictionary's dictionaryWithDictionary:recordValue
        set jsonData to current application's NSJSONSerialization's dataWithJSONObject:nsDict options:0 |error|:(missing value)
        set jsonString to current application's NSString's alloc()'s initWithData:jsonData encoding:(current application's NSUTF8StringEncoding)
        return jsonString as text
      end toJSON

      -- Convert an AppleScript list of records to a JSON array.
      -- Each item in listValue must be a record.
      on toJSONArray(listValue)
        set nsArray to current application's NSMutableArray's new()
        repeat with rec in listValue
          set nsDict to current application's NSDictionary's dictionaryWithDictionary:rec
          (nsArray's addObject:nsDict)
        end repeat
        set jsonData to current application's NSJSONSerialization's dataWithJSONObject:nsArray options:0 |error|:(missing value)
        set jsonString to current application's NSString's alloc()'s initWithData:jsonData encoding:(current application's NSUTF8StringEncoding)
        return jsonString as text
      end toJSONArray
    APPLESCRIPT
  end

  # Splits a semicolon-delimited parameter string into a clean array,
  # stripping whitespace and rejecting empty entries.
  def split_list(str)
    str.to_s.split(";").map(&:strip).reject(&:empty?)
  end

  module_function :run_applescript, :esc, :doc_target, :script_functions, :split_list

end
