# Tinderbox Export Codes Reference

Export codes are caret-delimited (`^code^`) functions used in Tinderbox export templates. They generate HTML, text, or structured output during export. Templates are special notes containing a mix of literal markup and export codes.

**Syntax**: `^codeName(arguments)^` — always include the closing caret.

---

## Quick Reference — All Export Codes

### Core Codes (46)

| Code | Type | Description |
|------|------|-------------|
| `^action(action)^` | Calculation | Execute action code during export |
| `^ancestors([start, prefix, suffix, end])^` | Link | Links to ancestor notes |
| `^backslashEncode(data)^` | Markup | Escape quotes with backslashes |
| `^childLinks([start, prefix, suffix, end])^` | Link | Links to child notes |
| `^children([template][,N])^` | Include | Include children via template |
| `^cloud([item,count])^` | Markup | Word cloud from note text |
| `^comment(data)^` | Include | HTML comment `<!-- data -->` |
| `^descendants([template][,N])^` | Include | Include all descendants |
| `^directory(item)^` | Include | Relative directory path |
| `^do(macro[,args])^` | Include | Execute macro |
| `^docTitle^` | Property | Document filename (without .tbx) |
| `^documentCloud([count])^` | Markup | Word cloud from entire document |
| `^else^` | Conditional | Else branch |
| `^endIf^` | Conditional | End conditional block |
| `^file([item])^` | Property | Export filename |
| `^host^` | Property | Website host from preferences |
| `^if(condition)^` | Conditional | Start conditional block |
| `^inboundBasicLinks([start, prefix, suffix, end[, type]])^` | Link | Incoming basic links |
| `^inboundLinks([start, prefix, suffix, end])^` | Link | All incoming links |
| `^inboundTextLinks([start, prefix, suffix, end[, type]])^` | Link | Incoming text links |
| `^include(item[,template])^` | Include | Embed content from other notes |
| `^indent([data][,N])^` | Markup | Indentation by depth |
| `^linkTo(item[, data][, css class])^` | Link | HTML hyperlink to note |
| `^nextSibling^` | Boolean | Has exportable next sibling? |
| `^not(condition)^` | Conditional | Negate condition |
| `^outboundBasicLinks([start, prefix, suffix, end[, type]])^` | Link | Outgoing basic links |
| `^outboundLinks([start, prefix, suffix, end])^` | Link | All outgoing links |
| `^outboundTextLinks([start, prefix, suffix, end[, type]])^` | Link | Outgoing text links |
| `^outboundWebLinks([start, prefix, suffix, end[, type]])^` | Link | Outgoing web links |
| `^paragraphs([item,]N)^` | Include | First N paragraphs |
| `^path([item])^` | Markup | Relative file path |
| `^previousSibling^` | Boolean | Has exportable previous sibling? |
| `^randomChildOf(item[,template])^` | Include | Random child via template |
| `^randomLine(item)^` | Include | Random paragraph from note |
| `^root^` | Markup | Relative path to root directory |
| `^sectionCloud([item,count])^` | Markup | Word cloud from section |
| `^sectionNumber([item])^` | Property | Hierarchical section number |
| `^setRoot([newRoot])^` | Markup | Override root path |
| `^siblings([start, prefix, suffix, end])^` | Link | Links to sibling notes |
| `^similarTo(item, count[, start, prefix, suffix, end])^` | Link | Similar notes by content |
| `^text([item][,N][,plain])^` | Include | Note body text |
| `^title([item])^` | Include | Note title ($Name) |
| `^url(item)^` | Link | Relative URL of exported page |
| `^value(expression)^` | Include | Evaluate any expression |
| `^version^` | Property | Tinderbox version number |


---

## Export Code Types

### 1. Boolean Comparison (2)

Used inside `^if()^` to test export-time conditions.

#### `^nextSibling^`

Returns true if the current note has an exportable next sibling.

```html
^if(^nextSibling^)^<hr>^endIf^
```

#### `^previousSibling^`

Returns true if the current note has an exportable previous sibling.

```html
^if(^previousSibling^)^<span class="prev">Previous</span>^endIf^
```

### 2. Calculation (1)

#### `^action(action)^`

Executes Tinderbox action code during export. Makes **permanent changes** to note attributes. Does not produce output itself.

```html
^action($Color="red")^
^action($ExportCount=$ExportCount+1)^
```

> **Warning**: Actions run during export permanently modify the document.

### 3. Conditional Markup (4)

#### `^if(condition)^` ... `^else^` ... `^endIf^`

Standard conditional block. Condition uses Tinderbox action code syntax.

```html
^if($Checked)^
  <span class="done">Done</span>
^else^
  <span class="todo">To Do</span>
^endIf^
```

Without `^else^`/`^endIf^`, the conditional extends to end of line only.

Nested conditionals (no "else if" construct):

```html
^if($Priority>3)^
  <strong>High</strong>
^else^
  ^if($Priority>1)^
    Medium
  ^else^
    Low
  ^endIf^
^endIf^
```

#### `^not(condition)^`

Negates a boolean condition. Use inside `^if()^`:

```html
^if(^not(^nextSibling^)^)^<p>Last item</p>^endIf^
```

> Do NOT mix with action code negation. Use `^if($MyString!="")^` not `^if(^not($MyString=="")^)^`.

### 4. Link Creation (14)

These generate HTML hyperlinks. Most list-generating codes share optional formatting parameters:

```
^code([start, list-item-prefix, list-item-suffix, end])^
```

Defaults: `<ul>`, `<li>`, `</li>`, `</ul>`.

#### `^linkTo(item[, data][, css class])^`

Creates an HTML `<a>` link to a note's exported page.

```html
^linkTo(Colophon)^
<!-- produces: <a href="Colophon.html">Colophon</a> -->

^linkTo(Colophon, Read the Colophon)^
<!-- custom link text -->

^linkTo(Colophon, Read the Colophon, xref)^
<!-- with CSS class: <a href="..." class="xref">Read the Colophon</a> -->
```

#### `^url(item)^`

Returns the relative URL path to a note's exported page (no `<a>` tag).

```html
<a href="^url(Colophon)^">Colophon</a>
```

#### `^ancestors([start, prefix, suffix, end])^`

Links to all ancestor notes (breadcrumb trail).

```html
^ancestors^                              <!-- default <ul>/<li> list -->
^ancestors("", "", " : ", "")^           <!-- colon-separated breadcrumbs -->
^ancestors("","","&nbsp;&gt;&nbsp;","")^ <!-- > separated breadcrumbs -->
```

#### `^childLinks([start, prefix, suffix, end])^`

Links to all children of the current note.

```html
^childLinks^                                        <!-- default <ul>/<li> list -->
^childLinks("<ol>","<li>","</li>","</ol>")^          <!-- ordered list -->
^childLinks("","","<br>","")^                        <!-- line-break separated -->
```

#### `^siblings([start, prefix, suffix, end])^`

Links to all siblings of the current note.

```html
^siblings^                                           <!-- default <ul>/<li> list -->
^siblings("","",", ","")^                            <!-- comma-separated -->
```

#### Outbound Link Codes

| Code | Parameters | Type Filter? |
|------|-----------|--------------|
| `^outboundLinks([start, prefix, suffix, end])^` | 0 or 4 | No |
| `^outboundBasicLinks([start, prefix, suffix, end[, type]])^` | 0, 4, or 5 | Yes (regex) |
| `^outboundTextLinks([start, prefix, suffix, end[, type]])^` | 0, 4, or 5 | Yes (regex) |
| `^outboundWebLinks([start, prefix, suffix, end[, type]])^` | 0, 4, or 5 | Yes (regex) |

```html
^outboundLinks^                                                          <!-- default list -->
^outboundBasicLinks("<ul>","<li>","</li>","</ul>")^                      <!-- all basic links -->
^outboundBasicLinks("<ul>","<li>","</li>","</ul>","(agree|disagree)")^   <!-- filtered by type -->
```

#### Inbound Link Codes

| Code | Parameters | Type Filter? |
|------|-----------|--------------|
| `^inboundLinks([start, prefix, suffix, end])^` | 0 or 4 | No |
| `^inboundBasicLinks([start, prefix, suffix, end[, type]])^` | 0, 4, or 5 | Yes (regex) |
| `^inboundTextLinks([start, prefix, suffix, end[, type]])^` | 0, 4, or 5 | Yes (regex) |

```html
^inboundLinks^                                                           <!-- default list -->
^inboundBasicLinks("<ul>","<li>","</li>","</ul>","(example|untitled)")^  <!-- filtered by type -->
```

> **Note**: When using the type filter, all 4 formatting parameters are required — you cannot pass type alone.

#### `^similarTo(item, count[, start, list-item-prefix, list-item-suffix, end])^`

Finds notes with similar content.

```html
^similarTo("this", 10)^
```

### 5. Data Include (12)

These embed content from notes, templates, or expressions into the export.

#### `^value(expression)^` — The Workhorse

Evaluates any Tinderbox expression and outputs the result. This is the most commonly used export code.

```html
<!-- Attribute values -->
^value($Name)^
^value($Width)^
^value($Tags)^

<!-- Another note's attribute -->
^value($Name(parent))^
^value($Width("Some Other Note"))^

<!-- Calculations -->
^value(sqrt($Width).format(2))^
^value($ChildCount * 2)^

<!-- String concatenation -->
^value("Author: " + $Author)^

<!-- Date formatting -->
^value($Created.format("y-MM-dd"))^
^value($Modified.format("EEEE, MMMM d, y"))^

<!-- Collection operations -->
^value(collect(children,$Name).format(", "))^
```

#### `^text([item][, N][, plain])^`

Exports note body text. How markup is handled depends on `$HTMLMarkupText`:

- **`$HTMLMarkupText=true`** (default): `^text^` processes styled text into HTML — paragraphs become `<p>` tags, bold becomes `<strong>`, lists become `<ul><li>`, etc. using the HTML markup tag pair attributes.
- **`$HTMLMarkupText=false`**: `^text^` outputs raw text without adding any HTML tags. This is the correct setting for notes containing code, CSS, or other content that should export verbatim.
- **`plain` parameter**: `^text(this, plain)^` always outputs raw text regardless of `$HTMLMarkupText`.

```html
^text^                        <!-- full text, markup depends on $HTMLMarkupText -->
^text(this, 5)^               <!-- first 5 words -->
^text(this, 10, plain)^       <!-- first 10 words, always plain text -->
^text(this, plain)^           <!-- full text, always plain text -->
```

Use `^value($Text)^` for completely raw, unprocessed text (bypasses the export pipeline entirely).

#### `^title([item])^`

Returns the note's `$Name` with HTML entity encoding for special characters.

```html
<h1>^title^</h1>
<a href="^url(parent)^">^title(parent)^</a>
```

Use `^value($Name)^` if you do NOT want HTML entity encoding.

#### `^children([template][, N])^`

Processes children through a template.

```html
^children^                         <!-- all children, default template -->
^children(list-item-template)^     <!-- all children, named template -->
^children(list-item-template, 5)^  <!-- first 5 children -->
```

#### `^descendants([template][, N])^`

Like `^children^` but processes all descendants recursively.

#### `^include(item[, template])^`

Embeds content from other notes. Arguments are themselves export codes that get evaluated:

```html
^include(^value("sidebar-content")^)^
^include(^value("header")^, ^value("header-template")^)^
^include(^value(find(inside(Some note)))^)^
```

#### `^paragraphs([item,] N)^`

Exports first N paragraphs of note text.

```html
^paragraphs(3)^              <!-- first 3 paragraphs of current note -->
^paragraphs(Summary, 1)^    <!-- first paragraph of "Summary" note -->
```

#### `^comment(data)^`

Inserts an HTML comment.

```html
^comment(Generated by Tinderbox)^
<!-- produces: <!-- Generated by Tinderbox --> -->
```

#### `^do(macro[, args])^`

Executes a named macro with arguments. Unlike the `do()` action code operator, this evaluates inline export codes within macro definitions.

```html
^do("formatDate", $Created)^
```

#### `^directory(item)^`

Returns relative directory path (no filename) for a note's export location.

#### `^randomChildOf(item[, template])^`

Exports a random child of the specified note.

#### `^randomLine(item)^`

Exports a random paragraph from the note's text.

### 6. Data Property (5)

Return document or note metadata.

#### `^docTitle^`

Document filename without `.tbx` extension. **Export-only** — cannot be retrieved via action code.

#### `^file([item])^`

Export filename (`$HTMLExportFileName` + `$HTMLExportExtension`).

> `^value($HTMLExportFileName)^` will NOT work as a substitute — the filename is computed at export time.

#### `^host^`

Website host from document HTML preferences.

#### `^sectionNumber([item])^`

Hierarchical outline position as dotted numbers (e.g., `1.3.2`).

#### `^version^`

Tinderbox version string (e.g., `11.5.2`). **Export-only**.

### 7. Export Markup (8)

Control export structure and formatting.

#### `^root^`

Relative path from current note's exported file to the root directory. Essential for building relative URLs:

```html
<link rel="stylesheet" href="^root^css/style.css">
<img src="^root^images/logo.png">
```

> Do NOT add a leading slash: `^root^css/style.css` not `^root^/css/style.css`.

#### `^setRoot([newRoot])^`

Overrides `^root^` behavior. Useful for absolute URLs:

```html
^setRoot(https://example.com/)^
<link rel="stylesheet" href="^root^css/style.css">
<!-- produces: https://example.com/css/style.css -->
^setRoot()^  <!-- restore relative URLs -->
```

#### `^path([item])^`

Full relative path including filename.

```html
^path^  <!-- e.g., "index/Archive/2024/January.html" -->
```

#### `^indent([data][, N])^`

Repeats a string once per ancestor (default: tab character). Useful for generating indented structures like outlines or sitemaps.

```html
^indent(-)^        <!-- at depth 6: "-----" -->
^indent(&nbsp;)^   <!-- at depth 3: "&nbsp;&nbsp;" -->
^indent("\t", 10)^  <!-- exactly 10 tabs -->
```

#### `^backslashEncode(data)^`

Escapes single and double quotes with backslashes. Useful for JSON/JavaScript output.

#### Word Cloud Codes

| Code | Scope |
|------|-------|
| `^cloud([item, count])^` | Single note's text |
| `^sectionCloud([item, count])^` | Section (parent level) |
| `^documentCloud([count])^` | Entire document |

Default count: 100 words. Uses `HTMLCloud1-5Start/End` attributes for size styling.

---

## Export Templates

Templates are special notes containing export codes mixed with literal markup. A template processes one note at a time — `this` refers to the note being exported.

### Setting Up Templates

1. Create a note to serve as the template
2. Set `$HTMLExportTemplate` on notes to use the template
3. The template's `$Text` contains the markup + export codes

### Minimal HTML Template Example

```html
<!DOCTYPE html>
<html>
<head>
  <title>^title^</title>
  <link rel="stylesheet" href="^root^css/style.css">
</head>
<body>
  <nav>^ancestors("", "", " &gt; ", "")^</nav>
  <h1>^title^</h1>
  <div class="meta">
    <span>Created: ^value($Created.format("y-MM-dd"))^</span>
    ^if($Tags!="")^
    <span>Tags: ^value($Tags)^</span>
    ^endIf^
  </div>
  <div class="content">
    ^text^
  </div>
  ^if($ChildCount>0)^
  <h2>Contents</h2>
  ^children(list-item-template)^
  ^endIf^
  <footer>
    ^if(^previousSibling^)^<a href="^url(prevSibling)^">Previous</a>^endIf^
    ^if(^nextSibling^)^<a href="^url(nextSibling)^">Next</a>^endIf^
  </footer>
</body>
</html>
```

### Plain Text / CSV Export

Templates are not limited to HTML — use them for any text format:

```
^value($Name)^	^value($Created.format("y-MM-dd"))^	^value($Tags)^
```

### JSON Export

```json
{
  "title": "^backslashEncode(^value($Name)^)^",
  "created": "^value($Created.format("y-MM-dd'T'HH:mm:ss"))^",
  "tags": [^value(collect(children,$Name).collect(x,'"'+x+'"').format(","))^],
  "text": "^backslashEncode(^value($Text)^)^"
}
```

---

## Export Code Arguments

| Type | Description | Example |
|------|-------------|---------|
| `action` | Action code statement | `$Color="red"` |
| `condition` | Boolean expression | `$Checked==true` |
| `count` | Numeric value | `10` |
| `css class` | CSS class name | `"xref"` |
| `data` | Value, attribute, or regex | `"hello"` |
| `expression` | Any evaluable expression | `$Name + " (" + $ChildCount + ")"` |
| `item` | Note name, path, or designator | `"Colophon"`, `parent`, `/path/to/note` |
| `N` | Numeric value | `5` |
| `template` | Template note name | `"list-item-template"` |
| `type` | Link type filter (regex) | `"(agree\|disagree)"` |

**Quoting**: Arguments containing operators (`+ - * / = ! | &`) should be double-quoted.

**List formatting parameters** (for link codes):

```
start            — before all items (default: "<ul>")
list-item-prefix — before each item (default: "<li>")
list-item-suffix — after each item (default: "</li>")
end              — after all items (default: "</ul>")
```

---

## Export Code Scope

| Scope | Codes |
|-------|-------|
| **Document** | `^docTitle^`, `^host^`, `^version^`, `^root^`, `^path^`, `^setRoot^`, `^documentCloud^` |
| **Group** | `^sectionCloud^` |
| **Item** | Most codes (operate on current note) |
| **N/A** | `^if^`, `^else^`, `^endIf^`, `^not^` |
| **Link-type aware** | `^inboundBasicLinks^`, `^inboundTextLinks^`, `^outboundBasicLinks^`, `^outboundTextLinks^`, `^outboundWebLinks^` |

---

## Key Export-Related Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `$HTMLExportTemplate` | string | Template note name for this note's export |
| `$HTMLExportPath` | string | Custom export directory |
| `$HTMLExportFileName` | string | Custom export filename (without extension) |
| `$HTMLExportExtension` | string | File extension (default: "html") |
| `$HTMLDontExport` | boolean | Exclude from export |
| `$HTMLMarkupText` | boolean | When `true` (default), `^text^` converts styled text to HTML (`<p>`, `<strong>`, etc.). When `false`, `^text^` outputs raw text without any HTML tags — use for code/CSS assets. |
| `$HTMLQuoteHTML` | boolean | Escape HTML entities in $Text |
| `$TextExportTemplate` | string | Template for text export |

Set via AppleScript:

```applescript
tell application id "Cere"
	tell front document
		act on noteRef with "$HTMLExportTemplate=\"my-template\""
		act on noteRef with "$HTMLDontExport=true"
	end tell
end tell
```

---

## Using Export Codes via AppleScript

Export codes are designed for the export pipeline, not direct AppleScript evaluation. However, `exportedString()` can evaluate a template against a note:

```applescript
tell application id "Cere"
	tell front document
		-- Evaluate a template on a note
		evaluate noteRef with "exportedString(this,\"template-name\")"
	end tell
end tell
```

The `^value()^` export code is equivalent to `evaluate` in AppleScript — both evaluate Tinderbox expressions. The difference is context: `^value()^` runs during export, `evaluate` runs from AppleScript.

---

## Template Infrastructure

### Template Notes

A note becomes a template when `$IsTemplate=true`. Templates are conventionally stored in a root-level "Templates" container whose `$OnAdd` sets `$IsTemplate=true` automatically.

### Creating Templates via AppleScript

```applescript
tell application id "Cere"
	tell front document
		-- Ensure Templates container exists
		if not (exists note "Templates") then
			set templatesContainer to make new note with properties {name:"Templates"}
			act on templatesContainer with "$OnAdd=\"$IsTemplate=true\""
		end if
		set templatesContainer to note "Templates"

		-- Create a template note
		set tmpl to make new note at templatesContainer with properties {name:"my-template"}
		act on tmpl with "$IsTemplate=true"
		set text of tmpl to "<html><head><title>^title^</title></head><body>^text^</body></html>"

		-- Assign template to a note
		act on noteRef with "$HTMLExportTemplate=\"/Templates/my-template\""
	end tell
end tell
```

### Built-in Templates

Tinderbox provides 5 built-in templates via File > Built-in Templates:
- **HTML** — Full HTML5 page with recursive descendant inclusion
- **HTML Single note** — Single note HTML5 export
- **OPML** — OPML outline export
- **Scrivener** — OPML variant for Scrivener
- **Preview** — Markdown preview with CSS

### Export Pipeline

```
Note to export
  → $HTMLExportTemplate selects template note
  → Template $Text parsed for ^caret^ codes
  → Each code evaluated in the exported note's context
  → ^text^ converts $Text using HTML* markup attributes (if $HTMLMarkupText=true)
  → ^text^ outputs raw text (if $HTMLMarkupText=false)
  → ^children^/^descendants^ recursively apply templates
  → File written: $HTMLExportFileName + $HTMLExportExtension
  → $HTMLExportCommand optionally post-processes output
  → File only written if content changed
```

### All HTML/Export Attributes

#### Export File Configuration

| Attribute | Type | Description |
|-----------|------|-------------|
| `$HTMLExportTemplate` | string | Path to template note |
| `$HTMLExportFileName` | string | Custom filename (auto-derived from $Name if empty) |
| `$HTMLExportExtension` | string | File extension (default: ".html") |
| `$HTMLExportPath` | string | Computed full OS path (read-only) |
| `$HTMLExportFileNameSpacer` | string | Character replacing spaces in filenames |
| `$HTMLFileNameLowerCase` | boolean | Force lowercase filenames |
| `$HTMLFileNameMaxLength` | number | Max filename length (default: 100) |
| `$HTMLExportCommand` | string | External post-processing command |
| `$HTMLPreviewCommand` | string | Preview rendering command |
| `$HTMLExportBefore` | string | Action code run before export |
| `$HTMLExportAfter` | string | Action code run after export |
| `$HTMLDontExport` | boolean | Exclude note from export |
| `$HTMLExportChildren` | boolean | Whether to export children |

#### Markup Tag Pairs

These control how styled `$Text` is converted during export:

| Attribute Pair | Purpose |
|----------------|---------|
| `$HTMLBoldStart/End` | Bold wrapping |
| `$HTMLItalicStart/End` | Italic wrapping |
| `$HTMLUnderlineStart/End` | Underline wrapping |
| `$HTMLStrikeStart/End` | Strikethrough wrapping |
| `$HTMLCodeStart/End` | Code/monospace wrapping |
| `$HTMLSubscriptStart/End` | Subscript wrapping |
| `$HTMLSuperscriptStart/End` | Superscript wrapping |
| `$HTMLParagraphStart/End` | Paragraph wrapping |
| `$HTMLFirstParagraphStart/End` | First paragraph (special styling) |
| `$HTMLListStart/End` | Unordered list container |
| `$HTMLListItemStart/End` | List item wrapping |
| `$HTMLOrderedListStart/End` | Ordered list container |
| `$HTMLOrderedListItemStart/End` | Ordered list item wrapping |
| `$HTMLImageStart/End` | Image element wrapping |

#### Template Path Attributes

These system attributes hold **paths** (`$Path`) to template notes. They tell Tinderbox which template to use for different export contexts:

| Attribute | Type | Description |
|-----------|------|-------------|
| `$HTMLExportTemplate` | string | Path to HTML export template note (e.g., `"/Templates/my-template"`) |
| `$TextExportTemplate` | string | Path to plain text export template note |
| `$EmailTemplate` | string | Path to email template note |
| `$RSSChannelTemplate` | string | Path to RSS channel template note |
| `$RSSItemTemplate` | string | Path to RSS item template note |
| `$PosterTemplate` | string | Path to poster template note |

```applescript
tell application id "Cere"
	tell front document
		-- Assign HTML template to a note
		act on noteRef with "$HTMLExportTemplate=\"/Templates/my-template\""
		-- Read back
		set tmpl to evaluate noteRef with "$HTMLExportTemplate"
	end tell
end tell
```

#### Template Status

| Attribute | Type | Description |
|-----------|------|-------------|
| `$IsTemplate` | boolean | Marks note as an export template |

#### Content Processing

| Attribute | Type | Description |
|-----------|------|-------------|
| `$HTMLMarkdown` | boolean | Enable Markdown processing |
| `$HTMLMarkupText` | boolean | When `true` (default), `^text^` converts styled text to HTML. When `false`, `^text^` outputs raw text — use for code/CSS/JS assets. |
| `$HTMLQuoteHTML` | boolean | Escape HTML entities in $Text |
| `$HTMLEntities` | boolean | HTML entity encoding |

---

## Poster Notes

A **poster** note displays a rendered web view on its face in map view. The HTML is computed from a template note using export codes.

### Setup
1. Assign the **Poster** prototype: `$Prototype="Poster"` (add via `require("Prototypes")` if not installed)
2. Create an HTML template note in `/Templates`
3. Set `$PosterTemplate` to the template's path

### Key Template Codes for Posters
| Code | Description |
|------|-------------|
| `^value($ScreenWidth)^` | Poster width in pixels |
| `^value($ScreenHeight)^` | Poster height in pixels |
| `^text^` | The poster note's text content |
| `^value($Name)^` | The poster note's title |
| `^value($Attribute)^` | Any attribute of the poster note |

### Sizing
- `$Width` and `$Height` control the note dimensions in map view
- 1 map unit = 32 pixels (e.g., `$Width=8` produces a 256px wide poster)

### Visualization Libraries
Posters work well with JavaScript visualization libraries embedded in the template HTML:
- **Plotly** — charts and graphs
- **Mermaid** — diagrams and flowcharts
- **Chart.js** — canvas-based charts
- Any library that renders in a web view

---

## Cross-References

- **[Action Functions](action-functions.md)** — Functions usable inside `^value()^`, `^if()^`, and `^action()^`
- **[Expressions & Actions](expressions.md)** — Expression syntax reference
- **[Action-Holding Attributes](action-attributes.md)** — Attributes that hold action code
