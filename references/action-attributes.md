# Tinderbox Action-Holding Attributes Reference

Tinderbox has 12 system attributes whose values are executable action code. These attributes hold Tinderbox expressions/actions that fire automatically in response to specific triggers.

All can be read and written via AppleScript using `evaluate` and `act on`.

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
| `$TableExpression` | On table render | Table cells | No (display only) |
| `$AgentQuery` | Every agent cycle | Agent matches | Yes (tested in AppleScript suite) |
| `$AgentAction` | Agent matches notes | Matched aliases | Yes (tested in AppleScript suite) |

---

## Detailed Reference

### $Rule

**Trigger**: Fires every agent cycle (approximately every 2-5 seconds, depending on document complexity).

**Scope**: Runs in the context of the note that holds the rule. `this` refers to the note itself.

**Use case**: Continuously computed values, auto-classification, dynamic formatting.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		-- Set a rule that continuously sets Badge
		act on noteRef with "$Rule='$Badge=\"ruled\"'"

		-- Read the rule
		set theRule to evaluate noteRef with "$Rule"

		-- IMPORTANT: Always clear rules when done to prevent ongoing side effects
		act on noteRef with "$Rule=\"\""
	end tell
end tell
```

> **Live-tested**: Setting `$Rule` via act on works. However, the rule cycle may not fire during the same AppleScript invocation. In testing, the rule did not fire within 6 seconds, suggesting rules may need the document to be in an active (foreground) state. Always clear rules after testing.

**$RuleDisabled** (Boolean): Controls whether `$Rule` fires. Set to `true` to prevent the rule from executing. Useful for one-shot rules that should only fire when manually enabled.

**Self-disabling rule pattern**: Set `$Rule="action($Text);"` and `$RuleDisabled=true`. The note's `$Text` contains the action code payload with `$RuleDisabled=true;` as its last line. To execute: set `$RuleDisabled=false` — the rule fires once, executes `$Text`, and the action code re-disables itself.

```applescript
tell application id "Cere"
	tell front document
		-- Set up a self-disabling rule
		act on noteRef with "$Rule=\"action($Text);\""
		act on noteRef with "$RuleDisabled=true"

		-- The note's $Text should end with:
		--   $RuleDisabled=true;
		-- This makes the rule self-disabling after one execution.

		-- To trigger: enable the rule
		act on noteRef with "$RuleDisabled=false"
		-- Rule fires on next cycle, executes $Text, which re-disables itself
	end tell
end tell
```

### $Edict

**Trigger**: Fires periodically, roughly hourly (much less frequently than rules).

**Scope**: Same as `$Rule` — runs on the note itself.

**Use case**: Low-priority maintenance tasks, periodic cleanup.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		act on noteRef with "$Edict='$Badge=\"checked\"'"
		act on noteRef with "$Edict=\"\""  -- clear when done
	end tell
end tell
```

> Not practically testable via AppleScript due to long cycle times.

### $OnAdd

**Trigger**: Fires when a note is added as a child of the container holding this attribute.

**Scope**: `this` refers to the **newly added child**, not the container. The action runs on the child.

**Use case**: Auto-tagging new notes, setting prototypes on creation, inbox processing.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		-- Set OnAdd on a container
		act on containerRef with "$OnAdd='$Badge=\"star\"'"

		-- Create a child — should trigger OnAdd
		act on containerRef with "create(\"NewChild\")"

		-- Check the child's badge
		set childRef to note "NewChild" of containerRef
		set theBadge to evaluate childRef with "$Badge"

		-- Clean up
		act on containerRef with "$OnAdd=\"\""
	end tell
end tell
```

> **Live-tested**: Setting `$OnAdd` via act on works. When creating a child via `create()` in the same AppleScript invocation, the OnAdd action may not fire immediately — it may require a Tinderbox UI cycle. The child is created successfully but the OnAdd side effect may be delayed.

### $OnRemove

**Trigger**: Fires when a note is removed from the container holding this attribute (moved elsewhere or deleted).

**Scope**: `this` refers to the note being removed.

**Use case**: Cleanup actions, logging departures.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		act on containerRef with "$OnRemove='$Badge=\"removed\"'"
	end tell
end tell
```

### $OnJoin

**Trigger**: Fires when a note joins a composite.

**Scope**: `this` refers to the note joining the composite.

**Use case**: Auto-configure composite members.

> Not testable via AppleScript — composite operations require UI interaction.

### $OnPaste

**Trigger**: Fires when a note is pasted, either into the same document or into a new document. If more than one note was copied, `$OnPaste` is called after *this* note has been created, but may be called before other notes have been created.

**Scope**: `this` refers to the pasted note.

**Use case**: Self-installing notes — copy a note into a new document and have it automatically set up prototypes, templates, containers, etc. Replaces the `$Rule` + `$RuleDisabled` pattern for installers.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		-- Set up an installer that runs when the note is pasted into a new document
		act on noteRef with "$OnPaste=\"action($Text);\""
		-- The note's $Text contains the full installer action code.
		-- When copied and pasted into another document, $OnPaste fires
		-- and executes the installer automatically.
	end tell
end tell
```

**Workflow**:
1. Put installer action code in the note's `$Text`
2. Set `$OnPaste="action($Text);"`
3. Copy the note, paste into target document
4. `$OnPaste` fires automatically — no manual steps needed

> **Added in v10.1.2**. Not testable via AppleScript (requires UI paste operation).

### $OnVisit

**Trigger**: Fires when the note is visited (selected, navigated to).

**Scope**: `this` refers to the visited note.

**Use case**: Track visit counts, update timestamps, trigger on-access actions.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		act on noteRef with "$OnVisit='$Badge=\"visited\"'"
		-- Setting selected note might trigger OnVisit
		set selected note to noteRef
	end tell
end tell
```

### $DisplayExpression

**Trigger**: Evaluated on every render cycle to compute the note's display title.

**Scope**: `this` refers to the note. The expression's result becomes the note's visible title in the map/outline.

**Use case**: Dynamic titles showing status, counts, or computed values.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		-- Set display expression — shows name wrapped in brackets
		act on noteRef with "$DisplayExpression=\"[\"+$Name+\"]\""

		-- Read the computed display name
		set displayName to evaluate noteRef with "$DisplayName"
		-- Returns "[NoteName]"

		-- Read the expression itself
		set expr to evaluate noteRef with "$DisplayExpression"

		-- Clear
		act on noteRef with "$DisplayExpression=\"\""
	end tell
end tell
```

> **Live-tested**: Setting `$DisplayExpression` and reading `$DisplayName` works correctly. `$DisplayName` returns the computed result of the expression. When `$DisplayExpression` is empty, `$DisplayName` returns `$Name`.

### $HoverExpression

**Trigger**: Evaluated when the user hovers over the note in the map view.

**Scope**: `this` refers to the hovered note.

**Use case**: Show tooltips with additional info.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		act on noteRef with "$HoverExpression=\"Tags: \"+$Tags"
	end tell
end tell
```

> Not testable via AppleScript — requires mouse hover UI interaction.

### $TableExpression

**Trigger**: Evaluated when the note is displayed in a table/column view.

**Scope**: `this` refers to the note being rendered.

**Use case**: Custom column content.

> Display-only — not meaningfully testable via AppleScript.

### $AgentQuery

**Trigger**: Evaluated every agent cycle to find matching notes.

**Scope**: Runs in the document scope. Returns a set of matching notes as aliases inside the agent.

**Use case**: Dynamic note collection based on criteria.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		act on agentRef with "$AgentQuery='$Prototype==\"Task\" & $Checked==false'"
		refresh agentRef  -- force immediate evaluation
		set results to notes of agentRef  -- alias children
	end tell
end tell
```

> **Already tested** in AppleScript test suite.

### $AgentAction

**Trigger**: Runs on each note matched by the agent's query.

**Scope**: `this` refers to each matched note (the alias in the agent). `that` may refer to the original.

**Use case**: Auto-color, auto-tag, or modify matched notes.

**AppleScript Example**:
```applescript
tell application id "Cere"
	tell front document
		act on agentRef with "$AgentAction='$Color=\"blue\"'"
	end tell
end tell
```

> **Already tested** conceptually in AppleScript test suite.

---

## Attribute Type

All 12 attributes have attribute type `"action"` — their values are Tinderbox action code strings, not plain text. When read via `evaluate`, the raw action code string is returned.

---

## Setting Action Code via AppleScript

Action-holding attributes require careful quoting because the action code itself contains quotes. Tinderbox does not support quote escaping — a `"` always terminates the string. When the action value contains nested quotes, use Tinderbox single-quoted strings (where `"` is literal inside single quotes):

```applescript
tell application id "Cere"
	tell front document
		-- Nested quotes — use Tinderbox single-quoted strings for the inner value
		act on noteRef with "$Rule='$Badge=\"flag\"'"

		-- Multiple actions in one attribute
		act on noteRef with "$OnAdd='$Badge=\"star\";$Color=\"green\"'"

		-- Reading back — returns the raw action code
		set theRule to evaluate noteRef with "$Rule"
		-- theRule = "$Badge=\"flag\""
	end tell
end tell
```

---

## Clearing Action Attributes

Always clear action attributes when done testing to prevent ongoing side effects:

```applescript
tell application id "Cere"
	tell front document
		act on noteRef with "$Rule=\"\""
		act on noteRef with "$OnAdd=\"\""
		act on noteRef with "$DisplayExpression=\"\""
	end tell
end tell
```

---

## Cross-References

- **[Action Functions](action-functions.md)** — All functions usable inside action code
- **[AppleScript API Reference](applescript-api.md)** — AppleScript bridge: evaluate, act on
- **[Expressions & Actions](expressions.md)** — Quick-reference expression syntax
- **[Test Script](../scripts/test-action-code.sh)** — Tests 14-16 cover action-holding attributes
