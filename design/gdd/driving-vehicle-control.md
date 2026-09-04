# Driving & Vehicle Control

Status: **Draft v0.2** — core scope decisions confirmed by project owner
(2026-09-04); implementation-level detail (exact tuning numbers,
input-parity prototyping) still open. See §9 for what remains.

## Confirmed Design Decisions

The repository holds no other design documentation, so these were decided
directly rather than derived from existing canon. Treat this list as the
source of truth for this feature going forward:

- **Genre/perspective:** third-person action-adventure. Vehicles are an
  optional traversal layer on top of an on-foot core loop — not a
  racing game, not a driving sim.
- **Vehicle roster:** a single vehicle ("the Runner"). No Hauler, no
  glider/boat, no garage or customization system. If a second vehicle
  becomes necessary later, it gets its own design pass rather than
  reviving the cut stubs in v0.1 of this doc.
- **Handling model:** arcade-style. Priority is fun and readability over
  physical accuracy.
- **High-speed exit:** disabled above a speed threshold (see §6) rather
  than always-allowed. This replaces the v0.1 default, which was flagged
  as the likely-wrong choice and has been corrected.
- **Platform:** designed for gamepad first, with keyboard/mouse as a
  supported fallback. (Carried over from v0.1 — not separately revisited;
  flag if this needs its own confirmation.)

## 1. Purpose & Design Goals

The vehicle gives the player a second traversal mode distinct from on-foot
movement: faster, less precise, and more momentum-driven. Design goals, in
priority order:

1. **Readability** — the player should always be able to predict where the
   vehicle will be half a second from now. No hidden-physics surprises.
2. **Low floor, high ceiling** — a new player can drive competently in
   under 30 seconds; an experienced player can chain drifts and jumps for
   faster routes.
3. **Seamless transitions** — entering/exiting the vehicle should never
   feel like a mode switch with a loading cost; it should read as one
   continuous action.
4. **Non-punishing failure** — crashing should cost time and momentum, not
   trigger death or heavy penalty, unless the specific encounter design
   calls for it.

## 2. The Vehicle: "the Runner"

A single, fully player-controlled vehicle — light, agile, easy to drift,
easy to spin out if oversteered. No roster table: this is the only
vehicle in scope for this pass, so there is nothing to compare it against.

If the project later wants a second vehicle (e.g. something heavier for
terrain traversal, or a context-specific water/air crossing), that is new
scope requiring its own design section — not a re-expansion of this one.

## 3. Input Mapping

### Gamepad (primary)
- Right trigger — accelerate
- Left trigger — brake / reverse (hold after stop)
- Left stick — steer
- Face button (e.g. A/Cross) — handbrake / drift
- Face button (e.g. B/Circle) — exit vehicle (see §6 for speed gating)
- Right stick — free-look camera while driving

### Keyboard/mouse (secondary)
- W / S — accelerate / brake-reverse
- A / D — steer
- Space — handbrake / drift
- Mouse — free-look camera
- F (or context prompt) — exit vehicle (see §6 for speed gating)

**Risk flagged:** dual-scheme parity (handbrake-drift feel on analog stick
vs. digital A/D) tends to diverge in practice — the keyboard version will
feel snappier/twitchier than the gamepad version unless steering input is
smoothed asymmetrically per input device. Needs a prototype pass, not just
a mapping table. Still open — see §9.

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
- The vehicle retains momentum through minor collisions (scenery, low
  obstacles) with a speed penalty, rather than hard-stopping.
- Hard stops (walls, large obstacles) reduce speed sharply and can
  eject the player from the vehicle above a velocity threshold — needs a
  tuned threshold so this reads as "that was a bad crash" and not as
  random punishment for clipping a curb.
- No persistent vehicle damage: the vehicle is a stateless traversal
  tool that resets on re-entry rather than accumulating damage requiring
  repair. Consistent with cutting the garage/customization system in §2 —
  there's no economy for a repair system to plug into.

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

- Approach the vehicle in range → context prompt appears → single button
  press mounts, with a short (assumed ~0.3–0.5s) blend animation, no hard
  cut.
- **Exit is speed-gated:** below the threshold, exit is available at any
  time and simply drops the player at current position. Above the
  threshold, the exit prompt/input is disabled — the player must slow down
  first. This replaces the v0.1 "always allow, drop at current velocity"
  default, which was flagged as the riskier option and has been corrected
  per the confirmed decision in the header.
- **Open (tuning-level, not design-level):** the exact speed threshold
  and what feedback communicates "too fast to exit" to the player (HUD
  icon greyed out? a rejection sound?) — needs a prototype pass, not a
  spec number invented here.

## 7. HUD / Feedback

- Speed readout (numeric or stylized bar) — visibility TBD pending overall
  HUD/UI design direction, which does not exist yet in this repo.
- Drift state indicator (e.g. color shift on speed bar) while
  handbrake-drifting.
- Exit-availability indicator, tied to the speed-gated exit rule in §6
  (e.g. the exit prompt dims/disables above the threshold rather than
  silently failing to respond).
- Damage/collision feedback via camera shake + a short hit-flash, not a
  persistent health bar (consistent with the "no persistent vehicle
  damage" decision in §4.2).

## 8. Accessibility

- Toggle: reduce camera shake / FOV-punch (see §5 risk).
- Toggle: steering assist (auto-correct oversteer for new players).
- Remappable inputs, consistent with any broader input-remapping system
  Dreamweaver ends up shipping (none defined yet).

## 9. Open Questions / Risks (rollup)

Scope-level questions from v0.1 are resolved (see "Confirmed Design
Decisions" above). What's left is implementation-level:

1. **Keyboard vs. gamepad drift-feel parity** (§3) — needs a prototype,
   not a spec. Highest-priority remaining item since it affects core feel.
2. **Hard-stop ejection threshold** (§4.2) — needs tuning, not a guess.
3. **Exit speed threshold and its feedback** (§6) — needs tuning + a UX
   pass on how "can't exit yet" reads to the player.
4. **Platform assumption** (gamepad-first) — carried over from v0.1
   without separate confirmation; flag if it needs its own check.

## 10. Non-Goals (this pass)

- No racing/competitive mode design.
- No second vehicle, vehicle economy, or cosmetic customization — see §2.
- No multiplayer/network sync considerations for vehicle physics (not
  confirmed either way — removed from non-goals in v0.2 rather than
  asserted, since claiming a non-goal implies knowing the actual goals).
