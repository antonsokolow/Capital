//
//  DispatchQueue.swift
//  Capital.iOS
//
//  Created by Anton Sokolov on 31.08.2019.
//  Copyright © 2019 Anton Sokolov. All rights reserved.
//

import Foundation


func background(work: @escaping () -> ()) {
    DispatchQueue.global(qos: .userInitiated).async {
        work()
    }
}

func main(work: @escaping () -> ()) {
    DispatchQueue.main.async {
        work()
    }
}

func delay(delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(wallDeadline: .now() + delay) {
        closure()
    }
}
