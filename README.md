# Palette-iOS

Palette chooses black or white foreground text for a UIKit background. It samples the background at a foreground view's top-left point and selects the greater WCAG contrast ratio. It is a contrast utility, not an image palette extractor.

## Requirements

- iOS 15 or later.
- Swift 6 language mode. The package manifest requires Swift tools 6.0 or later.
- Development and validation target Xcode 27 / Swift 6.4, with Xcode 26.6 / Swift 6.3.3 compatibility.
- UIKit APIs run on `@MainActor`; call them on the main thread from Objective-C.
- No third-party dependencies.
- The test runner requires an iOS 17 or later simulator; the library and example apps retain iOS 15 deployment targets.

## Installation

### Swift Package Manager (recommended)

Add `https://github.com/Charlisim/Palette-iOS` in Xcode's **Add Package Dependencies**, then link the `Palette` product. Until the modernization branch is merged and a 2.0.0 tag is published, use the `modernize/swift-6-2026` branch if available, or add this checkout as a local package. Existing tags contain the previous implementation.

### CocoaPods

For this checkout:

```ruby
pod 'Palette', :path => '../Palette-iOS'
```

The updated podspec prepares version 2.0.0. It is not a published CocoaPods release, and its remote source tag must be created before distribution.

## UIKit

Call after layout, for example in `viewDidLayoutSubviews`. The foreground must be a descendant of the sampled background.

```swift
import Palette

let palette = Palette(background: view, forView: label)
do {
    label.textColor = try palette.contrastingColor()
} catch {
    label.textColor = .label
}
```

The class convenience API is `try Palette.contrastingColor(background: view, for: label)`.

Sampling converts the foreground's local bounds origin into background coordinates, excludes that foreground from the snapshot, and restores its visibility on success or failure. Other background subviews remain part of the sample. Recalculate after layout, background content, or appearance changes; results are not cached. Sampled transparency is composited over the background view's resolved system background color.

### A known background color

Use this API to avoid view rendering when the background color is already known:

```swift
let textColor = try Palette.contrastingColor(
    for: .systemBackground,
    compositedOver: .white,
    traits: view.traitCollection
)
```

Dynamic colors resolve against the supplied traits. Grayscale and Display P3 colors convert to sRGB; extended channels are clamped to the sRGB range. Transparent colors are composited over `compositedOver`, which defaults to `.systemBackground`. A translucent base color is flattened over white. Pattern colors throw `PaletteError.unsupportedColor`.

### Sampling pixels

```swift
let sampled = try view.color(at: CGPoint(x: 20, y: 30))
```

The point is in the view's local bounds coordinates. The sampler reads a one-point footprint centered on it, with unpremultiplied RGBA values. Non-finite points, empty bounds, and points outside bounds throw `PaletteError.invalidPoint`; context creation failure throws `.renderingFailed`. Invalid view relationships throw `.unrelatedViews`.

## SwiftUI

For a known solid background, bridge the color without snapshotting a SwiftUI hierarchy:

```swift
import SwiftUI
import Palette

struct ContrastLabel: View {
    @Environment(\.colorScheme) private var colorScheme
    let background: Color

    var body: some View {
        let traits = UITraitCollection(
            userInterfaceStyle: colorScheme == .dark ? .dark : .light
        )
        let foreground = (try? Palette.contrastingColor(
            for: UIColor(background), traits: traits
        )) ?? .label
        Text("Readable text")
            .foregroundStyle(Color(uiColor: foreground))
            .padding()
            .background(background)
    }
}
```

## Objective-C and existing Swift callers

Existing selectors and Swift method signatures remain available:

```objc
@import Palette;

Palette *palette = [[Palette alloc] initWithBackground:self.view forView:label];
label.textColor = [palette getContrastingColor];
label.textColor = [Palette getContrastingColor:self.view forView:label];

NSError *error = nil;
UIColor *color = [palette contrastingColorWithError:&error];
label.textColor = color ?: [UIColor labelColor];
```

```swift
label.textColor = Palette.getContrastingColor(background: view, forView: label)
let sampled = view.getPixelColorAtPoint(point: point)
```

The compatibility contrast methods return the background's resolved `.label` color when sampling fails. The compatibility pixel method returns `.clear` on failure. Prefer the throwing APIs when failure needs to be distinguished from a valid sample.

## Migration from 1.x

This is a major-version update:

- Minimum iOS support moves from the inconsistent iOS 8/10/11 settings to iOS 15.
- Swift calls touching UIKit require main actor isolation; Objective-C callers must enforce main-thread access themselves.
- Contrast uses linearized sRGB relative luminance instead of the old weighted brightness threshold. Red now chooses black. This intentional visual change also applies to the existing methods.
- Sampling fixes uninitialized pixels, premultiplied alpha, nested/transformed coordinates, and nonzero bounds origins. The foreground no longer contaminates its own background sample.
- Foreground/background pairs must belong to the same descendant hierarchy. Detached foregrounds use the documented compatibility fallback or throw in the new API.
- Example applications use the scene lifecycle and calculate contrast after layout. Both Swift and Objective-C examples remain available.

For an opaque solid sRGB background, selecting the better of black and white produces at least 4.5:1 mathematical contrast. A single sample does not establish accessibility across gradients, photographs, text edges, materials, or a whole screen. See [WCAG contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).

## Verification

```sh
./scripts/verify.sh
```

The script runs Swift Testing through SPM and the Xcode application host, builds the Objective-C example, and builds the Release framework for physical iOS devices without distribution signing. It uses a temporary package workspace because running `xcodebuild` directly here selects the existing Xcode project. Plain `swift test` on macOS cannot run this UIKit-only package.

To select a toolchain or simulator explicitly:

```sh
DEVELOPER_DIR=/Applications/Xcode27.app/Contents/Developer \
PALETTE_DESTINATION='platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' \
PALETTE_RESULTS_DIR=/tmp/palette-results \
./scripts/verify.sh
```

Choose an empty results directory for each run. GitHub Actions runs the same verification script on macOS 26 with Xcode 26.6. Hosted CI execution is separate from local validation.

Tests cover primary colors, grayscale, Display P3, extended RGB, dynamic colors, alpha composition, nested/transformed views, nonzero bounds origins, foreground exclusion and restoration, invalid inputs, and compatibility entry points.

`CALayer.render(in:)` samples the model layer tree. It cannot reliably capture Metal, video, live visual-effect materials, or presentation-layer animations. Sampling and rendering are synchronous; keep calls out of per-frame hot loops and prefer the color-only API where possible.

## License

MIT. See [LICENSE](LICENSE).
