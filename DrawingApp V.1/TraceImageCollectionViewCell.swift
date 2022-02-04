//
//  TraceImageCollectionViewCell.swift
//  DrawingApp V.1
//
//  Created by Mohammed Qureshi on 2021/12/01.
//

import UIKit

class TraceImageCollectionViewCell: UICollectionViewCell {
    
    enum drawing: String { //might want to use this later. Well its actually better if im creating hard coded images from assets to just have an enum to handle switching between drawings.
        //This was super userful in getting all the values and having them grouped here as an enum with associated values.
        //typealias RawValue = UIInt
        case airplane = "airplane"
        case car = "car"
        case cat = "cat" //don't add parens for enum
        case hero = "hero"
        case shinkansen = "bulletTrain"
        case earthMoonAndSun = "earthMoonAndSun"
        case mountains = "mountains"
        case normalTrain = "normalTrain"
      
        var imageName: String {
            switch self {
            case.airplane:
                return "airplane.png"
            case.car:
                return "car.png"
            case.cat:
                return "cat.png"
            case.hero: //Enum case 'hero' cannot be used as an instance member = NO DOT NOTATION!
                return "hero.png"
            case.shinkansen:
                return "shinkansen.png"
            case .earthMoonAndSun:
                return "moonearthandsun.png"
            case .mountains:
                return "Mountains.png"
            case .normalTrain:
                return "normalTrain.png"
            }
        }
        
    } //You're going to have to give this enum its own class in the future because there will be far more images that you'll keep adding.
    
    
    
    static let identifier = "TraceImageCollectionViewCell"
    
    //we can create the image view specifically so it contains images from the assets and set the scale so it fills the screen imageView correctly.
    
    private let imageView: UIImageView = {
        //Cannot convert value of type '() -> ()' to specified type 'UIImageView' = has to return a UIImageView also add parens after the closure!
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true //keeps image inside bounds
        
        return imageView
    } ()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //we need to now add the image view to frame
        contentView.addSubview(imageView)
        
        //we can also assign the images here
        
        var drawings = [UIImage(named: drawing.airplane.rawValue), UIImage(named: drawing.airplane.rawValue), UIImage(named: drawing.airplane.rawValue), UIImage(named: drawing.airplane.rawValue), UIImage(named: drawing.airplane.rawValue), UIImage(named: drawing.airplane.rawValue), UIImage(named: drawing.airplane.rawValue)].compactMap({ $0 })
        
        
        //we can use compactMap to remove the nil values if there are any, so we can then call the drawings to return an optional Element.
        
        imageView.image = drawings.popLast() //returns last element in the collection.
    } //create the frame for the image view here
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews() //overrides initial class to layout subviews
        imageView.frame = contentView.bounds //
    }
    
    override func prepareForReuse() {
        super.prepareForReuse() //peforms clean up to reuse view
        imageView.image = nil //need to change this as it starts with a blank image and I want to keep the image.
    }
    
}
