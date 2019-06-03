//
//  ViewController.swift
//  FillingAnimation
//
//  Created by Zholdas on 5/23/19.
//  Copyright © 2019 Zholdas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var isStart = true
    
    lazy var animView: DownloadUploadButton = {
        let view = DownloadUploadButton()
        let tap = UITapGestureRecognizer(target: self, action: #selector(animatee))
        view.addGestureRecognizer(tap)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 50
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(animView)
        view.backgroundColor = .darkGray
        
        animView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        animView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        animView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    let duration: Float = 100
    var counter: Float = 0
    var progres: Float = 0
    var timer: Timer?

    @objc func animatee(){
        if isStart{
            isStart = !isStart
            animView.state = .download
            animView.startAnimation()
            counter = 0
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
                DispatchQueue.main.async {
                    if self.counter <= self.duration {
                        
                        self.progres = self.counter/self.duration
                        self.animView.updateProgress(self.progres)
                        self.counter += 1
                    } else {
                        timer.invalidate()
                    }
                }
            }
            self.timer!.fire()
        
        }
        else {
            isStart = !isStart
            animView.updateProgress(0)
            self.counter = 101
            animView.stopAnimation()
        }
    }
}

