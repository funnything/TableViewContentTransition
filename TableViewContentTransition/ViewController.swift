//
//  ViewController.swift
//  TableViewContentTransition
//
//  Created by Yosaku Toyama on 2020/03/27.
//  Copyright © 2020 Yosaku Toyama. All rights reserved.
//

import Cartography
import DifferenceKit
import Signals
import Then
import UIKit

class ViewController: UIViewController {
    var content = (0..<4).map { Item(id: $0, name: Int.random(in: 0..<3), detail: Int.random(in: 0..<Int.max)) }

    lazy var emptyView: UIView = undefined()
    lazy var tableView: UITableView = undefined()

    override func loadView() {
        super.loadView()

        emptyView = UILabel().then {
            $0.isHidden = true
            $0.text = "No data"
            view.addSubview($0)
            constrain($0) { v in
                v.center == v.sv.center
            }
        }

        tableView = UITableView().then {
            $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            $0.dataSource = self
            $0.delegate = self
            view.addSubview($0)
            constrain($0) { $0.matchParent() }
        }

        let sv = vstack(spacing: 16).then {
            view.addSubview($0)
            constrain($0) { v in
                v.bottom == v.sv.safeAreaLayoutGuide.bottom
                v.leading == v.sv.leading
                v.trailing == v.sv.trailing
            }
        }

        let rows = 4
        let columns = 4
        (0..<rows).forEach { y in
            _ = hstack().then { row in
                row.distribution = .fillEqually
                sv.addArrangedSubview(row)

                (0..<columns).forEach { x in
                    _ = UIButton(type: .system).then {
                        let seq = toSequence(y * columns + x)
                        $0.onTouchUpInside.subscribe(with: self) { [unowned self] in
                            self.updateContent(seq.map { Item(id: $0, name: Int.random(in: 0..<3), detail: Int.random(in: 0..<Int.max)) })
                        }
                        let title = seq.isEmpty ? "empty" : seq.map { "\($0)" }.joined(separator: "-")
                        $0.setTitle(title, for: .normal)
                        row.addArrangedSubview($0)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateContent(_ newContent: [Item]) {
        let changeset = StagedChangeset(source: content, target: newContent)
        if changeset.isEmpty {
            // Update even if changes is empty (non-visible property may updated)
            content = newContent
        } else {
            if content.isEmpty {
                UIView.crossFade(toShow: tableView, toHide: emptyView)
            } else if newContent.isEmpty {
                UIView.crossFade(toShow: emptyView, toHide: tableView)
            }

            tableView.reload(using: changeset, with: .automatic) { data in
                content = data
            }
        }
    }

    func toSequence(_ value: Int) -> [Int] {
        var v = value
        var i = 0
        var seq = [Int]()
        while v > 0 {
            if v % 2 > 0 {
                seq.append(i)
            }
            v /= 2
            i += 1
        }
        return seq
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath).then {
            let item = content[indexPath.row]
            $0.textLabel?.text = "\(item.id) (\(item.name))"
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Check item detail
        dump(content[indexPath.row])
    }
}

struct Item: Differentiable {
    let id: Int
    let name: Int
    let detail: Int

    var differenceIdentifier: Int {
        return id
    }

    func isContentEqual(to source: Item) -> Bool {
        return name == source.name
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

func hstack(spacing: CGFloat? = nil) -> UIStackView {
    UIStackView().then {
        $0.axis = .horizontal
        if let spacing = spacing {
            $0.spacing = spacing
        }
    }
}

func vstack(spacing: CGFloat? = nil) -> UIStackView {
    UIStackView().then {
        $0.axis = .vertical
        if let spacing = spacing {
            $0.spacing = spacing
        }
    }
}

extension UIView {
    static func crossFade(toShow: UIView, toHide: UIView) {
        toShow.alpha = 0
        toShow.isHidden = false

        UIView.animate(
            withDuration: 0.2,
            animations: {
                toShow.alpha = 1
                toHide.alpha = 0
            },
            completion:  { _ in
                toHide.isHidden = true
            }
        )
    }
}
