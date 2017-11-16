//
//  TagsViewController.swift
//  ActionableScreenshots
//
//  Created by Chuy Galvan on 11/15/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit
import RealmSwift

class TagsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var screenshot: Screenshot?
    
    private let REUSABLE_CELL_ID = "tagCell"
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screenshot!.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: REUSABLE_CELL_ID, for: indexPath)
        cell.textLabel?.text = screenshot?.tags[indexPath.row].id
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            try! realm.write {
                let id = screenshot?.tags[indexPath.row].id
                screenshot?.tags.remove(at: indexPath.row)
                let deletedTag = realm.object(ofType: Tag.self, forPrimaryKey: id)
                if deletedTag != nil {
                    if deletedTag!.screenshots.count == 0 {
                        realm.delete(deletedTag!)
                    }
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        if(tableView.isEditing)
        {
            tableView.isEditing = false
            self.navigationItem.rightBarButtonItem?.title = "Done"
        }
        else
        {
            tableView.isEditing = true
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Insert tag", message: "Tag name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if(textField?.text != "") {
                self.screenshot?.addTag(tagString: (textField?.text)!)
                self.tableView.reloadData()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}
