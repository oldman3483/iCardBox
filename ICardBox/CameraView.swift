//
//  CameraView.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onImageCaptured = onImageCaptured
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var onImageCaptured: ((UIImage) -> Void)?
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var selectedOrientation: ScanOrientation = .landscape
    private var overlayView: CardOverlayView!
    private var captureDevice: AVCaptureDevice?
    
    enum ScanOrientation {
        case landscape, portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "需要相機權限",
            message: "請到設定中開啟相機權限以使用掃描功能",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "關閉", style: .cancel) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        // 設定為最高畫質 - 強制使用 photo 預設值以獲得最佳品質
        captureSession.sessionPreset = .photo
        
        // 選擇最佳相機
        guard let backCamera = selectBestCamera() else {
            return
        }
        
        captureDevice = backCamera
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            
            // 設定最高畫質輸出
            stillImageOutput.isHighResolutionCaptureEnabled = true
            
            // 如果支援深度資料，也啟用（可能提升畫質）
            if stillImageOutput.isDepthDataDeliverySupported {
                stillImageOutput.isDepthDataDeliveryEnabled = false // 關閉以節省處理時間，專注畫質
            }
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                
                // 配置相機設定以獲得最佳畫質
                configureCameraSettings(for: backCamera)
                
                setupPreviewLayer()
                setupUI()
            }
        } catch {
            print("相機設定錯誤: \(error)")
        }
    }
    
    private func selectBestCamera() -> AVCaptureDevice? {
        // 優先選擇三鏡頭系統（iPhone 11 Pro 以上）
        if let tripleCamera = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
            return tripleCamera
        }
        
        // 其次選擇雙鏡頭系統（iPhone 7 Plus 以上）
        if let dualCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return dualCamera
        }
        
        // 再選擇廣角鏡頭（最常見且品質好）
        if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideCamera
        }
        
        // 最後選擇預設相機
        return AVCaptureDevice.default(for: .video)
    }
    
    private func configureCameraSettings(for device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            
            // 設定對焦模式為自動對焦（快速且準確）
            if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }
            
            // 設定曝光模式為自動曝光
            if device.isExposureModeSupported(.autoExpose) {
                device.exposureMode = .autoExpose
            }
            
            // 設定白平衡為自動
            if device.isWhiteBalanceModeSupported(.autoWhiteBalance) {
                device.whiteBalanceMode = .autoWhiteBalance
            }
            
            // 只在支援時設定近距離對焦，不強制限制
            if device.isAutoFocusRangeRestrictionSupported {
                device.autoFocusRangeRestriction = .none // 恢復為無限制
            }
            
            // 如果支援，開啟低光增強功能
            if device.isLowLightBoostSupported {
                device.automaticallyEnablesLowLightBoostWhenAvailable = true
            }
            
            device.unlockForConfiguration()
        } catch {
            print("相機設定配置錯誤: \(error)")
        }
    }
    
    private func setupPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        if let connection = videoPreviewLayer.connection, connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }
        
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
    }
    
    private func setupUI() {
        overlayView = CardOverlayView()
        overlayView.selectedOrientation = selectedOrientation
        overlayView.backgroundColor = .clear
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "請將名片靠近相機並保持穩定"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        let orientationStackView = createOrientationButtons()
        orientationStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(orientationStackView)
        
        let captureButton = createCaptureButton()
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // 新增：手動對焦按鈕
        let focusButton = UIButton(type: .system)
        focusButton.setImage(UIImage(systemName: "viewfinder.circle"), for: .normal)
        focusButton.tintColor = .white
        focusButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        focusButton.layer.cornerRadius = 20
        focusButton.translatesAutoresizingMaskIntoConstraints = false
        focusButton.addTarget(self, action: #selector(focusButtonTapped), for: .touchUpInside)
        view.addSubview(focusButton)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            focusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            focusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            focusButton.widthAnchor.constraint(equalToConstant: 40),
            focusButton.heightAnchor.constraint(equalToConstant: 40),
            
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            orientationStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orientationStackView.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -30),
            orientationStackView.widthAnchor.constraint(equalToConstant: 200),
            orientationStackView.heightAnchor.constraint(equalToConstant: 40),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // 添加點擊手勢進行對焦
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExpose))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func focusAndExpose(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(at: devicePoint)
    }
    
    @objc private func focusButtonTapped() {
        // 對焦到畫面中央（名片區域）
        focus(at: CGPoint(x: 0.5, y: 0.5))
    }
    
    private func focus(at point: CGPoint) {
        guard let device = captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                // 使用單次自動對焦，更快更準確
                if device.isFocusModeSupported(.autoFocus) {
                    device.focusMode = .autoFocus
                }
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                if device.isExposureModeSupported(.autoExpose) {
                    device.exposureMode = .autoExpose
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print("對焦設定錯誤: \(error)")
        }
    }
    
    private func createOrientationButtons() -> UIStackView {
        let landscapeButton = UIButton(type: .system)
        landscapeButton.setTitle("橫向", for: .normal)
        landscapeButton.setTitleColor(.black, for: .normal)
        landscapeButton.backgroundColor = .orange
        landscapeButton.layer.cornerRadius = 8
        landscapeButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        landscapeButton.addTarget(self, action: #selector(orientationChanged(_:)), for: .touchUpInside)
        landscapeButton.tag = 0
        
        let portraitButton = UIButton(type: .system)
        portraitButton.setTitle("縱向", for: .normal)
        portraitButton.setTitleColor(.black, for: .normal)
        portraitButton.backgroundColor = .lightGray
        portraitButton.layer.cornerRadius = 8
        portraitButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        portraitButton.addTarget(self, action: #selector(orientationChanged(_:)), for: .touchUpInside)
        portraitButton.tag = 1
        
        let stackView = UIStackView(arrangedSubviews: [landscapeButton, portraitButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        return stackView
    }
    
    private func createCaptureButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        let innerCircle = UIView()
        innerCircle.backgroundColor = .black
        innerCircle.layer.cornerRadius = 30
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.isUserInteractionEnabled = false
        button.addSubview(innerCircle)
        
        NSLayoutConstraint.activate([
            innerCircle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 60),
            innerCircle.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return button
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if captureSession != nil && !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    @objc private func orientationChanged(_ sender: UIButton) {
        selectedOrientation = sender.tag == 0 ? .landscape : .portrait
        
        if let stackView = sender.superview as? UIStackView {
            for (index, button) in stackView.arrangedSubviews.enumerated() {
                if let btn = button as? UIButton {
                    btn.backgroundColor = index == sender.tag ? .orange : .lightGray
                }
            }
        }
        
        overlayView.selectedOrientation = selectedOrientation
        overlayView.setNeedsDisplay()
    }
    
    @objc private func capturePhoto() {
        guard captureSession.isRunning else { return }
        guard stillImageOutput.connections.count > 0 else { return }
        
        // 創建最高畫質拍攝設定
        let settings: AVCapturePhotoSettings
        
        // 優先使用 HEIF 格式（更好的壓縮和品質）
        if stillImageOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        }
        
        // 啟用所有高品質設定
        if stillImageOutput.isHighResolutionCaptureEnabled {
            settings.isHighResolutionPhotoEnabled = true
        }
        
        // 設定品質優先級（不超過裝置最大支援值）
        if #available(iOS 13.0, *) {
            let maxQuality = stillImageOutput.maxPhotoQualityPrioritization
            settings.photoQualityPrioritization = maxQuality
        }
        
        // 啟用自動閃光燈（如果光線不足）
        if stillImageOutput.supportedFlashModes.contains(.auto) {
            settings.flashMode = .auto
        }
        
        // 啟用自動紅眼消除（雖然不是人像，但可能有助於品質）
        if stillImageOutput.isAutoRedEyeReductionSupported {
            settings.isAutoRedEyeReductionEnabled = true
        }
        
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func getCardFrameInScreen() -> CGRect {
        let viewBounds = view.bounds
        
        let cardWidth: CGFloat
        let cardHeight: CGFloat
        
        switch selectedOrientation {
        case .landscape:
            cardWidth = min(viewBounds.width * 0.85, 340)
            cardHeight = cardWidth * 0.63
        case .portrait:
            cardHeight = min(viewBounds.height * 0.42, 210)
            cardWidth = cardHeight * 0.63
        }
        
        return CGRect(
            x: (viewBounds.width - cardWidth) / 2,
            y: (viewBounds.height - cardHeight) / 2,
            width: cardWidth,
            height: cardHeight
        )
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let originalImage = UIImage(data: imageData) else {
            return
        }
        
        let correctedImage = fixImageOrientation(originalImage)
        
        if let croppedImage = cropImageToCardArea(correctedImage) {
            // 進一步優化圖片品質
            let enhancedImage = enhanceImageQuality(croppedImage)
            onImageCaptured?(enhancedImage)
        } else {
            let enhancedImage = enhanceImageQuality(correctedImage)
            onImageCaptured?(enhancedImage)
        }
        
        dismiss(animated: true)
    }
    
    private func enhanceImageQuality(_ image: UIImage) -> UIImage {
        // 使用最高的壓縮品質來保存圖片（接近無損）
        guard let imageData = image.jpegData(compressionQuality: 1.0),
              let enhancedImage = UIImage(data: imageData) else {
            return image
        }
        
        return enhancedImage
    }
    
    private func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func cropImageToCardArea(_ image: UIImage) -> UIImage? {
        let imageSize = image.size
        let viewBounds = view.bounds
        let cardFrame = getCardFrameInScreen()
        
        // 計算名片框在螢幕中的相對位置
        let relativeX = cardFrame.minX / viewBounds.width
        let relativeY = cardFrame.minY / viewBounds.height
        let relativeWidth = cardFrame.width / viewBounds.width
        let relativeHeight = cardFrame.height / viewBounds.height
        
        let imageAspectRatio = imageSize.width / imageSize.height
        let screenAspectRatio = viewBounds.width / viewBounds.height
        
        let cropRect: CGRect
        
        if imageAspectRatio > screenAspectRatio {
            // 圖片比螢幕寬，左右會被裁切
            let displayedWidth = imageSize.height * screenAspectRatio
            let cropOffsetX = (imageSize.width - displayedWidth) / 2
            
            cropRect = CGRect(
                x: cropOffsetX + relativeX * displayedWidth,
                y: relativeY * imageSize.height,
                width: relativeWidth * displayedWidth,
                height: relativeHeight * imageSize.height
            )
        } else {
            // 圖片比螢幕高，上下會被裁切
            let displayedHeight = imageSize.width / screenAspectRatio
            let cropOffsetY = (imageSize.height - displayedHeight) / 2
            
            cropRect = CGRect(
                x: relativeX * imageSize.width,
                y: cropOffsetY + relativeY * displayedHeight,
                width: relativeWidth * imageSize.width,
                height: relativeHeight * displayedHeight
            )
        }
        
        // 確保裁切區域在圖片範圍內
        let clampedRect = CGRect(
            x: max(0, min(cropRect.minX, imageSize.width - 50)),
            y: max(0, min(cropRect.minY, imageSize.height - 50)),
            width: min(cropRect.width, imageSize.width - max(0, cropRect.minX)),
            height: min(cropRect.height, imageSize.height - max(0, cropRect.minY))
        )
        
        // 檢查裁切區域是否合理
        guard clampedRect.width > 50 && clampedRect.height > 50 else {
            return image
        }
        
        // 使用 UIGraphicsImageRenderer 進行高品質裁切
        let scale = max(1.0, image.scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: clampedRect.size, format: format)
        
        let croppedImage = renderer.image { context in
            let drawRect = CGRect(
                x: -clampedRect.origin.x,
                y: -clampedRect.origin.y,
                width: imageSize.width,
                height: imageSize.height
            )
            image.draw(in: drawRect)
        }
        
        return croppedImage
    }
}

// MARK: - 名片框線覆蓋層 (保持原有功能)
class CardOverlayView: UIView {
    var selectedOrientation: CameraViewController.ScanOrientation = .landscape {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = false
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.clear(rect)
        
        // 設置半透明黑色背景
        context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
        context.fill(rect)
        
        // 計算名片框的尺寸和位置
        let cardWidth: CGFloat
        let cardHeight: CGFloat
        
        switch selectedOrientation {
        case .landscape:
            cardWidth = min(rect.width * 0.85, 340)
            cardHeight = cardWidth * 0.63
        case .portrait:
            cardHeight = min(rect.height * 0.42, 210)
            cardWidth = cardHeight * 0.63
        }
        
        let cardRect = CGRect(
            x: (rect.width - cardWidth) / 2,
            y: (rect.height - cardHeight) / 2,
            width: cardWidth,
            height: cardHeight
        )
        
        // 清除名片區域（透明）
        context.clear(cardRect)
        
        // 繪製名片框線
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        context.stroke(cardRect)
        
        // 繪製四個角落的橘色標記
        drawCornerMarkers(context: context, in: cardRect)
    }
    
    private func drawCornerMarkers(context: CGContext, in rect: CGRect) {
        context.setStrokeColor(UIColor.orange.cgColor)
        context.setLineWidth(3)
        
        let markerLength: CGFloat = 20
        
        // 左上角
        context.move(to: CGPoint(x: rect.minX, y: rect.minY + markerLength))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX + markerLength, y: rect.minY))
        
        // 右上角
        context.move(to: CGPoint(x: rect.maxX - markerLength, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + markerLength))
        
        // 左下角
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY - markerLength))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.minX + markerLength, y: rect.maxY))
        
        // 右下角
        context.move(to: CGPoint(x: rect.maxX - markerLength, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - markerLength))
        
        context.strokePath()
    }
}

// 保持原有的 ImagePicker 功能
struct ImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }
    }
}
