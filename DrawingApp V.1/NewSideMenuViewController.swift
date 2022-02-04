//
//  NewSideMenuViewController.swift
//  DrawingApp V.1
//
//  Created by Mohammed Qureshi on 2021/09/20.
//

//Thread 1: EXC_BAD_ACCESS (code=2, address=0x7ffedf76df18) remember don't make multiple instances of the vcs

import UIKit

class NewSideMenuViewController: UIViewController {

    let imageView = UIImageView()
    let tableView = UITableView()
    
   let mainVC = ViewController()
    
    //create an enum that handles state changes to go to different vcs.
    
    enum SideMenuOptions: String, CaseIterable {
        //Types that conform to the CaseIterable protocol are typically enumerations without associated values. When using a CaseIterable type, you can access a collection of all of the type’s cases by using the type’s allCases property.
        
        case Home = "Home"
        case Load = "Load Previous Drawings"
        case Instructions = "Instructions"
        case About = "About"
        case Close = "Close"
        
        var imageName: String {
            switch self {// self because we're calling this vc.
            case .Home: //set case then set image name
               return "house" //String literal is unused = no return declared
            case .Load:
                return "rectangle.on.rectangle"
            case .Instructions:
                return ""
            case .About:
                return ""
            case .Close:
                return ""
            
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
//        imageView.anchors(top: view.topAnchor, bottom: view.lastBaselineAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)
        // Do any additional setup after loading the view.
       // callSideMenu()
        //let imageBox = imageView.frame.size(CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
        imageView.anchors(top: view.topAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)
        view.addSubview(imageView)
        
        callSideMenu()
        
    }
    

    func callSideMenu() {
        mainVC.delegate = self
        //storyboard?.instantiateViewController(identifier: "SideMenuVC") as? NewSideMenuViewController
        addChild(mainVC) //add a child view controller that we can call here.
        view.addSubview(mainVC.view) //we then call the view as a subview of the side menu
        mainVC.didMove(toParent: self) //Called after the view controller is added or removed from a container view controller. Your view controller can override this method when it wants to react to being added to a container.
        
        //if we add a new vcs we can add this here.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}

struct NewSideMenuModel {
    var icon: UIImage
    var title: String
}

class SideMenuCell:UITableViewCell {
    class var identifier: String { return String(describing: self)}
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil)} //need to to create a nib file
    var tableViewIconImageView = UIImageView()
    
    var titleLabel = UILabel()
    
    override func awakeFromNib() { //override func not override class func otherwise you can't access properties above!
        super.awakeFromNib()
        
        let tableViewIconImageViewWidth = CGFloat(30.0)
        let tableViewIconImageViewHeight = CGFloat(30.0)
        
        tableViewIconImageView.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: tableViewIconImageViewWidth, height: tableViewIconImageViewHeight))
        
        
        self.backgroundColor = .clear
        
        self.tableViewIconImageView.tintColor = .white
    }
    
}

extension NewSideMenuViewController: MainViewControllerDelegate {
    func showSideMenu() {
        //animate the menu
       //performSegue(withIdentifier: "showSideMenu", sender: self)
        print("Button tapped")
    }
}
