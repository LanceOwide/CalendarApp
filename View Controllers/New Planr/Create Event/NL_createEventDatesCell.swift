//
//  NL_createEventCell.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/18/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit


class createEventDatesCell: UICollectionViewCell {
    
//    setup the text for the view
    let monthText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.contentMode = .scaleAspectFill
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
//    setup the text for the view
    let dayText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.contentMode = .scaleAspectFill
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //    setup the text for the view
let dowText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.contentMode = .scaleAspectFill
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
//    setup a container view for the label, since we can't puyt this directly into the view
    let textView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleHeightAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    
//    setup the views
    override init(frame: CGRect) {
      super.init(frame: frame)
        
        let monthHeight = CGFloat(20)
        let dayHeight = CGFloat(30)
        let dotWHeight = CGFloat(20)
        let width = CGFloat(75)
        let cellSize = CGFloat(80)
        
//
        
//        add the views to the content view
        self.contentView.addSubview(cellView)
        self.contentView.addSubview(textView)
        textView.addSubview(monthText)
        textView.addSubview(dayText)
        textView.addSubview(dowText)
        
        //x,y,w,h
        bubbleViewRightAnchor = cellView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = cellView.leftAnchor.constraint(equalTo: self.rightAnchor, constant: 8)
        cellView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = cellView.widthAnchor.constraint(equalToConstant:cellSize)
        bubbleHeightAnchor = cellView.heightAnchor.constraint(equalToConstant: cellSize)
        bubbleWidthAnchor?.isActive = true
        bubbleHeightAnchor?.isActive = true
        cellView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
//        add the textView beneatht the image
        textView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textView.backgroundColor = .white
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: cellSize).isActive = true
        textView.heightAnchor.constraint(equalToConstant: cellSize).isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
//        add the text into the textView
        monthText.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        monthText.backgroundColor = .white
        monthText.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        monthText.widthAnchor.constraint(equalToConstant: width).isActive = true
        monthText.heightAnchor.constraint(equalToConstant: monthHeight).isActive = true
        monthText.translatesAutoresizingMaskIntoConstraints = false
        
        //        add the text into the textView
        dayText.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        dayText.backgroundColor = .white
        dayText.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        dayText.widthAnchor.constraint(equalToConstant: width).isActive = true
        dayText.heightAnchor.constraint(equalToConstant: dayHeight).isActive = true
        dayText.translatesAutoresizingMaskIntoConstraints = false
        
        //        add the text into the textView
        dowText.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        dowText.backgroundColor = .white
        dowText.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        dowText.widthAnchor.constraint(equalToConstant: width).isActive = true
        dowText.heightAnchor.constraint(equalToConstant: dotWHeight).isActive = true
        dowText.translatesAutoresizingMaskIntoConstraints = false
    
    }
    
//    this is needed for the reuse of each cell
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
//    not sure what this does
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
}



