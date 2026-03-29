# Tinderbox Expression & Action Language Reference

Tinderbox has its own expression language used in `evaluate` and action language used in `act on`. This reference covers the syntax needed to construct these strings from AppleScript.

**IMPORTANT**: In AppleScript, both `evaluate` and `act on` must be called **in the context of a note within a tell block**: `evaluate noteRef with "..."` and `act on noteRef with "..."`.

## Attribute References

Attributes are referenced with `$` prefix:

```
$Name              — note name
$Text              — note text
$Color             — note color
$Created           — creation date
$Modified          — last modified date
$WordCount         — word count of $Text
$ChildCount        — number of children
$SiblingOrder      — position among siblings (1-based, writable — set to reorder outline)
$Prototype         — prototype name
$Tags              — set of tags (semicolon-separated)
$Path              — full path from root
$Width             — map width
$Height            — map height
$Xpos              — map X position
$Ypos              — map Y position
$Badge             — badge name
$Checked           — checkbox state (boolean)
$URL               — associated URL
$ReferenceURL      — reference URL
$ReadOnly          — is read-only
$HTMLExportPath    — export path
$Separator         — is a separator
```

### User Attribute References

User attributes use the same `$` syntax:

```
$MyCustomField
$ProjectStatus
$Priority
```

## Reading Attributes (via evaluate)

```applescript
tell application id "Cere"
    tell front document
        -- Simple attribute read — called ON THE NOTE
        evaluate noteRef with "$Name"
        evaluate noteRef with "$Created"
        evaluate noteRef with "$Tags"

        -- With formatting (Tinderbox format codes, NOT ICU)
        evaluate noteRef with "$Created.format(\"y-M0-D\")"
        evaluate noteRef with "$Modified.format(\"h:mm p\")"
    end tell
end tell
```

## Writing Attributes (via act on)

```applescript
tell application id "Cere"
    tell front document
        -- Simple assignment — called ON THE NOTE
        act on noteRef with "$Name=\"New Name\""
        act on noteRef with "$Color=\"red\""
        act on noteRef with "$Width=4"
        act on noteRef with "$Checked=true"

        -- Set/list append
        act on noteRef with "$Tags+=\"newtag\""

        -- Set/list remove
        act on noteRef with "$Tags-=\"oldtag\""

        -- Numeric increment
        act on noteRef with "$Priority=$Priority+1"
    end tell
end tell
```

## Operators

### Arithmetic
```
+    addition
-    subtraction
*    multiplication
/    division
```

> **Note**: `%` is NOT modulo in Tinderbox — it returns a literal string. Use `mod(a,b)` instead.

### Comparison
```
==   equals
!=   not equals
>    greater than
<    less than
>=   greater than or equal
<=   less than or equal
```

### Logical
```
&    AND
|    OR
!    NOT
```

### String
```
+           concatenation
.contains() contains substring
.beginsWith() starts with
.endsWith()  ends with
.lowercase() lowercase
.uppercase() uppercase
.trim()     trim whitespace
.wordCount  word count
.paragraphCount paragraph count
.size       character count
```

## String Operations

```applescript
tell application id "Cere"
    tell front document
        -- Contains
        evaluate noteRef with "$Name.contains(\"test\")"
        -- Returns "true" or "false" as string

        -- Begins with
        evaluate noteRef with "$Name.beginsWith(\"Project\")"

        -- Word count
        evaluate noteRef with "$Text.wordCount"

        -- Substring
        evaluate noteRef with "$Name.substr(0,5)"
    end tell
end tell
```

## Collection Operations

Operate on children, descendants, siblings, or linked notes:

```applescript
tell application id "Cere"
    tell front document
        -- Count with condition
        evaluate noteRef with "count(children, $Checked==true)"

        -- Collect values
        evaluate noteRef with "collect(children, $Name)"
        -- Returns semicolon-separated list

        -- Sum numeric values
        evaluate noteRef with "sum(children, $Price)"

        -- Average
        evaluate noteRef with "avg(children, $Priority)"

        -- Min / Max
        evaluate noteRef with "min(children, $Price)"
        evaluate noteRef with "max(children, $Priority)"

        -- Collect from descendants (recursive)
        evaluate noteRef with "collect(descendants, $Name)"

        -- Collect from linked notes
        evaluate noteRef with "collect(links, $Name)"

        -- Collect with condition
        evaluate noteRef with "collect_if(children, $Checked==true, $Name)"
    end tell
end tell
```

## Conditional Expressions

```applescript
tell application id "Cere"
    tell front document
        -- if/else
        evaluate noteRef with "if($Prototype==\"Task\"){$Status}else{\"N/A\"}"

        -- Nested conditions
        evaluate noteRef with "if($Priority>3){\"High\"}else{if($Priority>1){\"Medium\"}else{\"Low\"}}"
    end tell
end tell
```

## Conditional Actions

```applescript
tell application id "Cere"
    tell front document
        -- if/else in actions
        act on noteRef with "if($WordCount>100){$Badge=\"long\"}else{$Badge=\"short\"}"

        -- Apply conditionally
        act on noteRef with "if($Tags.contains(\"important\")){$Color=\"red\"}"
    end tell
end tell
```

## Date Functions

```applescript
tell application id "Cere"
    tell front document
        -- Current date/time
        evaluate noteRef with "date(\"today\")"
        evaluate noteRef with "date(\"now\")"
        evaluate noteRef with "date(\"yesterday\")"
        evaluate noteRef with "date(\"tomorrow\")"

        -- Date formatting (Tinderbox format codes, NOT ICU)
        evaluate noteRef with "$Created.format(\"y-M0-D\")"      -- 2026-03-02
        evaluate noteRef with "$Modified.format(\"W, MM d, y\")"  -- Monday, March 2, 2026

        -- Date arithmetic
        evaluate noteRef with "$Created + days(7)" -- 7 days after created

        -- Date comparison
        evaluate noteRef with "$Modified > date(\"yesterday\")"

        -- Set date attribute
        act on noteRef with "$DueDate=date(\"next week\")"
        act on noteRef with "$DueDate=date(\"2025-03-15\")"
    end tell
end tell
```

### Date Format Codes

Tinderbox uses its **own format codes** (not ICU/Unicode patterns). Use with `.format("codes")`.

| Code | Produces | Example |
|------|----------|---------|
| **Complete formats** | | |
| `L` | Local long date | April 29, 2003 |
| `l` | Local short date | 4-29-03 |
| `*` | RFC 822 | Tue, Apr 29 2003 14:32:00 +0500 |
| `=` | ISO 8601 with time | 2023-04-29T14:32:18+05:00 |
| `==` | ISO 8601 date only | 2023-04-29 |
| `U` | Unix epoch (seconds) | 1051625520 |
| `n` | Medium date + short time | 21 Jan 2020 at 17:12 |
| **Day** | | |
| `d` | Day, no padding | 9 |
| `D` | Day, zero-padded | 09 |
| `o` | Ordinal day | 2nd, 10th |
| `w` | Weekday abbreviation | Tue |
| `W` | Full weekday name | Tuesday |
| **Month** | | |
| `m` | Month, no padding | 4 |
| `M0` | Month, zero-padded | 04 |
| `M` | Month abbreviation | Apr |
| `MM` | Full month name | April |
| **Year** | | |
| `y` | 4-digit year | 2026 |
| `Y` | 2-digit year | 26 |
| **Time** | | |
| `t` | Local time format | 2:32 PM |
| `h` | 24-hour, zero-padded | 14 |
| `H` | 12-hour | 2 |
| `mm` | Minutes, zero-padded | 32 |
| `s` | Seconds, zero-padded | 18 |
| `p` | AM/PM | PM |

Use `\` to escape a code as literal text. Examples:

```
$Created.format("y-M0-D")           -- 2026-03-02
$Created.format("W, MM d, y")       -- Monday, March 2, 2026
$Modified.format("y-M0-D h:mm p")   -- 2026-03-02 14:32 PM
$Created.format("=")                -- ISO 8601
$Created.format("o MM y")           -- 2nd March 2026
```

## Action Commands

These are used in `act on` only:

### linkTo — Create a link

```applescript
tell application id "Cere"
    tell front document
        -- Basic link
        act on noteRef with "linkTo(\"/path/to/target\")"

        -- Typed link (type is auto-created if it doesn't exist)
        act on noteRef with "linkTo(\"/path/to/target\", \"references\")"
    end tell
end tell
```

### moveTo — Move a note

```applescript
tell application id "Cere"
    tell front document
        act on noteRef with "moveTo(\"/Destination/Container\")"
    end tell
end tell
```

### create — Create a child note

```applescript
tell application id "Cere"
    tell front document
        act on noteRef with "create(\"ChildName\")"
    end tell
end tell
```

### indent / outdent — Change nesting

```applescript
tell application id "Cere"
    tell front document
        act on noteRef with "indent"
        act on noteRef with "outdent"
    end tell
end tell
```

## Designators

Designators reference notes relative to the current context. Used in both `evaluate` and `act on`.

### Item Designators (single note)

Access another note's attributes: `$Attr(designator)`

```applescript
tell application id "Cere"
    tell front document
        evaluate noteRef with "$Name(parent)"        -- parent's name
        evaluate noteRef with "$Color(child[0])"     -- first child's color
        evaluate noteRef with "$Name(\"Some Note\")" -- named note's attribute
        evaluate noteRef with "$Name(\"/path/to/note\")" -- by path
    end tell
end tell
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

```applescript
tell application id "Cere"
    tell front document
        evaluate noteRef with "collect(children,$Name)"
        evaluate noteRef with "collect(find($Tags.contains(\"important\")),$Name)"
    end tell
end tell
```

> See **[Action Functions Reference](action-functions.md#15-designators)** for the complete designator list.

## Agent Query Syntax

Agent queries use Tinderbox expressions. Set them via `act on` on the agent:

```applescript
tell application id "Cere"
    tell front document
        -- Find notes with a specific prototype
        act on agentRef with "$AgentQuery='$Prototype==\"Task\"'"

        -- Find notes modified recently
        act on agentRef with "$AgentQuery='$Modified > date(\"yesterday\")'"

        -- Find notes with specific tags
        act on agentRef with "$AgentQuery='$Tags.contains(\"research\")'"

        -- Find notes inside a container
        act on agentRef with "$AgentQuery='inside(\"Projects\")'"

        -- Compound query
        act on agentRef with "$AgentQuery='$Prototype==\"Task\" & $Checked==false'"

        -- Simple query without inner quotes
        act on agentRef with "$AgentQuery=\"$WordCount>50\""
    end tell
end tell
```

## Agent Action Syntax

Actions that run on each note collected by an agent:

```applescript
tell application id "Cere"
    tell front document
        -- Color collected notes
        act on agentRef with "$AgentAction='$Color=\"blue\"'"

        -- Set a badge
        act on agentRef with "$AgentAction='$Badge=\"flag\"'"
    end tell
end tell
```

## Quoting Guide for AppleScript

When embedding Tinderbox expressions in AppleScript strings passed through the shell, you must manage multiple quoting layers:

1. **Shell layer**: Use a heredoc (`<<'APPLESCRIPT'`) to avoid shell escaping entirely
2. **AppleScript string layer**: Use double quotes for strings, `\"` for literal quotes inside
3. **Tinderbox expression layer**: For action-holding attributes with nested quotes, use Tinderbox single-quoted strings (`'...'`) where `"` is literal — Tinderbox does NOT support quote escaping, so `\"` inside a Tinderbox string does not work

```applescript
-- Simple — no inner quotes needed
evaluate noteRef with "$Name"

-- Inner quotes — escape with backslash (AppleScript layer only)
act on noteRef with "$Color=\"red\""

-- Nested quotes — use Tinderbox single-quoted strings
act on agentRef with "$AgentQuery='$Prototype==\"Task\"'"
```

### Boolean Return Values

Tinderbox boolean results from comparisons and functions:
- **True** = `"true"` (string)
- **False** = `""` (empty string), NOT `"false"`

Exception: `.contains()` on strings returns a **1-based position** (integer), not a boolean. On sets, `.contains()` returns position or empty string.

### Heredoc Pattern for Complex Expressions

```bash
osascript <<'APPLESCRIPT'
tell application id "Cere"
    tell front document
        set noteRef to note 1
        -- act on called on the note, not the app
        act on noteRef with "$AgentQuery='$Prototype==\"Task\" & $Checked==false'"
    end tell
end tell
APPLESCRIPT
```

---

## Cross-References

For deeper coverage, see:

- **[Action Functions Reference](action-functions.md)** — Complete catalog of 600+ action code functions by category
- **[Action-Holding Attributes](action-attributes.md)** — The 12 system attributes that hold executable action code ($Rule, $OnAdd, $DisplayExpression, etc.)
- **[AppleScript API Reference](applescript-api.md)** — AppleScript bridge layer: make, delete, move, evaluate, act on
