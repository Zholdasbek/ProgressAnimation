//
//  GlassView.swift
//  FillingAnimation
//
//  Created by Zholdas on 5/23/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit

enum AnimationButtonType {
    case download
    case upload
    
    var imageName: String {
        switch self {
        case .download:
            return "download"
        case .upload:
            return "upload"
        }
    }
    
    var animationDelay: TimeInterval {
        switch self {
        case .upload:
            return 0.1
        case .download:
            return 0.25
        }
    }
}

class DownloadUploadButton: UIView {

    var state: AnimationButtonType = .download
    
    let iconAnimationView = UIView()
    let iconView = UIView()
    let iconImageVeiw = UIImageView()

    var progressLayerPath = UIBezierPath()
    var progressLayer = CAShapeLayer()
    static let rotateAnimationKey = "rotation"

    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.lineWidth = 5
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.darkGray.cgColor
        progressLayer.strokeEnd = 0.0
        progressLayer.isHidden = true
        
        rotateAnimation.duration = 2
        rotateAnimation.repeatCount = Float.infinity
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = Float(Double.pi * 2)
        rotateAnimation.repeatCount = Float(TimeInterval.infinity)

        self.layer.addSublayer(progressLayer)

        self.backgroundColor = .white
        iconAnimationView.backgroundColor = .white
        iconView.backgroundColor = UIColor.darkGray
        
        iconImageVeiw.contentMode = .scaleAspectFit
        iconImageVeiw.image = UIImage(named: "download")
        
        self.addSubview(iconView)
        iconView.addSubview(iconAnimationView)
        iconView.mask = iconImageVeiw
        
        layoutIfNeeded()
        resetAnimationViewToTop()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        createCirclePath()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        progressLayer.path = progressLayerPath.cgPath
        progressLayer.position = center
        
        
        iconAnimationView.frame = CGRect(x: self.bounds.origin.x, y: -self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        iconImageVeiw.frame.size = CGSize(width: self.bounds.width/2.5, height: self.bounds.height/2.5)
        iconView.frame = self.bounds
        
        iconView.center = center
        iconImageVeiw.center = center
        
    }
    
    private func resetAnimationViewToTop() {
        iconAnimationView.frame.origin.y = -self.bounds.height
    }
    
    private func resetAnimationViewToBottom() {
        iconAnimationView.frame.origin.y = 0
    }
    
    private func animateViewTopToBottom() {
        resetAnimationViewToTop()
        UIView.animate(withDuration: 0.4) {
            self.iconAnimationView.frame.origin.y = 0
        }
    }
    
    private func animateViewBottomToTop() {
        resetAnimationViewToBottom()
        UIView.animate(withDuration: 0.4){
            self.iconAnimationView.frame.origin.y = -self.bounds.height
        }
    }
    
    private func animateIconSize(){
        iconImageVeiw.frame.size = CGSize(width: 0, height: 0)
        iconImageVeiw.frame.origin = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        UIView.animate(withDuration: 0.3) {
            self.iconImageVeiw.frame.size = CGSize(width: self.bounds.width/2.5, height: self.bounds.height/2.5)
            self.iconImageVeiw.frame.origin = CGPoint(x: self.bounds.width/3.33, y: self.bounds.height/3.33)
        }
    }
    
    
    func startAnimation(){
        switch state {
        case .download:
            progressLayer.isHidden = false
            self.animateViewTopToBottom()
            self.startCurvedCircleAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + state.animationDelay) {
                self.startRotatingProgress()
                self.animateIconSize()
                self.resetAnimationViewToTop()
                self.iconImageVeiw.image = UIImage(named: "stop")
            }
        case .upload:
            progressLayer.strokeEnd = 0.18
            progressLayer.strokeStart = 0.17
            DispatchQueue.main.asyncAfter(deadline: .now() + state.animationDelay, execute: {
                self.progressLayer.isHidden = false
                self.startRotatingProgress()
                self.animateIconSize()
                self.iconImageVeiw.image = UIImage(named: "stop")
            })
        }
    }
    
    func stopAnimation(){
        progressLayer.isHidden = true
        stopRotatingProgress()

        switch state {
        case .download:
            self.animateViewBottomToTop()
            self.progressLayer.strokeEnd = 0.0
            self.progressLayer.strokeStart = 0.0
            self.iconImageVeiw.image = UIImage(named: self.state.imageName)
        case .upload:
            iconImageVeiw.image = UIImage(named: self.state.imageName)
        }
    }

    func updateProgress(_ progress: Float) {
        progressLayer.strokeEnd = 0.18 + CGFloat(progress)
    }
    
    private func startCurvedCircleAnimation() {
        let duration: Float = 50
        var counter: Float = 0
        let pieceOfLayerStrokeEnd: Float = 0.18
        let pieceOfLayerStrokeStart: Float = 0.17
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            DispatchQueue.main.async {
                
            //MARK: Pice of layer to animation curve
                let strokeLength = counter/duration
                
                if counter < duration {
                    if strokeLength <= pieceOfLayerStrokeEnd {
                        self.progressLayer.strokeEnd = CGFloat(strokeLength)
                    }
                    let delay = 0.17
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                        self.progressLayer.strokeStart = CGFloat(pieceOfLayerStrokeStart)
                    })
                    counter += 1
                } else {
                    timer.invalidate()
                }
            }
        }
        timer.fire()
    }
    
    private func startRotatingProgress() {
        if progressLayer.animation(forKey: DownloadUploadButton.rotateAnimationKey) == nil {
            progressLayer.add(rotateAnimation, forKey: DownloadUploadButton.rotateAnimationKey)
        }
    }
    
    private func stopRotatingProgress() {
        if progressLayer.animation(forKey: DownloadUploadButton.rotateAnimationKey) != nil {
            progressLayer.removeAnimation(forKey: DownloadUploadButton.rotateAnimationKey)
        }
    }
    
    private func createCirclePath() {
        let curvingPoint = getCirclePoints(centerPoint: CGPoint.zero, radius: self.bounds.width/2.5, n: 12)
        
        progressLayerPath.move(to: CGPoint.zero)
        progressLayerPath.addCurve(to: curvingPoint[4], controlPoint1: CGPoint(x: 0.0, y: curvingPoint[4].y-(curvingPoint[4].y)/4), controlPoint2: CGPoint(x: 0.0, y: curvingPoint[4].y))
        progressLayerPath.addArc(withCenter: CGPoint.zero, radius: self.bounds.width/2.5, startAngle: CGFloat(Double.pi / 2 + 0.5), endAngle: CGFloat(Double.pi * 2.5 + 0.5), clockwise: true)
    }
    
    private func getCirclePoints(centerPoint point: CGPoint, radius: CGFloat, n: Int)->[CGPoint] {
        let result: [CGPoint] = stride(from: 0.0, to: 360.0, by: Double(360 / n)).map {
            let bearing = CGFloat($0) * .pi / 180
            let x = point.x + radius * cos(bearing)
            let y = point.y + radius * sin(bearing)
            return CGPoint(x: x, y: y)
        }
        return result
    }
}

