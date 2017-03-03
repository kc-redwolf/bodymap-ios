//
//  GameViewController.swift
//  BodyMap
//
//  Created by Michael Miller on 2/25/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class MainViewController: UIViewController, SceneKitViewDelegate, SCNSceneRendererDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var sceneKitView: SceneKitView!
    @IBOutlet weak var bottomSheet: BottomSheetView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates and scene
        sceneKitView.setScene(delegate: self, scene: Constants.car)
        
        // Init TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 68
    }
    
    // MARK: SceneView Delegate
    func sceneViewDidBeginMoving(position: SCNVector3) {
        //        print("\(position.x) : \(position.y) : \(position.z)")
    }
    
    func sceneViewItemSelected(name: String) {
        print(name)
    }
    
    // MARK: TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        return cell
    }

}
