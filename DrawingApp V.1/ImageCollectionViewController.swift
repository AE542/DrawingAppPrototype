//
//  ImageCollectionViewController.swift
//  DrawingApp V.1
//
//  Created by Mohammed Qureshi on 2021/11/29.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
   // var cellID = "CollectionViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //need to register the TraceImagecollectionView cell NOT the one included in this class.
        
        self.collectionView!.register(TraceImageCollectionViewCell.self, forCellWithReuseIdentifier: TraceImageCollectionViewCell.identifier)
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 6 //have to return the no of items otherwise they won't show up.
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TraceImageCollectionViewCell.identifier, for: indexPath)
     //remember the traceImage collection view cell id is the static let we created in the TICV cell swift file itself
        
    
        return cell
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView!.frame = view.bounds
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CGFloat(100)
        let height = CGFloat(50)
        let layout = UICollectionViewFlowLayout()
        _ = ImageCollectionViewController.self(collectionViewLayout: layout)
        
        return CGSize(width: width, height: height)
    }
    

}
