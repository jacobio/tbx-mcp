# Tinderbox Action Code Functions Reference

Comprehensive catalog of Tinderbox action code functions usable in `evaluate` and `act on` via AppleScript. Organized by category with AppleScript examples for key functions.

**Calling pattern**: `evaluate noteRef with "expression"` for reading, `act on noteRef with "action"` for writing.

**Live-tested discoveries** are marked with a test tube icon and documented in `scripts/test-action-code.sh`.

---

## 1. String Operators (~60)

### Case/Character

| Function | Description | Example |
|----------|-------------|---------|
| `.uppercase()` | Convert to uppercase | `$Name.uppercase()` |
| `.lowercase()` | Convert to lowercase | `$Name.lowercase()` |
| `.capitalize()` | Capitalize first letter of each word | `$Name.capitalize()` |
| `.tr(inStr[,outStr])` | Transliterate characters | `$Name.tr("abc","xyz")` |

### Search/Match

| Function | Returns | Description |
|----------|---------|-------------|
| `.contains(regex)` | **Position** (1-based int) or `0` | Substring/regex search |
| `.icontains(regex)` | Position or `0` | Case-insensitive contains |
| `.beginsWith(str)` | Boolean | Starts with string |
| `.endsWith(str)` | Boolean | Ends with string |
| `.containsAnyOf(regexList)` | Boolean | Matches any pattern in list |
| `.icontainsAnyOf(regexList)` | Boolean | Case-insensitive version |
| `.find(str)` | Position | Find position of substring |
| `.countOccurrencesOf(str)` | Number | Count occurrences |
| `.empty()` | Boolean | Is empty string |

> **Live-tested**: `.contains()` returns the **1-based character position** of the match, NOT `"true"/"false"`. Returns `0` when not found on strings. On sets, returns the 1-based item position or empty string when not found.

```applescript
-- .contains() returns position, not boolean
set pos to evaluate noteRef with "$Name.contains(\"ACTION\")"
-- pos = "7" (1-based position), not "true"
```

### Extraction/Modification

| Function | Description |
|----------|-------------|
| `.extract(regex[,caseInsensitive])` | Extract first regex match |
| `.extractAll(regex[,caseInsensitive])` | Extract all regex matches |
| `.following(str)` | Text after first occurrence of str |
| `.replace(regex,replacement)` | Replace matches |
| `.substr(start[,len])` | Substring (0-based start) |
| `.trim([filter])` | Trim whitespace (or specified chars) |
| `.reverse()` | Reverse string |
| `.split(regex)` | Split into list by delimiter/regex |
| `.deleteCharacters(charSet)` | Remove specified characters |

```applescript
-- Replace
evaluate noteRef with "$Text.replace(\"World\",\"Earth\")"
-- Substring
evaluate noteRef with "$Name.substr(0,5)"
-- Trim
evaluate noteRef with "\" hello \".trim()"
```

### Text Structure

| Function | Returns | Description |
|----------|---------|-------------|
| `.wordCount` or `.wordCount()` | Number | Count words |
| `.wordList()` | List | All words |
| `.words(N)` | String | First N words |
| `.paragraphCount` or `.paragraphCount()` | Number | Count paragraphs |
| `.paragraphList()` | List | All paragraphs |
| `.paragraph(N)` | String | Nth paragraph |
| `.paragraphs(N)` | String | First N paragraphs |
| `.sentence([N])` | String | Nth sentence (or first) |
| `.sentences()` | List | All sentences |
| `.nounList()` | List | Extracted nouns (NLP) |

### Conversion

| Function | Description |
|----------|-------------|
| `.toNumber()` | Convert string to number |
| `.json()` | Parse as JSON |
| `.jsonEncode()` | Encode string for JSON |

### Output

| Function | Description |
|----------|-------------|
| `.format()` | Format value |
| `.size` or `.size()` | Character count |
| `.show([bg,color,duration])` | Display in Tinderbox UI |
| `.speak([voice])` | Speak with text-to-speech |
| `.highlights([color])` | Apply text highlights |

### Stream Parsing (Capture)

For parsing structured text content progressively:

| Function | Description |
|----------|-------------|
| `.captureJson()` | Capture JSON value |
| `.captureXML()` | Capture XML element |
| `.captureLine([attr])` | Capture current line |
| `.captureWord([attr])` | Capture next word |
| `.captureToken([attr])` | Capture next token |
| `.captureNumber([attr])` | Capture next number |
| `.captureTo(match[,attr])` | Capture up to match string |
| `.captureRest([attr])` | Capture remaining text |

### Stream Parsing (Expect/Skip)

| Function | Description |
|----------|-------------|
| `.expect(str)` | Assert next text matches |
| `.expectNumber()` | Assert next token is number |
| `.expectWord()` | Assert next token is word |
| `.expectWhitespace()` | Assert next is whitespace |
| `.skip(N)` | Skip N characters |
| `.skipLine()` | Skip to end of line |
| `.skipTo(str)` | Skip to match string |
| `.skipToNumber()` | Skip to next number |
| `.skipWhitespace()` | Skip whitespace |

### Stream Control

| Function | Description |
|----------|-------------|
| `.try{actions}[.thenTry{actions}]` | Try parsing, fallback |
| `.failed()` | Check if parse failed |
| `.next()` | Advance parse position |

### Iteration

| Function | Description |
|----------|-------------|
| `.eachLine(loopVar[:condition]){actions}` | Iterate lines |

---

## 2. Number/Math Operators (~20)

### Standalone Functions

| Function | Description |
|----------|-------------|
| `abs(n)` | Absolute value |
| `ceil(n)` | Round up to integer |
| `floor(n)` | Round down to integer |
| `round(n)` | Round to nearest integer |
| `sqrt(n)` | Square root |
| `pow(base,exp)` | Power |
| `exp(n)` | Euler's number raised to n |
| `log(n)` | Natural logarithm |
| `mod(a,b)` | Modulo (remainder) |
| `rand()` | Random number 0-1 |
| `between(val,low,high)` | Value within range |
| `sin(n)` / `cos(n)` / `tan(n)` / `atan(n)` | Trigonometry (radians) |
| `degrees(rad)` / `radians(deg)` | Angle conversion |

> **Live-tested**: `mod(17,5)` returns `"2"`. The `%` operator does NOT work as modulo — it returns the literal string.

> **Live-tested**: `max(a,b)` and `min(a,b)` as standalone 2-arg functions do NOT work as value comparisons — `max(10,20)` returns `"10"`. Use `.max`/`.min` on collected lists instead (see List Operators).

```applescript
-- abs and round
evaluate noteRef with "abs(-42)"    -- "42"
evaluate noteRef with "round(3.7)"  -- "4"
evaluate noteRef with "mod(17,5)"   -- "2"
evaluate noteRef with "(10+20)*2"   -- "60"
```

### Arithmetic Operators

```
+    addition
-    subtraction
*    multiplication
/    division
```

> **Note**: `%` is NOT modulo. Use `mod(a,b)` instead.

### Number Dot Operators

| Function | Description |
|----------|-------------|
| `Number.ceil()` | Round up |
| `Number.floor()` | Round down |
| `Number.round()` | Round to nearest |
| `Number.precision(decimals)` | Set decimal places |
| `Number.format(decimals[,width,pad])` | Format number |

---

## 3. Date/Time Operators (~30)

### Creation

```applescript
evaluate noteRef with "date(\"today\")"
evaluate noteRef with "date(\"now\")"
evaluate noteRef with "date(\"yesterday\")"
evaluate noteRef with "date(\"tomorrow\")"
evaluate noteRef with "date(\"next week\")"
evaluate noteRef with "date(\"2025-03-15\")"
```

### Date Dot Operators

| Function | Returns | Description |
|----------|---------|-------------|
| `.day` or `.day()` | Number | Day of month (1-31) |
| `.month` or `.month()` | Number | Month (1-12) |
| `.year` or `.year()` | Number | Year |
| `.hour` or `.hour()` | Number | Hour (0-23) |
| `.minute` or `.minute()` | Number | Minute (0-59) |
| `.second` or `.second()` | Number | Second (0-59) |
| `.week` or `.week()` | Number | Week of year |
| `.weekday` or `.weekday()` | Number | 1=Monday through 7=Sunday |
| `.format(formatStr)` | String | Format date |

```applescript
evaluate noteRef with "$Created.day"                 -- "11"
evaluate noteRef with "$Created.year"                -- "2026"
evaluate noteRef with "date(\"today\").format(\"y\")"    -- "2026"
evaluate noteRef with "$Created.format(\"y-MM-dd\")"   -- "2026-02-11"
```

### Date Comparison

> **Live-tested**: Boolean comparisons return `"true"` for true and **empty string** `""` for false.

```applescript
evaluate noteRef with "date(\"today\")==date(\"today\")"     -- "true"
evaluate noteRef with "date(\"today\")!=date(\"yesterday\")"  -- "true"
evaluate noteRef with "$Created > date(\"yesterday\")"       -- "true"
evaluate noteRef with "$Created < date(\"now\")"             -- "true" or "" (same-second)
```

### Standalone Date Functions

| Function | Description |
|----------|-------------|
| `day(date[,val])` | Get/set day |
| `month(date[,val])` | Get/set month |
| `year(date[,val])` | Get/set year |
| `hour(date[,val])` | Get/set hour |
| `minute(date[,val])` | Get/set minute |
| `time(date[,h,m,s])` | Get/set time |

### Date Arithmetic Functions

| Function | Description |
|----------|-------------|
| `days(d1,d2)` | Days between dates |
| `hours(d1,d2)` | Hours between dates |
| `minutes(d1,d2)` | Minutes between dates |
| `months(d1,d2)` | Months between dates |
| `years(d1,d2)` | Years between dates |
| `weeks(d1,d2)` | Weeks between dates |
| `seconds(d1,d2)` | Seconds between dates |

### Interval Operators

| Function | Description |
|----------|-------------|
| `interval(dateStr)` | Create interval from string |
| `interval(startDate,endDate)` | Create interval from dates |
| `Interval.day()` | Days in interval |
| `Interval.hour()` | Hours in interval |
| `Interval.minute()` | Minutes in interval |
| `Interval.second()` | Seconds in interval |
| `Interval.format("l"\|"L")` | Format interval |

---

## 4. List/Set Operators (~37)

Sets are unordered with unique values (auto-deduplicated). Lists preserve order and allow duplicates. Both share most operators.

### Creation/Access

| Function | Description |
|----------|-------------|
| `list(a;b;c)` | Create list |
| `[N]` | Access by index |
| `.at(N)` | Access by index (supports negative) |
| `.first()` | First item |
| `.last()` | Last item |
| `.randomItem()` | Random item |

### Info

| Function | Returns | Description |
|----------|---------|-------------|
| `.count` or `.count()` | Number | Item count |
| `.size` or `.size()` | Number | Character count |
| `.empty()` | Boolean | Is empty |

### Search

| Function | Returns | Description |
|----------|---------|-------------|
| `.contains(str)` | **Position** (1-based) or `""` | Find item |
| `.icontains(str)` | Position or `""` | Case-insensitive find |
| `.containsAnyOf(regexList)` | Boolean | Match any pattern |
| `.icontainsAnyOf(regexList)` | Boolean | Case-insensitive version |
| `.countOccurrencesOf(str)` | Number | Count occurrences |
| `.lookup(key)` | Value | Key=value lookup |

> **Live-tested**: Set `.contains()` returns the **1-based item position** if found, **empty string** if not found.

```applescript
-- Set operations
act on noteRef with "$Tags=\"alpha;beta;gamma\""
act on noteRef with "$Tags+=\"delta\""          -- append
act on noteRef with "$Tags-=\"beta\""            -- remove
evaluate noteRef with "$Tags.contains(\"delta\")" -- "3" (position)
evaluate noteRef with "$Tags.contains(\"omega\")" -- "" (not found)
```

### Transform

| Function | Description |
|----------|-------------|
| `.sort([attrRef])` | Sort alphabetically |
| `.nsort([attrRef])` | Sort numerically |
| `.isort([attrRef])` | Sort case-insensitive |
| `.reverse()` | Reverse order |
| `.unique` | Remove duplicates |
| `.extend(list)` | Append another list |
| `.remove(value)` | Remove value |
| `.replace(regex,replacement)` | Replace in items |
| `.intersect(set)` | Set intersection |
| `.tr(in,out)` | Transliterate items |

### Aggregation

| Function | Returns | Description |
|----------|---------|-------------|
| `.sum()` | Number | Sum of numeric items |
| `.avg()` | Number | Average of numeric items |
| `.max` or `.max()` | Value | Maximum value |
| `.min` or `.min()` | Value | Minimum value |
| `.sum_if(loopVar,cond[,expr])` | Number | Conditional sum |

> **Live-tested**: `.max` and `.min` work on collected lists: `collect(children,$Width).max` returns `"30"`.

```applescript
-- Collection aggregation via collect + list operators
evaluate rootRef with "collect(children,$Width).max"  -- "30"
evaluate rootRef with "collect(children,$Width).min"  -- "10"
```

### Functional

| Function | Description |
|----------|-------------|
| `.each(loopVar){actions}` | Iterate items |
| `.collect(loopVar,expr)` | Map/transform items |
| `.collect_if(loopVar,cond,expr)` | Conditional map |
| `.count_if(loopVar,cond)` | Conditional count |
| `.any(loopVar,expr)` | Any match? |
| `.every(loopVar,expr)` | All match? |
| `.select()` | Filter items |

### Conversion

| Function | Description |
|----------|-------------|
| `.asString()` | Convert to string |
| `.format(delimiter)` | Join with delimiter |
| `.format(prefix,itemPrefix,itemSuffix,suffix)` | Custom formatting |

### Assignment Operators (act on only)

```applescript
act on noteRef with "$Tags+=\"newtag\""   -- append
act on noteRef with "$Tags-=\"oldtag\""   -- remove
```

---

## 5. Dictionary Operators (~10)

| Function | Description |
|----------|-------------|
| `dictionary("key:value;key:value")` | Create dictionary |
| `[keyStr]` | Get/set by key |
| `.keys` | Get all keys |
| `.values()` | Get all values |
| `.count` or `.count()` | Number of entries |
| `.size` or `.size()` | Character count |
| `.empty()` | Is empty |
| `.contains(key)` | Has key |
| `.icontains(key)` | Has key (case-insensitive) |
| `.add(itemDict)` | Add/replace entries |
| `.extend(itemDict)` | Add/append entries |

> **Note**: `$MyDict[key] += 1` is NOT supported. Use conventional reassignment.

---

## 6. JSON Operators (~11)

| Function | Description |
|----------|-------------|
| `String.json[key]` | Access JSON key |
| `String.json[N]` | Access JSON array element |
| `String.captureJSON()` | Parse JSON from string |
| `String.jsonEncode()` | Encode for JSON |
| `JSON.json[key]` | Access nested key |
| `JSON.json[N]` | Access nested array element |
| `JSON.jsonValue()` | Get JSON value |
| `JSON.jsonValue(path)` | Get nested value (e.g. `"person.lastName"`) |
| `JSON.each([path]){actions}` | Iterate JSON |
| `jsonEncode(dataStr)` | Standalone encode function |

---

## 7. XML Operators (3)

| Function | Description |
|----------|-------------|
| `.xml(path)` | Extract XML element by path |
| `XML.each(path){action}` | Iterate XML elements |
| `String.captureXML()` | Parse XML from string |

---

## 8. Color Operators (9)

| Function | Description |
|----------|-------------|
| `rgb(r,g,b)` | Create color from RGB (0-255) |
| `hsv(h,s,v)` | Create color from HSV |
| `.red()` | Red component (0-255) |
| `.green()` | Green component (0-255) |
| `.blue()` | Blue component (0-255) |
| `.hue()` | Hue (0-100) |
| `.saturation()` | Saturation (0-100) |
| `.brightness()` | Brightness (0-100) |
| `Color.format()` | Format as hex #RRGGBB |

---

## 9. StyledString Operators (6)

Only works with `$Text` attribute:

| Function | Description |
|----------|-------------|
| `.bold()` | Apply bold |
| `.italic()` | Apply italic |
| `.strike()` | Apply strikethrough |
| `.plain()` | Remove styling |
| `.fontSize(points)` | Set font size |
| `.textColor(color)` | Set text color |

---

## 10. Note/Tree/Link Operators (~25)

### Creation (act on only)

| Function | Description |
|----------|-------------|
| `create(name)` | Create child note (see path syntax below) |
| `createAgent(name,query)` | Create child agent |
| `createAlias(path)` | Create alias |
| `createAdornment(name)` | Create adornment |
| `createAttribute(name,type)` | Create user attribute |
| `createLink(source,dest,type)` | Create link |

### Links (act on only)

| Function | Description |
|----------|-------------|
| `linkTo(path[,type])` | Create outbound link |
| `linkFrom(path[,type])` | Create inbound link |
| `unlink(path)` | Remove link |
| `unlinkTo(path)` | Remove outbound link |
| `unlinkFrom(path)` | Remove inbound link |
| `linkToOriginal(path)` | Link to alias original |
| `linkFromOriginal(path)` | Link from alias original |
| `unlinkToOriginal(path)` | Unlink to alias original |
| `unlinkFromOriginal(path)` | Unlink from alias original |

### Navigation (evaluate)

| Function | Returns | Description |
|----------|---------|-------------|
| `descendedFrom(path)` | Boolean | Is descendant of note |
| `inside(path)` | Boolean | Is inside container |
| `first()` | Note | First child |
| `last()` | Note | Last child |
| `distance(path)` | Number | Tree distance |
| `distanceTo(path)` | Number | Map distance |

### Query (evaluate)

| Function | Returns | Description |
|----------|---------|-------------|
| `find(condition)` | Group | Find matching notes |
| `similarTo(path)` | List | Similar notes |
| `neighbors()` | Group | Nearby notes (map) |
| `neighborsWithin(dist)` | Group | Notes within distance |

### `create()` Path Syntax

> **Live-tested**: `create()` accepts absolute paths from the document root. Intermediate containers are auto-created if they don't exist.

```applescript
-- Create at absolute path (intermediate containers auto-created)
act on noteRef with "create(\"/Hints/Highlighters/MyHighlighter\")"

-- Create relative child
act on noteRef with "create(\"ChildName\")"

-- Set attributes on path-created notes using $Attr("/path") syntax
act on noteRef with "$Text(\"/Hints/Highlighters/MyHighlighter\")=\"content here\""
act on noteRef with "$Color(\"/Prototypes/Task\")=\"blue\""
```

### Deletion (act on only)

| Function | Description |
|----------|-------------|
| `delete()` | Delete current note |

---

## 11. Collection/Scope Functions (~10)

These operate on groups of notes (children, descendants, siblings, find results):

| Function | Returns | Description |
|----------|---------|-------------|
| `collect(scope, expr)` | List | Collect expression from scope |
| `collect_if(scope, cond, expr)` | List | Conditional collect |
| `count(scope[,cond])` | Number | Count notes |
| `sum(scope, expr)` | Number | Sum expression across scope |
| `avg(scope, expr)` | Number | Average expression |
| `min(scope, expr)` | Value | Minimum (see note below) |
| `max(scope, expr)` | Value | Maximum (see note below) |
| `any(scope, cond)` | Boolean | Any note matches? |
| `every(scope, cond)` | Boolean | All notes match? |
| `values(scope, attr)` | List | Unique values of attribute |

> **Live-tested**: `collect()` returns results as a **bracket-wrapped semicolon-separated list**: `[item1;item2;item3]`. Use `collect(children,$Name)` and parse the result.

> **Live-tested**: `sum(children,$Width)` and `avg(children,$Width)` work correctly. `count(children)` without a condition returns `"1"` — use `$ChildCount` instead for counting children.

> **Live-tested**: `collect_if(children,$Width>15,$Name)` works correctly, returning only matching items.

```applescript
-- Collection examples
evaluate rootRef with "collect(children,$Name)"              -- "[A;B;C]"
evaluate rootRef with "sum(children,$Width)"                 -- "60"
evaluate rootRef with "avg(children,$Width)"                 -- "20"
evaluate rootRef with "$ChildCount"                          -- "3" (use this for counting)
evaluate rootRef with "collect_if(children,$Width>15,$Name)" -- "[B;C]"
```

---

## 12. Control Flow (~5)

| Function | Description |
|----------|-------------|
| `if(cond){actions}[else{actions}]` | Conditional |
| `while(cond){actions}` | Loop |
| `eachLink(loopVar[,scope]){actions}` | Iterate links |
| `action(codeStr)` | Execute action code string (returns `"true"` on success) |
| `eval([item],expr)` | Evaluate expression |

> **Live-tested**: `if/else` works in both `evaluate` (returns value) and `act on` (executes actions). Nested `if/else` also works.

> **Live-tested**: `action($Text)` executes a note's `$Text` as action code and returns `"true"` on success. Useful for "installer" notes where the action code payload lives in `$Text` and is triggered by `$Rule="action($Text);"`.

```applescript
-- Execute note's text as action code
act on noteRef with "action($Text)"
-- Or set as a rule
act on noteRef with "$Rule=\"action($Text);\""
```

```applescript
-- Conditional expression
evaluate noteRef with "if($Width>15){\"big\"}else{\"small\"}"
-- Nested conditional
evaluate noteRef with "if($Width>25){\"large\"}else{if($Width>15){\"medium\"}else{\"small\"}}"
-- Conditional action
act on noteRef with "if($Width>15){$Badge=\"flag\"}else{$Badge=\"star\"}"
```

---

## 13. Encoding Functions (~6)

| Function | Description |
|----------|-------------|
| `urlEncode(str)` | URL-encode string |
| `jsonEncode(str)` | JSON-encode string |
| `escapeHTML(str)` | HTML entity encode |
| `attributeEncode(str)` | Encode for attribute name |
| `idEncode(str)` | Encode for ID |
| `backslashEncode(str)` | Backslash escape |

> **Live-tested**: `urlEncode("hello world")` returns `"hello%20world"`.

```applescript
evaluate noteRef with "urlEncode(\"hello world\")"  -- "hello%20world"
```

---

## 14. System/Misc Functions (~15)

| Function | Description |
|----------|-------------|
| `runCommand(cmd[,input,dir])` | Execute shell command (2nd arg piped as stdin) |
| `fetch(url,headers,attr,cmd[,method,body])` | HTTP fetch |
| `notify(headline[,details,date])` | macOS notification |
| `stamp([scope,]name)` | Apply named stamp |
| `show(msg[,bg,color,duration])` | Show message in UI |
| `play(sound)` | Play sound |
| `speak(msg[,voice])` | Text-to-speech |
| `paste()` | Paste clipboard contents |
| `exportedString(item[,template])` | Export with template |
| `hasLocalValue(attr[,item])` | Check if attribute has local value |
| `inheritsFrom([item,]proto)` | Check prototype inheritance |
| `type(attr)` | Get attribute data type |
| `version()` | Tinderbox version string |
| `locale()` | System locale |
| `modifierKeys` | Currently held modifier keys |
| `do(macro[,args])` | Execute macro |
| `require(feature)` | Add built-in container or toggle UI feature (see below) |
| `update(path)` | Recompile a specific `/Hints/Library` note; no-arg form only recompiles already-compiled notes |
| `var` | Declare local variable |
| `return` | Return value from function |
| `function` | Define inline function |

### `require()` Arguments

| Argument | Effect |
|----------|--------|
| `"Prototypes"` | Creates `/Prototypes` container (equiv. File > Built-In Prototypes) |
| `"Templates"` | Creates `/Templates` container (equiv. File > Built-In Templates) |
| `"Hints"` | Creates `/Hints` system container with Library, Stamps, Highlighters, etc. |
| `"Preview"` | Shows the text pane selector above the text pane |
| `"NoPreview"` | Hides the text pane selector above the text pane |

```applescript
-- Ensure system containers exist
act on noteRef with "require(\"Prototypes\")"
act on noteRef with "require(\"Templates\")"
act on noteRef with "require(\"Hints\")"

-- Toggle text pane selector
act on noteRef with "require(\"Preview\")"
act on noteRef with "require(\"NoPreview\")"
```

> Idempotent: calling `require()` when the container already exists has no effect.

> See **[System Containers](system-containers.md)** for full details on all four built-in containers.

### `update()` — Recompile Library Functions

```applescript
-- Recompile a specific library note (required for newly created notes)
act on noteRef with "update(\"/Hints/Library/MyFunctions\")"

-- No-arg form only recompiles already-compiled notes (not newly created ones)
act on noteRef with "update()"
```

> **Important:** `update()` without arguments does NOT compile newly created library notes. You must call `update("/Hints/Library/NoteName")` with the specific path to each new library note. Library notes must also have `$IsAction = true` to be recognized as action code.

### `runCommand()` — Shell Execution

> **Live-tested**: The second argument to `runCommand()` is piped as **stdin** to the command. This enables base64 decoding and other input-fed commands:

```applescript
-- Decode base64-encoded text (2nd arg is piped as stdin)
act on noteRef with "$Text=runCommand(\"base64 -D\",\"SGVsbG8gV29ybGQ=\")"
-- Result: $Text = "Hello World"

-- Run command with working directory
evaluate noteRef with "runCommand(\"ls\",\"\",$Path)"
```

> **Pattern**: To embed complex multi-line text (regex patterns, special characters) inside action code without escaping issues, base64-encode the content and decode at runtime via `runCommand("base64 -D", "base64string")`.

> **Live-tested**: `hasLocalValue("Badge")` returns `"true"` when Badge has been explicitly set on the note, confirming local override detection works.

> **Live-tested**: `inheritsFrom("ProtoName")` returns `"true"` when the note's prototype chain includes the named prototype.

> **Live-tested**: To reset an attribute to its prototype-inherited value, use `$Attr=;` (equals-semicolon with no value). This removes the local override and re-enables inheritance. Confirmed: `$Badge=;` restores the prototype's "star" value and `hasLocalValue("Badge")` returns false.

```applescript
-- Prototype queries
evaluate noteRef with "inheritsFrom(\"Task\")"       -- "true" or ""
evaluate noteRef with "hasLocalValue(\"Badge\")"       -- "true" or ""

-- Reset to inherited value (re-enable prototype inheritance)
act on noteRef with "$Badge=;"   -- removes local override
-- NOT the same as $Badge="" which sets a local empty value
```

---

## 15. Designators

Designators reference notes relative to the current context in expressions and actions.

### Item Designators (single note)

| Designator | Description |
|------------|-------------|
| `this` | Current note |
| `that` | Note being processed (in agent action) |
| `current` | Currently selected note |
| `agent` | The agent running the action |
| `adornment` | The adornment |
| `original` | Original of an alias |
| `parent` | Parent container |
| `grandparent` | Parent of parent |
| `child[N]` | Nth child (0-based) |
| `firstSibling` | First sibling |
| `prevSibling` | Previous sibling |
| `nextSibling` | Next sibling |
| `lastSibling` | Last sibling |
| `lastChild` | Last child |
| `previous` | Previous in outline |
| `next` | Next in outline |
| `previousItem` | Previous created item |
| `nextItem` | Next created item |
| `previousSiblingItem` | Previous sibling by creation |
| `nextSiblingItem` | Next sibling by creation |
| `randomChild` | Random child note |
| `selection` | Selected note |
| `library` | Library container |
| `my` | Alias for `this` |
| `root` | Document root |

### Group Designators (collection)

| Designator | Description |
|------------|-------------|
| `children` | All child notes |
| `descendants` | All descendants (recursive) |
| `siblings` | All sibling notes |
| `ancestors` | All ancestor notes |
| `all` | All notes in document |
| `find(condition)` | Notes matching condition |

### Link Designators

| Designator | Description |
|------------|-------------|
| `source` | Link source note |
| `destination` | Link destination note |
| `linkedTo(scope)` | Notes linked to from scope |
| `linkedFrom(scope)` | Notes linked from scope |

### Expanded Syntax

```applescript
-- Access attribute of another note via designator
evaluate noteRef with "$Name(parent)"     -- parent's name
evaluate noteRef with "$Color(child[0])"  -- first child's color

-- Path-based access
evaluate noteRef with "$Name(\"/path/to/note\")"

-- Named note access
evaluate noteRef with "$Name(\"Some Note\")"
```

> **Live-tested**: `$Name(parent)` works correctly, returning the parent note's name.

> **Live-tested**: `find()` in evaluate works: `collect(find($Name.contains("prefix")),$Name)` returns all matching note names.

---

## 16. Composite Operators (7 + 5 shorthand)

| Function | Description |
|----------|-------------|
| `compositeFor(name)` | Get composite by name |
| `compositeWithName(name)` | Get composite by name |
| `:count` | Number of composite members |
| `:kind` | Composite kind |
| `:name` | Composite name |
| `:role(roleStr)` | Member with role |
| `:roles` | All roles |
| `my:count` | Shorthand for `compositeFor(this):count` |
| `my:kind` | Shorthand for `compositeFor(this):kind` |
| `my:name` | Shorthand for `compositeFor(this):name` |
| `my:role(roleStr)` | Shorthand for `compositeFor(this):role(roleStr)` |
| `my:roles` | Shorthand for `compositeFor(this):roles` |

---

## Boolean Return Values

> **Live-tested**: Tinderbox boolean results are NOT always `"true"`/`"false"`:
> - **True** = `"true"` (string)
> - **False** = `""` (empty string), NOT `"false"`
>
> This applies to comparison operators (`==`, `!=`, `>`, `<`, `>=`, `<=`) and functions like `inheritsFrom()`, `hasLocalValue()`.
>
> Exception: `.contains()` on strings returns a **numeric position** (1-based), not a boolean. On sets, `.contains()` returns a position or empty string.

---

## Action Chaining

Multiple actions can be separated by semicolons in a single `act on` call:

```applescript
act on noteRef with "$Badge=\"flag\";$Color=\"red\";$Width=25"
```

> **Live-tested**: Semicolon-separated action chaining works correctly.

---

## String Quoting in Action Code

Tinderbox action code does **NOT** support backslash-escaped quotes. `\"` does not work as an escape sequence.

To embed double quotes inside a string value, wrap them in single quotes and use `+` for concatenation:

```
-- WRONG -- backslash escaping fails silently
$OnAdd="$Prototype=\"Code\";"

-- RIGHT -- single quotes preserve the double quotes
$OnAdd="$Prototype=" + '"Code";'
```

This is especially important when setting action-holding attributes (`$OnAdd`, `$Rule`, etc.) whose values themselves contain quoted strings.

---

## Cross-References

- **[AppleScript API Reference](applescript-api.md)** — AppleScript bridge layer: make, delete, move, evaluate, act on
- **[Action-Holding Attributes](action-attributes.md)** — The 12 system attributes that hold executable action code
- **[Expressions & Actions](expressions.md)** — Quick-reference for common patterns
- **[Test Script](../scripts/test-action-code.sh)** — 18 live-validated tests
