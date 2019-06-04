//
//  GlassView.swift
//  FillingAnimation
//
//  Created by Zholdas on 5/23/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit

enum AnimationButtonState {
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

    //MARK: - Public Properties
    
    var state: AnimationButtonState = .download
    
    //MARK: - Private Properties
    
    private let iconAnimationView = UIView()
    private let iconView = UIView()
    private let iconImageVeiw = UIImageView()
    
    private let iconImageSizeFromButton: CGFloat = 2.5
    
    private let iconBackgroundViewAnimationDuration: Double = 0.4

    private var progressLayerPath = UIBezierPath()
    private var progressLayer = CAShapeLayer()
    private static let rotateAnimationKey = "rotation"
    private let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
    
    private var pieceOfLayerStrokeEnd: CGFloat = 0.18
    private var pieceOfLayerStrokeStart: CGFloat = 0.17
    
    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        createCirclePath()
        setupLayerIconPosition()
    }
    
    //MARK: - Public Methods
    
    func startAnimation() {
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
            progressLayer.strokeEnd = pieceOfLayerStrokeEnd
            progressLayer.strokeStart = pieceOfLayerStrokeStart
            DispatchQueue.main.asyncAfter(deadline: .now() + state.animationDelay, execute: {
                self.progressLayer.isHidden = false
                self.startRotatingProgress()
                self.animateIconSize()
                self.iconImageVeiw.image = UIImage(named: "stop")
            })
        }
    }
    
    func stopAnimation() {
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
        progressLayer.strokeEnd = pieceOfLayerStrokeEnd + CGFloat(progress)
    }
    
    
    //MARK: - Private methods
    
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
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
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
    
    private func setupLayerIconPosition() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        progressLayer.path = progressLayerPath.cgPath
        progressLayer.position = center
        
        iconAnimationView.frame = CGRect(x: self.bounds.origin.x, y: -self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        iconImageVeiw.frame.size = CGSize(width: self.bounds.width/iconImageSizeFromButton, height: self.bounds.height/iconImageSizeFromButton)
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
        UIView.animate(withDuration: iconBackgroundViewAnimationDuration) {
            self.iconAnimationView.frame.origin.y = 0
        }
    }
    
    private func animateViewBottomToTop() {
        resetAnimationViewToBottom()
        UIView.animate(withDuration: iconBackgroundViewAnimationDuration){
            self.iconAnimationView.frame.origin.y = -self.bounds.height
        }
    }
    
    private func animateIconSize() {
        
        let iconSizeAnimationDuration: Double = 0.3
        
        iconImageVeiw.frame.size = CGSize.zero
        iconImageVeiw.frame.origin = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        UIView.animate(withDuration: iconSizeAnimationDuration) {
            self.iconImageVeiw.frame.size = CGSize(width: self.bounds.width/self.iconImageSizeFromButton, height: self.bounds.height/self.iconImageSizeFromButton)
            self.iconImageVeiw.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        }
    }
    
    private func startCurvedCircleAnimation() {
        let duration: CGFloat = 50
        var counter: CGFloat = 0
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            DispatchQueue.main.async {
                
            //MARK: Pice of layer to animation curve
                
                let strokeLength: CGFloat = counter/duration
                
                if counter < duration {
                    if strokeLength <= self.pieceOfLayerStrokeEnd {
                        self.progressLayer.strokeEnd = strokeLength
                    }
                    
                    let delay: Double = 0.17
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                        self.progressLayer.strokeStart = self.pieceOfLayerStrokeStart
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
        let numberOfPointToGet = 12
        let circlePathRadius = self.bounds.width/2.5
        
        let curvingPoint = getCirclePoints(centerPoint: CGPoint.zero, radius: circlePathRadius, n: numberOfPointToGet)
        
        progressLayerPath.move(to: CGPoint.zero)
        
        progressLayerPath.addCurve(to: curvingPoint[4], controlPoint1: CGPoint(x: 0.0, y: curvingPoint[4].y-(curvingPoint[4].y)/4), controlPoint2: CGPoint(x: 0.0, y: curvingPoint[4].y))
        
        progressLayerPath.addArc(withCenter: CGPoint.zero, radius: circlePathRadius, startAngle: CGFloat(Double.pi / 2 + 0.5), endAngle: CGFloat(Double.pi * 2.5 + 0.5), clockwise: true)
    }
    
    private func getCirclePoints(centerPoint point: CGPoint, radius: CGFloat, n: Int) -> [CGPoint] {
        let result: [CGPoint] = stride(from: 0.0, to: 360.0, by: Double(360 / n)).map {
            let bearing = CGFloat($0) * .pi / 180
            let x = point.x + radius * cos(bearing)
            let y = point.y + radius * sin(bearing)
            return CGPoint(x: x, y: y)
        }
        return result
    }
    
}

