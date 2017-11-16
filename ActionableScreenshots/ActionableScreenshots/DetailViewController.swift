//
//  DetailViewController.swift
//  ActionableScreenshots
//
//  Created by Chuy Galvan on 10/21/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

protocol UIWithCollection {
    func reloadCollection()
}

class DetailViewController: UIViewController {

    @IBOutlet weak var viewTextButton: UIButton!
    @IBOutlet weak var imgView: UIImageView!

    var screenshot: Screenshot?
    var screenshotId: String!
    var previousView: UIWithCollection!


    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        if !screenshot!.hasText {
            viewTextButton.isEnabled = false
            viewTextButton.alpha = 0.45
        }

        let fetchOptions = PHImageRequestOptions()
        fetchOptions.isSynchronous = true
        self.imgView.image = screenshot?.getImage(width: imgView.superview!.frame.size.width, height: imgView.superview!.frame.size.height, contentMode: .aspectFit, fetchOptions: fetchOptions)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showTags") {
            let destinationView = segue.destination as! TagsViewController
            destinationView.screenshot = screenshot
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }

    @IBAction func unwindTagsView(segueUnwind: UIStoryboardSegue) {

    }

    // MARK: - Button actions

    @IBAction func shareButtonTapped(_ sender: Any) {
        let act = UIActivityViewController(activityItems: [self.imgView.image!], applicationActivities: nil)
        act.popoverPresentationController?.sourceView = self.view
        self.present(act, animated: true, completion: nil)
    }

    @IBAction func viewTextButtonTapped(_ sender: Any) {
        if screenshot!.hasText {
            let alertController = UIAlertController(title: "Recognized Text", message: screenshot!.text, preferredStyle: .alert)

            let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                // ...
            }
            alertController.addAction(OKAction)

            self.present(alertController, animated: true) {
                // ...
            }
        }
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.screenshot?.deleteImageFromDevice()

        dismiss(animated: true, completion: {
            let realm = try! Realm()
            try! realm.write {
                realm.delete(self.screenshot!)
            }
            self.previousView.reloadCollection()
        })
    }

}
