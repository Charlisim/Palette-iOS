# Palette-iOS
Like Android Palette for iOS. Written in Swift

From any view (anything that inherits UIView) gets contrasting color (black or white) for specific point where is another view.

## Screenshots
<img src="/screenshots/red.png" alt="palette ios example" style="width:220;height:391">
![](/screenshots/gray.png =250x)
![](/screenshots/white.png =250x)

## How to use

    let palette = Palette(background:self.view, view:self.label)
    self.label.textColor = palette.getContrastingColor()


