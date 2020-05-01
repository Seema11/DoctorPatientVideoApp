//
//  FontExtension.swift
//  TemplateProjectSwift
//
//  Created by Mac22 on 12/02/19.
//  Copyright © 2019 NP. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    enum FontStandardSize {
        
        case size9
        case size11
        case size12
        case size15
        case size16
        case size17
        case size20
        case size24
        
        var size: CGFloat {
            switch self {
            case .size9:
                return 9
            case .size11:
                return 11
            case .size12:
                return 12
            case .size15:
                return 15
            case .size16:
                return 16
            case .size17:
                return 17
            case .size20:
                return 20
            case .size24:
                return 24
            }
        }
        
    }
    
    enum Font {
        case arabic
        case codec_bold
        case codec_light
        case gotham_bold
        case gotham_medium
        case gotham_regular
        case roboto_medium
        case roboto_regular
        
        var name: String {
            switch self {
                case .arabic:                                return "arabic"
                case .codec_bold:                        return "codec_bold"
                case .codec_light:                       return "codec_light"
                case .gotham_bold:                       return "gotham_bold"
                case .gotham_medium:                     return "gotham_medium"
                case .gotham_regular:                    return "gotham_regular"
                case .roboto_medium:                     return "roboto_medium"
                case .roboto_regular:                    return "roboto_regular"
            }
        }
        
    }
    
    class func font(_ font: Font, fontStandardSize: FontStandardSize) -> UIFont? {
        return UIFont.init(name: font.name, size: fontStandardSize.size)
    }
    
    class func font(_ font: Font, fontSize: CGFloat) -> UIFont? {
        
//        switch font {
//        case .SanFranciscoDisplayLight:        return UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.light)
//        case .SanFranciscoDisplayRegular:      return UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
//        case .SanFranciscoDisplayMedium:       return UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium)
//        case .SanFranciscoDisplaySemiBold:     return UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.semibold)
//        case .SanFranciscoDisplayBold:         return UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.bold)
//        }
        
        return UIFont.init(name: font.name, size: fontSize)
    }
    
    class func logAllAvailableFonts() {
        for family in UIFont.familyNames {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  ->  \(name)")
            }
        }
    }
    
}

extension UIFont {
    
    fileprivate func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
}
