//
//  MonthView.swift
//  calendarApp
//
//  Created by Lance Owide on 12/12/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

protocol NL_MonthViewDelegate: class {
    func didChangeMonth(monthIndex: Int, year: Int, state: Bool)
}

class NL_MonthView: UIView {
    var monthsArr = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var currentMonthIndex = 0
    var currentYear: Int = 0
    var pendingState: Bool = false
    var delegate: NL_MonthViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        currentMonthIndex = Calendar.current.component(.month, from: Date()) - 1
        currentYear = Calendar.current.component(.year, from: Date())
        
        setupViews()
        
        btnLeft.isEnabled=true
    }
    
    @objc func btnLeftRightActionExpand(sender: UIButton) {
        if sender == btnRight {
            currentMonthIndex += 1
            if currentMonthIndex > 11 {
                currentMonthIndex = 0
                currentYear += 1
            }
        } else if sender == btnLeft {
            currentMonthIndex -= 1
            if currentMonthIndex < 0 {
                currentMonthIndex = 11
                currentYear -= 1
            }
            }
        else if sender == pendingToggle{
        print("user changed the toggle status")
        pendingState = pendingToggle.isOn
        }
        
        lblName.text="\(monthsArr[currentMonthIndex]) \(currentYear)"
        delegate?.didChangeMonth(monthIndex: currentMonthIndex, year: currentYear, state: pendingState)
    }
    
    func setupViews() {
        self.addSubview(lblName)
        lblName.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive=true
        lblName.centerXAnchor.constraint(equalTo: centerXAnchor).isActive=true
        lblName.widthAnchor.constraint(equalToConstant: 150).isActive=true
        lblName.heightAnchor.constraint(equalToConstant: 30).isActive=true
        lblName.text="\(monthsArr[currentMonthIndex]) \(currentYear)"
        
        self.addSubview(btnRight)
        btnRight.topAnchor.constraint(equalTo: topAnchor,constant: 10).isActive=true
        btnRight.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive=true
        btnRight.widthAnchor.constraint(equalToConstant: 30).isActive=true
        btnRight.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
        self.addSubview(btnLeft)
        btnLeft.topAnchor.constraint(equalTo: topAnchor,constant: 10).isActive=true
        btnLeft.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive=true
        btnLeft.widthAnchor.constraint(equalToConstant: 30).isActive=true
        btnLeft.heightAnchor.constraint(equalToConstant: 30).isActive=true
        
////        add the switch
//        self.addSubview(pendingToggle)
//        pendingToggle.transform = CGAffineTransform(scaleX: 1, y: 1)
//        pendingToggle.topAnchor.constraint(equalTo: topAnchor, constant: 22).isActive = true
//        pendingToggle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        print("setting up the pendingToggle \(pendingState)")
//        pendingToggle.setOn(pendingState, animated: true)
//
        
//        based on whether the user is viewing pending events of not we show a different label on the header
        
        
        self.addSubview(lblConfirmed)
        lblConfirmed.text = "Confirmed"
        lblConfirmed.translatesAutoresizingMaskIntoConstraints = false
        lblConfirmed.textColor = MyVariables.colourPlanrGreen
        lblConfirmed.font = UIFont.systemFont(ofSize: 13)
        lblConfirmed.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        lblConfirmed.centerXAnchor.constraint(equalTo: centerXAnchor,constant: -50).isActive = true

            
            self.addSubview(lblAnd)
            lblAnd.text = "&"
            lblAnd.translatesAutoresizingMaskIntoConstraints = false
            lblAnd.textColor = MyVariables.colourLight
            lblAnd.font = UIFont.systemFont(ofSize: 13)
            lblAnd.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            lblAnd.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        
        

            self.addSubview(lblPending)
            lblPending.text = "Pending"
            lblPending.translatesAutoresizingMaskIntoConstraints = false
            lblPending.textColor = MyVariables.colourPendingText
            lblPending.font = UIFont.systemFont(ofSize: 13)
            lblPending.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            lblPending.centerXAnchor.constraint(equalTo: centerXAnchor,constant: 45).isActive = true
            


            self.addSubview(lblConfirmedCenter)
            lblConfirmedCenter.text = "Confirmed"
            lblConfirmedCenter.translatesAutoresizingMaskIntoConstraints = false
            lblConfirmedCenter.textColor = MyVariables.colourPlanrGreen
            lblConfirmedCenter.font = UIFont.systemFont(ofSize: 13)
            lblConfirmedCenter.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
            lblConfirmedCenter.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        if pendingState == true{
            lblPending.isHidden = false
            lblAnd.isHidden = false
            lblConfirmed.isHidden = false
            lblConfirmedCenter.isHidden = true
        }
        else{
            lblPending.isHidden = true
            lblAnd.isHidden = true
            lblConfirmed.isHidden = true
            lblConfirmedCenter.isHidden = false
        }
        
    }
    
    let lblName: UILabel = {
        let lbl=UILabel()
        lbl.text="Default Month Year text"
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center
        lbl.font=UIFont.boldSystemFont(ofSize: 16)
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let lblConfirmed: UILabel = {
        let lbl=UILabel()
        lbl.text="Default Month Year text"
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center
        lbl.font=UIFont.boldSystemFont(ofSize: 16)
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let lblPending: UILabel = {
        let lbl=UILabel()
        lbl.text="Default Month Year text"
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center
        lbl.font=UIFont.boldSystemFont(ofSize: 16)
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let lblConfirmedCenter: UILabel = {
        let lbl=UILabel()
        lbl.text="Default Month Year text"
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center
        lbl.font=UIFont.boldSystemFont(ofSize: 16)
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let lblAnd: UILabel = {
        let lbl=UILabel()
        lbl.text="Default Month Year text"
        lbl.textColor = UIColor.black
        lbl.textAlignment = .center
        lbl.font=UIFont.boldSystemFont(ofSize: 16)
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    
    let btnRight: UIButton = {
        let btn=UIButton()
        btn.setTitle(">", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
//        btn.layer.borderWidth = 2
//        btn.layer.borderColor = MyVariables.colourLight.cgColor
//        btn.layer.masksToBounds = true
//        btn.layer.cornerRadius = 3
        btn.translatesAutoresizingMaskIntoConstraints=false
        btn.addTarget(self, action: #selector(btnLeftRightActionExpand(sender:)), for: .touchUpInside)
        return btn
    }()
    
    let btnLeft: UIButton = {
        let btn=UIButton()
        btn.setTitle("<", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints=false
//        btn.layer.borderWidth = 2
//        btn.layer.borderColor = MyVariables.colourLight.cgColor
//        btn.layer.masksToBounds = true
//        btn.layer.cornerRadius = 3
        btn.addTarget(self, action: #selector(btnLeftRightActionExpand(sender:)), for: .touchUpInside)
        btn.setTitleColor(UIColor.lightGray, for: .disabled)
        return btn
    }()
    
    let btnExand: UIButton = {
        let btn=UIButton()
        btn.setTitle("˯", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints=false
//        btn.layer.borderWidth = 2
//        btn.layer.borderColor = MyVariables.colourLight.cgColor
//        btn.layer.masksToBounds = true
//        btn.layer.cornerRadius = 3
        btn.addTarget(self, action: #selector(btnLeftRightActionExpand(sender:)), for: .touchUpInside)
        btn.setTitleColor(UIColor.lightGray, for: .disabled)
        return btn
    }()
    
    let pendingToggle: UISwitch = {
      let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(btnLeftRightActionExpand(sender:)), for: .valueChanged)
        toggle.onTintColor = MyVariables.colourPendingText
    return toggle
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


