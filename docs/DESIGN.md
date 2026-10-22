# Taap Taap: design and playtest notes

## Intent

See a light → react → receive immediate feedback → build a streak → catch a boost → try to beat your last run. The board is the main visual object. Menus introduce that same board so the first game is understandable without a tutorial wall.

## Design skills consulted

Read and applied during this implementation:

- [Anthropic Frontend Design](https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md): intentional identity, typography, compact design tokens, restrained motion, visual critique. Its visual principles are adapted to native SwiftUI rather than its web implementation details.
- [Game Design Principles](https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/game-development/game-design/SKILL.md): action/feedback/reward loop, early wins, gradually increasing difficulty, optional modes, and iterative playtesting.
- [Game Art Principles](https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/game-development/game-art/SKILL.md): cohesive style, value contrast, recognizable silhouettes, consistent scaling, and artwork that supports play.

These are design references, not installed runtime dependencies. No third-party artwork or licensed characters are bundled.

## Art direction

| Token | Studio (default) | Sakura | Cyber |
| --- | --- | --- | --- |
| Background | `#EEF2F8` | `#FFF0F4` | `#080C20` |
| Surface | `#FFFFFF` | `#FFFAF6` | `#12182E` |
| Text | `#162440` | `#32233E` | `#EDF8FF` |
| Accent | `#225DE5` | `#B82664` | `#67F8ED` |
| Secondary | `#73A6F9` | `#FA9CB8` | `#F15BDE` |
| Bright tile | `#68C8FF` | `#FF9CBD` | `#67F8ED` |
| Type | SF Rounded | SF Rounded, heavy display | SF Monospaced |
| Geometry | Soft, rounded | Ink outlines, petal curves | Clipped-feeling tight corners |
| Illustration | Layered square mark | Sunburst and petals | Skyline and perspective grid |

Studio deliberately stays calm and conventional as the default. Sakura uses original manga-inspired shapes rather than borrowed characters. Cyber embraces the requested neon/retro vocabulary. Theme differences include backdrop, illustration, type, geometry, border weight, effects, and color—not only an accent-color swap.

Layout: portrait uses score → timer → board → feedback. Wide windows place the board left and stats/boost help right. The home screen pairs a board preview with a player/mode panel, stacking them on narrow windows. The board has four columns and six rows (24 square cells). Short landscape windows use six columns and four rows, keeping the same 24 targets and moving feedback beside the board. Short windows can scroll rather than crop controls.

## Rules and pacing

- Initial window: 5 seconds; next window = max(floor, previous × 0.95).
- At roughly 10, 25, and 45 bounces: 3.0s, 1.39s, and 0.50s.
- Classic/Rush floor: 0.45s; Zen floor: 1.0s.
- Score per hit: `(100 + round(50 × remainingFraction)) × combo`.
- Combo: `min(8, 1 + streak / 5)`; shield preserves it for one mistake.
- Boost cadence: after every eight hits, one target offers a pickup. Classic selects life/slow/shield equally; Rush and Zen select slow/shield equally. No purchases, rarity tiers, or hidden currencies.
- Slow motion consumes five real seconds, including across target changes. Pausing freezes both the effect and run timer. A second pickup refreshes the duration to five seconds.
- An input at or after expiration cannot score the expired target or the replacement target in the same event.
- All timing is driven from a monotonic app clock. Core event integration handles delayed frames consistently.

The curve is a starting point for device playtests, not a claim of measured optimal difficulty. Five seconds gives a novice room to discover the interaction. Skilled players immediately advance by tapping, so they need not wait. Zen provides a gentler floor. Shields and slowdowns give short recovery opportunities.

## Accessibility and controls

Active tiles use a scope or collectible symbol, high-value fill, perimeter timer, and border. Every tile has a row/column/state label and is a real button. The keyboard uses 24 unique keys, in board order: 1234, QWER, ASDF, ZXCV, 5678, TYUI. Space pauses and resumes. Decorative art is excluded from accessibility. Reduce Motion disables transient hit animation. Text labels use system styles except display headlines and compact key hints.

## Release playtest checklist

- iPhone small/large: portrait and both landscapes; no cropped navigation or unreadable cells.
- iPad: portrait, landscape, split view, Stage Manager, touch and hardware keyboard.
- macOS: mouse, keyboard, resize to minimum size, lose/restore app focus, close/reopen.
- All themes: bright target instantly recognizable; collectibles distinguishable at speed; text contrast and readable timers.
- Dynamic Type: large accessibility sizes; scrolling reaches every control; color picker fits.
- VoiceOver: useful tile labels, sensible focus after pause/results. Zen is the recommended starting mode; timed play is intrinsically demanding with spoken navigation.
- Reduce Motion: no hit pop effect; game timers continue normally.
- Timing: a late tap loses exactly one due target; slow effect lasts five unpaused seconds; Rush ends at 60; no background penalties.
- Persistence: old profiles/entries survive upgrade; mode filters and replay game counts are correct.
- Frame pacing: test on physical 60Hz and 120Hz devices; inspect energy use with Instruments. The UI updates at 30Hz, while rule deadlines use elapsed time rather than counting frames.

Simulator tests and screenshots are useful evidence; they do not replace real-device haptic, performance, or accessibility review.
