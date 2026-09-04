# Prototype: swipe-driving-loop

**Question**: Does swipe-based lane dodging + boost/brake feel responsive and
satisfying, in isolation, before any passengers/scoring/art are added?

**Status**: PROTOTYPE — throwaway code, not production. Do not import into
`src/`.

## How to run

1. Open Godot **4.6**.
2. "Import" this folder (`prototypes/swipe-driving-loop-concept/`) as a
   project, or open `project.godot` directly.
3. Press Play (F5). A portrait window opens.
4. Controls (mouse emulates touch on desktop — this is a real setting in
   `project.godot`, not a placeholder):
   - **Click + drag left/right, then release** → change lane
   - **Click + drag up, then release** → boost
   - **Click + drag down, then release** → brake
   - **Click after a crash** → restart
5. Play several runs. Try to react to obstacles as they appear, not from
   memory.

## What to pay attention to

- Does a lane-change swipe register and resolve *immediately*, or does it
  feel like there's a delay between your swipe and the car actually moving?
- Does the car's motion between lanes feel snappy, or floaty/sluggish?
- Can you reliably react to an obstacle appearing in your lane, or do you
  feel like you need to see it coming from further away than the game gives
  you?
- Does boost/brake register instantly on swipe, or is there a noticeable
  lag?

## Known tuning knob

`LANE_LERP_RATE` in `scripts/main.gd` controls how fast the car snaps to the
target lane. This is the single biggest lever on "input delay" feel — if
lane changes feel floaty, that's the first thing to try raising (more
instant) or lowering (more of an arcade "weighty" slide) before concluding
the whole approach doesn't work.

## What's intentionally missing

Passengers, scoring, money, upgrades, multiple road types, real art/audio,
menus, damage states beyond binary hit/reset, the Mombasa environment, the
conductor character. This prototype tests one thing only: does swiping to
dodge feel good.
