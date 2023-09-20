//
//  ManualAlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 4/2/23.
//

import UIKit

class ManualAlgorithmViewController: BaseViewController {
    
    private var scrollView: UIScrollView!
    private var collectionView: UICollectionView!
    
    @IBOutlet weak var stationsLabelImageView: UIImageView!
    @IBOutlet weak var roundsLabelImageView: UIImageView!
    
    private var gamecode = UserData.readGamecode("gamecode")!
    
    private var smallerGrid = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
    
    private var biggerGrid = [[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0]]
    
    private var collectionViewWidth = UIScreen.main.bounds.width * 0.75
    private var collectionViewCellSize : CGSize?
    private var collectionViewCellWidth : CGFloat?
    private var collectionViewCellSpacing: CGFloat = 6.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionViewScrollView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calculateSizesAndContentSize()
        setUpLabels()
    }
    
    
    
    private func calculateSizesAndContentSize() {
        var numberOfItemsInARow = 8 
        let cellSpacing = collectionViewCellSpacing

        if collectionView.numberOfItems(inSection: 0) > 8 {
            numberOfItemsInARow = collectionView.numberOfItems(inSection: 0)
        }
        let contentWidth = CGFloat(numberOfItemsInARow) * (collectionViewCellSize!.width + cellSpacing) + cellSpacing
        
        scrollView.contentSize = CGSize(width: contentWidth, height: collectionView.contentSize.height)
        collectionView.contentSize = scrollView.contentSize
        let collectionViewWidthConstraint = collectionView.widthAnchor.constraint(equalToConstant:  scrollView.contentSize.width)
        collectionViewWidthConstraint.isActive = true
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = collectionViewCellSize!
            flowLayout.minimumInteritemSpacing = collectionViewCellSpacing
            flowLayout.minimumLineSpacing = collectionViewCellSpacing
        }

    }
    
    private func setUpCollectionViewScrollView() {

        let totalSpacing = collectionViewCellSpacing * 9
        let availableWidth = floor(collectionViewWidth - totalSpacing)
        let toTheRight = collectionViewWidth * 0.05
        collectionViewCellWidth = availableWidth / 8
        collectionViewCellSize = CGSize(width: collectionViewCellWidth!, height: collectionViewCellWidth!)

        collectionViewCellSize = CGSize(width: collectionViewCellWidth!,
                                        height: collectionViewCellWidth!)

        //create
        
        scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)



        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:  UICollectionViewFlowLayout())
        collectionView.delaysContentTouches = true
        collectionView.isScrollEnabled = true


        collectionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(collectionView)

        scrollView.backgroundColor = UIColor.yellow
        collectionView.backgroundColor = UIColor.tintColor

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(AlgorithmCollectionViewCell.self, forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")

        let centerYMultiplier: CGFloat = 0.96
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: toTheRight) ,
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:  -view.frame.size.height * (1 - centerYMultiplier)),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            scrollView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75), // Make it square
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setUpLabels() {
        stationsLabelImageView.translatesAutoresizingMaskIntoConstraints = false
        roundsLabelImageView.translatesAutoresizingMaskIntoConstraints = false

        let stationsLabelWidthMultiplier: CGFloat = 116.0 / 281.0
        let roundsLabelHeightMultiplier: CGFloat = 104.0 / 291.0
    
        
        NSLayoutConstraint.activate([
            // Constraints for stationsLabelImageView
            stationsLabelImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: stationsLabelWidthMultiplier),
            stationsLabelImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stationsLabelImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -5 - stationsLabelImageView.frame.height),

            // Constraints for roundsLabelImageView
            roundsLabelImageView.heightAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: roundsLabelHeightMultiplier),
            roundsLabelImageView.trailingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: -5), // 5 points to the left of collectionView
            roundsLabelImageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])


    }
       
}



extension ManualAlgorithmViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return biggerGrid[0].count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return biggerGrid.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "AlgorithmCollectionViewCell", for: indexPath) as? AlgorithmCollectionViewCell else {
            return UICollectionViewCell()
        }
       
        if indexPath.section % 2 == 0 {
            cell.configureTestCell1()
        } else {
            cell.configureTestCell2()
        }

        return cell
    }
    
    
}

extension ManualAlgorithmViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == collectionView.numberOfSections - 1 {
            return UIEdgeInsets(top: 0, left:collectionViewCellSpacing, bottom: 0, right: collectionViewCellSpacing)
        } else if section == 0{
            return UIEdgeInsets(top: collectionViewCellSpacing, left:collectionViewCellSpacing, bottom: collectionViewCellSpacing, right: collectionViewCellSpacing)
        }else {
            return UIEdgeInsets(top: 0, left:collectionViewCellSpacing, bottom: collectionViewCellSpacing, right: collectionViewCellSpacing)
        }
    }
}
