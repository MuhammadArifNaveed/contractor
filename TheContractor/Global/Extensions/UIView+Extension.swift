//
//  UIView+Extension.swift
//  SimSwitch
//
//  Created by Gulfam Khan on 29/10/2019.
//  Copyright © 2019 Rapidzz. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var showShadow: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.dropShadow()
            }
        }
    }
    
    class func initializeFromNib(_ name: String? = nil) -> Self {
        return initializeFromNib(name, type: self)
    }
    
    class func initializeFromNib<T: UIView>(_ name: String? = nil, type: T.Type) -> T {
        return initializeFromNib(name, type: type)!
    }
    
    class func initializeFromNib<T: UIView>(_ name: String? = nil, type: T.Type) -> T? {
        var nibName = ""
        if let name = name {
            nibName = name
        }else {
            nibName = String(describing: type)
        }
        
        let nibViews = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)
        
        for view in nibViews ?? [] {
            if let matchView = view as? T {
                return matchView
            }
        }
        
        return nil
    }
    
    func changeRTL() {
        //        if UserDefaultsManager.shared.currentLocale == "en" {
        //            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        //        }else {
        //            self.flipImages()
        //            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        //        }
    }
    
    func flipImages() {
        //        for subview in self.subviews {
        //            if subview.isKind(of: UIImageView.self) {
        //                let imageView = subview as! UIImageView
        //                imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        //            }
        //
        //            if subview.isKind(of: UIButton.self) {
        //                let button = subview as! UIButton
        //                if let imageView = button.imageView {
        //                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        //                }
        //            }
        //
        //            if subview.subviews.count > 0 {
        //                subview.flipImages()
        //            }
        //        }
    }
    
    func setBorderLayer(width: CGFloat, color: UIColor, cornerRadius:CGFloat? = nil) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        
        if let radius = cornerRadius {
            self.layer.cornerRadius = radius
        }else {
            self.layer.cornerRadius = self.bounds.size.width / 2
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    
    func rotate(withRadian radian: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(rotationAngle: radian)
        })
    }
    
    func rotate(withAngle angle: CGFloat) {
        let radian = angle * .pi / 180
        rotate(withRadian: radian)
    }
    
    func setupImageGradient(colors: [CGColor], start: CGPoint? = nil, end: CGPoint? = nil, position:UInt32? = nil) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.frame = bounds
        if let start = start, let end = end {
            gradientLayer.startPoint = start
            gradientLayer.endPoint = end
        }else {
            gradientLayer.locations = [0, 1]
        }
        
        if let position = position {
            layer.insertSublayer(gradientLayer, at: position)
        }else {
            layer.addSublayer(gradientLayer)
        }
    }
    
    func dropShadow(radius: CGFloat? = 1 , opacity: Float? = 1) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = opacity!
        layer.shadowOffset = CGSize(width: 0, height: radius!)
        layer.shadowRadius = radius!
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor = .black, opacity: Float = 0.5, offSet: CGSize = CGSize(width: -1, height: 1), radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
    }
    
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
    
    func switchVisibility(_ duration:Double = 0.5) {
        if self.isHidden {
            self.isHidden = false
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 1
            }, completion: nil)
        }else {
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 0
            }) { (finished) in
                self.isHidden = finished
            }
        }
    }
}
extension UIView {
    func screenshot() -> UIImage {
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size: bounds.size).image { _ in
                drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
            UIGraphicsEndImageContext()
            return image
        }
    }
}
