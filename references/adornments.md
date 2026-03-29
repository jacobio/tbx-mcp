# Tinderbox Map Adornments Reference

> Examples include the required `document` parameter. Replace `"MyDoc"` with your document name.

Adornments are visual background elements exclusive to Map view that sit behind all notes. They provide colored, labeled regions to organize the visual space. They are one of the four fundamental note types in Tinderbox (note, alias, agent, adornment).

## Creating Adornments

Use the `create_note` tool with `kind: "adornment"`:

```
create_note(document: "MyDoc", name: "My Region", kind: "adornment")
```

After creation, configure with the `set_value` tool or the `do` tool:

```
set_value(document: "MyDoc", notes: "/My Region", attribute: "Color", value: "blue")
do(document: "MyDoc", action: "$Width=10;$Height=8;$Xpos=2;$Ypos=2", note: "/My Region")
```

## Position and Size Attributes

| Attribute | Description |
|-----------|-------------|
| `$Xpos` | Horizontal position on map |
| `$Ypos` | Vertical position on map |
| `$Width` | Width (set to 0 for vertical divider line) |
| `$Height` | Height (set to 0 for horizontal divider line) |

## Visual Appearance Attributes

| Attribute | Description |
|-----------|-------------|
| `$Color` | Background fill color. `"transparent"` hides fill but title still displays |
| `$BorderColor` | Border color (independent of `$Color`) |
| `$Border` | Border width (default 2). `0` = 1-pixel line |
| `$Opacity` | Translucency (0.0 to 1.0) |
| `$Shadow` | Defaults to `false` for adornments. Displays small inner shadow when enabled |
| `$Shape` | Shape of the adornment. Most shapes allowed |
| `$NameColor` | Color of the displayed name text |
| `$NameAlignment` | Alignment of the adornment's displayed name |
| `$AdornmentFont` | Font for adornment name. Falls back to `$NameFont` if empty |
| `$Subtitle` | Additional text displayed on the adornment |
| `$Badge` | Badge icon |
| `$DisplayExpression` | Dynamic display text expression |
| `$HoverExpression` | Expression shown on hover |

## Behavior Attributes

| Attribute | Description |
|-----------|-------------|
| `$Lock` | Prevents repositioning/resizing. Locked adornments excluded from drag-selections |
| `$Sticky` | Notes overlapping the adornment move with it when dragged |
| `$OnAdd` | Action code fired when a note is created on or moved onto the adornment |
| `$OnRemove` | Action code fired when a note is removed from atop the adornment |
| `$AgentQuery` | Makes it a "smart adornment" — auto-moves matching notes onto it |
| `$IsAdornment` | Read-only Boolean, automatically `true` for adornments |

## Smart Adornments

Setting `$AgentQuery` on an adornment makes it a "smart adornment":

- Query scope is **the current map only** (not the whole document like agents)
- Matching notes are **moved** (not aliased) onto the adornment
- Notes that stop matching are moved **off** alongside it (NOT restored to original positions)
- Matched notes fire the adornment's `$OnAdd` action code

### Differences from Agents

| Feature | Agent | Smart Adornment |
|---------|-------|-----------------|
| Creates aliases | Yes | No — moves originals |
| Scope | Entire document | Current map only |
| `$AgentPriority` | Honored | Ignored |
| `$CleanupAction` | Honored | Ignored |

### Priority
When multiple smart adornments match the same note, the one with the highest `$OutlineOrder` wins.

## The `adornment` Designator

In `$OnAdd`/`$OnRemove` action code, the `adornment` designator refers to the adornment itself:

```
$Color = $Color(adornment);
$Tags = $Tags + ";" + $Name(adornment);
```

Outside `$OnAdd`/`$OnRemove`, `adornment` refers to the uppermost adornment beneath the current note. If no adornment, it resolves to `this`.

## Sticky and Lock Behavior

### Sticky (`$Sticky = true`)
- Notes within or overlapping the adornment move with it when dragged
- Notes can still move independently within or off the adornment
- **Caution ("katamari effect")**: Overlapping sticky adornments cascade movement. Best practice: lock adornments, don't make them sticky unless needed

### Lock (`$Lock = true`)
- Prevents repositioning and resizing
- Locked adornments excluded from drag-selections
- Locked notes are ignored by smart adornments

## Adornments as Dividers

- `$Width = 0` creates a **vertical** divider line
- `$Height = 0` creates a **horizontal** divider line
- Color controlled by `$BorderColor` (or `$Color` as fallback)
- `$Border` controls thickness; wide values create bands

## Grid Attributes

| Attribute | Description |
|-----------|-------------|
| `$GridRows` | Number of grid rows |
| `$GridColumns` | Number of grid columns |
| `$GridLabels` | Text labels for grid cells |
| `$GridLabelFont` | Font for grid labels |
| `$GridLabelSize` | Size of grid label text |
| `$GridColor` | Color of grid lines and labels |
| `$GridOpacity` | Opacity of grid elements |

Grids are purely visual — they do not affect `$OnAdd` behavior. Smart adornments ignore grid assignments.

## Geographic Adornments

Activated when `$Latitude` and `$Longitude` are non-zero:

| Attribute | Description |
|-----------|-------------|
| `$Latitude` | Geographic latitude |
| `$Longitude` | Geographic longitude |
| `$Range` | Approximate map size in kilometres (controls zoom) |
| `$Address` | Can auto-calculate lat/long |

Uses Apple MapKit. Notes placed on geographic adornments auto-align to map coordinates.

## Important Limitations

1. Adornments are **NOT containers** — they cannot hold children in the outline hierarchy
2. **Cannot be linked** to/from other notes
3. **Cannot be searched** — always excluded regardless of `$Searchable`
4. **Cannot have aliases** or be aliased
5. **Do not display `$Text`** on their face — only `$Name` (and subtitle/badge/display expression)
6. **Cannot be exported** in HTML export
7. **Not visible** in Outline view
8. Smart adornment displaced notes are **not restored** to original positions
9. Always render **behind** all notes on the map

## Stacking Order

- New adornments appear on top of existing ones
- Reorder with forward/back commands
- `$OutlineOrder` determines visual stacking (lower = on top)
- Adornments are counted in `$OutlineOrder` but NOT in `$SiblingOrder`, `$ChildCount`, or `$DescendantCount`

---

## Cross-References

- **[Action-Holding Attributes](action-attributes.md)** — `$OnAdd`, `$OnRemove`, `$AgentQuery` behavior
- **[Expressions & Actions](expressions.md)** — Expression and action code syntax for smart adornment queries
- **[System Containers](system-containers.md)** — `/Prototypes` container for adornment prototypes
