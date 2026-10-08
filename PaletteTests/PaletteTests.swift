import Palette
import SwiftUI
import Testing
import UIKit

@Suite @MainActor
struct PaletteTests {
  @Test func transparentPixelsAreInitialized() {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    for _ in 0..<30 {
      #expect(view.getPixelColorAtPoint(point: CGPoint(x: 5, y: 5)) == .clear)
    }
  }

  @Test func sampledColorIsNotPremultiplied() {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    view.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
    let sampled = view.getPixelColorAtPoint(point: CGPoint(x: 5, y: 5))
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    #expect(sampled.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
    #expect(abs(red - 1) < 0.01)
    #expect(abs(alpha - 0.5) < 0.01)
  }

  @Test func nestedCoordinatesAreConverted() {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    background.backgroundColor = .white
    let container = UIView(frame: CGRect(x: 50, y: 50, width: 40, height: 40))
    container.backgroundColor = .black
    background.addSubview(container)
    let foreground = UIView(frame: CGRect(x: 5, y: 5, width: 10, height: 10))
    container.addSubview(foreground)
    #expect(Palette(background: background, forView: foreground).getContrastingColor() == .white)
  }

  @Test(arguments: [0, 1, 2, 3, 4, 5])
  func primaryColorsChooseMaximumContrast(_ index: Int) throws {
    let colors: [UIColor] = [.white, .black, .red, .green, .blue, .yellow]
    let expected: [UIColor] = [.black, .white, .black, .black, .white, .black]
    #expect(try Palette.contrastingColor(for: colors[index]) == expected[index])
  }

  @Test func grayscaleDoesNotAssumeFourSourceComponents() throws {
    #expect(try Palette.contrastingColor(for: UIColor(white: 0.8, alpha: 1)) == .black)
    #expect(try Palette.contrastingColor(for: UIColor(white: 0.1, alpha: 1)) == .white)
  }

  @Test func extendedAndDisplayP3ColorsAreConverted() throws {
    #expect(
      try Palette.contrastingColor(for: UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1))
        == .black)
    #expect(
      try Palette.contrastingColor(for: UIColor(red: 1.2, green: 1.2, blue: 1.2, alpha: 1))
        == .black)
  }

  @Test func dynamicColorsRespectExplicitTraits() throws {
    let dynamic = UIColor { traits in traits.userInterfaceStyle == .dark ? .black : .white }
    #expect(
      try Palette.contrastingColor(
        for: dynamic, traits: UITraitCollection(userInterfaceStyle: .dark)) == .white)
    #expect(
      try Palette.contrastingColor(
        for: dynamic, traits: UITraitCollection(userInterfaceStyle: .light)) == .black)
  }

  @Test func transparencyIsCompositedOverTheRequestedBase() throws {
    #expect(try Palette.contrastingColor(for: .clear, compositedOver: .black) == .white)
    #expect(try Palette.contrastingColor(for: .clear, compositedOver: .white) == .black)
    #expect(
      try Palette.contrastingColor(for: UIColor(white: 0, alpha: 0.2), compositedOver: .white)
        == .black)
    #expect(try Palette.contrastingColor(for: .clear, compositedOver: .clear) == .black)
  }

  @Test func patternColorsReportUnsupportedConversion() {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2)).image { context in
      UIColor.red.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
    }
    #expect(throws: PaletteError.unsupportedColor) {
      try Palette.contrastingColor(for: UIColor(patternImage: image))
    }
  }

  @Test(arguments: [
    CGPoint(x: -1, y: 5), CGPoint(x: 20, y: 5),
    CGPoint(x: 5, y: 20), CGPoint(x: CGFloat.nan, y: 5), CGPoint(x: 5, y: CGFloat.infinity),
  ])
  func invalidPointsAreRejected(_ point: CGPoint) {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    #expect(throws: PaletteError.invalidPoint) { try view.color(at: point) }
    #expect(view.getPixelColorAtPoint(point: point) == .clear)
  }

  @Test func emptyViewsAreRejected() {
    #expect(throws: PaletteError.invalidPoint) { try UIView().color(at: .zero) }
  }

  @Test func spatialSamplingUsesBothAxes() throws {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    background.backgroundColor = .white
    let quadrant = UIView(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
    quadrant.backgroundColor = .blue
    background.addSubview(quadrant)
    expectColor(try background.color(at: CGPoint(x: 75, y: 75)), matches: .blue)
    expectColor(try background.color(at: CGPoint(x: 75, y: 25)), matches: .white)
    expectColor(try background.color(at: CGPoint(x: 25, y: 75)), matches: .white)
  }

  @Test func nonzeroBoundsOriginsAreSupported() throws {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    background.bounds.origin = CGPoint(x: 40, y: 40)
    background.backgroundColor = .white
    let patch = UIView(frame: CGRect(x: 60, y: 60, width: 30, height: 30))
    patch.backgroundColor = .black
    background.addSubview(patch)
    expectColor(try background.color(at: CGPoint(x: 70, y: 70)), matches: .black)
    expectColor(try background.color(at: CGPoint(x: 110, y: 110)), matches: .white)
  }

  @Test func transformedForegroundUsesCoordinateConversion() throws {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    background.backgroundColor = .white
    let patch = UIView(frame: CGRect(x: 50, y: 50, width: 40, height: 40))
    patch.backgroundColor = .black
    background.addSubview(patch)
    let foreground = UIView(frame: CGRect(x: 5, y: 5, width: 10, height: 10))
    background.addSubview(foreground)
    foreground.transform = CGAffineTransform(translationX: 50, y: 50)
    #expect(try Palette(background: background, forView: foreground).contrastingColor() == .white)
  }

  @Test(arguments: [false, true])
  func foregroundIsExcludedAndVisibilityIsRestored(_ hidden: Bool) throws {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    background.backgroundColor = .white
    let foreground = UIView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
    foreground.backgroundColor = .black
    foreground.isHidden = hidden
    background.addSubview(foreground)
    #expect(try Palette(background: background, forView: foreground).contrastingColor() == .black)
    #expect(foreground.isHidden == hidden)
  }

  @Test func visibilityIsRestoredOnSamplingFailure() {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let foreground = UIView(frame: CGRect(x: 30, y: 30, width: 10, height: 10))
    background.addSubview(foreground)
    #expect(throws: PaletteError.invalidPoint) {
      try Palette(background: background, forView: foreground).contrastingColor()
    }
    #expect(!foreground.isHidden)
    #expect(
      Palette(background: background, forView: foreground).getContrastingColor()
        == UIColor.label.resolvedColor(with: background.traitCollection))
  }

  @Test func unrelatedViewsAreRejected() {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    #expect(throws: PaletteError.unrelatedViews) {
      try Palette(background: background, forView: UIView()).contrastingColor()
    }
    #expect(throws: PaletteError.unrelatedViews) {
      try Palette(background: background, forView: background).contrastingColor()
    }
  }

  @Test func legacyAndModernAPIsAgreeOnValidBackgrounds() throws {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    background.backgroundColor = .red
    let foreground = UIView(frame: CGRect(x: 5, y: 5, width: 10, height: 10))
    background.addSubview(foreground)
    let palette = Palette(background: background, forView: foreground)
    #expect(palette.getContrastingColor() == .black)
    #expect(
      try palette.contrastingColor()
        == Palette.contrastingColor(background: background, for: foreground))
    #expect(Palette.getContrastingColor(background: background, forView: foreground) == .black)
  }

  @Test func luminanceCrossoverSelectsTheGreaterRatio() throws {
    #expect(try Palette.contrastingColor(for: UIColor(white: 0.46, alpha: 1)) == .white)
    #expect(try Palette.contrastingColor(for: UIColor(white: 0.47, alpha: 1)) == .black)
  }

  @Test func swiftUIColorsBridgeToTheColorOnlyAPI() throws {
    #expect(try Palette.contrastingColor(for: UIColor(Color.red)) == .black)
    #expect(try Palette.contrastingColor(for: UIColor(Color.black)) == .white)
  }

  @Test func samplingAnArrangedSubviewDoesNotChangeStackLayout() throws {
    let background = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    background.backgroundColor = .white
    let foreground = UIView()
    foreground.backgroundColor = .red
    let other = UIView()
    other.backgroundColor = .black
    let stack = UIStackView(arrangedSubviews: [foreground, other])
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.frame = background.bounds
    background.addSubview(stack)
    background.layoutIfNeeded()
    let originalFrame = foreground.frame
    #expect(try Palette(background: background, forView: foreground).contrastingColor() == .black)
    #expect(foreground.frame == originalFrame)
    #expect(!foreground.isHidden)
  }

  private func expectColor(_ actual: UIColor, matches expected: UIColor) {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    var er: CGFloat = 0
    var eg: CGFloat = 0
    var eb: CGFloat = 0
    var ea: CGFloat = 0
    #expect(actual.getRed(&r, green: &g, blue: &b, alpha: &a))
    #expect(expected.getRed(&er, green: &eg, blue: &eb, alpha: &ea))
    #expect(abs(r - er) < 0.01)
    #expect(abs(g - eg) < 0.01)
    #expect(abs(b - eb) < 0.01)
    #expect(abs(a - ea) < 0.01)
  }
}
