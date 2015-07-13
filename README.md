# Palette-iOS
Like Android Palette for iOS. Written in Swift

From any view (anything that inherits UIView) gets contrasting color (black or white) for specific point where is another view.


## How to use

    let palette = Palette(background:self.view, view:self.label)
    self.label.textColor = palette.getContrastingColor()
