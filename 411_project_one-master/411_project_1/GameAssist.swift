//
//  GameAssist.swift
//  411Car
//
//  Created by Xianghui Huang on 3/03/19.
//  Copyright © 2019 Xianghui Huang. All rights reserved.
//
import Foundation
import UIKit

struct ColliderType {
    
    static let OBJECT_COLLIDER : UInt32 = 0
    static let ITEM_COLLIDER_1: UInt32 = 1
    static let ITEM_COLLIDER_2 : UInt32 = 2
}

class GameAssist : NSObject {
    
    func randomBetweenTwoNumbers(firstNumber : CGFloat ,  secondNumber : CGFloat) -> CGFloat{
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
}

class Settings {
    static let sharedInstance = Settings()
    
    private init(){
        
    }
    
    var highScore = 0
}
