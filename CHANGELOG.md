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
