# Game Concept: MATATU RUSH

*Created: 2026-09-02*
*Status: Draft*

---

## Elevator Pitch

> It's an arcade driving game where you pilot a Kenyan matatu through chaotic
> Mombasa-inspired traffic, picking up passengers and racing the clock to get
> them there without wrecking the van.
>
> Test: Can someone who has never heard of this game understand what they'd
> be doing in 10 seconds? Yes — "arcade matatu delivery driving" reads
> instantly.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Arcade driving / score-chase (passenger-delivery subgenre) |
| **Platform** | Mobile (Android primary), architecture supports later Web export |
| **Target Audience** | Casual-to-mid-core mobile players who like short, replayable arcade sessions; strong regional appeal to Kenyan/East African players seeking culturally authentic representation |
| **Player Count** | Single-player |
| **Session Length** | 1-3 minutes per run; multi-run sessions of 10-20 minutes |
| **Monetization** | F2P — optional rewarded ads (double earnings, continue run, bonus reward) + cosmetic purchases only, no gameplay advantage sales, no loot boxes/gambling |
| **Estimated Scope** | Large (12-24 months, solo, first game) |
| **Comparable Titles** | Crazy Taxi, Subway Surfers, Traffic Rider |

---

## Core Fantasy

"Can you get your passengers there on time without destroying the matatu?"
The player is a matatu driver — a folk-hero role in Kenyan urban culture,
equal parts reckless and skilled — weaving through market crowds, potholes,
and rival vehicles while a conductor character heckles and cheers from the
side door. It's the fantasy of mastery under chaos: total control expressed
through calculated risk, in a specific, textured world most driving games
never touch.

---

## Unique Hook

It's like Crazy Taxi, AND ALSO a specific, unapologetically East African
world — matatu culture, Sheng-inflected conductor banter, Mombasa-inspired
streets — where the risk/reward Rush Meter and a living conductor character
turn every near-miss into a moment the game reacts to, not just a score
tick.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 1 | Boost camera FOV/speed lines, engine audio, satisfying collision/pothole feedback |
| **Challenge** (obstacle course, mastery) | 2 | Traffic/pothole avoidance, tightening timers, precision-required Old Town road type |
| **Expression** (self-expression, creativity) | 3 | Matatu customization (paint, stickers, wheels, themes) — cosmetic only |
| **Fellowship** (social connection) | 4 | Conductor character banter reacting to play; leaderboard as asynchronous social proof |
| **Fantasy** (make-believe, role-playing) | 5 | "You are the matatu driver" role, folk-hero framing |
| **Discovery** (exploration, secrets) | 6 | Road-type variety, procedurally assembled routes, unlockable vehicle classes |
| **Narrative** (drama, story arc) | N/A | No story mode in v1 — personality delivered through barks, not plot |
| **Submission** (relaxation, comfort zone) | N/A | Explicitly not a relaxing game — pace and pressure are core to the fantasy |

### Key Dynamics (Emergent player behaviors)
- Players will chain near-misses and overtakes deliberately to build the Rush
  Meter multiplier rather than just driving safely, once they understand the
  risk/reward tradeoff.
- Players will develop route memory for procedurally-assembled road segments
  (recognizing "this is a Market Road chunk, slow down") — mastery expressed
  as pattern-reading, not memorization of one fixed track.
- Players will experiment with which upgrade path (speed vs. handling vs.
  suspension) best compensates for their own playstyle weaknesses.

### Core Mechanics (Systems we build)
1. Swipe-based lane/lateral movement + boost/brake with a third-person arcade
   camera that reacts to speed and events
2. Risk/reward Rush Meter: near-misses, overtakes, and clean drifts raise a
   score multiplier; collisions reset it
3. Passenger pickup/delivery loop with a per-route timer, patience-driven
   passenger states, and money-based scoring
4. Modular/procedural road assembly across distinct road types (City,
   Market, Coastal, Old Town, Highway, Chaotic) so runs don't repeat exactly
5. Vehicle progression: currency-funded upgrades (engine, top speed, brakes,
   handling, suspension, capacity, durability) and class unlocks

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | Player chooses risk level (safe vs. aggressive driving), route line, when to boost | Core |
| **Competence** (mastery, skill growth) | Direct skill expression through swipe timing, near-miss threading, multiplier chains; visible improvement via score/leaderboard | Core |
| **Relatedness** (connection, belonging) | Conductor character as a running companion; passengers react to driving; leaderboard as light social comparison | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — How: vehicle unlocks, upgrade trees, daily challenges, high-score chasing
- [x] **Explorers** (discovery, understanding systems, finding secrets) — How: learning road-type patterns, shortcuts, customization options
- [ ] **Socializers** (relationships, cooperation, community) — Not a focus in v1 (no multiplayer, no social features beyond leaderboard)
- [x] **Killers/Competitors** (domination, PvP, leaderboards) — How: local/daily/weekly/all-time leaderboards, personal best chasing, Rush Meter multiplier competition

### Flow State Design

- **Onboarding curve**: Sub-60-second tutorial (swipe left → swipe right →
  avoid traffic → pick up passengers → get them there on time), then straight
  into a real run. Launch-to-driving in 10-15 seconds.
- **Difficulty scaling**: Road type mix shifts from City/Coastal (forgiving)
  toward Market/Old Town/Chaotic (precision-demanding) as routes and vehicle
  tiers progress; traffic density and pothole frequency scale with distance.
- **Feedback clarity**: Rush Meter multiplier is always on-screen; passenger
  reaction barks and conductor lines give immediate qualitative feedback on
  driving quality; end-of-run screen breaks score into clear components.
- **Recovery from failure**: Potholes/collisions degrade condition and reset
  the multiplier but don't end the run outright (0% condition ends it) —
  failure is a setback with time to recover, not an instant restart, except
  at total vehicle loss. Restart-to-driving is near-instant either way.

---

## Core Loop

### Moment-to-Moment (30 seconds)
Swipe to change lanes/dodge traffic and potholes, swipe up to boost through
gaps, swipe down to brake for pickup zones — reading the road a few car
lengths ahead and threading near-misses for multiplier gain.

### Short-Term (5-15 minutes)
One route: pick up passengers up to capacity, navigate 2-4 road-type
segments to the destination before the timer runs out, banking near-misses
and clean driving into a growing Rush Meter multiplier, then cashing out at
the destination.

### Session-Level (30-120 minutes)
Several consecutive routes (Career mode) or one long Endless Rush attempt,
interspersed with garage visits to spend earned currency on upgrades or a
new vehicle class, checking the daily challenge, and chasing a new personal
best before the next real-life interruption.

### Long-Term Progression
Currency and route performance unlock better matatu classes (Kiboko → Mzee
→ Shark → Coastal King → Boss) and fund upgrade trees (engine, speed,
brakes, handling, suspension, capacity, durability); cosmetic customization
expands separately and doesn't gate power. "Done" is a soft concept — the
loop is built to be replayed, not completed, with Endless Rush and daily
challenges as the long-tail hook.

### Retention Hooks
- **Curiosity**: New road-type combinations from procedural assembly, next
  vehicle class unlock, what today's daily challenge is
- **Investment**: Accumulated currency, upgrade progress, personal high
  scores and near-miss streaks
- **Social**: Leaderboard placement (daily/weekly/all-time), local
  high-score chasing
- **Mastery**: Multiplier chains, near-miss precision, clean full-route runs
  without a single pothole hit

---

## Game Pillars

### Pillar 1: Instant Fun, Instant Understanding
Playable within 10-15 seconds of launch; controls must read immediately
with no explanation needed.

*Design test*: If a feature adds friction before the first drive (forced
tutorial screens, mandatory account creation, long loading), we cut it or
move it later.

### Pillar 2: Fault Is Yours, Not the Game's
Traffic and hazards follow predictable rules with controlled randomness —
mistakes must feel earned, never like the game cheated.

*Design test*: If a collision or pothole hit feels unfair in playtesting, we
redesign the trigger/telegraph, not just tune the damage numbers.

### Pillar 3: Risk Feels Good
The Rush Meter rewards aggressive, skillful driving over cautious play.

*Design test*: When balancing safe vs. aggressive driving, the aggressive
path stays the higher-scoring option — safety is viable, but never optimal.

### Pillar 4: Authentically East African, Never a Costume
Matatu culture, Sheng/Swahili flavor, and the Mombasa-inspired world are
the game's identity, not decoration on a generic racer.

*Design test*: If a joke, character line, or asset would only land as a
stereotype to an outsider audience, it gets cut or sent back for cultural
review — not shipped on our own judgment alone.

### Pillar 5: One More Run
Sessions are short, restarts are near-instant, and there's always a next
small goal.

*Design test*: If getting from the results screen back into a new run takes
more than a couple of taps, we cut steps.

### Anti-Pillars (What This Game Is NOT)

- **NOT a driving simulator**: No realistic physics or simulation depth —
  it would compromise Pillar 1 and Pillar 3's arcade feel.
- **NOT open-world**: Roads are modular/procedural chunks assembled per
  route, not a free-roam explorable city — full open-world simulation is
  out of scope for a solo, first-time dev.
- **NOT pay-to-win**: No purchasable gameplay advantage, no loot boxes or
  gambling mechanics — would compromise trust and Pillar 3's fairness.
- **NOT multiplayer in v1**: No real-time multiplayer, no forced online
  account — would multiply scope far beyond MVP feasibility.
- **NOT story-heavy**: No branching narrative or cutscenes — personality
  comes from conductor/passenger barks, not plot, keeping Pillar 5 intact.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Crazy Taxi | Arcade driving feel, pickup/dropoff loop, time pressure | Grounded in specific Kenyan matatu culture rather than a generic US city; adds Rush Meter risk/reward layer | Validates that a "arcade taxi" loop can carry a full game on its own |
| Subway Surfers | Fast restart loop, cosmetic-only monetization, daily challenges | Full third-person driving control instead of auto-runner lane-switching; passenger/economy layer | Validates F2P mobile arcade retention mechanics at massive scale |
| Traffic Rider | Traffic-weaving-for-score core mechanic, mobile touch controls | Adds passenger delivery objective and a character-driven tone instead of pure endurance scoring | Validates that traffic-threading alone is a proven mobile core loop |

**Non-game inspirations**: Kenyan matatu culture itself — the vehicles'
loud livery and personality, conductor call-and-response, Sheng slang,
Mombasa's Old Town and coastal atmosphere. Framing intentionally avoids
"gritty realism" in favor of a colorful, exaggerated arcade interpretation
that celebrates rather than exoticizes the culture.

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 13-35 |
| **Gaming experience** | Casual to mid-core mobile players |
| **Time availability** | Short bursts — a few minutes waiting in line, commuting, or between tasks; longer weekend sessions for progression/upgrades |
| **Platform preference** | Android phones, low-to-high end |
| **Current games they play** | Subway Surfers, Crazy Taxi (mobile ports), Traffic Rider, other arcade endless/score-chase titles |
| **What they're looking for** | A fast, funny, replayable arcade fix with genuine cultural specificity — not another generic racer skin |
| **What would turn them away** | Aggressive forced-ad monetization, sluggish/unresponsive controls, a "costume" version of the culture that feels inauthentic or stereotyped |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4.6 (GDScript) — matches this project's pinned engine version; strong 2D/3D mobile export, no licensing cost pressure for a solo first-time dev, sufficient for stylized (not photorealistic) 3D |
| **Key Technical Challenges** | Low-end Android performance with stylized 3D + traffic AI + procedural road assembly simultaneously; tuning "easy to learn, hard to master" arcade driving feel; predictable-but-varied traffic AI; save data versioning for progression/customization |
| **Art Style** | 3D stylized — colorful, clean, slightly exaggerated, strong silhouettes |
| **Art Pipeline Complexity** | High — culturally specific vehicle/environment art (matatu liveries, Old Town architecture, coastal props) can't be asset-flipped from generic racing-game stores |
| **Audio Needs** | Moderate-to-heavy — engine/horn/collision/pothole SFX, passenger and conductor voice lines or speech-bubble barks, original East-African-influenced dynamic music |
| **Networking** | None required for MVP; local high scores only, architected so online leaderboards can be added later |
| **Content Volume (MVP)** | 1 map (Mombasa-inspired), 1 playable matatu, basic traffic set, potholes, passenger pickups — per MVP Definition below |
| **Procedural Systems** | Modular/procedurally-assembled road segments across 6 road types (City, Market, Coastal, Old Town, Highway, Chaotic) so repeated runs vary |

---

## Risks and Open Questions

### Design Risks
- Arcade driving "feel" (responsive, satisfying, easy-to-learn-hard-to-master)
  is notoriously hard to hit and can't be fully validated on paper — must be
  prototyped and playtested before committing to systems beyond it.
- Rush Meter risk/reward balance could collapse into either "always play
  safe" or "multiplier trivially maxed" if near-miss/collision thresholds
  aren't tuned carefully.

### Technical Risks
- Stylized 3D + traffic AI + procedural roads simultaneously on low-end
  Android hardware is a real performance budget risk, not a cosmetic one —
  needs early profiling, not late-stage optimization.
- Procedural road assembly quality (does it feel varied vs. janky/repetitive)
  is unproven until built.

### Market Risks
- Arcade driving is a proven mobile genre, but competes for attention
  against extremely well-funded incumbents (Subway Surfers, etc.) — cultural
  specificity is the differentiator, and its market pull outside East Africa
  is untested.

### Scope Risks
- The full 39-section vision (all game modes, full Mombasa world, full
  vehicle roster, customization, leaderboards, daily challenges) is large
  for a solo first-time developer on a 1-2 year timeline — MVP discipline
  (see below) is the primary mitigation.
- Content volume (multiple road types, vehicle classes, passenger barks) can
  quietly expand past capacity if built before the core loop is validated
  fun.

### Open Questions
- Is Sheng/Swahili dialogue authentic and non-stereotyped as written, or
  does it need review/rewrite by a native-fluency reviewer before ship?
  Resolve via cultural review pass once conductor/passenger bark scripts
  exist, not by the author's own judgment alone.
- Does the core swipe-driving loop hold up as fun in isolation before any
  passengers, scoring, or progression are added? Resolve via `/prototype`
  before any GDDs are written.
- What's the actual low-end Android performance ceiling for this art
  direction? Resolve via an early technical-artist/performance-analyst
  profiling pass during prototyping, not after content is built.

---

## MVP Definition

**Core hypothesis**: Swiping to dodge traffic/potholes while racing a timer
to deliver passengers is fun in short, replayable sessions on mobile,
independent of progression, customization, or content breadth.

**Required for MVP**:
1. One Mombasa-inspired map with basic traffic and potholes
2. One playable matatu with swipe controls (left/right/boost/brake),
   collision/damage state, and boost
3. Passenger pickup zones, a per-route timer, scoring, and money
4. Game over / restart loop, basic upgrades, and local save

**Explicitly NOT in MVP** (defer to later):
- Multiple road types beyond a basic set, full road-type variety
- Full vehicle roster/unlock system, matatu customization
- Conductor character barks/voice lines, passenger reaction states
- Rush Meter multiplier system, daily challenges, leaderboard, Endless Rush
  mode, monetization (ads/cosmetic purchases)

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 1 map, 1 vehicle, basic traffic/potholes | Core drive-pickup-deliver loop, timer, score, money, boost, collision, restart, basic upgrades, local save | 2-3 months |
| **Vertical Slice** | 1 fully polished Mombasa map (Old Town + Coastal road types) | Core + Rush Meter, conductor barks, passenger reactions, upgrade tree | 4-6 months |
| **Alpha** | All 6 road types, full vehicle roster (rough art) | All Phase 1-6 systems from source spec, daily challenge, local leaderboard | 9-14 months |
| **Full Vision** | Complete polished content, store-ready | All features polished, monetization live, performance-optimized for low-end Android, release-prepped | 12-24 months |

---

## Visual Identity Anchor

**Direction**: *Coastal Arcade Realism* — stylized 3D that reads instantly
as East African without chasing photorealism.

**One-line visual rule**: Every surface reads at a glance from a moving
camera — bold silhouettes and saturated coastal color first, texture detail
second.

**Supporting principles**:
1. **Warm coastal palette over generic asphalt-gray** — terracotta, ocean
   blue, palm green, market-stall color pops dominate over the neutral grays
   typical of Western racing games. *Design test*: if an environment piece
   could be dropped into a generic city racer unchanged, redesign its color
   and silhouette.
2. **Silhouette-first vehicle and prop design** — matatus, tuk-tuks, and
   market stalls must be identifiable by outline alone at speed. *Design
   test*: if two vehicle types are only distinguishable by texture, not
   shape, redesign one.
3. **Exaggeration over accuracy** — Old Town architecture, market density,
   and matatu livery are stylized/heightened, not a literal Mombasa
   reconstruction. *Design test*: if an asset is being built for geographic
   accuracy rather than readability or character, it's out of scope.

**Color philosophy**: Coastal-inspired saturation (ocean blues, terracotta
and sand, palm greens, market color bursts) against clean, uncluttered road
surfaces — color signals gameplay information (lanes, hazards, pickup
zones) first, atmosphere second.

*(Note: AD-CONCEPT-VISUAL director review was skipped per Lean review
mode — this anchor was authored directly from the source concept and
should get a full art-director pass during `/art-bible`.)*

---

## Next Steps

- [x] CD-PILLARS skipped — Lean mode
- [x] AD-CONCEPT-VISUAL skipped — Lean mode
- [x] TD-FEASIBILITY skipped — Lean mode
- [x] PR-SCOPE skipped — Lean mode
- [ ] Fill in CLAUDE.md technology stack based on engine choice (`/setup-engine` — Godot 4.6 / GDScript, already specified)
- [ ] **Prototype core idea** (`/prototype swipe-driving-loop`) — validate the core swipe/dodge/boost loop is fun before writing any GDDs
- [ ] If prototype PROCEEDS: create visual identity spec (`/art-bible`), then decompose concept into systems (`/map-systems`)
- [ ] Design each system (`/design-system [system-name]`) — use prototype learnings in Tuning Knobs and Formulas sections
- [ ] Build vertical slice in Pre-Production (`/vertical-slice`) — validate full game loop before committing to Production
- [ ] Validate core loop with playtest (`/playtest-report`)
- [ ] Plan first milestone (`/sprint-plan new`)
