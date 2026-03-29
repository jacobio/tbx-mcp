# System Containers & Built-In Features

> Examples include the required `document` parameter. Replace `"MyDoc"` with your document name.

Tinderbox recognizes four special root-level containers created via the **File** menu, plus action code functions (`require()`, `update()`) for programmatic access. This reference covers all system containers, their internal structure, and how to work with them via MCP tools.

---

## The `require()` Function

The `require()` function programmatically adds built-in containers and toggles UI features. It is the preferred way to ensure system containers exist before working with them.

| Call | Effect |
|------|--------|
| `require("Prototypes")` | Creates `/Prototypes` container (equivalent to File > Built-In Prototypes) |
| `require("Templates")` | Creates `/Templates` container (equivalent to File > Built-In Templates) |
| `require("Hints")` | Creates `/Hints` container with full sub-structure (equivalent to File > Built-In Hints) |
| `require("Preview")` | Shows the text pane selector above the text pane |
| `require("NoPreview")` | Hides the text pane selector above the text pane |

**MCP Example**:
```
// Ensure Prototypes container exists
do(document: "MyDoc", action: "require(\"Prototypes\")", note: "/")

// Ensure Templates container exists
do(document: "MyDoc", action: "require(\"Templates\")", note: "/")

// Ensure Hints container exists (with full sub-structure)
do(document: "MyDoc", action: "require(\"Hints\")", note: "/")

// Show the text pane selector
do(document: "MyDoc", action: "require(\"Preview\")", note: "/")

// Hide the text pane selector
do(document: "MyDoc", action: "require(\"NoPreview\")", note: "/")
```

> **Note**: `require()` is idempotent — calling it when the container already exists has no effect.

> **Note**: There is no `require("Composites")` documented. That container must be created via the File menu or manually (see section below).

---

## The `update()` Function

The `update()` function recompiles user-defined functions stored in `/Hints/Library` notes.

### Two Forms

| Call | Effect |
|------|--------|
| `update()` | Recompiles all **already-compiled** Library notes. Does NOT compile newly created notes that have never been compiled. |
| `update("/Hints/Library/NoteName")` | Compiles/recompiles a **specific** Library note by path. Works on newly created notes that have never been compiled. |

### Usage

```
// After modifying an EXISTING Library function note's text
do(document: "MyDoc", action: "update()", note: "/")

// After CREATING a new Library function note, compile it by path
do(document: "MyDoc", action: "update(\"/Hints/Library/MyFunction\")", note: "/")
```

> **Important**: Library notes are compiled at document open. The no-argument `update()` only recompiles notes that were previously compiled. When creating new Library notes programmatically (e.g., in an installer), you **must** use `update("/Hints/Library/NoteName")` with the explicit path to compile each new note. The no-argument form will not pick them up.

> **Important**: Library notes must have `$IsAction = true` to be recognized as action code. The built-in Library container's `$OnAdd` sets `$Prototype="Action"` which enables this, but when creating notes programmatically you should set `$IsAction = true` explicitly.

---

## 1. Prototypes Container (`/Prototypes`)

**Created by**: File > Built-In Prototypes, or `require("Prototypes")`, or automatically via `#` note-name syntax

### Automatic Attributes

| Attribute | Value | Purpose |
|-----------|-------|---------|
| `$OnAdd` | `$IsPrototype=true` | Any child note becomes a prototype |
| `$HTMLDontExport` | `true` | Excluded from HTML export |
| `$HTMLExportChildren` | `false` | Children excluded from export |

### Built-In Prototypes

When created via the File menu, these prototype notes are available as children:

Action, Code, Dashboard, Event, HTML, Markdown, Person, Reference, Task

### The `#` Syntax

Tinderbox's note-name parser recognizes `#PrototypeName` at the end of a new note's name:

- `John Brown#Person` creates a note named "John Brown" with prototype "Person"
- If the "Person" prototype doesn't exist, it's auto-created in `/Prototypes`
- If `/Prototypes` doesn't exist, it's auto-created at root level
- `#` followed by a digit (e.g., "Activity #3") is NOT treated as prototype syntax

**MCP Example**:
```
// Using require() — preferred
do(document: "MyDoc", action: "require(\"Prototypes\")", note: "/")

// Or create manually with the correct attributes
create_note(document: "MyDoc", name: "Prototypes", container: "/")
set_value(document: "MyDoc", notes: "/Prototypes", attribute: "OnAdd", value: "$IsPrototype=true")
set_value(document: "MyDoc", notes: "/Prototypes", attribute: "HTMLDontExport", value: "true")
set_value(document: "MyDoc", notes: "/Prototypes", attribute: "HTMLExportChildren", value: "false")

// Add a custom prototype
create_note(document: "MyDoc", name: "Task", container: "/Prototypes")
// $IsPrototype is set automatically by $OnAdd
set_value(document: "MyDoc", notes: "/Prototypes/Task", attribute: "Badge", value: "star")
set_value(document: "MyDoc", notes: "/Prototypes/Task", attribute: "Color", value: "blue")
```

---

## 2. Templates Container (`/Templates`)

**Created by**: File > Built-In Templates, or `require("Templates")`

### Automatic Attributes

| Attribute | Value | Purpose |
|-----------|-------|---------|
| `$OnAdd` | `$IsTemplate=true` | Any child note becomes an export template |

### Built-In Templates

HTML, HTML Single note, OPML, Scrivener, Preview

### Key Behavior

- Must be a **root-level** note (interior notes named "Templates" are not recognized)
- Notes with `$IsTemplate=true` appear in template selection menus
- Agents cannot function as templates, even with `$IsTemplate=true`
- Creating templates also adds the "HTML" prototype to `/Prototypes` if needed

**MCP Example**:
```
// Using require() — preferred
do(document: "MyDoc", action: "require(\"Templates\")", note: "/")

// Or create manually
create_note(document: "MyDoc", name: "Templates", container: "/")
set_value(document: "MyDoc", notes: "/Templates", attribute: "OnAdd", value: "$IsTemplate=true")

// Add a custom template
create_note(document: "MyDoc", name: "My Export", container: "/Templates", text: "<html><head><title>^value($Name)^</title></head><body>^text^</body></html>")
```

---

## 3. Hints Container (`/Hints`)

**Created by**: File > Built-In Hints, or `require("Hints")`

The Hints container has the most complex internal structure of the four system containers. It provides AI tagging, syntax highlighting, stamps management, library functions, and preview features.

### Internal Structure

```
/Hints
  /Taggers         # AI-assisted automatic tagging
  /Highlighters    # Syntax highlighting definitions
  /Stamps          # Reusable action code stamps
  /Library         # User-defined functions (loaded at startup)
  /Stoplist        # Words to exclude from word clouds
  /Preview         # Preview template configuration
  /AI              # AI integration settings
```

### Taggers (`/Hints/Taggers`)

Tagger notes provide hints to Tinderbox for automatic tagging of note content. Each tagger note is named after a **Set-type attribute**.

**Built-in taggers**:

| Note Name | Method | Description |
|-----------|--------|-------------|
| `NLPlaces` | Apple NLP | Detects location/place names in `$Text` |
| `NLNames` | Apple NLP | Detects person names in `$Text` |
| `NLOrganizations` | Apple NLP | Detects organization names in `$Text` |
| `NLTags` | Manual rules | User-created tags (no NLP) |

**Tagger file syntax** (inside the tagger note's `$Text`):

```
tag: term1; term2; term3;
```

- Trailing semicolon is **mandatory**
- Each line maps a tag value to terms that trigger it
- Taggers analyze `$Name` and `$Text` of notes
- Tags are added when terms match and removed when terms disappear
- The associated Set attribute becomes read-only (tagger-managed)

**Custom taggers**: Create a Set-type user attribute, then create a tagger note in `/Hints/Taggers` with that exact attribute name.

### Library (`/Hints/Library`)

Notes in the Library container define user functions that are compiled at document open. These functions are then available in any action code throughout the document.

```
// Library note text defines a function:
// function myHelper(x) { return x * 2; }

// After modifying an existing Library note, recompile all:
do(document: "MyDoc", action: "update()", note: "/")

// After creating a NEW Library note, compile it by path:
do(document: "MyDoc", action: "update(\"/Hints/Library/MyHelper\")", note: "/")
```

- Library notes must have `$IsAction = true` to be compiled as action code
- The built-in Library container's `$OnAdd` sets `$Prototype="Action"` which enables `$IsAction`; when creating notes programmatically, set `$IsAction = true` explicitly
- Notes with parenthesized names like `(Documentation)` are treated as commentary, not compiled
- Functions defined here are globally available in action code expressions
- When creating new library notes in an installer, use `update("/Hints/Library/NoteName")` for each note — the no-argument `update()` will not compile notes that have never been compiled before

### Highlighters (`/Hints/Highlighters`)

Define syntax highlighting rules using regex patterns paired with formatting.

**Built-in highlighters**: Markdown, Syntax (demonstration)

Set `$SyntaxHighlighting` on a note to the highlighter name to activate it:

```
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "SyntaxHighlighting", value: "Markdown")
```

### Stamps (`/Hints/Stamps`)

When the Hints container is present, stamps from the Stamps Inspector are replicated here as notes.

- Stamps can be edited in either location (Inspector or Hints container)
- Ordering is independent between the two locations
- Notes with parenthesized names are treated as commentary
- Stamp names containing exactly one colon create submenus in the Stamps menu

**MCP Example**:
```
// Assuming /Hints/Taggers already exists
// Create a custom tagger (requires a Set-type user attribute named "Topics")
create_note(document: "MyDoc", name: "Topics", container: "/Hints/Taggers", text: "AI: artificial intelligence; machine learning; neural network;\nData: database; SQL; data warehouse;\n")
```

---

## 4. Composites Container (`/Composites`)

**Created by**: File > Built-In Composites

### Automatic Attributes

| Attribute | Value | Purpose |
|-----------|-------|---------|
| `$HTMLDontExport` | `true` | Excluded from HTML export |
| `$HTMLExportChildren` | `false` | Children excluded from export |

### Key Behavior

- Composites are groups of notes that work together, primarily for Map view
- Composite masters stored here appear in the **Note > Create Composite** menu
- Composites must have a composite name to appear in selection lists
- In Map view, touching note icons automatically form composites

**MCP Example**:
```
create_note(document: "MyDoc", name: "Composites", container: "/")
set_value(document: "MyDoc", notes: "/Composites", attribute: "HTMLDontExport", value: "true")
set_value(document: "MyDoc", notes: "/Composites", attribute: "HTMLExportChildren", value: "false")
```

---

## Text Pane Selector

The text pane selector displays tabs above the text pane for switching between Text, Preview, and Export views.

### Programmatic Control

```
// Show the text pane selector
do(document: "MyDoc", action: "require(\"Preview\")", note: "/")

// Hide the text pane selector
do(document: "MyDoc", action: "require(\"NoPreview\")", note: "/")
```

### Keyboard Shortcut

**Option-Command-E** cycles through the text pane modes: Text, Preview, Export.

### Menu Access

Window > Show/Hide Text Pane Selector

---

## Summary

| Container | `require()` | File Menu | Key `$OnAdd` |
|-----------|-------------|-----------|---------------|
| `/Prototypes` | `require("Prototypes")` | File > Built-In Prototypes | `$IsPrototype=true` |
| `/Templates` | `require("Templates")` | File > Built-In Templates | `$IsTemplate=true` |
| `/Hints` | `require("Hints")` | File > Built-In Hints | (complex sub-structure) |
| `/Composites` | — | File > Built-In Composites | (none) |

| Feature | `require()` Call |
|---------|-----------------|
| Show text pane selector | `require("Preview")` |
| Hide text pane selector | `require("NoPreview")` |

---

## Cross-References

- **[Action Functions](action-functions.md)** — `require()` and `update()` in System/Misc section
- **[Action-Holding Attributes](action-attributes.md)** — `$OnAdd` behavior for `/Prototypes` and `/Templates` containers
- **[Expressions & Actions](expressions.md)** — Expression and action code syntax reference
