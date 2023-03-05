//
//  ViewController.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Aniket on 02/02/23.
//
import UIKit
import ARKit
import CoreML
import CreateMLComponents
import CoreImage
import Vision
import Accelerate
import AVFoundation


class ViewController: UIViewController, ARSessionDelegate {
    static var Instance = ViewController()
    
    var nodes: [SCNNode] = []
    let node = SCNNode()
    
    var contours: [ContourStruct] = []
    
    var paperBRect = CGRect()
    var feetBRect = CGRect()
    
    var footHeight = Double()
    var FootWidth = Double()
    

    let image = UIImage(named:"vaishnvi.jpg")!
    
    var somethingIsWrong = false
    
  
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var InstructionPanel: UIView!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    
    @IBOutlet weak var calculatSize: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleSwitch.isHidden = true
        activityIndicator.isHidden = true
        configureLighting()
        InstructionPanel.isHidden = true
        addTapGestureToSceneView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.frameSemantics.insert(.personSegmentation)
        UIApplication.shared.isIdleTimerDisabled = true
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling4X
    }

    @IBAction func cleanAllNodes(_ sender: Any) {
        cleanAllNodes()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        sceneView.session.pause()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setUpSceneView()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    
    @IBAction func checkGenderSwitch(_ sender: Any) {
        if toggleSwitch.isOn {
            genderIsMale = false
        }else{
            genderIsMale = true
        }
        
    }
    
    @IBAction func OnCalculateSize(_ sender: Any) {
    
        calculatSize.isHidden = true
        
        Helper.instance.deleteImges()
        var image2 = sceneView.snapshot()
        
        Helper.instance.showLoader()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            sceneView.session.pause()

//            var assumeCrop = self.image
            var assumeCrop = preProcess.instace.assumeCrop(image: image2, width: 120.0, height: 135.0)
            Helper.instance.saveImage(image: assumeCrop, name: "assumeCrop")
            if assumeCrop != nil {
                
                let gaussianBlur = preProcess.instace.applyGaussianBlur(to: assumeCrop)
                Helper.instance.saveImage(image: gaussianBlur!, name: "gaussianBlur")
                if gaussianBlur != nil {
                    
                    let convertRGBToHSV = preProcess.instace.convertRGBToHSV(image: assumeCrop)
                    Helper.instance.saveImage(image: convertRGBToHSV!, name: "convertRGBToHSV")
                    if gaussianBlur != nil {
                        
                        let normalize = preProcess.instace.normalizeImage(image: convertRGBToHSV!)
                        Helper.instance.saveImage(image: normalize!, name: "normalize")
                        if gaussianBlur != nil {
                            
                            let kmeanImage = KMeansClusterer.instace.ClusterImage(image: normalize!)
                            Helper.instance.saveImage(image: kmeanImage!, name: "kmeanImage")
                            if kmeanImage != nil {
                                
                                let edge = edgeDetection.instace.outerEdgeDetction(kmeanImage!)
                                Helper.instance.saveImage(image: edge, name: "outerEdge")
                                if edge != nil {
                                    
                                    let paperCropedImg = findTheContours.instace.findPaperContours(edge, originalImage: kmeanImage!)
                                    Helper.instance.saveImage(image: paperCropedImg, name: "paperCropedImg")
                                    if paperCropedImg != nil {
                                        
                                        let  croppedImage = cropImages.instance.croppedImage(bRect: ViewController.Instance.paperBRect, image: paperCropedImg)
                                        Helper.instance.saveImage(image: croppedImage, name: "croppedImage")
                                        if croppedImage != nil {
                                            
                                            let edgeAgain = edgeDetection.instace.outerEdgeDetction(croppedImage)
                                            Helper.instance.saveImage(image: edgeAgain, name: "InnerEdgeAgain")
                                            if croppedImage != nil {
                                                
                                                let feetContours = findTheContours.instace.findFeetContours(edgeAgain)
                                                Helper.instance.saveImage(image: feetContours, name: "feetContours")
                                                if feetContours != nil {
                                                    
                                                    Helper.instance.hideLoader()
                                                    
                                                    let calculate = postProcess.instace.calcFeetSize(pcropedImg: paperCropedImg, oimg: croppedImage, fboundRect: ViewController.Instance.feetBRect)
                                                    showSize(calculate.0 , calculate.1)
                                                }
                                                else {
                                                    someThingWrong()
                                                }
                                            }
                                            else{
                                                someThingWrong()
                                            }
                                        }
                                        else {
                                            someThingWrong()
                                        }
                                    }
                                    else {
                                        someThingWrong()
                                    }
                                }
                                else {
                                    someThingWrong()
                                }
                            }
                            else{
                                someThingWrong()
                            }
                        }
                        else {
                            someThingWrong()
                        }
                    }
                    else {
                        someThingWrong()
                    }
                }
                else {
                    someThingWrong()
                }
            }
            else {
                someThingWrong ()
            }
        }
    }
    
    
    func showSize (_ height : String , _ width : String) {
        let alertControl = UIAlertController(title: "Your Shoe Size!", message: "Height : \(height) CM & Width : \(width) CM" , preferredStyle: .alert)
        let size = UIAlertAction(title: "Okay", style: .cancel) { [self] action in
            self.dismiss(animated: true)
            cleanAllNodes()
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            sceneView.session.pause()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.calculatSize.isHidden = false
                self.setUpSceneView()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        alertControl.addAction(size)
        present(alertControl, animated: true, completion: nil)
    }
    
    
    func someThingWrong () {
        Helper.instance.hideLoader()
        let alertControl = UIAlertController(title: "Alert!", message: "Something went wrong please rescan" , preferredStyle: .alert)
        let size = UIAlertAction(title: "Rescan", style: .cancel) { [self] action in
            self.dismiss(animated: true)
            somethingIsWrong = false
            cleanAllNodes()
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            sceneView.session.pause()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setUpSceneView()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.dismiss(animated: true)
            }
        }
        alertControl.addAction(size)
        present(alertControl, animated: true, completion: nil)
    }
    
    
    
    @IBAction func onInfoButtonClicked(_ sender: Any) {
        InstructionPanel.layer.cornerRadius = 50
        if InstructionPanel.isHidden == false {
            self.InstructionPanel.isHidden = true
            self.toggleSwitch.isHidden = true
        }
        else {
            InstructionPanel.isHidden = false
            UIView.transition(with: InstructionPanel, duration: 0.4,
                              options: .transitionFlipFromTop,
                              animations: {
                self.toggleSwitch.isHidden = false
                self.InstructionPanel.isHidden = false
            })
        }
    }
    
    func cleanAllNodes() {
        if nodes.count > 0 {
            for node in nodes {
                node.removeFromParentNode()
            }
            nodes = []
        }
    }
    

    
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        let supportNode = SCNNode()
        supportNode.geometry = SCNBox(width: 1.0, height: 0.0001, length: 1.0, chamferRadius: 0.3)
        supportNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 128/255, green: 96/255, blue: 77/255, alpha: 1.0)
        supportNode.eulerAngles = SCNVector3(0, 0, 0)
        supportNode.position = SCNVector3(x,y,z)
        nodes.append(supportNode)
        sceneView.scene.rootNode.addChildNode(supportNode)
        
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.210, height: 0.0005, length: 0.300, chamferRadius: 0)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        let rotation = SCNVector3(0, 0, 0)
        node.eulerAngles = rotation
        node.position = SCNVector3(x,y,z)
        nodes.append(node)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    public class var transparentLightBlue: UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.00)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        plane.materials.first?.diffuse.contents = UIColor.clear
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(x,y,z)
        
        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
              let planeNode = node.childNodes.first,
              let plane = planeNode.geometry as? SCNPlane
        else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}

