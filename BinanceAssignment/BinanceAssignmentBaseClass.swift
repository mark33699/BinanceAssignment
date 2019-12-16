//
//  BinanceAssignmentBaseClass.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/11.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit

///BA mean BinanceAssignment, all customized class should inherit from it
class BABassClass
{
    deinit
    {
        print("\(Self.self) deinit")
    }
}

class BABassViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle { .none }
    
    deinit
    {
        print("\(Self.self) deinit")
    }
}

class BATableViewCell: UITableViewCell
{
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
}

class BATableView: UITableView
{
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect, style: UITableView.Style)
    {
        super.init(frame: frame, style: style)
        backgroundColor = .generalBackground
        separatorStyle = .none
        rowHeight = 25
    }
}
