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

private struct Color{
    let r:CGFloat;
    let g:CGFloat;
    let b:CGFloat;
    let a:CGFloat;
    
    init(color:UIColor){
        let numComponents = CGColorGetNumberOfComponents(color.CGColor);
        if numComponents == 4{
            let components = CGColorGetComponents(color.CGColor)
            r = components[0]
            g = components[1]
            b = components[2]
            a = components[3]
        }else{
            r = 0
            g = 0
            b = 0
            a = 0
        }
        
        
    }
}
public class Palette{
    
    let background:UIView
    let view:UIView
    
    public init(background:UIView, forView:UIView){
        self.background = background
        self.view = forView
    }
    private func getImageColor()->UIColor{
        let point = CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y)
        return self.background.getPixelColorAtPoint(point)
        
    }
    private func printColors(color:UIColor){
        let numComponents = CGColorGetNumberOfComponents(color.CGColor);
        if numComponents == 4{
            let components = CGColorGetComponents(color.CGColor)
            println(components[0])
            println(components[1])
            println(components[2])
            println(components[3])
        }
    }

    
    private func blackOrWhiteContrastingColor(color:UIColor) -> UIColor {
        let rgbaT = Color(color: color)
        let components = CGColorGetComponents(color.CGColor)
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        if (brightness < 0.5)
        {
            return UIColor.whiteColor()
        }
        else
        {
            return UIColor.blackColor()
        }
    }
    
    public func getContrastingColor()->UIColor{
        return blackOrWhiteContrastingColor(getImageColor())
    }
    
    public static func getContrastingColor(background:UIView, forView:UIView)->UIColor{
        return Palette(background: background, forView: forView).getContrastingColor()
    }
}
