//
//  ViewController.swift
//  NextReality_Tutorial9
//
//  Created by Ambuj Punn on 10/30/18.
//  Copyright © 2018 Ambuj Punn. All rights reserved.
//  With help from https://hackernoon.com/playing-videos-in-augmented-reality-using-arkit-7df3db3795b7
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    // 4.2
    var grids = [Grid]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // 4.4
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        // 4.1
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // 4.7
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // 4.5
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // 4.3
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = Grid(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
            }.first
        
        guard let foundGrid = grid else {
            return
        }
        
        foundGrid.update(anchor: planeAnchor)
    }
    
    // 4.8
    @objc func tapped(gesture: UITapGestureRecognizer) {
        // Get 2D position of touch event on screen
        let touchPosition = gesture.location(in: sceneView)
        
        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)
        
        guard let hitTest = hitTestResults.first else {
            return
        }
       
        addTV(hitTest)
    }
    
    // 4.9
    func addTV(_ hitTestResult: ARHitTestResult) {
        let scene = SCNScene(named: "art.scnassets/tv.scn")!
        let tvNode = scene.rootNode.childNode(withName: "tv_node", recursively: true)
        tvNode?.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
        
        // 5.1
        let tvScreenPlaneNode = tvNode?.childNode(withName: "screen", recursively: true)
        let tvScreenPlaneNodeGeometry = tvScreenPlaneNode?.geometry as! SCNPlane
       
        let tvVideoNode = SKVideoNode(fileNamed: "video.mov")
        let videoScene = SKScene(size: .init(width: tvScreenPlaneNodeGeometry.width*1000, height: tvScreenPlaneNodeGeometry.height*1000))
        videoScene.addChild(tvVideoNode)
        
        tvVideoNode.position = CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2)
        tvVideoNode.size = videoScene.size
        
        let tvScreenMaterial = tvScreenPlaneNodeGeometry.materials.first(where: { $0.name == "video" })
        tvScreenMaterial?.diffuse.contents = videoScene
        
        tvVideoNode.play()
        // 4.9
        self.sceneView.scene.rootNode.addChildNode(tvNode!)
    }
}
