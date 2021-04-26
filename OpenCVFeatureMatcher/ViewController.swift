//
//  ViewController.swift
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func didPressedButton(_ sender: Any) {

        let grayImage = OpenCVWrapper.toGray(catImageView.image!)

        catImageView.image = grayImage

    }

}

