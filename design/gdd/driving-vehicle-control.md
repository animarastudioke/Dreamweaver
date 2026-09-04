# Driving & Vehicle Control

Status: **Draft v0.1** — first pass, unreviewed against any wider Dreamweaver design canon (none exists in this repo yet).

## Assumptions this draft is built on (unconfirmed — correct or approve)

The repository currently contains no design documentation beyond a one-line
README ("Dreamweaver"). No genre, engine, camera perspective, or existing
vehicle content was available to ground this section, so the following were
assumed rather than derived. Anything below should be treated as
provisional until one of these is confirmed:

- **Genre/perspective:** third-person action-adventure, open or semi-open
  world, with vehicles as an optional traversal layer rather than the core
  loop (i.e. not a racing game or driving sim).
- **Handling model:** arcade-style, not simulation-grade. Priority is fun
  and readability over physical accuracy.
- **Platform:** designed for gamepad first, with keyboard/mouse as a
  supported fallback.
- **Vehicle role:** vehicles exist to speed up traversal and unlock
  set-piece moments (chases, ramps, terrain crossing), not as a
  progression/customization system in their own right.

If any of these are wrong, the sections below (especially Handling Model
and Camera) likely need to be rewritten rather than tweaked.

## 1. Purpose & Design Goals

Vehicles give the player a second traversal mode distinct from on-foot
movement: faster, less precise, and more momentum-driven. Design goals, in
priority order:

1. **Readability** — the player should always be able to predict where the
   vehicle will be half a second from now. No hidden-physics surprises.
2. **Low floor, high ceiling** — a new player can drive competently in
   under 30 seconds; an experienced player can chain drifts and jumps for
   faster routes.
3. **Seamless transitions** — entering/exiting a vehicle should never feel
   like a mode switch with a loading cost; it should read as one continuous
   action.
4. **Non-punishing failure** — crashing should cost time and momentum, not
   trigger death or heavy penalty, unless the specific
   encounter design calls for it.

## 2. Vehicle Types (initial roster)

Placeholder roster — assumes a small number of archetypes rather than deep
customization. **[Open question: does Dreamweaver want a garage/upgrade
system, or a fixed small set of vehicles?]**

| Vehicle | Role | Handling character |
|---|---|---|
| Runner (light car/bike) | Default, agile, first unlocked | Fast acceleration, tight turning, low mass — easy to drift, easy to spin out |
| Hauler (heavy vehicle) | Terrain/obstacle traversal | Slow acceleration, high mass, can push through light obstacles, poor turning |
| Glider/boat (context vehicle) | Traversal over water/air gaps | Different control scheme (see 4.3), likely scripted/limited-use |

Only the Runner is assumed to be fully player-controlled with free-roam
physics; the other two are sketched at low confidence and need their own
passes once the roster is confirmed.

## 3. Input Mapping

### Gamepad (primary)
- Right trigger — accelerate
- Left trigger — brake / reverse (hold after stop)
- Left stick — steer
- Face button (e.g. A/Cross) — handbrake / drift
- Face button (e.g. B/Circle) — exit vehicle
- Right stick — free-look camera while driving

### Keyboard/mouse (secondary)
- W / S — accelerate / brake-reverse
- A / D — steer
- Space — handbrake / drift
- Mouse — free-look camera
- F (or context prompt) — exit vehicle

**Risk flagged:** dual-scheme parity (handbrake-drift feel on analog stick
vs. digital A/D) tends to diverge in practice — the keyboard version will
feel snappier/twitchier than the gamepad version unless steering input is
smoothed asymmetrically per input device. Needs a prototype pass, not just
a mapping table.

## 4. Handling Model

### 4.1 Core loop
- Acceleration is not instant; there's a short ramp-up so top speed feels
  earned, not free.
- Steering authority scales inversely with speed: tighter turning at low
  speed, wider turning radius at high speed, to avoid "twitchy at speed"
  feel.
- Drift is entered via handbrake + steering input, and lets the player
  rotate the vehicle's heading faster than its velocity vector changes —
  the classic arcade drift gap between "where you're pointed" and "where
  you're going."

### 4.2 Momentum & collision
- Vehicles retain momentum through minor collisions (scenery, low
  obstacles) with a speed penalty, rather than hard-stopping.
- Hard stops (walls, large obstacles) reduce speed sharply and can
  eject the player from the vehicle above a velocity threshold — needs a
  tuned threshold so this reads as "that was a bad crash" and not as
  random punishment for clipping a curb.
- **[Open question: does the vehicle take persistent damage, or is it a
  stateless traversal tool that resets on re-entry?]** This draft assumes
  the latter (no persistent vehicle damage) since no economy/repair system
  is implied anywhere in the (currently empty) design canon.

### 4.3 Non-Runner vehicles
Not designed in this pass — flagged as a gap rather than guessed at, since
a Hauler and a glider/boat plausibly need entirely different control
verbs (push-weight vs. lift/thrust) that a single "driving" model doesn't
cover well.

## 5. Camera

- Default: chase camera, positioned behind and slightly above the
  vehicle, with a speed-based FOV increase to sell velocity.
- Camera lags behind rotation slightly (spring/damped follow) so sharp
  turns and drifts don't whip-pan the view.
- Free-look (right stick / mouse) temporarily overrides follow, recenters
  on release.
- **Risk flagged:** speed-based FOV + drift rotation lag is a common
  source of motion sickness complaints; needs a camera-shake/FOV-punch
  toggle in accessibility settings (see §8), not treated as a nice-to-have.

## 6. Enter / Exit Flow

- Approach a vehicle in range → context prompt appears → single button
  press mounts, with a short (assumed ~0.3–0.5s) blend animation, no hard
  cut.
- Exit is available at any speed **[open question: should high-speed exit
  be disabled or should it eject the player with fall-damage-style
  consequences? Not specified anywhere yet]** — this draft assumes exit is
  always allowed and simply drops the player at current velocity, which is
  probably the riskier of the two options and should be the first thing
  challenged in review.

## 7. HUD / Feedback

- Speed readout (numeric or stylized bar) — visibility TBD pending overall
  HUD/UI design direction, which does not exist yet in this repo.
- Drift state indicator (e.g. color shift on speed bar) while
  handbrake-drifting.
- Damage/collision feedback via camera shake + a short hit-flash, not a
  persistent health bar (consistent with the "no persistent vehicle
  damage" assumption in §4.2).

## 8. Accessibility

- Toggle: reduce camera shake / FOV-punch (see §5 risk).
- Toggle: steering assist (auto-correct oversteer for new players).
- Remappable inputs, consistent with any broader input-remapping system
  Dreamweaver ends up shipping (none defined yet).

## 9. Open Questions / Risks (rollup)

These are the items most likely to change the shape of this document once
real project context exists:

1. Is Dreamweaver even a genre where vehicles make sense as described, or
   is this entire "arcade traversal vehicle" framing wrong for the game?
2. Full vehicle roster and whether there's progression/customization.
3. Non-Runner (Hauler, glider/boat) control schemes — currently undesigned.
4. Vehicle damage/repair — assumed none; unconfirmed.
5. High-speed exit consequences — assumed none; flagged as likely wrong.
6. Keyboard vs. gamepad drift-feel parity — needs a prototype, not a spec.

## 10. Non-Goals (this pass)

- No racing/competitive mode design.
- No vehicle economy, purchasing, or cosmetic customization.
- No multiplayer/network sync considerations for vehicle physics.
