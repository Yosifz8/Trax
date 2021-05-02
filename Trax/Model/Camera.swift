//
//  Camera.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//

import Foundation
import AVFoundation

class Camera {
    static func checkCameraPermission(completion:@escaping (Bool) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
//            setupCaptureSession()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case .denied:
            completion(false)
//            perform(#selector(showPermissionAlert), with: nil, afterDelay: 0.1)
            return
        case .restricted:
            completion(false)
//            perform(#selector(showPermissionAlert), with: nil, afterDelay: 0.1)
            return
        @unknown default:
            completion(false)
            return
        }
    }
}
