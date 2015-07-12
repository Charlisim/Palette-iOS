//
//  Palette.swift
//  Palette-iOS
//
//  Created by Carlos Simon Villas on 12/07/15.
//  Copyright (c) 2015 Charlisim. All rights reserved.
//

import UIKit

class PaletteObject{
    
    let image:UIImage
    let view:UIView
    init(){
        self.image = UIImage()
        self.view = UIView()
    }
    init(image:UIImage, forView:UIView){
        self.image = image
        self.view = forView
        println(self.printColors(getImageColor()))
    }
    func getImageColor()->UIColor{
        let point = CGPointMake(self.view.frame.midX, self.view.frame.midY)
        return self.image.getPixelColor(point)
        
    }
    func printColors(color:UIColor){
        let numComponents = CGColorGetNumberOfComponents(color.CGColor);
        if numComponents == 4{
            let components = CGColorGetComponents(color.CGColor)
            println(components[0])
            println(components[1])
            println(components[2])
            println(components[3])
        }
    }
}
