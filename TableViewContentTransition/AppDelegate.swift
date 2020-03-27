//
//  AppDelegate.swift
//  TableViewContentTransition
//
//  Created by Yosaku Toyama on 2020/03/27.
//  Copyright © 2020 Yosaku Toyama. All rights reserved.
//

import Then
import UIKit

func undefined<T>(_ name: String = #function, file: StaticString = #file, line: UInt = #line) -> T {
    fatalError("\(name) is not initialized", file: file, line: line)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds).then {
            $0.rootViewController = ViewController()
            $0.backgroundColor = .white
            $0.makeKeyAndVisible()
        }

        return true
    }
}
