# Driving & Vehicle Control

> **Status**: In Design
> **Author**: user + game-designer, godot-specialist
> **Last Updated**: 2026-09-03
> **Implements Pillar**: Pillar 1 (Instant Fun, Instant Understanding), Pillar 2 (Fault Is Yours, Not the Game's)

## Overview

Driving & Vehicle Control is the mechanical and input layer that turns a
swipe into matatu movement — lane-changing, boosting, and braking on a
scrolling road, plus the arcade camera that reacts to speed and events. It is
the single system every other system in the game either feeds into or
depends on: Traffic & Obstacle System needs a moving, positioned vehicle to
spawn threats against; Collision & Damage System needs a defined hitbox and
movement state; Passenger & Delivery Loop needs a vehicle that can reach
pickup/drop-off zones; and the entire Rush Meter risk/reward layer only has
meaning if the underlying movement already feels controllable. Mechanically,
it owns: lane-position state (current lane, target lane, lateral
interpolation), speed state (base speed, boost/brake multipliers and
durations), the touch-swipe input mapping (with a required on-screen-button
accessibility alternative), and the third-person arcade camera's reactive
behavior.

This is also where the game's central fantasy lives. The concept doc's Core
Fantasy is "mastery under chaos: total control expressed through calculated
risk" — that isn't delivered by any menu or meta-system, it's delivered
every single frame the player is swiping to thread a gap. Pillar 1 ("Instant
Fun, Instant Understanding") is a direct requirement on this system
specifically: the controls must read immediately, with the player driving
within 10-15 seconds of launch. The swipe-driving-loop prototype already
validated the responsiveness half of this — lane changes registered with no
perceptible input delay using `LANE_LERP_RATE = 12.0` — but explicitly did
**not** validate that driving alone is fun; that verdict depends on Traffic &
Obstacle System's density design, not this system in isolation.

## Player Fantasy

The player should feel like a driver whose hands are faster than the
traffic — that a gap existed for a fraction of a second and they were the
one who saw it and took it. This is "mastery under chaos": the road is
genuinely crowded and unpredictable, but every near-miss lands as *your*
read of the situation, not luck. The specific emotional beat this system has
to deliver, every few seconds, is the half-second between initiating a swipe
and the vehicle snapping into the new lane clear of an obstacle — that's the
moment Crazy Taxi and Traffic Rider both build their whole feel around, and
it's the moment the concept prototype already proved can land instantly (no
perceptible delay at `LANE_LERP_RATE = 12.0`).

Boost and brake extend this same fantasy rather than sitting apart from it:
boosting through a gap should feel like a deliberate escalation of risk the
player chose, and braking for a pickup zone should feel like a controlled,
confident slow-down — never a panic tap. The camera's job is to sell speed
and consequence (FOV push on boost, reactive shake or lean on near-misses)
so the fantasy reads even to someone watching over the player's shoulder,
not just to the person holding the phone.

This is explicitly a **direct** fantasy — the player isn't managing this
system from a menu or feeling its downstream effects; they are, frame to
frame, *being* the driver.

## Detailed Design

### Core Rules

1. **Lane model**: 3 fixed lanes (indices 0–2), constant lane width. The
   vehicle tracks `current_lane` (int) and `target_lane` (int). A left/right
   swipe sets `target_lane = clamp(target_lane ± 1, 0, 2)`.
2. **Lateral movement**: vehicle X-position interpolates toward the target
   lane's X-position every physics tick at a tunable `LANE_LERP_RATE`
   (prototype-validated starting value: `12.0`). This is continuous and
   independent of the speed state below — the vehicle can be mid-lane-change
   while boosting or braking.
3. **Lane edges (hard clamp)**: a swipe attempting to leave lane 0 (further
   left) or lane 2 (further right) is absorbed with no effect — no off-road
   area exists. This satisfies Pillar 2: a clamped swipe is neither a
   penalty nor a surprise.
4. **Forward speed**: `current_speed = BASE_SPEED × active_multiplier`,
   where `active_multiplier` is `1.0` (Cruising), `BOOST_MULTIPLIER`
   (Boosting), or `BRAKE_MULTIPLIER` (Braking).
5. **Boost**: an up-swipe enters Boosting for `BOOST_DURATION` seconds.
   Freely retriggerable — no cooldown. Re-triggering while already boosting
   resets the duration timer.
6. **Brake**: a down-swipe enters Braking for `BRAKE_DURATION` seconds, same
   retrigger rule as boost.
7. **Boost/brake mutual exclusion**: the two states cannot be active
   simultaneously. Whichever swipe (up or down) is most recent wins and
   immediately overrides the other, resetting to that state's full duration.
8. **Dual input paths**: touch swipe is primary; a required on-screen
   four-button alternative (lane-left / lane-right / boost / brake) drives
   the *same* underlying actions — `target_lane` changes and boost/brake
   triggers — so neither input path has a responsiveness or capability
   advantage. Swipe detection uses a minimum-distance threshold
   (prototype-validated: `40.0px`) to reject accidental taps.
9. **Camera**: third-person arcade camera, fixed local offset behind/above
   the vehicle. Reacts to state: FOV push and speed-line intensity scale
   with `active_multiplier`; a subtle reactive lean/shake triggers on
   external near-miss events (near-miss *detection* is owned by Rush Meter,
   not this system — see Interactions below).

### States and Transitions

| State | Entry Condition | Behavior | Exit Condition |
|---|---|---|---|
| **Cruising** | Default; boost/brake timer expires | `active_multiplier = 1.0` | Up-swipe → Boosting; Down-swipe → Braking; external hit signal → Locked |
| **Boosting** | Up-swipe detected | `active_multiplier = BOOST_MULTIPLIER`; timer counts down from `BOOST_DURATION` | Timer expires → Cruising; Down-swipe → Braking (immediate override); external hit signal → Locked |
| **Braking** | Down-swipe detected | `active_multiplier = BRAKE_MULTIPLIER`; timer counts down from `BRAKE_DURATION` | Timer expires → Cruising; Up-swipe → Boosting (immediate override); external hit signal → Locked |
| **Locked** | Collision & Damage System signals a hit | Lane-change and boost/brake input ignored; speed behavior owned externally by Collision & Damage System | Collision & Damage System signals recovery → Cruising |

Lane position (current/target lane, lerp toward target) is tracked
independently of this table and is active in every state except Locked.

### Interactions with Other Systems

- **Traffic & Obstacle System** *(downstream)* — consumes this system's
  per-frame lane index and world-space transform to know where the player is
  relative to spawned obstacles. This system does not know about obstacles
  at all — no coupling in the other direction.
- **Collision & Damage System** *(downstream)* — consumes this system's
  collider transform; this system must expose a `lock_movement()` /
  `unlock_movement()` hook that Collision calls to drive the Locked state.
  This system does **not** own hit detection or damage resolution.
- **Passenger & Delivery Loop** *(downstream)* — reads vehicle world
  position/route progress to detect proximity to pickup/drop-off zones.
  Read-only; does not modify vehicle movement.
- **Rush Meter** *(downstream, Vertical Slice)* — will need proximity data
  to compute near-misses. This system should expose raw obstacle-distance
  data (or emit an event) rather than compute "near-miss" itself — that
  judgment call belongs in Rush Meter's own GDD, not here.
- **Vehicle Progression & Upgrades** *(downstream, MVP)* — modifies this
  system's tunable values (`BASE_SPEED`, `BOOST_MULTIPLIER`,
  `LANE_LERP_RATE`, etc.) via upgrade-applied multipliers. This system must
  expose these as externally-settable parameters, never hardcoded
  constants, so upgrades can apply without touching this system's code.
- **HUD & UI** *(downstream, MVP)* — reads current state
  (Cruising/Boosting/Braking) and speed to drive visual feedback (speed
  lines, boost indicator).
- **Onboarding/Tutorial Flow** *(downstream, Vertical Slice)* — needs input
  events (first successful lane change, first boost) to gate tutorial steps.

## Formulas

[To be designed]

## Edge Cases

[To be designed]

## Dependencies

[To be designed]

## Tuning Knobs

[To be designed]

## Visual/Audio Requirements

[To be designed]

## UI Requirements

[To be designed]

## Acceptance Criteria

[To be designed]

## Open Questions

[To be designed]
