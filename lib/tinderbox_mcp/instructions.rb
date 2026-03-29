module TinderboxMCP
  module Instructions

    def self.text
      <<~'INSTRUCTIONS'
# Tinderbox MCP Quick Reference

## Attribute References

Tinderbox attributes are accessed with the `$` prefix. Key built-in attributes:

**Identity & Content**: $Name, $Text, $Path, $ID, $Container (set to move notes), $Prototype
**Dates**: $Created, $Modified, $StartDate, $DueDate, $EndDate
**Appearance**: $Color, $Badge, $Width, $Height, $Xpos, $Ypos, $Shape, $NameFont, $NameColor, $NameBold, $MapNameSize, $OutlineNameSize
**Metrics**: $WordCount, $ChildCount, $DescendantCount, $SiblingOrder, $OutlineOrder, $OutlineDepth
**Links**: $OutboundLinkCount, $InboundLinkCount, $PlainLinkCount, $WebLinkCount
**Organization**: $Tags, $Checked
**Behavior**: $IsAgent, $IsPrototype, $IsAlias, $ReadOnly
**Agent-specific**: $AgentQuery, $AgentAction, $AgentPriority, $CleanupAction
**Action-holding**: $Rule, $Edict, $OnAdd, $OnRemove, $OnVisit, $DisplayExpression, $HoverExpression

User-created attributes start with a capital letter: `$MyCustomAttr`. Create with `createAttribute("AttrName","type")` where type is: string, number, boolean, date, color, list, set, dictionary, interval, email, file, url.

## Expression Syntax

Expressions are read-only and return values. Use with the `evaluate` tool.

### Operators
- **Arithmetic**: `+`, `-`, `*`, `/` (note: `%` is NOT modulo — use `mod(a,b)` instead)
- **Comparison**: `==`, `!=`, `>`, `<`, `>=`, `<=`
- **Logical**: `&` (AND), `|` (OR), `!` (NOT). Use parentheses for grouping: `(A | B) & C`
- **String concatenation**: `+`

### Designators (relative note references)
- `parent` — parent container
- `child` / `children` — direct children
- `nextSibling` / `prevSibling` — siblings
- `ancestors` / `descendants` — full lineage
- `all` — every note in the document
- `find(query)` — notes matching a query anywhere in the document
- Access attribute of another note: `$Name(parent)`, `$Color(/path/to/note)`

### Key Functions
- **Collections**: `collect(scope, $Attr)`, `collect_if(scope, condition, $Attr)`, `count(scope)`, `sum(scope, $Attr)`, `min(scope, $Attr)`, `max(scope, $Attr)`, `avg(scope, $Attr)`
- **String**: `.contains(pattern)` (supports regex), `.icontains(pattern)`, `.beginsWith(str)`, `.endsWith(str)`, `.replace(pattern, replacement)`, `.lowercase()`, `.uppercase()`, `.trim()`, `.substr(start, len)`, `.split(delim)`. Strings can also be compared with `==`, `!=`, `>`, `<`, etc.
- **Date**: `date("today")`, `date("now")`, `date("yesterday")`, `date("today+7")`, `date("today-1 week")`, `minutes`, `hours`, `days`, `weeks`, `months`, `years` (intervals)
- **Formatting**: `format(value, pattern)` — e.g., `format($WordCount, "0")` for integer
- **Math**: `sqrt(x)`, `abs(x)`, `floor(x)`, `ceil(x)`, `round(x)`, `sin(x)`, `cos(x)`

### Query Patterns (used in get_notes query parameter and $AgentQuery)
- Exact match: `$Name=="Meeting Notes"`
- Partial match: `$Name.contains("meeting")`
- Case-insensitive: `$Name.icontains("meeting")`
- Numeric: `$WordCount > 500`
- Date: `$Modified > date("today-1 week")`
- Compound: `$Name.contains("Vienna") & $WordCount > 100`
- OR: `$Tags.contains("urgent") | $Checked`
- Negation: `!$Checked`
- Container: `$Container=="/Projects"`
- Prototype: `$Prototype=="Task"`
- Link queries: `linkedTo(/path/to/note[,"linkType"])`, `linkedFrom(/path/to/note[,"linkType"])`
- Document-wide search: `collect(find($Name.contains("x")), $Path)`

## Action Code

Actions perform mutations. Use with the `do` tool.

### Assignment
- String value: `$Color="red"` or `$Text='some text'`
- Expression: `$Width=$Height*2`
- From another note: `$Color=$Color(parent)`

### CRITICAL — String Quoting Rules
Tinderbox action code has NO escape sequences. `\"` does NOT work. Instead:
- Use **single quotes** when value contains double quotes: `$Text='He said "hello"'`
- Use **double quotes** when value contains apostrophes: `$Text="it's fine"`
- Use **`+` concatenation** when value contains both: `$Text="it" + "'" + 's "both"'`

### CRITICAL — Conditional Syntax
Tinderbox has NO `else if` or `elseif`. Only `if` and `if/else`:
- `if(condition){actions}`
- `if(condition){actions}else{actions}`
- For multi-branch: nest if inside else: `if(A){...}else{if(B){...}else{...}}`

### Loops
- `list.each(x){actions using x}`
- `$Tags.each(tag){...}`
- `collect(children,$Name).each(n){...}`

### Key Action Functions
- `linkTo(pathOrDesignator[,"linkType"])` — create link from current note
- `createLink(sourcePath, destPath[, "linkType"])` — create link between any notes
- `createAttribute("AttrName","type")` — create user attribute
- `createAgent(path)` — create an agent
- `create(name)` — create child note
- `linkFromOriginal()` — create link from an alias's original note

## Map Adornments

Adornments are visual background elements in Map view that sit behind all notes. Create with `create_note` using `kind: "adornment"`, then configure with `set_value` or `do`.

**Key attributes**: `$Color`, `$Width`, `$Height`, `$Xpos`, `$Ypos`, `$Border`, `$BorderColor`, `$Opacity`, `$Shape`, `$Lock`, `$Sticky`, `$NameColor`, `$NameAlignment`

**Smart adornments**: Set `$AgentQuery` on an adornment to auto-move matching notes onto it (scope: current map only, moves originals — not aliases like agents).

**$OnAdd/$OnRemove**: Action code that fires when notes are moved onto/off the adornment. Use the `adornment` designator to reference the adornment itself: `$Color=$Color(adornment)`.

**Sticky**: When `$Sticky` is true, notes overlapping the adornment move with it when dragged. **Lock**: `$Lock` prevents repositioning/resizing.

**Dividers**: Set `$Width=0` for vertical line, `$Height=0` for horizontal line.

**Gotchas**: Adornments are NOT containers (no children in outline), cannot be linked to/from, cannot be searched, and do not display `$Text` on their face (only `$Name`).

## Poster Notes (Map View Visualizations)

A poster note displays a rendered web view on its face in map view. To create one:
- Assign the **Poster** prototype: `$Prototype="Poster"` (add it via `/Prototypes` if not installed)
- Create an HTML **template note** in `/Templates` using export codes (e.g., `^value($ScreenWidth)` for width in pixels, `^value($ScreenHeight)` for height, `^text` for the note's text)
- Set `$PosterTemplate` to the template note's path
- Control size with `$Width` and `$Height` (1 unit = 32px)

Posters work well with plotly, mermaid, chart.js, and other JavaScript visualization libraries.

## Note URLs

Tinderbox notes can be referenced by URL using the `tinderbox://` scheme. The format is:
`tinderbox://<document>/?view=<viewType>+select=<noteID>`

- `<document>` — document name (lowercase, no extension): `untitled`, `my-project`
- `<viewType>` — one of: `outline`, `map`, `chart`, `treemap`, `timeline`, `attribute-browser`, `hyperbolic`
- `<noteID>` — the note's numeric `$ID` value

Example: `tinderbox://untitled/?view=outline+select=1774798250`

To construct a URL, evaluate `$ID` on the note and build the string. These URLs can open a specific note in a specific view when clicked.

## Inheritance

Notes can have a Prototype note (set via `$Prototype`). A note inherits attribute values from its prototype unless it has its own local value. Notes can always override inherited values. Prototypes can themselves have prototypes, forming an inheritance chain. By convention, prototype notes set `$IsPrototype` to true and live in the `/Prototypes` container.

## Important Gotchas

1. **`evaluate` always returns text** — even for numbers/booleans. `$WordCount` returns `"42"` not `42`.
2. **`.contains()` returns position, not boolean** — returns 1-based character position of match, or 0 if not found. In boolean context this works correctly (0=false, nonzero=true), but be aware when using the return value.
3. **Paths start with `/`** — always use full paths from root: `/Projects/My Note`, not `Projects/My Note`.
4. **`/` not allowed in note names** — it's the path separator. Use alternatives.
5. **`act on` returns may be empty** — don't rely on return values from actions.
6. **Boolean attributes** — test with `$Checked` not `$Checked==true`. In queries, `$Checked` means true, `!$Checked` means false.
7. **No quote escaping** — see String Quoting Rules above.
8. **No else-if** — see Conditional Syntax above.
9. **Agents need name set after creation** — `make new agent` doesn't always respect name in properties.
10. **Text set after creation** — set text separately after `make new note`, not in creation properties.
11. **Semicolons in paths** — the tools use `;` as delimiter. Note paths containing `;` cannot be used in multi-note parameters.

## Detailed Reference

For deeper reference, use the `get_reference` tool with one of these topics:
- `adornments` — Map adornments: smart adornments, sticky/lock, grids, dividers
- `expressions` — Full expression & action code syntax with examples
- `action-functions` — Catalog of 300+ action code functions by category
- `action-attributes` — 12 action-holding attributes ($Rule, $AgentQuery, etc.)
- `system-containers` — Prototypes, Templates, Hints, and Composites
- `export-codes` — 46 ^caret^ export template codes
      INSTRUCTIONS
    end

  end
end
