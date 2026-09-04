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

> All formulas below use `delta_time` = Godot's physics-tick delta
> (`_physics_process(delta)`), fixed at `physics_ticks_per_second` (default
> 60Hz) regardless of render framerate — this is what makes the tick-based
> smoothing formulas below frame-rate independent.

### 1. Lane Target Position

The `lane_target_x` formula is defined as:

`lane_target_x = (target_lane - (LANE_COUNT - 1) / 2) × LANE_WIDTH`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| Target lane index | `target_lane` | int | 0–2 | Lane the vehicle is moving toward (clamped by Core Rule 1) |
| Lane count | `LANE_COUNT` | int (structural constant) | fixed at 3 | Not a tuning knob — changing it requires re-authoring road art/obstacle spawn logic |
| Lane width | `LANE_WIDTH` | float (constant) | validated: 3.0m | Distance between adjacent lane centers |
| Result | `lane_target_x` | float | discrete set | World-space X coordinate of the target lane's center |

**Output Range:** Discrete set `{-3.0, 0.0, 3.0}` meters for the approved
3-lane / 3.0m configuration — never continuous, never out-of-set, since
`target_lane` is hard-clamped upstream (Core Rule 1/3).

**Example:** `target_lane = 2` → `(2 - 1) × 3.0 = 3.0m` (rightmost lane).

### 2. Lateral Position Interpolation (the core feel formula)

The `lateral_position_interpolation` formula is defined as:

`vehicle_x' = lerp(vehicle_x, lane_target_x, 1 - e^(-LANE_LERP_RATE × delta_time))`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| Current vehicle X | `vehicle_x` | float | -3.0–3.0m | Vehicle's world X position this tick (state, feeds from prior tick's output) |
| Target lane X | `lane_target_x` | float | {-3.0, 0.0, 3.0}m | From Formula 1 |
| Lane response rate | `LANE_LERP_RATE` | float (constant) | validated: 12.0 (1/s) | Controls how fast the vehicle catches up to the target lane |
| Physics delta | `delta_time` | float | ~0.0167s at 60Hz | Fixed physics tick duration |
| Result | `vehicle_x'` | float | -3.0–3.0m | New `vehicle_x` for this tick |

**Output Range:** Always within the closed interval between the previous
`vehicle_x` and `lane_target_x` — the smoothing factor `1 - e^(-k)` is
always in `[0, 1)` for `k ≥ 0`, so this formula can never overshoot or
oscillate, and `vehicle_x` stays within `[-3.0, 3.0]` for the life of the
run.

**Example:** Player is centered (`vehicle_x = 0.0`, lane 1) and swipes right
(`target_lane = 2`, `lane_target_x = 3.0`). At `LANE_LERP_RATE = 12.0`, one
tick at 60fps (`delta_time ≈ 0.01667s`):
`factor = 1 - e^(-12 × 0.01667) = 1 - e^(-0.2) = 0.1813`
`new_vehicle_x = 0.0 + (3.0 - 0.0) × 0.1813 = 0.544m`

The time constant `τ = 1/LANE_LERP_RATE = 0.083s (83ms)` is a useful design
metric: the vehicle reaches ~63% of the way to target in 83ms, ~90% by
192ms, ~95% by 250ms — all under typical "perceptible input lag" thresholds
(~100ms), consistent with the prototype's validated "no perceptible delay"
finding.

**Gap fix — arrival tolerance**: because this is exponential smoothing,
`vehicle_x` asymptotically approaches `lane_target_x` and mathematically
never becomes exactly equal to it. Any downstream system that needs to know
"the vehicle has arrived in lane N" (not just "is moving toward lane N")
must check `abs(vehicle_x - lane_target_x) < LANE_ARRIVAL_EPSILON` rather
than exact equality. See `LANE_ARRIVAL_EPSILON` in Tuning Knobs.

**Approved deviation from the prototype:** the prototype used a linear lerp
with a clamp (`lerp(x, target, clamp(delta * RATE, 0, 1))`), which hard-snaps
to the target in a single frame if a physics tick ever exceeds ~83ms — a
real risk given this project's 30fps-floor low-end Android target. This
exponential form degrades gracefully instead of popping. `LANE_LERP_RATE =
12.0` is unchanged; only the smoothing math shape changed. At normal 60fps
the two forms differ by ~9% per tick (0.1813 vs. the linear form's 0.2),
well within playtest noise — the validated "instant, no lag" feel carries
over.

### 3. Boost/Brake State Timer

The `state_timer_update` formula is defined as:

`up_swipe → boost_timer = BOOST_DURATION, brake_timer = 0`
`down_swipe → brake_timer = BRAKE_DURATION, boost_timer = 0`
`otherwise → boost_timer = max(0, boost_timer - delta_time), brake_timer = max(0, brake_timer - delta_time)`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| Up-swipe detected this tick | `up_swipe` | bool | true/false | From swipe classification (input handling, not covered here) |
| Down-swipe detected this tick | `down_swipe` | bool | true/false | Same |
| Boost duration | `BOOST_DURATION` | float (constant) | validated: 1.0s | Full boost window on trigger |
| Brake duration | `BRAKE_DURATION` | float (constant) | validated: 0.4s | Full brake window on trigger |
| Result | `boost_timer`, `brake_timer` | float | 0–duration, mutually exclusive | Countdown state per Core Rules 5–7 |

**Output Range:** `boost_timer ∈ [0.0, 1.0]`, `brake_timer ∈ [0.0, 0.4]`; by
construction (explicit opposing-timer zeroing), the two can never both be
nonzero simultaneously.

**Example:** Player is braking (`brake_timer = 0.25` remaining) and swipes
up. This tick: `up_swipe = true` → `boost_timer = 1.0`, `brake_timer = 0`
(forced). Braking is cut short exactly as Core Rule 7 requires.

**Approved bug fix vs. the prototype:** the prototype only *sets* the
newly-triggered timer and never *clears* the opposing one — speed selection
then uses `if boost_timer>0 elif brake_timer>0`, which is priority order,
not recency. If mid-boost and the player swipes down, the prototype's
`brake_timer` is set correctly but boost still wins every tick until its own
timer naturally expires — the down-swipe is silently ignored. This violates
Core Rule 7 ("most recent swipe wins"). The explicit zeroing above fixes it
and makes Formula 4's priority check correct-by-construction rather than
order-dependent.

### 4. Forward Speed

The `current_speed` formula is defined as:

`current_speed = BASE_SPEED × active_multiplier`, where `active_multiplier = BOOST_MULTIPLIER if boost_timer > 0, else BRAKE_MULTIPLIER if brake_timer > 0, else 1.0`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| Base speed | `BASE_SPEED` | float (constant) | validated: 14.0 m/s | Cruising forward speed |
| Boost multiplier | `BOOST_MULTIPLIER` | float (constant) | validated: 1.8 | Applied while `boost_timer > 0` |
| Brake multiplier | `BRAKE_MULTIPLIER` | float (constant) | validated: 0.45 | Applied while `brake_timer > 0` |
| Boost/brake timers | `boost_timer`, `brake_timer` | float | ≥0 | From Formula 3 |
| Result | `current_speed` | float | discrete set | Current forward speed, m/s |

**Output Range:** Discrete 3-value set `{6.3, 14.0, 25.2}` m/s given current
constants — no blending between states, matching the Core Rules'
intentionally instant (not eased) speed transitions.

**Example:** Cruising: `14.0 × 1.0 = 14.0 m/s` (~50.4 km/h). Boosting:
`14.0 × 1.8 = 25.2 m/s` (~90.7 km/h). Braking: `14.0 × 0.45 = 6.3 m/s`
(~22.7 km/h).

**Gap fix — Locked state**: this formula is defined only for
Cruising/Boosting/Braking. The instant the vehicle enters Locked, this
system stops evaluating Formula 4 entirely — `current_speed` for the
duration of Locked is owned and driven by Collision & Damage System (per
the States and Transitions table), not computed here. This system resumes
evaluating Formula 4 (from the Cruising branch) only once Collision &
Damage System signals recovery. Flagging explicitly because the original
draft left this silent, which read as though `active_multiplier` had an
undefined value during Locked rather than "not this system's formula to
evaluate."

### 5. Camera Reactive FOV

The `camera_fov` formula is defined as:

`target_fov = BASE_FOV + FOV_GAIN × (active_multiplier - 1.0)`
`camera_fov' = lerp(camera_fov, target_fov, 1 - e^(-CAMERA_FOV_LERP_RATE × delta_time))`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| Active multiplier | `active_multiplier` | float | {0.45, 1.0, 1.8} | Reused from Formula 4 — one variable driving both speed and camera |
| Base FOV | `BASE_FOV` | float (constant, **unvalidated — proposed starting value**) | 75.0° | Godot `Camera3D`'s own engine default, used as a neutral anchor |
| FOV gain | `FOV_GAIN` | float (constant, **unvalidated — proposed starting value**) | 8.0°/multiplier-unit | Degrees of push/pull per unit of `active_multiplier` above/below 1.0 |
| Camera lerp rate | `CAMERA_FOV_LERP_RATE` | float (constant, **unvalidated — proposed starting value**) | 6.0 (1/s) | Deliberately half of `LANE_LERP_RATE` — camera should read as reactive/cinematic, not as snappy as lane response |
| Result | `camera_fov'` | float | 70.6°–81.4° | Live camera FOV |

**Output Range:** `[70.6°, 81.4°]` given current constants — never
overshoots per-tick, same reasoning as Formula 2.

**Example:** Boost triggers, `active_multiplier → 1.8`.
`target_fov = 75.0 + 8.0 × 0.8 = 81.4°`. One tick at 60fps:
`factor = 1 - e^(-6×0.01667) = 1 - e^(-0.1) = 0.0952`;
`camera_fov = 75.0 + 6.4×0.0952 = 75.61°`. Time constant `τ = 1/6 ≈ 167ms` —
about twice as slow to converge as the lane change, an intentional
differentiation between "controls feel instant" and "camera feels
reactive."

> **Unvalidated constants**: `BASE_FOV`, `FOV_GAIN`, and
> `CAMERA_FOV_LERP_RATE` do not exist in the prototype (its camera had no
> FOV reactivity at all) and have zero playtest backing — they are proposed
> starting values, not measured ones. Re-verify against a real camera-feel
> pass before treating them as final; see Tuning Knobs.

### 6. Speed-Line Intensity

The `speedline_intensity` formula is defined as:

`speedline_intensity = clamp((active_multiplier - 1.0) / (BOOST_MULTIPLIER - 1.0), 0.0, 1.0)`

**Variables:**
| Variable | Symbol | Type | Range | Description |
|---|---|---|---|---|
| Active multiplier | `active_multiplier` | float | {0.45, 1.0, 1.8} | From Formula 4 |
| Boost multiplier | `BOOST_MULTIPLIER` | float (constant) | validated: 1.8 | Normalization anchor |
| Result | `speedline_intensity` | float | 0.0–1.0 | Shader/particle intensity parameter |

**Output Range:** Clamped 0.0–1.0. Cruising and Braking both map to `0.0`
(no speed lines below 1x); Boosting maps to `1.0`.

**Example:** Boosting: `(1.8-1.0)/(1.8-1.0) = 1.0` (full intensity).
Braking: `(0.45-1.0)` is negative → clamped to `0.0`.

**Approved design decision:** the mapping is deliberately asymmetric —
speed lines only appear on boost, never on brake — because forward-motion
streak VFX reads oddly during a slow-down. No smoothing is applied;
intensity pops instantly with `active_multiplier`, reinforcing boost's
"deliberate escalation" feel (per Player Fantasy) rather than easing in,
unlike the camera FOV.

## Edge Cases

- **If a swipe gesture's start-to-end distance is below `SWIPE_MIN_DISTANCE`
  (40.0px)**: no action is taken — not classified as a lane-change, boost,
  or brake. Prevents accidental taps from triggering movement.
- **If a swipe is diagonal (both |dx| and |dy| exceed the threshold)**:
  classify by dominant axis — whichever of |dx| or |dy| is larger wins; the
  other axis is ignored for that gesture. Prevents an imprecise swipe from
  double-triggering (e.g., both a lane change and a boost).
- **If a diagonal swipe is an exact tie (`|dx| == |dy|`, a true 45°
  gesture)**: horizontal wins — classify as a lane change, not boost/brake.
  Lane changes are the higher-frequency, lower-consequence action; defaulting
  an ambiguous input to it is less disruptive than an unintended boost or
  brake, consistent with Pillar 2's "never a surprise" fairness test.
- **If both an up-swipe and down-swipe are detected in the same physics
  tick** (only possible via simultaneous on-screen button presses, since a
  single touch gesture can't be both): down-swipe (brake) takes priority,
  since braking is the safer/more conservative action and Pillar 2 favors
  outcomes that never feel like the game punished the player for an
  ambiguous input.
- **If a swipe or button press occurs while the vehicle is in the Locked
  state** (mid-collision-reaction): the input is dropped entirely, not
  queued — the player must re-input after recovery. Queueing would let a
  pre-collision panic-swipe fire unexpectedly after recovery, which would
  read as the game acting on stale intent.
- **If the vehicle enters Locked state while `boost_timer` or `brake_timer`
  is still counting down**: both timers are force-reset to `0` on Locked
  entry. Recovery always exits into a clean Cruising state — prevents a
  "surprise boost" immediately after a collision, which would violate
  Pillar 2.
- **If an on-screen button is held down rather than tapped**: treated as
  edge-triggered, identical to a swipe gesture — one press = one
  lane-change/boost/brake trigger, not a continuous repeat. This keeps the
  two input paths (swipe vs. button) functionally equivalent per Core Rule
  8.
- **If a physics tick's `delta_time` spikes far above normal** (app resumed
  from background, engine hitch): Formula 2's exponential form degrades
  gracefully — a huge `delta_time` drives the smoothing factor toward
  `1.0`, snapping to the target lane rather than breaking (unlike the
  prototype's linear-clamp form, which had the same snap behavior but only
  above a hard threshold). Still, the engine implementation should clamp
  raw `delta_time` at the physics-process level (standard Godot practice)
  so unrelated per-frame accumulators (distance traveled, timers) don't
  spike from the same hitch.
- **At run start**: `current_lane` and `target_lane` both default to `1`
  (center lane), `vehicle_x = 0.0` — no interpolation needed on the first
  frame.
- **If `target_lane` changes again before the previous lane-change
  interpolation finishes**: no special handling needed — Formula 2
  continuously re-targets every tick, so the vehicle smoothly redirects
  toward the new target without any pop or discontinuity.

## Dependencies

**Upstream (this system depends on):** None — Foundation layer, zero
dependencies. This is intentional; it's why Driving & Vehicle Control is
first in the design order.

**Downstream (systems that depend on this one):**

| System | Dependency Type | What it needs from this system |
|---|---|---|
| Traffic & Obstacle System | **Hard** | Per-frame lane index + world-space transform — cannot spawn/evaluate threats without a positioned vehicle |
| Collision & Damage System | **Hard** | Collider transform + the `lock_movement()`/`unlock_movement()` hook |
| Passenger & Delivery Loop | **Hard** | Vehicle world position/route progress to detect pickup/drop-off proximity |
| Rush Meter *(Vertical Slice)* | **Hard** | Raw obstacle-distance data to compute near-misses |
| Vehicle Progression & Upgrades *(MVP)* | **Hard** | Externally-settable tunable parameters (`BASE_SPEED`, `BOOST_MULTIPLIER`, `LANE_LERP_RATE`, etc.) |
| HUD & UI *(MVP)* | **Hard** | Current state (Cruising/Boosting/Braking) + speed, to render any driving-related feedback at all |
| Onboarding/Tutorial Flow *(Vertical Slice)* | **Soft** | Input events (first lane change, first boost) to gate tutorial steps — tutorial could function in a degraded form without this, just less precisely |

**Bidirectionality note**: none of these 7 systems have GDDs yet. Per
`design-docs.md`'s bidirectionality rule, each one's own GDD must list
"Driving & Vehicle Control" as an upstream dependency when it's authored —
flagging this now so `/design-system` for any of them cross-checks against
this table rather than silently diverging.

## Tuning Knobs

| Knob | Default | Safe Range | Affects | Risk at Extremes |
|---|---|---|---|---|
| `BASE_SPEED` | 14.0 m/s | 8.0–20.0 | Overall pace/difficulty | Too low: no urgency, violates Pillar 3 (Risk Feels Good). Too high: unreadable at current `LANE_LERP_RATE`, dodging starts to feel unfair (violates Pillar 2) |
| `BOOST_MULTIPLIER` | 1.8 | 1.3–2.5 | Boost's risk/reward magnitude | Too low: boost feels pointless. Too high: trivializes route timers, breaks Economy & Scoring balance once that GDD exists |
| `BRAKE_MULTIPLIER` | 0.45 | 0.2–0.7 | Precision-stop control at pickup zones | Too low (near 0): feels like an awkward full stop. Too high (near 1): brake barely does anything, useless for pickup zones |
| `BOOST_DURATION` | 1.0s | 0.5–2.0s | Commitment length of a boost | Too short: not worth the swipe. Too long: removes agency — player stuck fast through obstacles they didn't mean to hit |
| `BRAKE_DURATION` | 0.4s | 0.2–1.0s | Commitment length of a brake | Too short: unusable for an actual pickup-zone stop. Too long: brake becomes a "safe spam" strategy, undermining Pillar 3 |
| `LANE_LERP_RATE` | 12.0 (1/s) | 8.0–20.0 | **The core feel knob** — lane-change snappiness | Too low: sluggish, violates Pillar 1 (the prototype validated ~12.0 specifically — don't drift far without re-testing). Too high (>25): teleport-like, breaks camera readability |
| `LANE_WIDTH` | 3.0m | 2.5–4.0m | Obstacle spacing, threading tension | Too narrow: obstacles visually overlap, near-misses feel cheap. Too wide: undermines the "threading a gap" fantasy entirely — see interaction note below |
| `SWIPE_MIN_DISTANCE` | 40.0px | 20–80px | Accidental-tap rejection | Too low: false positives from taps. Too high: legitimate quick swipes get rejected — directly undermines the validated "no perceptible delay" finding |
| `BASE_FOV` *(unvalidated)* | 75.0° | 65–85° | Baseline camera framing | Too narrow: claustrophobic. Too wide: fisheye distortion, hard to judge lane distances |
| `FOV_GAIN` *(unvalidated)* | 8.0° | 4–15° | Boost/brake visual intensity | Too low: boost doesn't read as different. Too high: disorienting during rapid boost↔brake switching |
| `CAMERA_FOV_LERP_RATE` *(unvalidated)* | 6.0 (1/s) | 3–10 | Camera reactivity speed | Should stay below `LANE_LERP_RATE` — this preserves the intentional Player Fantasy distinction ("controls feel instant, camera feels reactive") |
| `LANE_ARRIVAL_EPSILON` | 0.02m | 0.005–0.05m | Threshold at which `abs(vehicle_x - lane_target_x) < ε` counts as "arrived in lane" for downstream systems (see Formula 2 gap fix) | Too tight: downstream systems (Passenger & Delivery Loop's zone detection, etc.) may never register "arrived" due to floating-point noise. Too loose: "arrived" fires while still visibly mid-lerp, looks wrong to any system gating visuals on it |

**Interaction to watch**: `LANE_LERP_RATE` and `LANE_WIDTH` are coupled —
the *effective* real-world lane-change speed (meters/second) is roughly
`LANE_LERP_RATE × LANE_WIDTH`-scaled, so widening lanes without
re-validating the lerp rate changes felt responsiveness even though the
constant itself didn't move.

## Visual/Audio Requirements

*(Consistent with the "Coastal Arcade Realism" Visual Identity Anchor and
the approved lane/speed/camera mechanics above. This section covers only
what Driving & Vehicle Control must produce or expose — full mixing/
layering ownership belongs to the downstream Audio System GDD, Vertical
Slice tier.)*

### VFX & Visual Feedback per Event

**Lane change** (`LANE_LERP_RATE=12.0`, ~83ms to 63%) — near-instant and
constantly repeating, so feedback must be cheap and non-fatiguing, not a
"moment." A subtle body-roll/bank into the direction of travel (transform-
or vertex-shader-based) sells weight. **No spawned lane-target
decal/pulse** — the action is already instant and clear from vehicle motion
alone; a spawned indicator would add drawcall cost and fatigue for
something that fires this often.

**Boost trigger** (25.2 m/s, 1.0s) — full-intensity speed-line VFX
(already asymmetric per Formula 6), implemented as a lightweight
screen-space streak shader, not per-particle sprites (draw-call budget is
tight). **Streaks are neutral/desaturated**, not warm-palette-tinted — the
Visual Identity Anchor's own color philosophy puts gameplay signaling
before atmosphere, and a state-change cue needs to read via
brightness/contrast against an already-saturated coastal backdrop. Camera
FOV push (Formula 5, 75°→81.4°) is the *primary* boost signal — functionally
free (one camera parameter, zero draw calls) and should carry more
perceptual weight than any particle effect. Optional low-priority: a
single-shot forward lean/anticipation pose on boost start (transform-only).

**Brake trigger** (6.3 m/s, 0.4s) — no speed-line VFX by design (asymmetric,
per Formula 6), so brake needs its own distinct, cheap tell. FOV pull-in
(mirrored from boost) plus a nose-down pitch/weight-transfer on the vehicle
body, both transform-level and effectively free. **No aggressive tire-
screech/skid-burst VFX** — this is a direct, load-bearing enforcement of the
already-approved Player Fantasy line ("a controlled, confident slow-down,
never a panic tap"); screech/skid visual language reads as emergency, which
contradicts it. A brief single-shot dust/tire-touch puff at brake
initiation is acceptable for tactile confirmation.

**Camera reactivity (general)** — FOV transitions ease in/out on a curve
matched to each state's duration window (1.0s boost / 0.4s brake per
Formula 5), never snap. **No screen shake** on boost or brake — shake risks
impairing lane/road/hazard legibility at speed, conflicting with the
Anchor's core rule ("every surface reads at a glance from a moving
camera").

### Vehicle (Matatu) Visual Style Constraints

- **Silhouette-first is the dominant constraint at this system's speed
  range** — the matatu's outline must read instantly from directly behind
  and in peripheral vision at 14–25 m/s: boxy minibus proportions,
  exaggerated roofline/wheel scale over literal accuracy.
- **Livery vs. gameplay color language**: matatu culture's loud, custom
  livery art is a real strength to lean into for "market-stall color pops"
  and place identity — but the Anchor's color philosophy reserves color for
  gameplay signaling (lanes, hazards, pickup zones) *first*. Livery art must
  avoid dominant color masses that could later collide with whatever
  hazard/lane color palette gets locked in a future `/art-bible` pass (e.g.,
  if hazard-red is chosen downstream, livery shouldn't lean heavily red).
  **Flag forward to the eventual `/art-bible` pass** — no formal hazard/lane
  palette exists yet to check against.
- **Animation scope at this system's level**: wheel spin plus the
  lane-change bank and brake/boost pitch above is sufficient — no detailed
  suspension articulation needed, consistent with "texture detail second"
  and the tight performance budget.
- Single LOD is likely sufficient for the player vehicle, since the fixed
  third-person offset keeps it at constant screen distance (traffic-vehicle
  LOD is Traffic & Obstacle System's concern, not this one's).

### Audio Requirements (system-scoped)

This system exposes audio-relevant signals; it does not fully design audio
— that's the downstream Audio System GDD's job (Vertical Slice tier).

- Expose continuous normalized speed (or at minimum the three discrete
  states: Cruising/Boosting/Braking) so engine audio can crossfade/
  pitch-shift smoothly rather than hard-cutting between loops.
- Expose discrete trigger events: `boost_started`, `boost_ended`,
  `brake_started`, `brake_ended`. **No `lane_change` audio trigger hook for
  now** — lane changes fire too frequently; a hook can be added later if the
  Audio System GDD wants one, but exposing it now risks over-scoping this
  GDD.
- **Boost SFX character** (for the Audio GDD to execute against): a punchy
  one-shot at trigger — turbo-whoosh or horn-blast (real matatus are known
  for loud decorative horns, a culturally-authentic hook) — layered under
  the continuous engine loop, not replacing it, so escalation reads as "same
  vehicle pushed harder." Reinforces boost's approved "deliberate
  escalation of risk" fantasy.
- **Brake SFX character**: **air-brake hiss**, not tire-screech or generic
  engine-braking growl — matches real matatu culture (air brakes are a
  distinctive period/cultural detail) while still satisfying the load-bearing
  "no panic" constraint from Player Fantasy.
- **Diegetic only** — engine/boost/brake audio stays fully diegetic, no
  UI-layer stinger. These trigger at high arcade frequency; a UI chime on
  every trigger would fatigue quickly.

### Visual Identity Anchor Principle Application

- **Silhouette-first** is the most directly load-bearing principle for this
  system — readability at speed from a follow camera depends entirely on
  outline clarity, governing both vehicle design and the lean/pitch
  animation choices above.
- **Exaggeration over accuracy** governs the animation language (pitch-dive
  on brake, lean on boost, oversized wheels) — heightened response sells
  state changes instantly, which "mastery under chaos" requires.
- **Warm coastal palette** is the weakest direct connection here: boost/
  brake feedback color is deliberately neutral/desaturated for
  contrast-based legibility, a real trade-off against "warm palette over
  generic gray" — resolved in favor of legibility per the Anchor's own
  stated priority (gameplay info before atmosphere).

### Mobile Performance Constraints Applied

- No volumetric fog/light shafts or other Forward+-only features anywhere
  in this system's VFX (Forward Mobile renderer only).
- Speed-line VFX uses a shared/pooled, lightweight screen-space shader
  approach, not per-event particle instancing, given the <150 draw-call
  budget.
- FOV push and vehicle-transform reactivity (lean/pitch) are effectively
  free and preferred over spawned effects wherever a choice exists.

## UI Requirements

This system requires two 2D overlay elements to exist; both are
placeholder-level specs here — full visual/interaction polish belongs to
HUD & UI's own GDD (MVP tier), and any colorblind/low-vision accessibility
treatment belongs to a future accessibility pass, flagged below.

**On-screen control buttons** (the required accessibility-parity input path
from Core Rule 8):
- Four buttons: lane-left, lane-right, boost, brake — positioned within
  comfortable thumb reach for one-handed portrait play (bottom third of
  screen, split left/right for lane buttons vs. boost/brake).
- Must be edge-triggered on press (per Edge Cases — no hold-to-repeat).
- Must visually confirm a press (brief pressed-state highlight) within the
  same frame — this is the on-screen path's equivalent of the swipe's "no
  perceptible delay," and it must not lag behind the swipe path or it fails
  Core Rule 8's parity requirement.

**Boost/brake state indicator**:
- A minimal always-visible cue (icon or short bar) showing current state
  (Cruising/Boosting/Braking), independent of the 3D camera/speed-line
  feedback — needed because camera FOV push alone isn't accessible to
  colorblind or low-vision players, and doesn't help a player glancing at
  their phone mid-distraction.
- **Flagged forward**: full accessibility treatment (colorblind-safe state
  encoding, text alternative) is out of scope for this GDD — belongs to
  HUD & UI's GDD with accessibility-specialist input.

Both elements are functional requirements this system depends on existing;
their visual design is HUD & UI's to own.

## Acceptance Criteria

### Lane Movement & Clamping (Core Rules 1–3)

- **GIVEN** vehicle in lane 1, **WHEN** player swipes right (or presses the right button), **THEN** `target_lane` becomes 2 and `lane_target_x` becomes 3.0m (Formula 1).
- **GIVEN** vehicle in lane 0, **WHEN** player swipes left, **THEN** `target_lane` remains 0 and `vehicle_x` does not move (no perceptible x-position change over the following 1s).
- **GIVEN** vehicle in lane 2, **WHEN** player swipes right repeatedly (3+ times), **THEN** `target_lane` stays clamped at 2 for every attempt — never exceeds 2, never wraps.
- **GIVEN** `vehicle_x = 0.0` and a swipe-right just triggered (`lane_target_x = 3.0`), **WHEN** one physics tick elapses at `delta_time ≈ 0.01667s` (60Hz), **THEN** `vehicle_x` equals `0.544 ±0.01m` (per Formula 2's worked example — verify via debug overlay or log at a pinned `dt`).

### Forward Speed (Core Rule 4 / Formula 4)

- **GIVEN** state = Cruising, **WHEN** `current_speed` is sampled, **THEN** it equals `14.0 m/s ±0.01`.
- **GIVEN** state = Boosting, **WHEN** `current_speed` is sampled, **THEN** it equals `25.2 m/s ±0.01`.
- **GIVEN** state = Braking, **WHEN** `current_speed` is sampled, **THEN** it equals `6.3 m/s ±0.01`.

### Boost (Core Rule 5)

- **GIVEN** state = Cruising, **WHEN** player up-swipes, **THEN** state becomes Boosting, `boost_timer = 1.0s`, and `current_speed` becomes `25.2 m/s` within the same tick.
- **GIVEN** state = Boosting with `boost_timer = 0.4s` remaining, **WHEN** player up-swipes again, **THEN** `boost_timer` resets to `1.0s` (not additive to `1.4s`) and state remains Boosting.
- **GIVEN** state = Boosting, **WHEN** `boost_timer` reaches 0 with no further input, **THEN** state transitions to Cruising and `current_speed` returns to `14.0 m/s`.

### Brake (Core Rule 6)

- **GIVEN** state = Cruising, **WHEN** player down-swipes, **THEN** state becomes Braking, `brake_timer = 0.4s`, `current_speed = 6.3 m/s`.
- **GIVEN** state = Braking with `brake_timer = 0.1s` remaining, **WHEN** player down-swipes again, **THEN** `brake_timer` resets to `0.4s` (not additive) and state remains Braking.
- **GIVEN** state = Braking, **WHEN** `brake_timer` reaches 0 with no further input, **THEN** state transitions to Cruising and `current_speed` returns to `14.0 m/s`.

### Mutual Exclusion — Bug Regression (Core Rule 7 / Formula 3's approved fix)

- **[BUG REGRESSION]** **GIVEN** state = Boosting with `boost_timer = 0.7s` remaining, **WHEN** player down-swipes, **THEN** `boost_timer` is forced to `0` in the same tick, state transitions immediately to Braking with `brake_timer = 0.4s`, and `current_speed` changes directly from `25.2` to `6.3 m/s` with no intermediate cruise-speed frame.
- **[BUG REGRESSION]** **GIVEN** state = Braking with `brake_timer = 0.2s` remaining, **WHEN** player up-swipes, **THEN** `brake_timer` is forced to `0` in the same tick, state transitions immediately to Boosting with `boost_timer = 1.0s`, and `current_speed` changes directly from `6.3` to `25.2 m/s`.
- **[BUG REGRESSION]** **GIVEN** state = Boosting, **WHEN** player down-swipes then immediately up-swipes again before the tick advances further, **THEN** the final state reflects only the most recent input (Boosting, `boost_timer = 1.0s`) — confirms priority is recency-based, not "boost always wins" (the original prototype defect).

### State Machine — Locked

- **GIVEN** any of Cruising/Boosting/Braking, **WHEN** the collision system signals Locked entry, **THEN** state becomes Locked and both `boost_timer` and `brake_timer` are set to `0` within the same tick.
- **GIVEN** state = Locked, **WHEN** player swipes (any direction) or presses any on-screen button, **THEN** `target_lane`, `vehicle_x` trajectory, `boost_timer`, and `brake_timer` all remain unchanged — the input produces no effect at all, immediate or delayed.
- **GIVEN** state = Locked with input attempted during lock, **WHEN** the external recovery signal fires with no further input after recovery, **THEN** state becomes Cruising and the previously-dropped input does **not** retroactively fire (confirms "dropped, not queued").
- **GIVEN** state = Locked, **WHEN** the external recovery signal fires, **THEN** state transitions to Cruising and `current_speed` becomes `14.0 m/s`.

### Input Parity — Swipe vs. Button (Core Rule 8)

- **GIVEN** vehicle in lane 1, **WHEN** tested once via a valid swipe-right (≥40px) and once via a right on-screen button tap (separate isolated runs), **THEN** both produce identical `target_lane` (2) and identical lerp trajectory — no measurable difference in outcome or per-frame timing.
- **GIVEN** a swipe with start-to-end distance of 39px, **WHEN** released, **THEN** no lane change, boost, or brake fires (treated as a no-op, not a partial/weak trigger).
- **GIVEN** a swipe with start-to-end distance of 40px or more, **WHEN** released, **THEN** the corresponding action fires exactly once.
- **GIVEN** an on-screen button held down continuously for 2 seconds, **WHEN** sampled every frame during the hold, **THEN** the associated action fires exactly once on initial press and does not re-fire while held (edge-triggered, not repeat).

### Diagonal Swipe Classification

- **GIVEN** a swipe where `|dx| > |dy|` and both exceed 40px, **WHEN** released, **THEN** it is classified as a lane-change (left/right) — no boost/brake fires.
- **GIVEN** a swipe where `|dy| > |dx|` and both exceed 40px, **WHEN** released, **THEN** it is classified as boost (up) or brake (down) — no lane change fires.
- **GIVEN** a swipe where `|dx| == |dy|` exactly (a true 45° gesture) and both exceed 40px, **WHEN** released, **THEN** it is classified as a lane change (horizontal wins ties, per Edge Cases).

### Simultaneous Input & Delta-Time Spike

- **GIVEN** state = Cruising, **WHEN** an up-swipe and down-swipe are both registered within the same physics tick (e.g., simultaneous button presses), **THEN** brake wins: state becomes Braking, `brake_timer = 0.4s`, `boost_timer` stays/forced to `0`.
- **GIVEN** `vehicle_x` mid-lerp toward a target lane, **WHEN** a physics tick with an abnormal `delta_time` spike occurs (e.g., simulated 500ms hitch), **THEN** `vehicle_x` moves toward `lane_target_x` without overshoot or oscillation and without visibly teleporting past the target lane's position (verify against Formula 2's degrade-gracefully behavior, not the old linear-clamp hard-snap).

### Run Start & Re-targeting

- **GIVEN** a fresh run start, **WHEN** the scene loads before any input, **THEN** `current_lane = 1`, `target_lane = 1`, `vehicle_x = 0.0`.
- **GIVEN** `vehicle_x` mid-lerp toward lane 2, **WHEN** player swipes left again before arrival, **THEN** `lane_target_x` updates immediately to lane 1's position and the lerp continues from the vehicle's current in-flight position — no reset to the lane-1 start position, no pop.
- **GIVEN** `vehicle_x` approaching `lane_target_x`, **WHEN** `abs(vehicle_x - lane_target_x) < LANE_ARRIVAL_EPSILON` (0.02m), **THEN** any downstream system checking lane arrival registers "arrived" — confirms the epsilon-based check works as specified in the Formula 2 gap fix.

### Camera & VFX (Formulas 5–6) — directional checks only, values unvalidated

- **GIVEN** state transitions to Boosting, **WHEN** FOV is observed over the following ~250ms, **THEN** it smoothly increases from `75.0°` toward `81.4°` with no snap or overshoot (directional/smoothness check — the exact `81.4°` endpoint is explicitly marked unvalidated in Formula 5 and should not be treated as a hard pass/fail number).
- **GIVEN** state = Boosting, **WHEN** speed-line VFX is checked, **THEN** it is visible; **GIVEN** state = Cruising or Braking, **WHEN** checked, **THEN** speed lines are not visible (Formula 6's asymmetric boost-only behavior).

### Performance Budget (target platform: mobile Android, Forward Mobile)

- **GIVEN** the driving loop running on a representative low-end Android reference device, **WHEN** measured via Godot's Debugger > Monitors over a 60-second session including at least 10 lane changes, 5 boosts, and 5 brakes, **THEN** average FPS is ≥30 with no single stretch below 30fps lasting longer than 2 seconds.
- **GIVEN** the same profiling session, **WHEN** draw calls are sampled via Monitors > Rendering, **THEN** the driving scene (vehicle + camera + VFX from this system) stays under 150 draw calls per frame.
- **GIVEN** the same profiling session, **WHEN** memory is sampled via Monitors > Memory at t=10s and again at t=60s, **THEN** total working set stays under ~512MB and shows no sustained upward trend indicating a leak.

**Story-type classification for QA plan purposes**: this system is
primarily **Logic** (lane clamping, speed formulas, timer/mutual-exclusion
state machine) — those criteria require automated unit tests in
`tests/unit/driving/` per the BLOCKING gate. The Locked-state interaction
with Collision & Damage System is **Integration** once that system exists.
Camera FOV/speed-lines and UI button feedback are **Visual/Feel** and
**UI** respectively — advisory evidence (screenshot + sign-off, manual
walkthrough) is sufficient for those, per the story-type table in
`.claude/docs/coding-standards.md`.

> **Note on the 5th flagged gap (system-specific performance budget)**: the
> <150 draw-call / ~512MB figures above are whole-build budgets from
> `technical-preferences.md`, not a driving-system-specific sub-budget. This
> GDD asks QA to profile the driving scene in isolation; once Traffic &
> Obstacle System is designed and shares a frame with this system, a proper
> per-system budget allocation should replace this whole-build proxy. Not
> blocking for this GDD — flagged forward.

## Open Questions

1. **Are `BASE_FOV` (75.0°), `FOV_GAIN` (8.0°), and `CAMERA_FOV_LERP_RATE`
   (6.0) actually the right camera-feel values?** These are proposed
   starting points with zero playtest backing (Formula 5) — the prototype
   had no FOV reactivity at all. **Owner**: game-designer / godot-specialist.
   **Target**: resolve during this system's first implementation pass, via a
   dedicated camera-feel check before treating these as final.

2. **Does the whole-build performance budget (<150 draw calls, ~512MB)
   need a driving-system-specific sub-allocation?** Currently this GDD's
   Acceptance Criteria profile the driving scene against project-wide
   figures from `technical-preferences.md`, not a number scoped to this
   system alone. **Owner**: performance-analyst. **Target**: once Traffic &
   Obstacle System is designed and the two systems share a frame budget.

3. **Is `LANE_ARRIVAL_EPSILON = 0.02m` the right arrival tolerance?**
   Proposed to close the "exponential lerp never exactly arrives" gap
   (Formula 2), but untested against real downstream consumers (e.g.,
   Passenger & Delivery Loop's zone detection). Too tight risks
   floating-point flicker; too loose risks visibly-early "arrived" signals.
   **Owner**: game-designer. **Target**: first `dev-story` implementation
   pass, with a note back to this GDD if the value needs to change.

4. **Does Collision & Damage System's actual recovery-signal design match
   this GDD's assumptions about Locked state?** This GDD assumes: entry
   zeroes both boost/brake timers, recovery always exits to Cruising (never
   back into Boosting/Braking), and dropped input during Locked is never
   queued. These are reasonable defaults chosen here, in the absence of that
   system's own GDD — Collision & Damage System's author should explicitly
   confirm or override them, not silently diverge. **Owner**: whoever
   authors `design/gdd/collision-damage-system.md`. **Target**: when that
   GDD's Interactions-with-Other-Systems section is written.
