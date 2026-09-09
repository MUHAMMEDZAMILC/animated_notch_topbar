# Destinations API — Response Contract

This document describes the `destinations` response the app consumes to
dynamically configure `AnimatedNotchTopBar`'s tabs, theme, and page
backgrounds. It matches `lib/destinations.dart` and `lib/main.dart` exactly.

## Sample response

```json
{
  "destinations": [
    {
      "_id": "6a9e7663e0e9afe8f60a8044",
      "key": "home",
      "unselectedImage": "assets/coffee_cover.png",
      "selectedImage": "assets/coffee_selected.png",
      "isComingSoon": false,
      "label": "Home",
      "order": 0,
      "posterUrl": null,
      "tabBackground": {
        "type": "solid",
        "colors": ["#6f44dc"],
        "angle": 180,
        "image": null,
        "mediaType": "image"
      },
      "tabRowBackground": {
        "type": "solid",
        "colors": ["#c28fff"],
        "angle": 180,
        "image": null,
        "mediaType": "image"
      },
      "pageBackground": {
        "type": "gradient",
        "colors": ["#EFF8E6", "#DDEFCB"],
        "angle": 180,
        "image": null,
        "mediaType": "image"
      }
    },
    {
      "_id": "6a9e7663e0e9afe8f60a8045",
      "key": "super_mall",
      "unselectedImage": "assets/mall_cover.png",
      "selectedImage": "assets/mall_selected.png",
      "isComingSoon": false,
      "label": "Super Mall",
      "order": 1,
      "posterUrl": null,
      "tabBackground": { "type": "solid", "colors": ["#FFFFFF"], "angle": 180, "image": null, "mediaType": "image" },
      "tabRowBackground": { "type": "solid", "colors": ["#FFE8C6"], "angle": 180, "image": null, "mediaType": "image" },
      "pageBackground": { "type": "solid", "colors": ["#F1FBF2"], "angle": 180, "image": null, "mediaType": "image" }
    },
    {
      "_id": "6a9e7663e0e9afe8f60a8046",
      "key": "off_zone",
      "unselectedImage": "assets/offers_cover.png",
      "selectedImage": "assets/offers_selected.png",
      "isComingSoon": true,
      "label": "%Off Zone",
      "order": 2,
      "posterUrl": "https://cdn.example.com/posters/off-zone.jpg",
      "tabBackground": { "type": "solid", "colors": ["#FFFFFF"], "angle": 180, "image": null, "mediaType": "image" },
      "tabRowBackground": {
        "type": "image",
        "colors": ["#EAF4D8"],
        "angle": 180,
        "image": "https://cdn.example.com/backgrounds/off-zone-bar.jpg",
        "mediaType": "image"
      },
      "pageBackground": { "type": "gradient", "colors": ["#FFFDF6", "#FBF6E4"], "angle": 180, "image": null, "mediaType": "image" }
    },
    {
      "_id": "6a9e7663e0e9afe8f60a8047",
      "key": "make_a_print",
      "unselectedImage": "assets/print_cover.png",
      "selectedImage": "assets/print_selected.png",
      "isComingSoon": true,
      "label": "Make a Print",
      "order": 3,
      "posterUrl": "https://cdn.example.com/posters/make-a-print.jpg",
      "tabBackground": { "type": "solid", "colors": ["#FFFFFF"], "angle": 180, "image": null, "mediaType": "image" },
      "tabRowBackground": { "type": "solid", "colors": ["#FFFFFF"], "angle": 180, "image": null, "mediaType": "image" },
      "pageBackground": {
        "type": "image",
        "colors": ["#FDF6EA"],
        "angle": 180,
        "image": "https://cdn.example.com/backgrounds/print-page.jpg",
        "mediaType": "image"
      }
    }
  ]
}
```

## Key information

### Top level

| Key | Type | Required | Indicates |
|---|---|---|---|
| `destinations` | array | yes | The tabs. Client sorts by `order` before use — array position doesn't matter. Client currently asserts exactly 4 entries (`validateFourTabs: true`). |

### Per-destination

| Key | Type | Required | Indicates in UI |
|---|---|---|---|
| `_id` | string | yes | Identity only. Not rendered. |
| `key` | string | yes | Which body page/content this tab shows. Client-side routing key — **must stay stable** once shipped; renaming it breaks the mapping silently. Currently must be one of: `home`, `super_mall`, `off_zone`, `make_a_print`. |
| `unselectedImage` | string / `null` | no | Tab's icon while inactive (asset path or URL). |
| `selectedImage` | string / `null` | no | Tab's icon while active. If only one of `unselectedImage`/`selectedImage` is sent, the set one is reused for both states, so the icon never disappears when tapped. If **both** are null/empty, the tab renders `label` as text instead — icon and text are mutually exclusive, never mixed. |
| `isComingSoon` | bool | yes | `true` → tab renders dimmed (~45% opacity), can't be selected, shows a "Coming soon" caption under the label, and tapping it opens `posterUrl` in a bottom sheet instead of switching pages. `false` → normal, fully interactive tab. |
| `label` | string | yes | Tab's visible text (only shown if no icon images are set) and always the title in the "`label` is coming soon!" bottom sheet message. |
| `order` | int | yes | Sort key for left-to-right tab position. Doesn't need to be contiguous. |
| `posterUrl` | string / `null` | no | Image shown full-width in the bottom sheet opened by tapping a coming-soon tab. `null` → a placeholder hourglass icon is shown instead. Only meaningful when `isComingSoon: true`. |
| `tabBackground` | [background object](#background-object) | yes | Fill color of the selected tab's pill/notch — the small highlight shape behind the active tab's icon/label. |
| `tabRowBackground` | [background object](#background-object) | yes | The whole top app bar background — behind the greeting text, location, and the full row of tab pills. |
| `pageBackground` | [background object](#background-object) | yes (falls back to `tabRowBackground` if omitted, for back-compat) | Background of the scrollable page content below the bar for this tab. Independent of `tabRowBackground` — they don't have to match. |

### Background object

Shared shape used by `tabBackground`, `tabRowBackground`, and `pageBackground`.

| Key | Type | Notes |
|---|---|---|
| `type` | `"solid"` \| `"gradient"` \| `"image"` | Authoritative switch — decides which of the fields below are actually used. |
| `colors` | array of `"#RRGGBB"` / `"#AARRGGBB"` | `"solid"`: only `colors[0]` is used. `"gradient"`: all entries used as stops in order (needs ≥2 to visually be a gradient). `"image"`: unused today by rendering, but send a representative color anyway as a forward-compatible fallback. |
| `angle` | number (degrees, CSS convention) | Gradient direction only. `180` = top → bottom (the only value used in the sample above). `0` = bottom → top, `90` = left → right, `270` = right → left. Ignored for `"solid"`/`"image"`. |
| `image` | string / `null` | Asset path or URL. Used only when `type: "image"`. |
| `mediaType` | `"image"` \| `"gif"` | Must be `"image"` or `"gif"` when `type: "image"`. Both render identically — `image`'s value is loaded via `Image.network`/`Image.asset`, which decode and animate multi-frame GIFs automatically, so no special-casing is needed for `"gif"` beyond sending it. Reserved for future media kinds (e.g. video) — anything else is currently ignored client-side. |

### Resolution rule per `type`

| `type` | What's actually rendered |
|---|---|
| `"solid"` | Flat color from `colors[0]`. |
| `"gradient"` | Linear gradient through all of `colors`, direction from `angle`. |
| `"image"` | The image at `image` (static or animated GIF), requires `mediaType: "image"` or `"gif"` too. |

## Notes for backend

1. **`key` stability** — renaming a `key` breaks the client's body-content mapping silently (falls back to a blank page). Treat it as a stable identifier, not a display string.
2. **Only one icon pair per destination** — there's no separate hover/pressed state, just selected vs. unselected.
3. **`mediaType: "video"` isn't wired up client-side yet** — don't send it expecting it to render.
4. **`pageBackground` is optional only for backward compatibility** — new payloads should always send it explicitly rather than relying on the `tabRowBackground` fallback.
