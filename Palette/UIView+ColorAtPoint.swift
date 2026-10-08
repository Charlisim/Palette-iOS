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

@MainActor
extension UIView {
  /// Samples a one-point footprint centered at `point`, in local bounds coordinates.
  /// Returns an unpremultiplied sRGB color, including its alpha.
  /// Layer rendering cannot capture GPU-only content such as Metal or video surfaces.
  public func color(at point: CGPoint) throws -> UIColor {
    layoutIfNeeded()
    guard point.x.isFinite, point.y.isFinite, bounds.contains(point) else {
      throw PaletteError.invalidPoint
    }
    var pixel = [UInt8](repeating: 0, count: 4)
    try pixel.withUnsafeMutableBytes { bytes in
      guard let space = CGColorSpace(name: CGColorSpace.sRGB),
        let context = CGContext(
          data: bytes.baseAddress, width: 1, height: 1,
          bitsPerComponent: 8, bytesPerRow: 4, space: space,
          bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue
            | CGImageAlphaInfo.premultipliedLast.rawValue
        )
      else {
        throw PaletteError.renderingFailed
      }
      context.translateBy(
        x: 0.5 - point.x,
        y: 0.5 - point.y)
      traitCollection.performAsCurrent {
        layer.render(in: context)
      }
    }
    let alpha = CGFloat(pixel[3]) / 255
    guard alpha > 0 else { return .clear }
    return UIColor(
      red: min(CGFloat(pixel[0]) / 255 / alpha, 1),
      green: min(CGFloat(pixel[1]) / 255 / alpha, 1),
      blue: min(CGFloat(pixel[2]) / 255 / alpha, 1),
      alpha: alpha)
  }

  /// Source-compatible entry point. Invalid points or rendering failures return clear.
  public func getPixelColorAtPoint(point: CGPoint) -> UIColor {
    (try? color(at: point)) ?? .clear
  }
}
