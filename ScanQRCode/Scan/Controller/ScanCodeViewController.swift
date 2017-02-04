//
//  ScanCodeViewController.swift
//  ScanQRCode
//
//  Created by admin on 2016/11/25.
//  Copyright © 2016年 admin. All rights reserved.
//

import UIKit
import AVFoundation

private let scanAnimationDuration = 3.0//扫描时长

class ScanCodeViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var scanPane: UIImageView!///扫描框
//    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var scanSession :  AVCaptureSession?
    var lightOn = false///开光灯
    lazy var scanLine : UIImageView =
        {
            
            let scanLine = UIImageView()
            scanLine.frame = CGRect(x: 0, y: 0, width: self.scanPane.bounds.width, height: 3)
            scanLine.image = UIImage(named: "QRCode_ScanLine")
            
            return scanLine
            
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.layoutIfNeeded()
        scanPane.addSubview(scanLine)
        
        setupScanSession()
        

    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        startScan()
        
    }
    
    func setupScanSession()
    {
        
        do
        {
            
            //初始化设备数据
            //设置捕捉设备
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            //设置设备输入输出
            let input = try AVCaptureDeviceInput(device: device)
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //设置会话
            let  scanSession = AVCaptureSession()
            scanSession.canSetSessionPreset(AVCaptureSessionPresetHigh)
            
            if scanSession.canAddInput(input)
            {
                scanSession.addInput(input)
            }
            
            if scanSession.canAddOutput(output)
            {
                scanSession.addOutput(output)
            }
            
            //设置扫描类型(二维码和条形码)
            output.metadataObjectTypes = [
                AVMetadataObjectTypeFace,
                AVMetadataObjectTypeQRCode,
                AVMetadataObjectTypeCode39Code,
                AVMetadataObjectTypeCode128Code,
                AVMetadataObjectTypeCode39Mod43Code,
                AVMetadataObjectTypeEAN13Code,
                AVMetadataObjectTypeEAN8Code,
                AVMetadataObjectTypeCode93Code]
            
            //预览图层
            let scanPreviewLayer = AVCaptureVideoPreviewLayer(session:scanSession)
            scanPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            scanPreviewLayer!.frame = view.layer.bounds
            
            view.layer.insertSublayer(scanPreviewLayer!, at: 0)
            
            //设置扫描区域
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil, using: { (noti) in
                output.rectOfInterest = (scanPreviewLayer?.metadataOutputRectOfInterest(for: self.scanPane.frame))!
            })
            
            
            
            
            
            
            //////////////
            
            
            //保存会话
            self.scanSession = scanSession
            
        }
        catch
        {
            //摄像头不可用
            
//            Tool.confirm(title: "温馨提示", message: "摄像头不可用", controller: self)
            
            print("摄像头不可用")
            return
        }
        
    }
    //开始扫描
    fileprivate func startScan()
    {
        
        scanLine.layer.add(scanAnimation(), forKey: "scan")
        
        guard let scanSession = scanSession else { return }
        
        if !scanSession.isRunning
        {
            scanSession.startRunning()
        }
        
        
    }
    
    //扫描动画
    private func scanAnimation() -> CABasicAnimation
    {
        
        let startPoint = CGPoint(x: scanLine .center.x  , y: 1)
        let endPoint = CGPoint(x: scanLine.center.x, y: scanPane.bounds.size.height - 2)
        
        let translation = CABasicAnimation(keyPath: "position")
        translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        translation.fromValue = NSValue(cgPoint: startPoint)
        translation.toValue = NSValue(cgPoint: endPoint)
        translation.duration = scanAnimationDuration
        translation.repeatCount = MAXFLOAT
        translation.autoreverses = true
        
        return translation
    }
    
    //相册
    @IBAction func photo()
    {
        
//        Tool.shareTool.choosePicture(self, editor: true, options: .photoLibrary) {[weak self] (image) in
//            
//            self!.activityIndicatorView.startAnimating()
//            
//            DispatchQueue.global().async {
//                let recognizeResult = image.recognizeQRCode()
//                let result = recognizeResult?.characters.count > 0 ? recognizeResult : "无法识别"
//                DispatchQueue.main.async {
//                    self!.activityIndicatorView.stopAnimating()
//                    Tool.confirm(title: "扫描结果", message: result, controller: self!)
//                }
//            }
//        }
        
    }

    //闪光灯
    @IBAction func light(_ sender: UIButton)
    {
        
        lightOn = !lightOn
        sender.isSelected = lightOn
        turnTorchOn()
        
    }
    
        ///闪光灯
    private func turnTorchOn()
    {
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else
        {
            
            if lightOn
            {
                
//                Tool.confirm(title: "温馨提示", message: "闪光灯不可用", controller: self)
                print("闪光灯不可用")
                
            }
            
            return
        }
        
        if device.hasTorch
        {
            do
            {
                try device.lockForConfiguration()
                
                if lightOn && device.torchMode == .off
                {
                    device.torchMode = .on
                }
                
                if !lightOn && device.torchMode == .on
                {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            }
            catch{ }
            
        }
        
    }
    
//    optional public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!)

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!)
    {
        
        print(metadataObjects)
        print("fenggexian")

        //停止扫描
        self.scanLine.layer.removeAllAnimations()
        self.scanSession!.stopRunning()
        
        //播放声音
//        Tool.playAlertSound(sound: "noticeMusic.caf")
        
        //扫完完成
        if metadataObjects.count > 0
        {
            
            if let resultObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject
            {
                
                print(resultObj)
                print(resultObj.stringValue)
//                Tool.confirm(title: "扫描结果", message: resultObj.stringValue, controller: self,handler: { (_) in
                    //继续扫描
//                    self.startScan()
//                })
                let mess = "扫出来是这个：\n "+resultObj.stringValue
                
                let alertController = UIAlertController(title: "提示", message: mess, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in
                    self.startScan()})
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            if let resultObj = metadataObjects.first as? AVMetadataFaceObject
            {
                
                print(resultObj)
                print(resultObj.rollAngle)
                print(resultObj.yawAngle)
                let alertController = UIAlertController(title: "提醒", message: "这是人脸！快去扫描二维码", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "我错了", style: UIAlertActionStyle.default, handler: {
                    action in
                    self.startScan()
                })
                 alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                //                Tool.confirm(title: "扫描结果", message: resultObj.stringValue, controller: self,handler: { (_) in
                //继续扫描
                //                    self.startScan()
                //                })
                
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
