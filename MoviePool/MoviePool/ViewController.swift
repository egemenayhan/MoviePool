//
//  ViewController.swift
//  MoviePool
//
//  Created by EGEMEN AYHAN on 22.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import UIKit
import Networker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = TopMoviesRequest(forPage: 1)
        NetworkManager.shared.execute(request) { (result: Result<PaginatedResponse>) in
            switch (result) {
            case .success(let page):
                print("Page: \(page.page.currentPage)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

