# Tinderbox Action-Holding Attributes Reference

> Examples include the required `document` parameter. Replace `"MyDoc"` with your document name.

Tinderbox has 12 system attributes whose values are executable action code. These attributes hold Tinderbox action code that fire automatically in response to specific triggers.

All can be read via the `evaluate` tool and written via the `set_value` tool or the `do` tool.

---

## Overview

| Attribute | Trigger | Scope | Scriptable? |
|-----------|---------|-------|-------------|
| `$Rule` | Every agent cycle (~2-5s) | The note itself | Yes |
| `$Edict` | Periodically (~hourly) | The note itself | No (cycle too long) |
| `$OnAdd` | Note added to container | The added child | Yes |
| `$OnRemove` | Note removed from container | The removed note | Possible |
| `$OnJoin` | Note joins composite | The joining note | No (composites need UI) |
| `$OnPaste` | Note pasted (same or different doc) | The pasted note | No (paste needs UI) |
| `$OnVisit` | Note visited/selected | The visited note | Possible |
| `$DisplayExpression` | On render | Display result | Yes |
| `$HoverExpression` | On hover | Hover text | No (needs UI hover) |
| `$TableExpression` | On map container render | Map container summary | No (display only) |
| `$AgentQuery` | Every agent cycle | Agent matches | Yes |
| `$AgentAction` | Agent matches notes | Matched aliases | Yes |

---

## Detailed Reference

### $Rule

**Trigger**: Fires every agent cycle (approximately every 2-5 seconds, depending on document complexity).

**Scope**: Runs in the context of the note that holds the rule. `this` refers to the note itself.

**Use case**: Continuously computed values, auto-classification, dynamic formatting.

**MCP Example**:
```
// Set a rule that continuously sets Badge
do(document: "MyDoc", action: "$Rule='$Badge=\"ruled\"'", note: "/path/to/note")

// Read the rule
evaluate(document: "MyDoc", expression: "$Rule", note: "/path/to/note")

// IMPORTANT: Always clear rules when done to prevent ongoing side effects
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "Rule", value: "")
```

> **Live-tested**: Setting `$Rule` via the `do` tool works. However, the rule cycle may not fire immediately. Always clear rules after testing.

`$RuleDisabled` (Boolean): Controls whether `$Rule` fires. Set to `true` to prevent the rule from executing. Useful for one-shot rules that should only fire when manually enabled.

**Self-disabling rule pattern**: Set `$Rule="action($Text);"` and `$RuleDisabled=true`. The note's `$Text` contains the action code payload with `$RuleDisabled=true;` as its last line. To execute: set `$RuleDisabled=false` — the rule fires once, executes `$Text`, and the action code re-disables itself.

```
// Set up a self-disabling rule
do(document: "MyDoc", action: "$Rule=\"action($Text);\"", note: "/path/to/note")
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "RuleDisabled", value: "true")

// The note's $Text should end with:
//   $RuleDisabled=true;
// This makes the rule self-disabling after one execution.

// To trigger: enable the rule
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "RuleDisabled", value: "false")
// Rule fires on next cycle, executes $Text, which re-disables itself
```

### $Edict

**Trigger**: Fires periodically, roughly hourly (much less frequently than rules).

**Scope**: Same as `$Rule` — runs on the note itself.

**Use case**: Low-priority maintenance tasks, periodic cleanup.

**MCP Example**:
```
do(document: "MyDoc", action: "$Edict='$Badge=\"checked\"'", note: "/path/to/note")
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "Edict", value: "")  # clear when done
```

> Not practically testable due to long cycle times.

### $OnAdd

**Trigger**: Fires when a note is added as a child of the container holding this attribute.

**Scope**: `this` refers to the **newly added child**, not the container. The action runs on the child.

**Use case**: Auto-tagging new notes, setting prototypes on creation, inbox processing.

**MCP Example**:
```
// Set OnAdd on a container
do(document: "MyDoc", action: "$OnAdd='$Badge=\"star\"'", note: "/path/to/note")

// Create a child — should trigger OnAdd
create_note(document: "MyDoc", name: "NewChild", container: "/path/to/note")

// Check the child's badge
evaluate(document: "MyDoc", expression: "$Badge", note: "/path/to/note/NewChild")

// Clean up
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "OnAdd", value: "")
```

> **Live-tested**: Setting `$OnAdd` works. When creating a child via the `create_note` tool, the `$OnAdd` action may not fire immediately — it may require a Tinderbox UI cycle. The child is created successfully but the `$OnAdd` side effect may be delayed.

### $OnRemove

**Trigger**: Fires when a note is removed from the container holding this attribute (moved elsewhere or deleted).

**Scope**: `this` refers to the note being removed.

**Use case**: Cleanup actions, logging departures.

**MCP Example**:
```
do(document: "MyDoc", action: "$OnRemove='$Badge=\"removed\"'", note: "/path/to/note")
```

### $OnJoin

**Trigger**: Fires when a note joins a composite.

**Scope**: `this` refers to the note joining the composite.

**Use case**: Auto-configure composite members.

> Not testable via MCP tools — composite operations require UI interaction.

### $OnPaste

**Trigger**: Fires when a note is pasted, either into the same document or into a new document. If more than one note was copied, `$OnPaste` is called after *this* note has been created, but may be called before other notes have been created.

**Scope**: `this` refers to the pasted note.

**Use case**: Self-installing notes — copy a note into a new document and have it automatically set up prototypes, templates, containers, etc. Replaces the `$Rule` + `$RuleDisabled` pattern for installers.

**MCP Example**:
```
// Set up an installer that runs when the note is pasted into a new document
do(document: "MyDoc", action: "$OnPaste=\"action($Text);\"", note: "/path/to/note")
// The note's $Text contains the full installer action code.
// When copied and pasted into another document, $OnPaste fires
// and executes the installer automatically.
```

**Workflow**:
1. Put installer action code in the note's `$Text`
2. Set `$OnPaste="action($Text);"`
3. Copy the note, paste into target document
4. `$OnPaste` fires automatically — no manual steps needed

> **Added in v10.1.2**. Not testable via MCP tools (requires UI paste operation).

### $OnVisit

**Trigger**: Fires when the note is visited (selected, navigated to).

**Scope**: `this` refers to the visited note.

**Use case**: Track visit counts, update timestamps, trigger on-access actions.

**MCP Example**:
```
do(document: "MyDoc", action: "$OnVisit='$Badge=\"visited\"'", note: "/path/to/note")
```

### $DisplayExpression

**Trigger**: Evaluated on every render cycle to compute the note's display title.

**Scope**: `this` refers to the note. The expression's result becomes the note's visible title in the map/outline.

**Use case**: Dynamic titles showing status, counts, or computed values.

**MCP Example**:
```
// Set display expression — shows name wrapped in brackets
do(document: "MyDoc", action: "$DisplayExpression=\"[\"+$Name+\"]\"", note: "/path/to/note")

// Read the computed display name
evaluate(document: "MyDoc", expression: "$DisplayName", note: "/path/to/note")
// Returns "[NoteName]"

// Read the expression itself
evaluate(document: "MyDoc", expression: "$DisplayExpression", note: "/path/to/note")

// Clear
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "DisplayExpression", value: "")
```

> **Live-tested**: Setting `$DisplayExpression` and reading `$DisplayName` works correctly. `$DisplayName` returns the computed result of the expression. When `$DisplayExpression` is empty, `$DisplayName` returns `$Name`.

### $HoverExpression

**Trigger**: Evaluated when the user hovers over the note in the map view.

**Scope**: `this` refers to the hovered note.

**Use case**: Show tooltips with additional info.

**MCP Example**:
```
do(document: "MyDoc", action: "$HoverExpression=\"Tags: \"+$Tags", note: "/path/to/note")
```

> Not testable via MCP tools — requires mouse hover UI interaction.

### $TableExpression

**Trigger**: Evaluated when the note is displayed in a table/column view.

**Scope**: `this` refers to the note being rendered.

**Use case**: Custom column content.

> Display-only — not meaningfully testable via MCP tools.

### $AgentQuery

**Trigger**: Evaluated every agent cycle to find matching notes.

**Scope**: Runs in the document scope. Returns a set of matching notes as aliases inside the agent.

**Use case**: Dynamic note collection based on criteria.

**MCP Example**:
```
do(document: "MyDoc", action: "$AgentQuery='$Prototype==\"Task\" & $Checked==false'", note: "/path/to/note")
```

### $AgentAction

**Trigger**: Runs on each note matched by the agent's query.

**Scope**: `this` refers to each matched note (the alias in the agent). `that` may refer to the original.

**Use case**: Auto-color, auto-tag, or modify matched notes.

**MCP Example**:
```
do(document: "MyDoc", action: "$AgentAction='$Color=\"blue\"'", note: "/path/to/note")
```

---

## Attribute Type

All 12 attributes have attribute type `"action"` — their values are Tinderbox action code strings, not plain text. When read via the `evaluate` tool, the raw action code string is returned.

---

## Setting Action Code via MCP Tools

Action-holding attributes require careful quoting because the action code itself contains quotes. Tinderbox does not support quote escaping — a `"` always terminates the string. When the action value contains nested quotes, use Tinderbox single-quoted strings (where `"` is literal inside single quotes):

```
// Nested quotes — use Tinderbox single-quoted strings for the inner value
do(document: "MyDoc", action: "$Rule='$Badge=\"flag\"'", note: "/path/to/note")

// Multiple actions in one attribute
do(document: "MyDoc", action: "$OnAdd='$Badge=\"star\";$Color=\"green\"'", note: "/path/to/note")

// Reading back — returns the raw action code
evaluate(document: "MyDoc", expression: "$Rule", note: "/path/to/note")
// returns: $Badge="flag"

// Alternatively, use set_value for simple values
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "Rule", value: "$Badge=\"flag\"")
```

---

## Clearing Action Attributes

Always clear action attributes when done testing to prevent ongoing side effects:

```
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "Rule", value: "")
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "OnAdd", value: "")
set_value(document: "MyDoc", notes: "/path/to/note", attribute: "DisplayExpression", value: "")
```

---

## Cross-References

- **[Action Functions](action-functions.md)** — All functions usable inside action code
- **[Expressions & Actions](expressions.md)** — Quick-reference expression syntax
