# Implementation Plan — Wiring `animated_notch_topbar` into an Existing Project

Target: a project that already has its own API service fetching `GET
/destinations` (full image URLs already resolved server-side) and needs to
render the response with [`animated_notch_topbar`](https://pub.dev/packages/animated_notch_topbar),
using `CachedNetworkImage` instead of the package's built-in `Image.network`.

## 1. Dependencies

```yaml
dependencies:
  animated_notch_topbar: ^0.0.1
  cached_network_image: ^3.4.1   # likely already present
```

## 2. Why the "widget" fields, not the "url" fields

`TopBarTab` and `TopBarTheme` accept two ways to show an image:

- `unselectedImage` / `selectedImage` (`String`) and `backgroundImageUrl`
  (`String`) — the package renders these itself with plain `Image.network`
  (`lib/src/top_bar.dart`), **no caching**.
- `unselectedWidget` / `selectedWidget` (`Widget`) and `backgroundImage`
  (`DecorationImage`) — you supply the widget/image provider yourself, which
  is the escape hatch for caching.

**Rule: always populate the widget/`DecorationImage` fields, never the
string-URL fields, when you want caching.**

## 3. Data models

Mirror `example/lib/destinations.dart`'s shape (`TabBackground` +
`Destination`) since the `/destinations` response matches it field-for-field:

- `TabBackground` — parses `{type, colors, angle, image, mediaType}`
  (`solid` / `gradient` / `image`), exposes `toGradient()` and `solidColor`.
- `Destination` — parses `_id`, `key`, `label`, `order`, `isComingSoon`,
  `unselectedImage`, `selectedImage`, `tabBackground`, `tabRowBackground`,
  `pageBackground`, `posterUrl`.

Point your existing API service's response parsing through
`Destination.listFromJson(json)` (sorted by `order`) instead of writing a new
networking layer — only the *parsing* and *mapping* are new.

> Note: in the current API sample, `posterUrl` is `null` even for the
> `isComingSoon: true` entry ("make_a_print") — see the fallback in step 6.

## 4. Mapping function — `destinationToTab`

```dart
TopBarTab destinationToTab(Destination d) {
  final row = d.tabRowBackground;
  final unselectedUrl = d.unselectedImage ?? d.selectedImage;
  final selectedUrl = d.selectedImage ?? d.unselectedImage;

  final theme = TopBarTheme(
    gradient: row.isGradient ? row.colors : null,
    backgroundColor: !row.isGradient && !row.hasImage ? row.solidColor : null,
    backgroundImage: row.hasImage
        ? DecorationImage(
            image: CachedNetworkImageProvider(row.image!),
            fit: BoxFit.cover,
          )
        : null,
    useDarkForeground: _isLight(row.solidColor),
  );

  return TopBarTab(
    label: d.label,
    sub: d.isComingSoon ? 'Coming soon' : null,
    theme: theme,
    selectedColor: d.tabBackground.solidColor,
    enabled: !d.isComingSoon,
    unselectedWidget: unselectedUrl == null
        ? null
        : ClipRRect(
            borderRadius: BorderRadius.circular(9.62),
            child: CachedNetworkImage(
              imageUrl: unselectedUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.image, color: Colors.grey),
            ),
          ),
    selectedWidget: selectedUrl == null
        ? null
        : CachedNetworkImage(
            imageUrl: selectedUrl,
            fit: BoxFit.contain,
            height: 46.92 * 0.65, // matches tabHeight * 0.65 used internally
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.image, color: Colors.grey),
          ),
  );
}

bool _isLight(Color color) => color.computeLuminance() > 0.6;
```

Key differences from the package's own example app:

- `backgroundImage` (`DecorationImage` + `CachedNetworkImageProvider`)
  instead of `backgroundImageUrl` (raw string).
- `unselectedWidget` / `selectedWidget` (`CachedNetworkImage`) instead of
  `unselectedImage` / `selectedImage` (raw string).

## 5. Wiring the bar

```dart
final tabs = destinations.map(destinationToTab).toList();

AnimatedNotchTopBar(
  greetingName: user.name,
  locationLabel: user.location,
  tabs: tabs,
  validateFourTabs: tabs.length == 4, // drop if tab count varies
  onTabChanged: (i) => setState(() => _index = i),
  onDisabledTabTap: _showComingSoonPoster,
)
```

Place this **inside** a widget that is a descendant of your `MaterialApp`
(not in the same `State` that builds `MaterialApp` itself) — the
coming-soon bottom sheet in step 6 needs a `BuildContext` under
`MaterialApp`'s `Navigator`/`MaterialLocalizations`, or it crashes with a
"No MaterialLocalizations found" assertion.

## 6. Coming-soon bottom sheet, with `posterUrl` fallback

Fall back to the tab's own image when `posterUrl` is `null`, so the sheet
never shows just a bare icon:

```dart
void _showComingSoonPoster(int index) {
  final d = destinations[index];
  final posterUrl = d.posterUrl ?? d.selectedImage ?? d.unselectedImage;

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (posterUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover),
            )
          else
            const Icon(Icons.hourglass_top_rounded, size: 48),
          const SizedBox(height: 16),
          Text(
            '${d.label} is coming soon!',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: your navigation — details/waitlist page for `d`.
              },
              child: const Text('Learn more'),
            ),
          ),
        ],
      ),
    ),
  );
}
```

## 7. Edge cases

- **Empty `destinations` list** — don't render `AnimatedNotchTopBar` (it
  asserts `tabs.length > 0`); show a loading/empty state instead.
- **`validateFourTabs`** — only pass `true` if your API always returns
  exactly 4 destinations; otherwise omit it (defaults to `false`).
- **Missing `tabBackground` / `tabRowBackground`** — the sample response
  always includes them, but if your service can omit them, add null-safe
  defaults in `TabBackground.fromJson`.
- **Both `selectedImage`/`unselectedImage` null** — `destinationToTab`
  leaves both widget fields `null`, and the package automatically falls
  back to rendering `label` as text — no extra work needed.

## 8. Testing checklist

- [ ] Tap each enabled tab → notch slides, bar gradient/background
      transitions.
- [ ] Tap the `isComingSoon` tab → bottom sheet opens with poster (or
      fallback image) + "Learn more" button, no `MaterialLocalizations`
      crash.
- [ ] Kill network mid-load → `errorWidget`/`placeholder` show instead of a
      broken-image flash.
- [ ] Re-open the same tab twice → `CachedNetworkImage` doesn't re-fetch
      (verify via network inspector).
