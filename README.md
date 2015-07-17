# Palette-iOS
Like Android Palette for iOS. Written in Swift and compatible with Objective-C

From any view (anything that inherits UIView) gets contrasting color (black or white) for specific point where is another view.

## Screenshots
<img src="/screenshots/red.png" alt="palette ios example" width="220" height="391">
<img src="/screenshots/gray.png" alt="palette ios example" width="220" height="391">
<img src="/screenshots/white.png" alt="palette ios example" width="220" height="391">


## How to install

### Cocoapods

    pod "Palette"

## How to use

### In Swift

    let palette = Palette(background:self.view, view:self.label)
    self.label.textColor = palette.getContrastingColor()
    
or 
    
    self.label.textColor = Palette.getContrastingColor(self.view, forView: self.label)

### In Objective-C 
    
    Palette * palette = [[Palette alloc] initWithBackground:self.view forView:label];
    label.textColor =  [palette getContrastingColor];

or 

    label.textColor = [Palette getContrastingColor:self.view forView:label];


