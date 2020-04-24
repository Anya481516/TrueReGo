//
//  AnnotationView.swift
//  ReGo
//
//  Created by Анна Мельхова on 20.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

class AnnotationView : UIView {

    var button = UIButton()

    init (rect: CGRect, button: UIButton) {
        super.init(frame: rect)
        self.button = button
        self.addSubview(self.button)
    }
    
    init () {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
