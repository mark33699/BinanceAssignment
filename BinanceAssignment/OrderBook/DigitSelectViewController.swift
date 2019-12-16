//
//  DigitSelectViewController.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/16.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit

let digitSelectMenuWidth = 100
let digitSelectButtonHeight = 40

class DigitSelectViewController: BABassViewController
{
    let digitBtn1 = UIButton()
    let digitBtn2 = UIButton()
    let digitBtn3 = UIButton()
    let digitBtn4 = UIButton()
    var buttons: [UIButton]
    {
        [digitBtn1, digitBtn2, digitBtn3, digitBtn4]
    }
    
    var didSelectDigitHandler: ((_ selectIndex: Int) -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .digitSelectMenu
        
        let stackVeiw = UIStackView.init(arrangedSubviews: buttons)
        view.addSubview(stackVeiw)
        stackVeiw.axis = .vertical
        stackVeiw.distribution = .fillEqually
        stackVeiw.snp.makeConstraints
        { (maker) in
            maker.top.equalToSuperview().offset(13) //ArrowHeight
            maker.left.equalToSuperview()
            maker.width.equalTo(digitSelectMenuWidth)
            maker.height.equalTo(digitSelectButtonHeight * 4)
        }
        
        for (offset, btn) in buttons.enumerated()
        {
            btn.tag = offset
            btn.setTitleColor(UIColor.binanceYellow, for: .highlighted)
            btn.addTarget(self, action: #selector(didTapDigit), for: .touchUpInside)
        }
    }
    
    func setupButtonsTitle(from digit: Int)
    {
        for (offset, btn) in buttons.enumerated()
        {
            btn.setTitle("\(digit + offset)", for: .normal)
        }
    }
    
    @objc func didTapDigit(btn: UIButton)
    {
        if let handler = didSelectDigitHandler
        {
            handler(btn.tag)
        }
        dismiss(animated: true, completion: nil)
    }
}
