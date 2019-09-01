//
//  MainViewController.swift
//  MetalCamera
//
//  Created by Greg on 24/07/2019.
//  Copyright © 2019 GS. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

final class MainViewController: UIViewController {
    
    @IBOutlet weak var metalView: MetalView!
    private var videoCapture: VideoCapture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCamera()
    }
    
    private func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.setUp(sessionPreset: AVCaptureSession.Preset.hd1280x720, frameRate: 60) { success in
            if success {
                self.videoCapture.start()
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension MainViewController: VideoCaptureDelegate {
    
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        
        DispatchQueue.main.async {
            self.metalView.pixelBuffer = pixelBuffer
        }
    }
}

