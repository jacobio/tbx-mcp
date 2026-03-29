# Tinderbox Action Code Functions Reference

> Examples include the required `document` parameter. Replace `"MyDoc"` with your document name.

Comprehensive catalog of Tinderbox action code functions usable via the `evaluate` and `do` MCP tools. Organized by category with MCP tool call examples for key functions.

**Calling pattern**: `evaluate(document: "MyDoc", expression: "expression", note: "/path/to/note")` for reading, `do(document: "MyDoc", action: "action code", note: "/path/to/note")` for writing.

**Live-tested discoveries** are marked with a test tube icon.

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
| `.beginsWith(str)` | `"true"` or `""` | Starts with string |
| `.endsWith(str)` | `"true"` or `""` | Ends with string |
| `.containsAnyOf(regexList)` | `"true"` or `""` | Matches any pattern in list |
| `.icontainsAnyOf(regexList)` | `"true"` or `""` | Case-insensitive version |
| `.find(str)` | Position | Find position of substring |
| `.countOccurrencesOf(str)` | Number | Count occurrences |
| `.empty()` | `"true"` or `""` | Is empty string |

> **Live-tested**: `.contains()` on strings returns the **1-based character position** of the match, NOT `"true"`/`""`. Returns `0` when not found. On sets, `.contains()` returns the 1-based item position or `""` (empty string) when not found.

```
// .contains() on strings returns position, not boolean
evaluate(document: "MyDoc", expression: "$Name.contains(\"ACTION\")", note: "/path/to/note")
// returns "7" (1-based position), not "true"
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

```
// Replace
evaluate(document: "MyDoc", expression: "$Text.replace(\"World\",\"Earth\")", note: "/path/to/note")
// Substring
evaluate(document: "MyDoc", expression: "$Name.substr(0,5)", note: "/path/to/note")
// Trim
evaluate(document: "MyDoc", expression: "\" hello \".trim()", note: "/path/to/note")
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

```
// abs and round
evaluate(document: "MyDoc", expression: "abs(-42)", note: "/path/to/note")    # "42"
evaluate(document: "MyDoc", expression: "round(3.7)", note: "/path/to/note")   # "4"
evaluate(document: "MyDoc", expression: "mod(17,5)", note: "/path/to/note")    # "2"
evaluate(document: "MyDoc", expression: "(10+20)*2", note: "/path/to/note")    # "60"
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

```
evaluate(document: "MyDoc", expression: "date(\"today\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "date(\"now\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "date(\"yesterday\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "date(\"tomorrow\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "date(\"next week\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "date(\"2025-03-15\")", note: "/path/to/note")
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

```
evaluate(document: "MyDoc", expression: "$Created.day", note: "/path/to/note")                  # "11"
evaluate(document: "MyDoc", expression: "$Created.year", note: "/path/to/note")                 # "2026"
evaluate(document: "MyDoc", expression: "date(\"today\").format(\"y\")", note: "/path/to/note")     # "2026"
evaluate(document: "MyDoc", expression: "$Created.format(\"y-M0-D0\")", note: "/path/to/note")     # "2026-02-11"
```

### Date Comparison

> **Live-tested**: Comparisons return `"true"` for true and `""` (empty string) for false.

```
evaluate(document: "MyDoc", expression: "date(\"today\")==date(\"today\")", note: "/path/to/note")       # "true"
evaluate(document: "MyDoc", expression: "date(\"today\")!=date(\"yesterday\")", note: "/path/to/note")   # "true"
evaluate(document: "MyDoc", expression: "$Created > date(\"yesterday\")", note: "/path/to/note")         # "true"
evaluate(document: "MyDoc", expression: "$Created < date(\"now\")", note: "/path/to/note")               # "true" or ""
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
| `.empty()` | `"true"` or `""` | Is empty |

### Search

| Function | Returns | Description |
|----------|---------|-------------|
| `.contains(str)` | **Position** (1-based) or `""` | Find item |
| `.icontains(str)` | Position or `""` | Case-insensitive find |
| `.containsAnyOf(regexList)` | `"true"` or `""` | Match any pattern |
| `.icontainsAnyOf(regexList)` | `"true"` or `""` | Case-insensitive version |
| `.countOccurrencesOf(str)` | Number | Count occurrences |
| `.lookup(key)` | Value | Key=value lookup |

> **Live-tested**: Set `.contains()` returns the **1-based item position** if found, `""` (empty string) if not found.

```
// Set operations
do(document: "MyDoc", action: "$Tags=\"alpha;beta;gamma\"", note: "/path/to/note")
do(document: "MyDoc", action: "$Tags+=\"delta\"", note: "/path/to/note")            # append
do(document: "MyDoc", action: "$Tags-=\"beta\"", note: "/path/to/note")             # remove
evaluate(document: "MyDoc", expression: "$Tags.contains(\"delta\")", note: "/path/to/note")  # "3" (position)
evaluate(document: "MyDoc", expression: "$Tags.contains(\"omega\")", note: "/path/to/note")  # "" (not found)
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

```
// Collection aggregation via collect + list operators
evaluate(document: "MyDoc", expression: "collect(children,$Width).max", note: "/path/to/note")  # "30"
evaluate(document: "MyDoc", expression: "collect(children,$Width).min", note: "/path/to/note")  # "10"
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

### Assignment Operators (the `do` tool only)

```
do(document: "MyDoc", action: "$Tags+=\"newtag\"", note: "/path/to/note")   # append
do(document: "MyDoc", action: "$Tags-=\"oldtag\"", note: "/path/to/note")   # remove
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

### Creation (the `do` tool only)

| Function | Description |
|----------|-------------|
| `create(name)` | Create child note (see path syntax below) |
| `createAgent([container,] name)` | Create agent (set $AgentQuery separately) |
| `createAlias(path)` | Create alias |
| `createAdornment(name)` | Create adornment |
| `createAttribute(name,type)` | Create user attribute |
| `createLink(source,dest,type)` | Create link |

### Links (the `do` tool only)

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

### Navigation (the `evaluate` tool)

| Function | Returns | Description |
|----------|---------|-------------|
| `descendedFrom(path)` | `"true"` or `""` | Is descendant of note |
| `inside(path)` | `"true"` or `""` | Is inside container |
| `first(item[, childrenNum])` | Note | First child |
| `last(item[, childrenNum])` | Note | Last child |
| `distance(startItem, endItem)` | Number | Tree distance between two notes |
| `distanceTo(path)` | Number | Map distance |

### Query (the `evaluate` tool)

| Function | Returns | Description |
|----------|---------|-------------|
| `find(condition)` | Group | Find matching notes |
| `similarTo(path)` | List | Similar notes |
| `neighbors(scope, distanceNum[, linkTypeStr])` | Group | Nearby notes (map) |
| `neighborsWithin(scope, distanceNum[, linkTypeStr])` | Group | Notes within distance |

### `create()` Path Syntax

> **Live-tested**: `create()` accepts absolute paths from the document root. Intermediate containers are auto-created if they don't exist.

```
// Create at absolute path (intermediate containers auto-created)
do(document: "MyDoc", action: "create(\"/Hints/Highlighters/MyHighlighter\")", note: "/path/to/note")

// Create relative child
do(document: "MyDoc", action: "create(\"ChildName\")", note: "/path/to/note")

// Set attributes on path-created notes using $Attr("/path") syntax
do(document: "MyDoc", action: "$Text(\"/Hints/Highlighters/MyHighlighter\")=\"content here\"", note: "/path/to/note")
do(document: "MyDoc", action: "$Color(\"/Prototypes/Task\")=\"blue\"", note: "/path/to/note")
```

### Deletion (the `do` tool only)

| Function | Description |
|----------|-------------|
| `delete(scope)` | Delete note(s) specified by scope |

---

## 11. Collection/Scope Functions (~10)

These operate on groups of notes (children, descendants, siblings, find results):

| Function | Returns | Description |
|----------|---------|-------------|
| `collect(scope, expr)` | List | Collect expression from scope |
| `collect_if(scope, cond, expr)` | List | Conditional collect |
| `count(scope)` | Number | Count notes in scope (for children use `$ChildCount` instead) |
| `count_if(scope, cond)` | Number | Conditional count |
| `sum(scope, expr)` | Number | Sum expression across scope |
| `avg(scope, expr)` | Number | Average expression |
| `min(scope, expr)` | Value | Minimum (see note below) |
| `max(scope, expr)` | Value | Maximum (see note below) |
| `any(scope, cond)` | `"true"` or `""` | Any note matches? |
| `every(scope, cond)` | `"true"` or `""` | All notes match? |
| `values(scope, attr)` | List | Unique values of attribute |

> **Live-tested**: `collect()` returns results as a **bracket-wrapped semicolon-separated list**: `[item1;item2;item3]`. Use `collect(children,$Name)` and parse the result.

> **Live-tested**: `sum(children,$Width)` and `avg(children,$Width)` work correctly. `count(children)` without a condition returns `"1"` -- use `$ChildCount` instead for counting children. Use `count_if(scope, condition)` for conditional counting.

> **Live-tested**: `collect_if(children,$Width>15,$Name)` works correctly, returning only matching items.

```
// Collection examples
evaluate(document: "MyDoc", expression: "collect(children,$Name)", note: "/path/to/note")              # "[A;B;C]"
evaluate(document: "MyDoc", expression: "sum(children,$Width)", note: "/path/to/note")                 # "60"
evaluate(document: "MyDoc", expression: "avg(children,$Width)", note: "/path/to/note")                 # "20"
evaluate(document: "MyDoc", expression: "$ChildCount", note: "/path/to/note")                          # "3" (use this for counting children)
evaluate(document: "MyDoc", expression: "collect_if(children,$Width>15,$Name)", note: "/path/to/note")  # "[B;C]"
evaluate(document: "MyDoc", expression: "count_if(children,$Width>15)", note: "/path/to/note")          # "2"
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

> **Live-tested**: `if/else` works in both the `evaluate` tool (returns value) and the `do` tool (executes action code). Nested `if/else` also works.

> **Live-tested**: `action($Text)` executes a note's `$Text` as action code and returns `"true"` on success. Useful for "installer" notes where the action code payload lives in `$Text` and is triggered by `$Rule="action($Text);"`.

```
// Execute note's text as action code
do(document: "MyDoc", action: "action($Text)", note: "/path/to/note")
// Or set as a rule
do(document: "MyDoc", action: "$Rule=\"action($Text);\"", note: "/path/to/note")
```

```
// Conditional expression
evaluate(document: "MyDoc", expression: "if($Width>15){\"big\"}else{\"small\"}", note: "/path/to/note")
// Nested conditional
evaluate(document: "MyDoc", expression: "if($Width>25){\"large\"}else{if($Width>15){\"medium\"}else{\"small\"}}", note: "/path/to/note")
// Conditional action code
do(document: "MyDoc", action: "if($Width>15){$Badge=\"flag\"}else{$Badge=\"star\"}", note: "/path/to/note")
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
| `backslashEncode(str)` | Backslash escape (export code only: `^backslashEncode(data)^`) |

> **Live-tested**: `urlEncode("hello world")` returns `"hello%20world"`.

```
evaluate(document: "MyDoc", expression: "urlEncode(\"hello world\")", note: "/path/to/note")  # "hello%20world"
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

```
// Ensure system containers exist
do(document: "MyDoc", action: "require(\"Prototypes\")", note: "/path/to/note")
do(document: "MyDoc", action: "require(\"Templates\")", note: "/path/to/note")
do(document: "MyDoc", action: "require(\"Hints\")", note: "/path/to/note")

// Toggle text pane selector
do(document: "MyDoc", action: "require(\"Preview\")", note: "/path/to/note")
do(document: "MyDoc", action: "require(\"NoPreview\")", note: "/path/to/note")
```

> Idempotent: calling `require()` when the container already exists has no effect.

> See **[System Containers](system-containers.md)** for full details on all four built-in containers.

### `update()` -- Recompile Library Functions

```
// Recompile a specific library note (required for newly created notes)
do(document: "MyDoc", action: "update(\"/Hints/Library/MyFunctions\")", note: "/path/to/note")

// No-arg form only recompiles already-compiled notes (not newly created ones)
do(document: "MyDoc", action: "update()", note: "/path/to/note")
```

> **Important:** `update()` without arguments does NOT compile newly created library notes. You must call `update("/Hints/Library/NoteName")` with the specific path to each new library note. Library notes must also have `$IsAction = true` to be recognized as action code.

### `runCommand()` -- Shell Execution

> **Live-tested**: The second argument to `runCommand()` is piped as **stdin** to the command. This enables base64 decoding and other input-fed commands:

```
// Decode base64-encoded text (2nd arg is piped as stdin)
do(document: "MyDoc", action: "$Text=runCommand(\"base64 -D\",\"SGVsbG8gV29ybGQ=\")", note: "/path/to/note")
// Result: $Text = "Hello World"

// Run command with working directory
evaluate(document: "MyDoc", expression: "runCommand(\"ls\",\"\",$Path)", note: "/path/to/note")
```

> **Pattern**: To embed complex multi-line text (regex patterns, special characters) inside action code without escaping issues, base64-encode the content and decode at runtime via `runCommand("base64 -D", "base64string")`.

> **Live-tested**: `hasLocalValue("Badge")` returns `"true"` when Badge has been explicitly set on the note, confirming local override detection works.

> **Live-tested**: `inheritsFrom("ProtoName")` returns `"true"` when the note's prototype chain includes the named prototype.

> **Live-tested**: To reset an attribute to its prototype-inherited value, use `$Attr=;` (equals-semicolon with no value). This removes the local override and re-enables inheritance. Confirmed: `$Badge=;` restores the prototype's "star" value and `hasLocalValue("Badge")` returns false.

```
// Prototype queries
evaluate(document: "MyDoc", expression: "inheritsFrom(\"Task\")", note: "/path/to/note")        # "true" or ""
evaluate(document: "MyDoc", expression: "hasLocalValue(\"Badge\")", note: "/path/to/note")       # "true" or ""

// Reset to inherited value (re-enable prototype inheritance)
do(document: "MyDoc", action: "$Badge=;", note: "/path/to/note")   # removes local override
// NOT the same as $Badge="" which sets a local empty value
```

---

## 15. Designators

Designators reference notes relative to the current context in expressions and action code.

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

```
// Access attribute of another note via designator
evaluate(document: "MyDoc", expression: "$Name(parent)", note: "/path/to/note")     # parent's name
evaluate(document: "MyDoc", expression: "$Color(child[0])", note: "/path/to/note")  # first child's color

// Path-based access
evaluate(document: "MyDoc", expression: "$Name(\"/path/to/note\")", note: "/path/to/note")

// Named note access
evaluate(document: "MyDoc", expression: "$Name(\"Some Note\")", note: "/path/to/note")
```

> **Live-tested**: `$Name(parent)` works correctly, returning the parent note's name.

> **Live-tested**: `find()` in the `evaluate` tool works: `collect(find($Name.contains("prefix")),$Name)` returns all matching note names.

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
> Exception: `.contains()` on strings returns a **numeric position** (1-based) or `0`, not a boolean. On sets, `.contains()` returns a 1-based position or `""` (empty string).

---

## Action Chaining

Multiple actions can be separated by semicolons in a single `do` tool call:

```
do(document: "MyDoc", action: "$Badge=\"flag\";$Color=\"red\";$Width=25", note: "/path/to/note")
```

> **Live-tested**: Semicolon-separated action chaining works correctly.

---

## String Quoting in Action Code

Tinderbox action code does **NOT** support backslash-escaped quotes. `\"` does not work as an escape sequence.

To embed double quotes inside a string value, wrap them in single quotes and use `+` for concatenation:

```
// WRONG: backslash escaping fails silently
// $OnAdd="$Prototype=\"Code\";"

// RIGHT: single quotes preserve the double quotes
// $OnAdd="$Prototype=" + '"Code";'
```

This is especially important when setting action-holding attributes (`$OnAdd`, `$Rule`, etc.) whose values themselves contain quoted strings.

---

## Cross-References

- **[Action-Holding Attributes](action-attributes.md)** -- The 12 system attributes that hold executable action code
- **[Expressions & Actions](expressions.md)** -- Quick-reference for common patterns
