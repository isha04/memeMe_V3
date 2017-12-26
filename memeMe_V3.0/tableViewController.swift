//
//  tableView.swift
//  memeMe_V3.0
//
//  Created by amarjeet on 23/12/17.
//  Copyright © 2017 amarjeet. All rights reserved.
//

import Foundation
import UIKit

class tableViewController: UITableViewController {
    
    var images: [UIImage] = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.images = memeCreate().images
        //memeCreate().refreshTable()
        //self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resuseIdentifier")!
        cell.imageView?.image = images[indexPath.row]
        //cell.textLabel?.text = (memeCreate().titles)[indexPath.row]
        cell.imageView?.contentMode = .scaleAspectFit
        return cell
    }
    
    @IBAction func createMeme(_ sender: Any) {
        performSegue(withIdentifier: "createMeme", sender: sender)
    }
    
    
}
