//
//  ViewController.swift
//  TableViewContentTransition
//
//  Created by Yosaku Toyama on 2020/03/27.
//  Copyright © 2020 Yosaku Toyama. All rights reserved.
//

import Cartography
import Then
import UIKit

class ViewController: UIViewController {
    var content = [0, 1, 2, 3, 4]

    lazy var emptyView: UIView = undefined()
    lazy var tableView: UITableView = undefined()

    override func loadView() {
        super.loadView()

        emptyView = UILabel().then {
            $0.text = "No data"
            view.addSubview($0)
            constrain($0) { v in
                v.center == v.sv.center
            }
        }

        tableView = UITableView().then {
            $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            $0.dataSource = self
            view.addSubview($0)
            constrain($0) { $0.matchParent() }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath).then {
            let item = content[indexPath.row]
            $0.textLabel?.text = "\(item)"
        }
    }
}

extension ViewProxy {
    var sv: ViewProxy {
        guard let sv = superview else {
            fatalError("superview == nil")
        }
        return sv
    }

    func match(to anchor: ViewProxy) {
        top == anchor.top
        bottom == anchor.bottom
        leading == anchor.leading
        trailing == anchor.trailing
    }

    func matchParent() {
        match(to: sv)
    }
}
