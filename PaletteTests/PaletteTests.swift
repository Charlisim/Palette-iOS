//
//  PaletteTests.swift
//  PaletteTests
//
//  Created by Carlos Simon Villas on 12/07/15.
//  Copyright (c) 2015 Charlisim. All rights reserved.
//

import UIKit
import XCTest
import Palette

class PaletteTests: XCTestCase {
    let vc = ViewController()
    var palette:Palette?
    override func setUp() {
        super.setUp()
        self.palette = Palette(background: self.vc.view, forView: self.vc.label)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExists() {
        XCTAssertTrue(self.palette != nil)
    }
    func testReturnColor(){
        XCTAssertTrue(self.palette?.getContrastingColor() != nil, "")
    }
    func testWhiteBackground(){
        self.vc.view.backgroundColor = UIColor.white
        print(self.palette?.getContrastingColor())
        let color1 = self.palette!.getContrastingColor().cgColor
        let color2 = UIColor.black.cgColor
        XCTAssertEqual(color1, color2)
    }
    func testBlackBackground(){
        self.vc.view.backgroundColor = UIColor.black
        print(self.palette?.getContrastingColor())
        let color1 = self.palette!.getContrastingColor().cgColor
        let color2 = UIColor.white.cgColor
        XCTAssertEqual(color1, color2)
    }
    func testRedBackground(){
        self.vc.view.backgroundColor = UIColor.red
        print(self.palette?.getContrastingColor())
        let color1 = self.palette!.getContrastingColor().cgColor
        let color2 = UIColor.white.cgColor
        XCTAssertEqual(color1, color2)
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.vc.view.backgroundColor = UIColor.red

        self.measure {
            self.palette!.getContrastingColor()
            // Put the code you want to measure the time of here.
        }
    }
    
}
