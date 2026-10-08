// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "Palette",
  platforms: [.iOS(.v15)],
  products: [.library(name: "Palette", targets: ["Palette"])],
  targets: [
    .target(name: "Palette", path: "Palette", exclude: ["Info.plist", "Palette-iOS.h"]),
    .testTarget(
      name: "PaletteTests", dependencies: ["Palette"], path: "PaletteTests",
      exclude: ["Info.plist"]),
  ],
  swiftLanguageModes: [.v6]
)
