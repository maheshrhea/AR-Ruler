//
//  ViewController.swift
//  AR Ruler


import UIKit
import SceneKit
import ARKit
import Firebase

class ViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate{
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var hConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextfield: UITextField!
    
    @IBOutlet weak var Label: UILabel!
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
    }
    
    
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    var objArray : [Name] = [Name]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
            
        }
    }
    
    func addDot(at hitResult : ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate (){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
                pow(end.position.y - start.position.y, 2) +
                pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(abs(distance))", atPosition: end.position)
        
        if distance >= 0.05{
            let alert = UIAlertController(title: "Threat", message: "Hypothyroidism chances high", preferredStyle: .alert)
            let exit = UIAlertAction(title: "Okay", style: .default) { (_) in
                self.startOver()
            }
            alert.addAction(exit)
            present(alert, animated: true, completion: nil)
        }else if distance >= 0.03 && distance<0.05{
            let alert2 = UIAlertController(title: "Risk", message: "Hypothyroidism chances moderate", preferredStyle: .alert)
            let exit2 = UIAlertAction(title: "Okay", style: .default) { (_) in
                self.startOver()
            }
            alert2.addAction(exit2)
            present(alert2, animated: true, completion: nil)
        }else{
            let alert3 = UIAlertController(title: "Safe", message: "Hypothyroidism chances low", preferredStyle: .alert)
            let exit3 = UIAlertAction(title: "Okay", style: .default) { (_) in
                self.startOver()
            }
            alert3.addAction(exit3)
            present(alert3, animated: true, completion: nil)
        }
    }
    
    func updateText(text: String, atPosition position: SCNVector3){
        sceneView.session.pause()
        
        Label.text = "Result: \(text)"
        
        UIView.animate(withDuration: 2.0) {
            self.hConstraint.constant = 0
            self.view.layoutIfNeeded()
        }

        
        textNode.removeFromParentNode()

        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)

        textGeometry.firstMaterial?.diffuse.contents = UIColor.red

        textNode = SCNNode(geometry: textGeometry)

        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)

        textNode.scale = SCNVector3(0.01, 0.01, 0.01)

        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    
    @IBAction func saveRecord(_ sender: Any) {
        // save the recorde)
        UIView.animate(withDuration: 2.5) {
            self.hConstraint.constant = 600
            self.view.layoutIfNeeded()
        }
        for dot in dotNodes {
            dot.removeFromParentNode()
        }
        dotNodes = [SCNNode]()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        sceneView.addGestureRecognizer(tapGesture)
        
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        
        let namesDB = FIRDatabase.database().reference().child("Names")
       
        let namesDict = ["Name": messageTextfield.text, "Result": Label.text]
        
        namesDB.childByAutoId().setValue(namesDict){
            (error, ref) in
            
            if error != nil{
                print(error!)
            }else{
                print("Name saved successfully")
                
                self.messageTextfield.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    @IBAction func cancelRecord(_ sender: Any) {
        
        UIView.animate(withDuration: 2.5) {
            self.hConstraint.constant = 600
            self.view.layoutIfNeeded()
        }
        for dot in dotNodes {
            dot.removeFromParentNode()
        }
        dotNodes = [SCNNode]()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        messageTextfield.endEditing(true)
        
        sceneView.clearsContextBeforeDrawing = true
    }
    
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    
        UIView.animate(withDuration:  0.5) {
            self.hConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration:  0.5) {
            self.hConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    @IBOutlet weak var myLabel: UILabel!
    
    func startOver(){
        
    }
    }
    













