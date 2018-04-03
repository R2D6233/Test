//
//  TableViewController.swift
//  Test Project
//
//  Created by Admin on 03.04.18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var presents = [Present]()
    
    @IBOutlet weak var tableView: UITableView!
    var managedObjextContent:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = "Photos"
        managedObjextContent = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.view.setGradientBackground(colorOne: UIColor(red: 84/255, green: 150/255,  blue: 255/255, alpha: 1), colorTwo: UIColor(red: 135/255, green: 57/255, blue: 229/255, alpha: 1))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        let presentRequest:NSFetchRequest<Present> = Present.fetchRequest()
        
        do {
            presents = try managedObjextContent.fetch(presentRequest)
            self.tableView.reloadData()
        } catch {
            print("Could not load data from database \(error.localizedDescription)")
        }
    }
    
    // MARK: - Table view data source
    
    var rowHeights:[Int:CGFloat] = [:]
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.rowHeights[indexPath.row]{
            return height + 65.5
        }else{
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presents.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        let presentItem = presents[indexPath.row]
        
        DispatchQueue.main.async {
            if let image = UIImage(data: (presentItem.image)!) {
                let aspectRatio = (image as UIImage).size.height/(image as UIImage).size.width
                cell.photoImageView.image = image
                let imageHeight = cell.photoImageView.frame.width * aspectRatio
                tableView.beginUpdates()
                self.rowHeights[indexPath.row] = imageHeight
                tableView.endUpdates()
            }
        }
        
        if presentItem.date != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            print(presentItem.date)
            let convertedDate = dateFormatter.string(from: presentItem.date!)
            cell.dateLabel.text = convertedDate
        }
        
        cell.nameLabel.text = presentItem.name
        cell.descriptionLabel.text = presentItem.title
        cell.photoImageView.contentMode = .scaleAspectFit
        
        return cell
    }
    
}

extension UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}



