# Concept Prototype Report: swipe-driving-loop

> **Date**: 2026-09-03
> **Prototype Path**: Engine (Godot)
> **Concept File**: design/gdd/game-concept.md (MATATU RUSH)

---

## Hypothesis

If the player swipes left/right to dodge traffic/potholes while swiping up to
boost and down to brake, the driving will feel responsive and satisfying — true
if a first-time player can react to and dodge an oncoming obstacle within
roughly 300ms, repeatably, without describing the controls as laggy or
unpredictable.

---

## Riskiest Assumption Tested

Whether swipe-based lateral movement could deliver "no noticeable input delay"
arcade-driving feel at all. This held up: lane-change swipes registered
instantly on release, with no perceptible lag. A second, unstated risk
surfaced during testing instead — whether the loop is actually *challenging*,
independent of how responsive the controls are. It was not.

---

## Approach

Godot 4.7.2 / GDScript, entire scene built procedurally in `main.gd` (no
hand-authored `.tscn` beyond a bare root) to minimize scene-file authoring
risk for a one-shot build. Straight 3-lane strip, one placeholder box vehicle,
plain red box obstacles spawning in a single random lane every 0.9s and
scrolling toward the player.

**Path chosen:** Engine
**Reason for path:** Driving feel is timing-sensitive; browser latency would
have produced a false result for this specific hypothesis.

**Shortcuts taken (intentional):**
- Single undifferentiated obstacle type (no potholes vs. traffic distinction)
- No real art — colored boxes only
- No audio, no menus, no scoring beyond a raw distance counter
- Single straight road, no road-type variety
- No Rush Meter, no passengers, no conductor

**Iteration note:** The first build ran with no visible errors but rendered
only a flat background color — not a logic bug, but a renderer configuration
mismatch (`rendering_method="mobile"` on a dev machine with no Vulkan/D3D12
support). Fixed by pinning `gl_compatibility` explicitly for local testing.
This also surfaced that the dev machine runs Godot 4.7.2, not the 4.6
originally pinned — engine reference docs were upgraded accordingly
(`/setup-engine upgrade 4.6 4.7.2`).

---

## Result

Player-reported findings (single internal playtester, several runs):

- Lane-change swipes register the instant the player releases the swipe — no
  perceptible input delay.
- Collision detection and the flash/reset loop function correctly and felt
  fair.
- Camera behavior was fine, no complaints.
- **No moment felt fun.** Direct quote: "there was none."
- **Nothing was ever actually challenging.** Direct quote: "it was easy the
  whole time, nothing to react under pressure." Root cause (from reading the
  spawn logic against this feedback): obstacles spawn one at a time in a
  single random lane out of three, so two lanes are free almost always — a
  player can dodge by doing almost nothing, never facing a real decision.
- Player specifically wants road curvature in future iterations instead of a
  fully straight path, for variety and as a natural difficulty lever.

---

## Metrics

| Metric | Value |
|--------|-------|
| Path used | Engine |
| Iterations to playable | 2 (initial build; then a renderer-config fix — not a logic bug) |
| Prototype duration | Same session, a few hours across build + iteration + playtesting |
| Playtesters | 1 internal |
| Feel assessment | Swipe-to-lane-change response felt instantaneous with no perceptible lag; difficulty was flat — single-obstacle-per-spawn across 3 lanes left 2 lanes free almost always, producing no reactive pressure |
| Hypothesis verdict | PARTIALLY CONFIRMED — the responsiveness half of the hypothesis held; the "satisfying" half did not, due to spawn/difficulty tuning, not control feel |

---

## Recommendation: PROCEED

The part of the hypothesis that was genuinely at risk — whether swipe input
can deliver arcade-tight responsiveness at all — is confirmed, and confirmed
cheaply (default tuning values worked on the first playable pass). The
absence of fun and the absence of pressure are real findings, but they trace
to a specific, fixable cause (spawn density/lane coverage), not to the
control scheme itself. Per the player's own verdict: "the core loop is worth
building, difficulty just needs tuning." This is a tuning problem to solve
early in implementation, not a signal to pivot or kill the mechanic.

---

## If Proceeding

- **Core tuning values discovered:** `LANE_LERP_RATE = 12.0` (lane-snap
  speed) felt instantly responsive as a starting value — carry forward into
  the real Driving system's tuning knobs.
- **Assumptions confirmed:** Swipe-based lateral dodge can deliver "no
  noticeable input delay" arcade feel — Pillars 1 and 2 have a real
  foundation to build on.
- **Assumptions disproved:** The MATATU RUSH concept doc's MVP core
  hypothesis — "dodging traffic/potholes is fun in isolation" — is NOT
  confirmed as-is. Obstacle density and multi-lane threat coverage are load-
  bearing for whether the loop feels like a game at all; they cannot be left
  at placeholder defaults when the real Driving/Traffic system GDD is
  written. This needs explicit design attention (spawn rules, lane-threat
  distribution, speed scaling), not just implementation of the mechanic as
  described.
- **Emergent mechanics worth formalizing:** Road curvature as a difficulty
  and variety lever, beyond straight-line obstacle density alone — raised
  unprompted by the playtester.

**Next steps:**
1. `/design-review design/gdd/game-concept.md`
2. `/gate-check`
3. `/map-systems`
4. `/design-system [mechanic]` — when authoring the Driving/Traffic system
   GDD, treat obstacle density, lane-threat distribution, and road curvature
   as first-class Tuning Knobs, not afterthoughts. Consider a short follow-up
   spike (`/prototype --spike`) specifically re-tuning spawn density before
   locking formulas in the GDD, since this pass never got past the easiest
   possible spawn configuration.

---

## Lessons Learned

- **What assumptions were broken by actually building this?** "Dodging
  obstacles is fun" is not automatically true once the mechanic exists — fun
  required actual risk, and risk required deliberate spawn/density tuning
  that this pass didn't attempt (it used arbitrary placeholder defaults).

- **What surprised us that didn't show up in the brainstorm?** How much the
  *felt* experience is dominated by threat density/pressure rather than raw
  control responsiveness. The brainstorm and concept doc treated "does
  swiping feel responsive" as the risky unknown; in practice that part was
  easy to get right, and the untested assumption — "is there enough going on
  to require the responsiveness" — turned out to be the real gap.

- **What would we test differently next time?** Treat "is the control
  responsive" and "is the challenge real" as two separate questions from the
  start, and tune obstacle density explicitly during the prototype pass
  rather than assuming reasonable-looking placeholder values would produce a
  reasonable-feeling difficulty curve.

---

> *Prototype code location: `prototypes/swipe-driving-loop-concept/`*
> *This code is throwaway. Never refactor into production.*
