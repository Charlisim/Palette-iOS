//The MIT License (MIT)
//
//Copyright (c) 2015 Carlos Simón
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import UIKit

/// Errors produced when a background cannot be sampled or converted to sRGB.
public enum PaletteError: Error, Sendable, Equatable {
  case invalidPoint
  case renderingFailed
  case unsupportedColor
  case unrelatedViews
}

/// Chooses opaque black or white text for a sampled UIKit background.
/// All view access and rendering run on the main actor.
@MainActor
@objc(Palette)
public final class Palette: NSObject {
  private let background: UIView
  private let view: UIView

  @objc(initWithBackground:forView:)
  public init(background: UIView, forView: UIView) {
    self.background = background
    self.view = forView
    super.init()
  }

  /// Samples the foreground's top-left bounds point in background coordinates.
  /// The foreground is excluded from the snapshot and its visibility is restored.
  /// Transparent pixels are composited over the background's system background color.
  @objc(contrastingColorWithError:)
  public func contrastingColor() throws -> UIColor {
    guard view !== background, view.isDescendant(of: background) else {
      throw PaletteError.unrelatedViews
    }
    background.layoutIfNeeded()
    let point = view.convert(view.bounds.origin, to: background)
    // Hide only the layer so UIStackView does not collapse an arranged foreground.
    let wasHidden = view.layer.isHidden
    view.layer.isHidden = true
    defer { view.layer.isHidden = wasHidden }
    let color = try background.color(at: point)
    return try Self.contrastingColor(for: color, traits: background.traitCollection)
  }

  @objc(contrastingColorWithBackground:forView:error:)
  public static func contrastingColor(background: UIView, for view: UIView) throws -> UIColor {
    try Palette(background: background, forView: view).contrastingColor()
  }

  /// Selects the higher WCAG contrast ratio against an sRGB background.
  /// Dynamic colors resolve using `traits`. A translucent base is flattened over white.
  /// This color-only API also works with SwiftUI through UIColor/Color bridging.
  public static func contrastingColor(
    for color: UIColor,
    compositedOver baseColor: UIColor = .systemBackground,
    traits: UITraitCollection = .current
  ) throws -> UIColor {
    let foreground = try components(of: color, traits: traits)
    let base = try components(of: baseColor, traits: traits)
    let opaqueBase = (
      base.r * base.a + 1 - base.a,
      base.g * base.a + 1 - base.a,
      base.b * base.a + 1 - base.a
    )
    let red = foreground.r * foreground.a + opaqueBase.0 * (1 - foreground.a)
    let green = foreground.g * foreground.a + opaqueBase.1 * (1 - foreground.a)
    let blue = foreground.b * foreground.a + opaqueBase.2 * (1 - foreground.a)
    let luminance = 0.2126 * linearize(red) + 0.7152 * linearize(green) + 0.0722 * linearize(blue)
    let blackContrast = (luminance + 0.05) / 0.05
    let whiteContrast = 1.05 / (luminance + 0.05)
    return blackContrast >= whiteContrast ? .black : .white
  }

  /// Source-compatible entry point. If sampling fails, returns the resolved system label color.
  @objc(getContrastingColor)
  public func getContrastingColor() -> UIColor {
    (try? contrastingColor()) ?? UIColor.label.resolvedColor(with: background.traitCollection)
  }

  @objc(getContrastingColor:forView:)
  public static func getContrastingColor(background: UIView, forView: UIView) -> UIColor {
    Palette(background: background, forView: forView).getContrastingColor()
  }

  private static func components(of color: UIColor, traits: UITraitCollection) throws
    -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
  {
    guard let space = CGColorSpace(name: CGColorSpace.sRGB),
      let converted = color.resolvedColor(with: traits).cgColor.converted(
        to: space, intent: .relativeColorimetric, options: nil),
      let values = converted.components, values.count == 4
    else {
      throw PaletteError.unsupportedColor
    }
    return (clamp(values[0]), clamp(values[1]), clamp(values[2]), clamp(values[3]))
  }

  private static func clamp(_ value: CGFloat) -> CGFloat {
    min(max(value, 0), 1)
  }

  private static func linearize(_ value: CGFloat) -> CGFloat {
    value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
  }
}
