# Systems Index: MATATU RUSH

> **Status**: Draft
> **Created**: 2026-09-03
> **Last Updated**: 2026-09-03
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

MATATU RUSH is an arcade driving/score-chase game built around one core loop —
swipe to dodge traffic and potholes while racing a timer to deliver passengers
— wrapped in a risk/reward Rush Meter and a currency-funded vehicle progression
system, all set in a procedurally-assembled, Mombasa-inspired world. The
concept prototype (`prototypes/swipe-driving-loop-concept/`) confirmed the
control scheme's responsiveness but found the base dodge loop under-tuned for
challenge — so the Driving, Traffic, and Collision systems below carry more
design weight than a typical MVP set, since they're what the rest of the game
(Rush Meter, Economy, Progression) is built on top of. Passenger delivery is
the game's actual objective (not just driving for its own sake), and the
Conductor/Passenger Reaction systems are what turn Pillar 4 ("Authentically
East African, Never a Costume") from an art-direction goal into an actual
gameplay-and-writing system.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Driving & Vehicle Control | Core | MVP | Designed (pending review) | design/gdd/driving-vehicle-control.md | — |
| 2 | Procedural Road Assembly | Core | MVP | Not Started | — | — |
| 3 | Traffic & Obstacle System | Gameplay | MVP | Not Started | — | Driving & Vehicle Control |
| 4 | Collision & Damage System | Gameplay | MVP | Not Started | — | Driving & Vehicle Control, Traffic & Obstacle System |
| 5 | Passenger & Delivery Loop | Gameplay | MVP | Not Started | — | Driving & Vehicle Control, Procedural Road Assembly |
| 6 | Game State & Run Loop | Core | MVP | Not Started | — | Collision & Damage System, Passenger & Delivery Loop |
| 7 | Economy & Scoring | Economy | MVP | Not Started | — | Passenger & Delivery Loop, Rush Meter |
| 8 | Vehicle Progression & Upgrades | Progression | MVP | Not Started | — | Economy & Scoring, Driving & Vehicle Control |
| 9 | Save System | Persistence | MVP | Not Started | — | Economy & Scoring, Vehicle Progression & Upgrades |
| 10 | HUD & UI | UI | MVP | Not Started | — | Rush Meter, Economy & Scoring, Passenger & Delivery Loop, Game State & Run Loop |
| 11 | Rush Meter | Gameplay | Vertical Slice | Not Started | — | Driving & Vehicle Control, Traffic & Obstacle System, Collision & Damage System |
| 12 | Conductor Character System | Narrative | Vertical Slice | Not Started | — | Driving & Vehicle Control, Collision & Damage System / Rush Meter |
| 13 | Passenger Reaction System | Narrative | Vertical Slice | Not Started | — | Passenger & Delivery Loop, Collision & Damage System / Rush Meter |
| 14 | Audio System | Audio | Vertical Slice | Not Started | — | Driving & Vehicle Control, Collision & Damage System, Conductor Character System, Passenger Reaction System |
| 15 | Onboarding/Tutorial Flow (inferred) | Meta | Vertical Slice | Not Started | — | Driving & Vehicle Control, Passenger & Delivery Loop, HUD & UI |
| 16 | Daily Challenges | Meta | Alpha | Not Started | — | Game State & Run Loop, Economy & Scoring |
| 17 | Leaderboard | Meta | Alpha | Not Started | — | Economy & Scoring, Game State & Run Loop |
| 18 | Cosmetic Customization | Progression | Full Vision | Not Started | — | Economy & Scoring, Vehicle Progression & Upgrades |
| 19 | Endless Rush Mode | Gameplay | Full Vision | Not Started | — | Driving & Vehicle Control, Traffic & Obstacle System, Game State & Run Loop |

Note on scope-within-a-system: **Procedural Road Assembly** and **Vehicle
Progression & Upgrades** each span multiple priority tiers within one GDD
(MVP = 1 basic map / basic upgrades only; Vertical Slice expands road variety
to Old Town + Coastal; Alpha expands to the full 6 road types and full
vehicle roster). Design the MVP scope first and revise the same doc rather
than creating tier-specific duplicate GDDs.

---

## Categories

| Category | Description | Systems in this project |
|----------|-------------|--------------------------|
| **Core** | Foundation everything depends on | Driving & Vehicle Control, Procedural Road Assembly, Game State & Run Loop |
| **Gameplay** | The systems that make the game fun | Traffic & Obstacle System, Collision & Damage System, Passenger & Delivery Loop, Rush Meter, Endless Rush Mode |
| **Progression** | How the player grows over time | Vehicle Progression & Upgrades, Cosmetic Customization |
| **Economy** | Resource creation and consumption | Economy & Scoring |
| **Persistence** | Save state and continuity | Save System |
| **UI** | Player-facing information displays | HUD & UI |
| **Audio** | Sound and music systems | Audio System |
| **Narrative** | Story and dialogue delivery | Conductor Character System, Passenger Reaction System |
| **Meta** | Systems outside the core game loop | Onboarding/Tutorial Flow, Daily Challenges, Leaderboard |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for the core loop to function. Without these, you can't test "is this fun?" | First playable prototype | Design FIRST |
| **Vertical Slice** | Required for one complete, polished area. Demonstrates the full experience. | Vertical slice / demo | Design SECOND |
| **Alpha** | All features present in rough form. Complete mechanical scope, placeholder content OK. | Alpha milestone | Design THIRD |
| **Full Vision** | Polish, edge cases, nice-to-haves, and content-complete features. | Beta / Release | Design as needed |

---

## Dependency Map

### Foundation Layer (no dependencies)

1. Driving & Vehicle Control — nothing else in the game functions without a driveable, controllable vehicle
2. Procedural Road Assembly — provides the world the vehicle drives on; the concept prototype used a static strip, so this needs its own real design pass

### Core Layer (depends on foundation)

1. Traffic & Obstacle System — depends on: Driving & Vehicle Control
2. Collision & Damage System — depends on: Driving & Vehicle Control, Traffic & Obstacle System
3. Passenger & Delivery Loop — depends on: Driving & Vehicle Control, Procedural Road Assembly
4. Game State & Run Loop — depends on: Collision & Damage System, Passenger & Delivery Loop

### Feature Layer (depends on core)

1. Rush Meter — depends on: Driving & Vehicle Control, Traffic & Obstacle System, Collision & Damage System
2. Economy & Scoring — depends on: Passenger & Delivery Loop, Rush Meter
3. Vehicle Progression & Upgrades — depends on: Economy & Scoring, Driving & Vehicle Control
4. Save System — depends on: Economy & Scoring, Vehicle Progression & Upgrades
5. Conductor Character System — depends on: Driving & Vehicle Control, Collision & Damage System / Rush Meter
6. Passenger Reaction System — depends on: Passenger & Delivery Loop, Collision & Damage System / Rush Meter
7. Daily Challenges — depends on: Game State & Run Loop, Economy & Scoring
8. Leaderboard — depends on: Economy & Scoring, Game State & Run Loop
9. Cosmetic Customization — depends on: Economy & Scoring, Vehicle Progression & Upgrades
10. Endless Rush Mode — depends on: Driving & Vehicle Control, Traffic & Obstacle System, Game State & Run Loop

### Presentation Layer (depends on features)

1. HUD & UI — depends on: Rush Meter, Economy & Scoring, Passenger & Delivery Loop, Game State & Run Loop
2. Audio System — depends on: Driving & Vehicle Control, Collision & Damage System, Conductor Character System, Passenger Reaction System

### Polish Layer (depends on everything)

1. Onboarding/Tutorial Flow — depends on: Driving & Vehicle Control, Passenger & Delivery Loop, HUD & UI

---

## Recommended Design Order

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Driving & Vehicle Control | MVP | Foundation | game-designer, godot-specialist | M |
| 2 | Procedural Road Assembly | MVP | Foundation | game-designer, level-designer | M |
| 3 | Traffic & Obstacle System | MVP | Core | game-designer, systems-designer | M |
| 4 | Collision & Damage System | MVP | Core | systems-designer | S |
| 5 | Passenger & Delivery Loop | MVP | Core | game-designer, systems-designer | M |
| 6 | Game State & Run Loop | MVP | Core | game-designer | S |
| 7 | Economy & Scoring | MVP | Feature | economy-designer | S |
| 8 | Vehicle Progression & Upgrades | MVP | Feature | economy-designer, systems-designer | M |
| 9 | Save System | MVP | Feature | godot-specialist, lead-programmer | S |
| 10 | HUD & UI | MVP | Presentation | ux-designer | M |
| 11 | Rush Meter | Vertical Slice | Feature | systems-designer, game-designer | M |
| 12 | Conductor Character System | Vertical Slice | Feature | narrative-director, writer | M |
| 13 | Passenger Reaction System | Vertical Slice | Feature | narrative-director, systems-designer | S |
| 14 | Audio System | Vertical Slice | Presentation | audio-director | M |
| 15 | Onboarding/Tutorial Flow | Vertical Slice | Polish | ux-designer | S |
| 16 | Leaderboard | Alpha | Feature | systems-designer, backend | S |
| 17 | Daily Challenges | Alpha | Feature | live-ops-designer | S |
| 18 | Cosmetic Customization | Full Vision | Feature | art-director, economy-designer | M |
| 19 | Endless Rush Mode | Full Vision | Feature | game-designer | S |

---

## Circular Dependencies

- None found. The dependency graph is a clean DAG — Driving & Vehicle Control
  and Procedural Road Assembly anchor everything else with no back-edges.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-------------------|------------|
| Traffic & Obstacle System | Design | The concept prototype found the placeholder single-lane spawn pattern produced "nothing to react under pressure" — obstacle density and lane-threat distribution are unproven as a *fun* design, not just an implementation detail | Treat density/distribution as first-class Tuning Knobs in the GDD; consider a follow-up `/prototype --spike` on density before locking formulas, per the prototype REPORT.md's own recommendation |
| Procedural Road Assembly | Technical + Design | Whether procedurally-assembled road chunks feel varied vs. janky/repetitive is explicitly unproven (flagged as a Technical Risk in the concept doc); also a real Android performance risk once combined with 3D + traffic AI | Early technical-artist/performance-analyst profiling pass; consider a chunk-variety spike before committing to the full 6-road-type system |
| Rush Meter | Design | Concept doc's own Design Risks flag that the risk/reward balance could collapse into "always play safe" or "trivially maxed multiplier" if thresholds aren't tuned carefully | Design with explicit tuning ranges and playtest the balance specifically, not just the mechanic's existence |
| Conductor Character System / Passenger Reaction System | Design + Cultural | Pillar 4 ("Authentically East African, Never a Costume") and the concept doc's own Open Questions flag that Sheng/Swahili dialogue authenticity needs native-fluency review — this is the system where that risk actually surfaces in shippable content | Cultural review pass once bark/dialogue scripts exist, per the concept doc's own resolution plan — not shipped on the author's judgment alone |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 19 |
| Design docs started | 1 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 1/10 |
| Vertical Slice systems designed | 0/5 |

---

## Next Steps

- [x] Review and approve this systems enumeration
- [ ] Design MVP-tier systems first (use `/design-system [system-name]`), starting with Driving & Vehicle Control
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check pre-production` when MVP systems are designed
- [ ] Validate the highest-risk systems with `/vertical-slice` before committing to Production
