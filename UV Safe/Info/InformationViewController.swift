//
//  InformationViewController.swift
//  UV Safe
//
//  Created by Sapna Patel on 7/24/17.
//  Copyright © 2017 Sapna Patel. All rights reserved.
//

import UIKit

struct InfoCellContent {
    let image: UIImage?
    let details: String?
}

class InformationViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        
        case cells
        
        enum NibName: String, CaseIterable {
            case ImageCell
            case InfoCell
        }
        
        enum Identifier: String, CaseIterable {
            case image
            case info
        }
        
        enum Cells: Int, CaseIterable {
            case chart
            case spf
            case water
            case sunglasses
            case clothes
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    let infoCellContent: [InfoCellContent] = [
        InfoCellContent(image: UIImage(named: "UVChart"), details: nil),
        InfoCellContent(image: UIImage(named: "SPF"), details: "Use SPF 30+ Sunscreen"),
        InfoCellContent(image: UIImage(named: "Water"), details: "Stay Hydrated"),
        InfoCellContent(image: UIImage(named: "Sunglasses"), details: "Wear Polarized Sunglasses"),
        InfoCellContent(image: UIImage(named: "Clothes"), details: "Cover Skin with Clothes")
    ]
    
    var CELL_WIDTH: CGFloat {
        return collectionView.frame.width - 20
    }
    
    var CELL_BOX_SIZE: CGFloat {
        return collectionView.frame.width / 2 - 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.overrideUserInterfaceStyle = .dark
        
        registerNibs()
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
        
        addEasterEgg()
    }

    private func addEasterEgg() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(performEasterEgg))
        longPress.minimumPressDuration = 5
        navigationController?.navigationBar.addGestureRecognizer(longPress)
    }
    
    @objc private func performEasterEgg() {
        let alert = UIAlertController(title: nil, message: "Designed by Mandy ™", preferredStyle: .alert)
        alert.view.tintColor = .black
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            alert.dismiss(animated: true)
        }
    }
}

extension InformationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func registerNibs() {
        for i in 0 ..< Section.NibName.allCases.count {
            let nib = UINib(nibName: Section.NibName.allCases[i].rawValue, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: Section.Identifier.allCases[i].rawValue)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else {
            print("Cannot find section at index \(section).")
            return 0
        }
        
        switch sectionType {
            case .cells:
                return Section.Cells.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellType = Section.Cells(rawValue: indexPath.row) else {
            print("Cannot find section at index \(indexPath.row).")
            return UICollectionViewCell()
        }
        
        switch cellType {
            case .chart:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.image.rawValue,
                                                              for: indexPath) as! ImageCell
                cell.setHeight(to: CELL_BOX_SIZE)
                cell.setWidth(to: CELL_WIDTH)
                
                let content = infoCellContent[indexPath.row]
                cell.imageView.image = content.image
                
                return cell
                
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.info.rawValue,
                                                              for: indexPath) as! InfoCell
                cell.setHeight(to: CELL_BOX_SIZE)
                cell.setWidth(to: CELL_BOX_SIZE)
                
                let content = infoCellContent[indexPath.row]
                cell.imageView.image = content.image
                cell.details.text = content.details
                
                return cell
        }
    }
}
