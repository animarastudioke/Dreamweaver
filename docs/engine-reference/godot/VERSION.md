# Godot Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.7.2 |
| **Release Date** | 2026 |
| **Project Pinned** | 2026-09-03 |
| **Last Docs Verified** | 2026-09-03 |
| **LLM Knowledge Cutoff** | May 2025 |

## Knowledge Gap Warning

The LLM's training data likely covers Godot up to ~4.3. Versions 4.4, 4.5,
4.6, and 4.7 introduced significant changes that the model does NOT know about.
Always cross-reference this directory before suggesting Godot API calls.

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 4.4 | ~Mid 2025 | MEDIUM | Jolt physics option, FileAccess return types, shader texture type changes |
| 4.5 | ~Late 2025 | HIGH | Accessibility (AccessKit), variadic args, @abstract, shader baker, SMAA |
| 4.6 | Jan 2026 | HIGH | Jolt default, glow rework, D3D12 default on Windows, IK restored |
| 4.7 | 2026 | HIGH | Mouse/keyboard device ID constants, Jolt SoftBody3D/WorldBoundaryShape3D behavior changes, GDScript typed-return override rule, packed-array setter change |

## Verified Sources

- Official docs: https://docs.godotengine.org/en/stable/
- 4.6→4.7 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html
- 4.5→4.6 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html
- 4.4→4.5 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.5.html
- Changelog: https://github.com/godotengine/godot/blob/master/CHANGELOG.md
- Release notes: https://godotengine.org/releases/4.6/

## Migration Notes — 4.6 → 4.7

**Migration guide**: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html

**Reason for upgrade**: Dev machine (no Vulkan/D3D12 support) has Godot 4.7.2
installed; the project was pinned to 4.6 during initial `/setup-engine`
before any local engine testing occurred.

**Key breaking changes** (see `breaking-changes.md` for the full table):
- Mouse/keyboard device IDs changed from `0` to `InputEvent.DEVICE_ID_MOUSE` /
  `DEVICE_ID_KEYBOARD` — relevant for this project's touch-first input work
- Jolt Physics (this project's pinned default): `WorldBoundaryShape3D` plane-distance
  sign reversed; `SoftBody3D` default mass and linear stiffness behavior changed
- `AudioStreamPlayer.area_mask` default changed `1` → `0`
- GDScript: packed-array element assignment no longer calls the setter for the
  whole array property; overriding a typed-return method now requires an
  explicit return type on the override
- New-project stretch mode/aspect defaults changed to `canvas_items`/`expand`
  (was `disabled`/`keep`) — check `project.godot` once real UI work starts
- `AudioEffectSpectrumAnalyzer.tap_back_pos` removed

**Deprecated APIs found in this project**: none — `src/` has no code yet, and
the `prototypes/swipe-driving-loop-concept/` prototype doesn't touch any
changed API.

**Recommended migration order**: n/a (no existing code to migrate).
