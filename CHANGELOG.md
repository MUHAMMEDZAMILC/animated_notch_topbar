## 0.0.9

- Fix a dark/near-black flash on unselected tabs: the card's box-shadow
  (`Color(0x14000000)`) popped in/out abruptly instead of animating, and
  the tab background color animated toward `Colors.transparent` — whose
  RGB is black — causing `Color.lerp` to pass through a translucent
  near-black tint mid-transition. Box-shadow removed; the color now
  fades to the same color at zero alpha instead.
- Add `disabledOpacity` for controlling how dimmed a disabled ("coming
  soon") tab renders:
  - `AnimatedNotchTopBar.disabledOpacity` (`double`, default `0.45`) —
    bar-wide default.
  - `TopBarTab.disabledOpacity` (`double?`) — per-tab override, e.g.
    pass `1` to keep one coming-soon destination at full opacity while
    others stay dimmed.
- Example app: `Destination.comingSoonOpacity` (from the API's new
  `comingSoonOpacity` field) now maps onto `TopBarTab.disabledOpacity`.

## 0.0.8

- Add gradient support for the notch/active-tab-pill fill:
  - `TopBarTab.selectedGradient` (`List<Color>?`) — takes precedence
    over `selectedColor` when set with 2+ colors.
  - `AnimatedNotchTopBar.selectedWidgetGradient` (`List<Color>?`) — the
    widget-level override counterpart to `selectedWidgetColor`.
  - `NotchPainter` paints with a top-to-bottom gradient shader when one
    is provided, falling back to a solid color otherwise.
- Example app: `destinationToTab` now maps a `tabBackground.type:
  "gradient"` destination onto `selectedGradient` instead of silently
  collapsing it to its first color.

## 0.0.7

- README: screenshots still didn't render with relative Markdown image
  paths — pub.dev's sanitizer only allows `<img>` with an absolute
  `src` and falls back to plain `[alt text]` otherwise (it doesn't
  rewrite image paths against the `repository` field the way it does
  for links). Switched to absolute `raw.githubusercontent.com` URLs.
  Also: the GitHub repository was private, which alone would have
  made any external image link 404 — it's now public.

## 0.0.6

- README: fix screenshots not rendering on pub.dev — raw `<img>` HTML
  tags with relative `src` get stripped by pub.dev's README sanitizer.
  Switched to Markdown image syntax (`![alt](path)`), which pub.dev
  rewrites against the `repository` field instead.

## 0.0.5

- README: add real app screenshots (Home tab, Super Mall tab, coming-soon
  bottom sheet) and author contact links (LinkedIn, GitHub).

## 0.0.4

- Location label now renders with proper `Icons.location_on` /
  `Icons.arrow_drop_down` icons instead of emoji characters.
- Tab `InkWell` also disables `hoverColor`/`focusColor`, closing the last
  gap where a lingering highlight could still show (web/desktop or
  trackpad input).
- README: richer feature list, author/contact section (LinkedIn, GitHub),
  and a placeholder slot for a demo GIF.

## 0.0.3

- Example app: remove press overlay/ripple from the "Learn more" button
  in the coming-soon bottom sheet, matching the tabs' ripple-free feel.
  No changes to the published library code.

## 0.0.2

- Remove the tap ripple/highlight effect on tab selection (`InkWell` now
  uses `NoSplash.splashFactory` with transparent splash/highlight colors).

## 0.0.1

- Initial release: `AnimatedNotchTopBar` with data-driven tabs,
  per-tab gradient themes, animated sliding notch indicator, optional
  greeting/location/bell header row, and optional search field.
