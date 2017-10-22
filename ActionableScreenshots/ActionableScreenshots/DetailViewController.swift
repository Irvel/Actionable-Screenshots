//
//  DetailViewController.swift
//  ActionableScreenshots
//
//  Created by Chuy Galvan on 10/21/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import UIKit
import Photos

class DetailViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    var idForImage: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        let imageFetch = PHAsset.fetchAssets(withLocalIdentifiers: [idForImage], options: nil).firstObject
        
        PHImageManager.default().requestImage(for: imageFetch!, targetSize: CGSize(width: imgView.frame.size.width, height: imgView.frame.size.height), contentMode: .aspectFit, options: nil) { (image: UIImage?, info: [AnyHashable: Any]?) -> Void in
            self.imgView.image = image
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let act = UIActivityViewController(activityItems: [self.imgView.image!], applicationActivities: nil)
        act.popoverPresentationController?.sourceView = self.view
        self.present(act, animated: true, completion: nil)
    }

}
