# Tinderbox Expression & Action Language Reference

> Examples include the required `document` parameter. Replace `"MyDoc"` with your document name.

Tinderbox has its own expression language (used with the `evaluate` tool) and action code language (used with the `do` tool). This reference covers the syntax for constructing these strings.

## Attribute References

Attributes are referenced with `$` prefix:

```
$Name              # note name
$Text              # note text
$Color             # note color
$Created           # creation date
$Modified          # last modified date
$WordCount         # word count of $Text
$ChildCount        # number of children
$SiblingOrder      # position among siblings (1-based, writable -- set to reorder outline)
$Prototype         # prototype name
$Tags              # set of tags (semicolon-separated)
$Path              # full path from root
$Width             # map width
$Height            # map height
$Xpos              # map X position
$Ypos              # map Y position
$Badge             # badge name
$Checked           # checkbox state (boolean)
$URL               # associated URL
$ReferenceURL      # reference URL
$ReadOnly          # is read-only
$HTMLExportPath    # export path
$Separator         # is a separator
```

### User Attribute References

User attributes use the same `$` syntax:

```
$MyCustomField
$ProjectStatus
```

## Reading Attributes

Use the `evaluate` tool to read attribute values. All results are returned as strings.

```
// Simple attribute reads
evaluate(document: "MyDoc", expression: "$Name", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "$Created", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "$Tags", note: "/path/to/note")

// With formatting (Tinderbox format codes, NOT ICU)
evaluate(document: "MyDoc", expression: "$Created.format(\"y-M0-D0\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "$Modified.format(\"h:mm p\")", note: "/path/to/note")
```

## Writing Attributes

Use the `set_value` tool for simple attribute changes, or the `do` tool for action code:

```
// Via set_value (preferred for simple assignments -- handles quoting safely)
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "Name", value: "New Name")
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "Color", value: "red")

// Via do tool (for expressions, arithmetic, set operations)
do(document: "MyDoc", action: "$Width=4", note: "/path/to/note")
do(document: "MyDoc", action: "$Checked=true", note: "/path/to/note")

// Set/list append
do(document: "MyDoc", action: "$Tags+=\"newtag\"", note: "/path/to/note")

// Set/list remove
do(document: "MyDoc", action: "$Tags-=\"oldtag\"", note: "/path/to/note")

// Numeric increment
do(document: "MyDoc", action: "$MyCount=$MyCount+1", note: "/path/to/note")
```

## Operators

Operators are summarized in the quick reference. Below are additional notes and edge-case behaviors.

### Arithmetic

`+`, `-`, `*`, `/` work on numeric values. `+` also concatenates strings.

> **Note**: `%` is NOT modulo in Tinderbox -- it returns a literal string. Use `mod(a,b)` instead.

### Comparison

`==`, `!=`, `>`, `<`, `>=`, `<=` compare values and return `"true"` or `""` (empty string).

String comparisons are case-sensitive by default. For case-insensitive matching, use `.icontains()` or `.lowercase()` before comparing.

### Logical

`&` (AND), `|` (OR), `!` (NOT). Use parentheses for grouping: `(A | B) & C`.

Both `""` (empty string) and `0` are falsy. Everything else is truthy.

## String Operations

```
// .contains() returns 1-based character position of match, or 0 if not found
// Supports regex patterns as argument
evaluate(document: "MyDoc", expression: "$Name.contains(\"test\")", note: "/path/to/note")

// Begins with / ends with -- return "true" or ""
evaluate(document: "MyDoc", expression: "$Name.beginsWith(\"Project\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "$Name.endsWith(\".md\")", note: "/path/to/note")

// Word count / paragraph count / character count
evaluate(document: "MyDoc", expression: "$Text.wordCount", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "$Text.paragraphCount", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "$Text.size", note: "/path/to/note")

// Substring
evaluate(document: "MyDoc", expression: "$Name.substr(0,5)", note: "/path/to/note")

// Case conversion
evaluate(document: "MyDoc", expression: "$Name.lowercase()", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "$Name.uppercase()", note: "/path/to/note")

// Trim whitespace
evaluate(document: "MyDoc", expression: "$Name.trim()", note: "/path/to/note")
```

## Collection Operations

Operate on children, descendants, siblings, or linked notes:

```
// Count with condition (use count_if, not count)
evaluate(document: "MyDoc", expression: "count_if(children, $Checked==true)", note: "/path/to/note")

// Collect values -- returns semicolon-separated list
evaluate(document: "MyDoc", expression: "collect(children, $Name)", note: "/path/to/note")

// Sum numeric values
evaluate(document: "MyDoc", expression: "sum(children, $Price)", note: "/path/to/note")

// Average
evaluate(document: "MyDoc", expression: "avg(children, $Score)", note: "/path/to/note")

// Min / Max
evaluate(document: "MyDoc", expression: "min(children, $Price)", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "max(children, $Score)", note: "/path/to/note")

// Collect from descendants (recursive)
evaluate(document: "MyDoc", expression: "collect(descendants, $Name)", note: "/path/to/note")

// Collect from linked notes
evaluate(document: "MyDoc", expression: "collect(links, $Name)", note: "/path/to/note")

// Collect with condition
evaluate(document: "MyDoc", expression: "collect_if(children, $Checked==true, $Name)", note: "/path/to/note")
```

## Conditional Expressions

```
// if/else -- used in expressions (returns a value)
evaluate(document: "MyDoc", expression: "if($Prototype==\"Task\"){$Status}else{\"N/A\"}", note: "/path/to/note")

// Nested conditions (no else-if -- must nest if inside else)
evaluate(document: "MyDoc", expression: "if($Score>80){\"High\"}else{if($Score>50){\"Medium\"}else{\"Low\"}}", note: "/path/to/note")
```

## Conditional Actions

```
// if/else in action code -- used with the do tool
do(document: "MyDoc", action: "if($WordCount>100){$Badge=\"long\"}else{$Badge=\"short\"}", note: "/path/to/note")

// Apply conditionally
do(document: "MyDoc", action: "if($Tags.contains(\"important\")){$Color=\"red\"}", note: "/path/to/note")
```

## Date Functions

```
// Current date/time
evaluate(document: "MyDoc", expression: "date(\"today\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "date(\"now\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "date(\"yesterday\")", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "date(\"tomorrow\")", note: "/path/to/note")

// Date formatting (Tinderbox format codes, NOT ICU)
evaluate(document: "MyDoc", expression: "$Created.format(\"y-M0-D0\")", note: "/path/to/note")       # 2026-03-02
evaluate(document: "MyDoc", expression: "$Modified.format(\"W, MM d, y\")", note: "/path/to/note")   # Monday, March 2, 2026

// Date arithmetic
evaluate(document: "MyDoc", expression: "$Created + days(7)", note: "/path/to/note")    # 7 days after created

// Date comparison -- returns "true" or ""
evaluate(document: "MyDoc", expression: "$Modified > date(\"yesterday\")", note: "/path/to/note")

// Set date attribute
do(document: "MyDoc", action: "$DueDate=date(\"next week\")", note: "/path/to/note")
do(document: "MyDoc", action: "$DueDate=date(\"2025-03-15\")", note: "/path/to/note")
```

### Date Format Codes

Tinderbox uses its **own format codes** (NOT ICU/Unicode patterns like `EEEE` or `yyyy`). Use with `.format("codes")`. Reference date: Tue, 29 Apr 2003 14:32:18 +0500.

#### Preset Formats (use alone, not combined)

| Code | Description | Example Output |
|------|-------------|----------------|
| `L` | Local long date (locale-dependent) | `April 29, 2003` |
| `l` | Local short date (lowercase L, not numeral 1) | `4-29-03` |
| `*` | RFC 822 | `Tue, Apr 29 2003 14:32:00 +0500` |
| `=` | ISO 8601 with time | `2003-04-29T14:32:18+05:00` |
| `==` | ISO 8601 date only | `2003-04-29` |
| `U` | Unix epoch (seconds since Jan 1, 1970) | `1051625520` |
| `n` | Medium date + short time (locale-dependent) | `29 Apr 2003 at 14:32` |

#### Day Codes

| Code | Description | Example Output |
|------|-------------|----------------|
| `d` | Day of month, unpadded | `9` |
| `D0` | Day of month, zero-padded (the `0` is the digit zero, not letter O) | `09` |
| `o` | Day of month, ordinal | `2nd`, `10th` |
| `w` | Weekday abbreviation | `Tue` |
| `W` | Full weekday name | `Tuesday` |

#### Month Codes

| Code | Description | Example Output |
|------|-------------|----------------|
| `m` | Month number, unpadded | `4` |
| `M0` | Month number, zero-padded (the `0` is the digit zero, not letter O) | `04` |
| `M` | Month abbreviation | `Apr` |
| `MM` | Full month name | `April` |

#### Year Codes

| Code | Description | Example Output |
|------|-------------|----------------|
| `y` | Four-digit year | `2003` |
| `Y` | Two-digit year | `03` |

#### Time Codes

| Code | Description | Example Output |
|------|-------------|----------------|
| `t` | Local time format (locale-dependent) | `2:32 PM` |
| `h` | Hour, 24-hour clock, zero-padded | `14` |
| `H` | Hour, 12-hour clock, unpadded | `2` |
| `mm` | Minutes, zero-padded | `32` |
| `s` | Seconds, zero-padded (always `00` -- seconds cannot be set) | `00` |
| `p` | AM/PM indicator | `PM` |

#### Combining Codes

Codes act as placeholders within a literal string. Any character that is NOT a recognized code passes through literally. Codes can be combined freely:

```
$Created.format("y-M0-D0")           # 2003-04-29
$Created.format("W, d MM y")         # Tuesday, 29 April 2003
$Modified.format("y-M0-D0 h:mm p")   # 2003-04-29 14:32 PM
$Created.format("H:mm p")            # 2:32 PM
$Created.format("=")                 # ISO 8601
$Created.format("o MM y")            # 29th April 2003
$Created.format("==")                # 2003-04-29 (date only)
```

#### Escaping Literal Characters

Use `\` to prevent a character from being interpreted as a format code:

```
$Created.format("\da\y: D0")          # day: 29 (the d, a, y are escaped as literals)
```

> **CAUTION**: Any unrecognized character passes through literally, but any character that *happens* to match a code letter WILL be interpreted as that code. For example, `"Created on d/m/y"` would replace `d`, `m`, and `y` with date values, AND `t` with the local time. Escape with `\` any literal text that contains code letters.

## Action Commands

These are used with the `do` tool:

### linkTo -- Create a link

```
// Basic link
do(document: "MyDoc", action: "linkTo(\"/path/to/target\")", note: "/path/to/source")

// Typed link (type is auto-created if it doesn't exist)
do(document: "MyDoc", action: "linkTo(\"/path/to/target\", \"references\")", note: "/path/to/source")
```

### Move a note (set $Container)

```
do(document: "MyDoc", action: "$Container=\"/Destination/Container\"", note: "/path/to/note")
```

### create -- Create a child note

```
do(document: "MyDoc", action: "create(\"ChildName\")", note: "/path/to/parent")
```

## Designators

Designators reference notes relative to the current context. Used in both expressions and action code.

### Item Designators (single note)

Access another note's attributes: `$Attr(designator)`

```
evaluate(document: "MyDoc", expression: "$Name(parent)", note: "/path/to/note")            # parent's name
evaluate(document: "MyDoc", expression: "$Color(child[0])", note: "/path/to/note")         # first child's color
evaluate(document: "MyDoc", expression: "$Name(\"/path/to/other\")", note: "/path/to/note") # by path
```

| Designator | Description |
|------------|-------------|
| `this` | Current note |
| `parent` | Parent container |
| `child[N]` | Nth child (0-based) |
| `prevSibling` / `nextSibling` | Adjacent siblings |
| `original` | Original of an alias |
| `agent` | The running agent |

### Group Designators (collections)

Used with collection functions: `collect(group, expr)`, `sum(group, expr)`, etc.

| Designator | Description |
|------------|-------------|
| `children` | All child notes |
| `descendants` | All descendants (recursive) |
| `siblings` | All sibling notes |
| `ancestors` | All ancestor notes |
| `all` | All notes in document |
| `find(condition)` | Notes matching condition |

```
evaluate(document: "MyDoc", expression: "collect(children,$Name)", note: "/path/to/note")
evaluate(document: "MyDoc", expression: "collect(find($Tags.contains(\"important\")),$Name)", note: "/path/to/note")
```

> See **[Action Functions Reference](action-functions.md#15-designators)** for the complete designator list.

## Agent Query Syntax

Agent queries use Tinderbox expressions. Set them via the `set_value` tool:

```
// Find notes with a specific prototype
set_value(document: "MyDoc", notes: "/path/to/agent", attribute: "AgentQuery", value: "$Prototype==\"Task\"")

// Find notes modified recently
set_value(document: "MyDoc", notes: "/path/to/agent", attribute: "AgentQuery", value: "$Modified > date(\"yesterday\")")

// Find notes with specific tags
set_value(document: "MyDoc", notes: "/path/to/agent", attribute: "AgentQuery", value: "$Tags.contains(\"research\")")

// Find notes inside a container
set_value(document: "MyDoc", notes: "/path/to/agent", attribute: "AgentQuery", value: "inside(\"Projects\")")

// Compound query
set_value(document: "MyDoc", notes: "/path/to/agent", attribute: "AgentQuery", value: "$Prototype==\"Task\" & $Checked==false")
```

## Agent Action Syntax

Action code that runs on each note collected by an agent:

```
// Color collected notes
set_value(document: "MyDoc", notes: "/path/to/agent", attribute: "AgentAction", value: "$Color=\"blue\"")

// Set a badge
set_value(document: "MyDoc", notes: "/path/to/agent", attribute: "AgentAction", value: "$Badge=\"flag\"")
```

## Quoting Rules

Tinderbox action code has **NO escape sequences** -- `\"` does NOT work inside Tinderbox strings. Instead:

- Use **single quotes** when value contains double quotes: `$Text='He said "hello"'`
- Use **double quotes** when value contains apostrophes: `$Text="it's fine"`
- Use **`+` concatenation** when value contains both quote types

For simple attribute assignments, prefer the `set_value` tool which handles quoting automatically.

### Boolean Return Values

Tinderbox boolean results from comparisons and functions:
- **True** = `"true"` (string)
- **False** = `""` (empty string), NOT `"false"`

Exception: `.contains()` on strings returns a **1-based position** (integer) or `0` if not found. On sets, `.contains()` returns 1-based position or `""` (empty string) if not found.

---

## Cross-References

For deeper coverage, see:

- **[Action Functions Reference](action-functions.md)** -- Complete catalog of 300+ action code functions by category
- **[Action-Holding Attributes](action-attributes.md)** -- The 12 system attributes that hold executable action code ($Rule, $OnAdd, $DisplayExpression, etc.)
