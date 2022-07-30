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
    let r:CGFloat?;
    let g:CGFloat?;
    let b:CGFloat?;
    let a:CGFloat?;
    
    init(color:UIColor){
        let numComponents = color.cgColor.numberOfComponents;
        if numComponents == 4{
            let components = color.cgColor.components
            r = components?[0]
            g = components?[1]
            b = components?[2]
            a = components?[3]
        }else{
            r = 0
            g = 0
            b = 0
            a = 0
        }
        
        
    }
}

@objc public class Palette:NSObject{
    
    let background:UIView
    let view:UIView
    /**
        Initialize Palette object
        
        @param background: View that will be used to find background color
        @param forView: View whose cordinates will be use to find complementary color

    */
    public init(background:UIView, forView:UIView){
        self.background = background
        self.view = forView
    }
    private func getBackgroundColorAtViewPoint()->UIColor{
        let point = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y)
        return self.background.getPixelColorAtPoint(point: point)
        
    }
    private func printColors(color:UIColor){
        let numComponents = color.cgColor.numberOfComponents;
        if numComponents == 4{
            let components = color.cgColor.components
            print(components?[0] ?? 0)
            print(components?[1] ?? 0)
            print(components?[2] ?? 0)
            print(components?[3] ?? 0)
            
        }
    }

    
    private func blackOrWhiteContrastingColor(color:UIColor) -> UIColor {
        let components = color.cgColor.components
        let rBright = (components?[0] ?? 0) * 299
        let gBright = (components?[1] ?? 0) * 587
        let bBright = (components?[2] ?? 0) * 114
        let brightness = (rBright + gBright + bBright)  / 1000
        if (brightness < 0.5)
        {
            return UIColor.white
        }
        else
        {
            return UIColor.black
        }
    }
    
    /**
        Returns black or white color according background color on coordinates where is placed second view
        Uses the following formula ((Red value X 299) + (Green value X 587) + (Blue value X 114)) / 1000
        As recomended by W3 http://www.w3.org/TR/AERT#color-contrast
        @return Contrasting color
    */
    public func getContrastingColor()->UIColor{
        return blackOrWhiteContrastingColor(color: getBackgroundColorAtViewPoint())
    }
    /**
        Returns black or white color according background color on coordinates where is placed second view
        Uses the following formula ((Red value X 299) + (Green value X 587) + (Blue value X 114)) / 1000
        As recomended by W3 http://www.w3.org/TR/AERT#color-contrast
    
        @param background: View that will be used to find background color
        @param forView: View whose cordinates will be use to find complementary color
        @return Contrasting color
    */
    public static func getContrastingColor(background:UIView, forView:UIView)->UIColor{
        return Palette(background: background, forView: forView).getContrastingColor()
    }
    

}
