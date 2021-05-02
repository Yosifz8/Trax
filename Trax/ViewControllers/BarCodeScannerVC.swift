//
//  BarCodeScannerVC.swift
//  Trax
//
//  Created by Yosi Faroh Zada on 27/04/2021.
//

import AVFoundation
import UIKit

protocol BarCodeScannerDelegate: class {
    func didSelectBarcode(with barcode:String)
}

class BarCodeScannerVC: UIViewController {
    private weak var delegate: BarCodeScannerDelegate?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(delegate: BarCodeScannerDelegate) {
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- BarCodeScannerVC Lifecycle

extension BarCodeScannerVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupUI()
        
        createCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
}

// MARK:- BarCodeScannerVC UI Setup

extension BarCodeScannerVC {
    private func setupUI() {
        let closeBtn = UIButton()
        
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.setTitleColor(.black, for: .normal)
        
        closeBtn.addTarget(self, action: #selector(didPressCloseBtn), for: .touchUpInside)
        
        self.view.addSubview(closeBtn)

        closeBtn.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: nil)
        closeBtn.centerXToSuperview()
    }
}

// MARK:- BarCodeScannerVC IBActions

extension BarCodeScannerVC {
    @objc private func didPressCloseBtn() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- BarCodeScannerVC Methods

extension BarCodeScannerVC {
    private func createCaptureSession() {
        Camera.checkCameraPermission { [weak self] (authorized) in
            if authorized {
                self?.setupCaptureSession()
            } else {
                self?.perform(#selector(self?.showPermissionAlert), with: nil, afterDelay: 0.1)
            }
        }
    }
    
    @objc private func showPermissionAlert() {
        let alert = UIAlertController(title: "Camera Permission", message: "The app need permission to access your camera", preferredStyle: .alert)
        alert.addAction(.init(title: "Settings", style: .default, handler: { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("failed to start capture session")
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("failed to start capture session")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            print("failed to start capture session")
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }
}

// MARK:- AVCaptureMetadataOutputObjectsDelegate

extension BarCodeScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue,
           let delegate = self.delegate {
            delegate.didSelectBarcode(with: stringValue)
        }

        dismiss(animated: true)
    }
}
