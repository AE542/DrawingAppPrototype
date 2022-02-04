//
//  ViewController.swift
//  DrawingApp V.1
//
//  Created by Mohammed Qureshi on 2021/07/11.
//
//2021/07/11 Started Project
//-add accessibility and share options. Also upload to Cloud? Side Menu
//2021/08/12 Set out views one main canvas then work from there.
//2021/08/22 View wasn't showing because NO TRAILING ANCHOR! Also was view.safeAreaLayoutGuides which just wasn't showing up at all.
//2021/09/12 Added navigationVC from SceneDelegate not from the AppDelegate.
//2021/09/13 OK....for some reason the simulator allows the toolpicker to work for but not on the device??? Also can't clear thez canvas...gonna try another way... isn't working either. Something to do with the way the view is initialised... However it's working on the device now as intended in dark mode...but light mode the nav bar is flashing everytime...Why? Something to do with the way the canvas view is being initialised. (Small note for the future: create a drawing data model that gets initialised with a PK Drawing...or bundle identifier to load the pictures you're making for the app).
//2021/09/14 decided to stick with a regular nav controller embeded into the main view for now. Will look into doing it programmatically later. Need to make canvasView a global var so it can allow the delete method to work. Also problem when ipad is in landscape mode, the right side of the screen is obscured...again has somethign to do with the canvasView's initialisation inside the viewWillAppear
//2021/09/15 PROGRESS! Creating an individual instance of a PKToolPicker like so; PKToolPicker.init() allows it to work now! PKToolPicker.shared(for:window) was deprecated so now we have to use it this way. Shows up now, with no individual canvas views made in functions showing up and obscuring the screen with no constraints in landscape mode. This is the best way to do it. Also constraints extension for UIView are working as I wanted, didn't need to create them in the IB.
//2021/09/19 Ok so now the image I made can be loaded into the program within the screen bounds. Creating an extra func in the UIView extension to handle adding resizing the background image is working well to keep it on screen but I want the image to take up the whole canvas view, and not zoom in and out changing the ratio of the image.
//2021/09/20 Having problems making the image stay at the size of the screen while simultaneously maintaining its ratio... Fixed the weird issue where the car was clipping over images of itself, however on device the drawing keep reappearing even after being deleted... resolved the deprecated allowsFingerDrawing -> drawingPolicy = .anyInput, can draw with fingers now.
//2021/09/21 No progress on the side menu. Can't get it to load up without causing a bad access error. Because calling instance of vc on itself. Don't do that.
//2021/09/22 Ok it seems to be when I clear the drawing that the old drawings reappear. So need to figure out why its doing that.

//2021/10/06 Adding share functionality...app is still breaking and freezing when the button is pressed...will need to present the popoverpresentation controller as a bar button item
//2021/10/07 Share popOverPresentation controller was the correct way to get this showing. Is now working in the app! Will need to add some more functionality to it.
//2021/10/10 Ok, can now save images but drawings not being saved with images...may need to make a custom method to save the PKDrawing over the original image.

import UIKit
import PencilKit

protocol MainViewControllerDelegate: AnyObject {
    //to get the side menu to show. Now we've created this here we need to call it in the side menu vc.
    func showSideMenu()
}

//let mainViewHeight = UIScreen.main.nativeBounds.height
//let mainViewWidth = UIScreen.main.nativeBounds.width //both CGFloat

//let mainViewHeight: CGFloat = 768
//let mainViewWidth: CGFloat = 500

class ViewController: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    //PKToolPickerObserver handles the toolpicker on screen.
    
//let sideMenuVC = SideMenu()
//var mainView = UIView()

//let newSideMenuVC = NewSideMenuViewController()
    
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
        case empty = ""
      
        var imageName: String {
            switch self {
            case.airplane:
                return "Airplane.png"
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
                return "mountains.png"
            case .normalTrain:
                return "normalTrain.png"
            case .empty:
                return ""
            }
        }
        
    }
    
    weak var delegate: MainViewControllerDelegate? //weak so we don't cause a memory leak
    //'weak' must not be applied to non-class-bound 'MainViewControllerDelegate'; consider adding a protocol conformance that has a class bound. = this means that we have to make the delegate conform to any object so we can use it.
    
    let dataModelController = DataModelController()
    
    let canvasView = PKCanvasView()
    let toolPicker = PKToolPicker.init() //crucial! Allows us to create individual instances of the toolPicker.
    var currentDrawing = String()
    
   // let newCanvasView = PKCanvasView()
   // let views = Views()
    var buttonChangeCounter = 1
    
    var pkDrawing = PKDrawing() //create a blank drawing we can call upon when we want to save or add a new drawing.
    var newPKDrawing = PKDrawing()
    //before there were vars for each of the pictures. Bad idea, better to use an enum to handle them with a switch case for each. Will need to make a new file to call upon the images.
    
    let imageView = UIImageView()
    var currentImage: UIImage? //if you make an optional UIImage, we could implement it when changing the current displayed image.
    //let drawings = [car, airplane]
    
    
    //let mainViewHeight = UIScreen.main.nativeBounds.height
    let mainViewWidth = UIScreen.main.nativeBounds.width //both CGFloat
    
    //let mainViewWidth = 500
    let canvasViewOverScrollHeight: CGFloat = 500
    
    
    let share = UIImage(systemName:"square.and.arrow.up")
    
    let handDrawing = UIImage(systemName: "hand.draw")
    
    var hasModifiedDrawing = false
    
    var drawingIndex: Int = 0
    
    
    var totalImages = [drawing.hero.rawValue, drawing.shinkansen.rawValue, drawing.airplane.rawValue, drawing.cat.rawValue]
//    let viewWidth = view.bounds.width
//    let viewHeight = view.bounds.height
    
    var removeIsPressed = false // to change the button text
    
    //remember just replace the title with image and you can use a UIImage instead of a text title
    let save = UIBarButtonItem(title: "Save Drawing", style: .plain, target: self, action: #selector(saveCurrentDrawing))
    let optionsMenu = UIBarButtonItem(title:"Options", style: .done, target: self, action: #selector(showSideMenu))
    let changePicture = UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(changeDrawing(_:)))
    
    var removePicture = UIBarButtonItem(title: "Remove Background Image", style: .plain, target: self, action: #selector(removeBackgroundImage))
    
   // var change = UIBarButtonItemGroup(barButtonItems: [removePicture], representativeItem: <#T##UIBarButtonItem?#>)
    
//    let addBackgroundBack = UIBarButtonItem(title: "Add Background", style: .plain, target: self, action: #selector(removeBackgroundImage))
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let fingerDrawing = canvasView.drawingPolicy = .anyInput
        
        let fingerDraw = UIBarButtonItem(image: handDrawing, style: .plain, target: self, action: #selector(drawUsingFinger))
        //change with SF Symbols at later date.
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(clearCanvas))
        let share = UIBarButtonItem(image:share, style: .plain, target: self, action: #selector(shareImage))
//        //remember just replace the title with image and you can use a UIImage instead of a text title

        navigationItem.leftBarButtonItems = [optionsMenu, share, fingerDraw, changePicture]
        navigationItem.rightBarButtonItems = [save, delete, removePicture]
        //need to add save button and data model for saving picture progress.
      //  navigationController?.title = car
        
        canvasView.delegate = self //The object you use to respond to changes in the drawn content or with the selected tool.
        dataModelController.dataModel.drawings.append(pkDrawing)
        canvasView.drawing = dataModelController.dataModel.drawings[drawingIndex]

                    toolPicker.setVisible(true, forFirstResponder: canvasView)
                    toolPicker.addObserver(canvasView)
                    toolPicker.addObserver(self)
                    canvasView.becomeFirstResponder()
        
        
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false //so we can draw over it.
//        canvasView.maximumZoomScale = 2 //setting the maximum zoom scale to 1 prevents the weird behaviour where the image isn't zooming with the canvas view.
//        canvasView.minimumZoomScale = 1
        //canvasView.setNeedsDisplay()
        
        setCurrentImage(image: drawing.mountains.rawValue)
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dataModelController.dataModel.drawings.append(pkDrawing)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if hasModifiedDrawing == true {
            dataModelController.dataModel.drawings.append(pkDrawing)
            dataModelController.updateDrawing(canvasView.drawing, at: drawingIndex)
        }
    }
    
    
    func setCurrentImage(image: String){
        
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        canvasView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        //let heroImageName = drawing.hero.rawValue
        let imageToAdd = UIImage(named: image)
        let newImageView = UIImageView(image: imageToAdd)
        imageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)

        view.addSubview(newImageView)
        newImageView.anchors(top: view.topAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)

        view.addSubview(canvasView) //putting this above the anchors stops the constraint fatal error. this view needs to be added to subview BEFORE anchoring it.
       // view.bringSubviewToFront(canvasView)
                canvasView.anchors(top: view.topAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)
        //YES this is working on all simulators and the iPad properly now!!
 
    }
    
    @objc func removeBackgroundImage(image: UIImage) {
        //image
        //imageView.removeFromSuperview()
        buttonChangeCounter += 1
        
        switch buttonChangeCounter {
        case 1: removePicture.title = "Add Background Image"
            setCurrentImage(image: drawing.shinkansen.rawValue)
            
        case 2: removePicture.title = "Remove Background Image"
            setCurrentImage(image: (drawing.empty.rawValue))
        buttonChangeCounter = 0 //reset back when to the original name of the button when case 2 is valid.
        default:
            print("Unable to change background text.")
        }
       // removePicture.title = "Add Background" //this was a simple way to change the UIBar Button Item,
        //setCurrentImage(image: drawing.shinkansen.rawValue) //this does change picture but I need it to remove and load the same picture... could create a blank image to compensate for this but thats not necessary. There is another way
        setCurrentImage(image: drawing.empty.rawValue)
        
        viewDidDisappear(true)
    }
    
    func updateContentSize() {
        let drawing = canvasView.drawing
        let contentHeight: CGFloat //adjust the content size to be bigger than the content height
        
        if drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasViewOverScrollHeight) * canvasView.zoomScale)
        } else {
            contentHeight = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: mainViewWidth * canvasView.zoomScale, height: contentHeight)
    }
    
    //attempt to set size of picture to size of canvasView.
    
    //self.canvasView.frame = self.setSize()
    
    func setSize() -> CGRect {
        
        currentImage = UIImage(named: "hero.png")
        let containerRatio = self.imageView.frame.size.height/self.imageView.frame.size.width
        let imageRatio = self.currentImage!.size.height/self.currentImage!.size.width

        if containerRatio > imageRatio {
            return self.getHeight() //Cannot convert return expression of type '()' to return type 'CGRect' add it as return type to getHeight func
        } else {
            return self.getWidth()
        }
    }

    func getHeight() -> CGRect {
        currentImage = UIImage(named: "hero.png")
        let containerView = self.imageView
        guard let image = self.currentImage else { return CGRect.init()}
        let ratio = containerView.frame.size.width / image.size.width
        let newHeight = ratio * image.size.height
        let size = CGSize(width: containerView.frame.width, height: containerView.frame.height)
        var yPosition = (containerView.frame.size.height - newHeight) / 2
        yPosition = (yPosition < 0 ? 0 : yPosition) + containerView.frame.origin.y//use NCO here
        let origin = CGPoint.init(x: 0, y: yPosition)
        return CGRect.init(origin: origin, size: size)


    }
//
    func getWidth() -> CGRect {
        let containerView = self.imageView
        guard let image = self.currentImage else { return CGRect.init()}
        let ratio = containerView.frame.size.height / image.size.height
        let newWidth = ratio * image.size.height
        let size = CGSize(width: newWidth, height: containerView.frame.height)
        let xPosition = (containerView.frame.size.width - newWidth) / 2
        let yPosition = containerView.frame.origin.y
        let origin = CGPoint.init(x: xPosition, y: yPosition)
        return CGRect.init(origin: origin, size: size)
    }

    @objc func clearCanvas() {
        let ac = UIAlertController(title: "Do you want to delete your drawings?", message: "Save your progress if you want to!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.canvasView.drawing = self.newPKDrawing
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        //canvasView.drawing = pkDrawing //creates a new canvasView. Will need to add an alert controller to make sure they want to delete their drawings.
        present(ac, animated: true, completion: nil)
    }

    @objc func drawUsingFinger() {
        //add finger support for the app here. allowsDrawingWithFinger has been deprecated.
        self.canvasView.drawingPolicy = .anyInput
       // self.canvasView.drawingPolicy
    }
    
    @objc func shareImage(sender: UIView) {
        
        let description = "Share your drawing"
        let currentImage = UIImage(named: drawing.hero.imageName)!
        
        //the image new property uses a getter to find the value and return it...but its not showing maybe because its optional.

        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [description, currentImage], applicationActivities: nil)
        //we can add further items here later in the array
        //Ok didn't notice this but adding current image brings up all the other options to share the image, like print, share, assign to contact etc.
        
        //because its in iPad we need to use the popover presentation controller
        activityViewController.popoverPresentationController?.sourceView = self.view // source view = The view containing the anchor rectangle for the popover.
        
        //pre configure the activity items
        activityViewController.activityItemsConfiguration = [UIActivity.ActivityType.saveToCameraRoll] as? UIActivityItemsConfigurationReading
        //this should enable save to cameraRoll functionality. Don't need messages.
        //You should subclass UIActivity only if you want to provide custom services to the user. A service takes data that is passed to it, does something to that data, and returns the results.
        
        //we can then exclude the activity items in an array like so
        
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.openInIBooks]
        
        //present the app modally.
        
        activityViewController.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
        //Ok seemed to have fixed the app freezing andnow it presents a share button with copy and save to file functions.
        self.present(activityViewController, animated: true, completion: nil)
        
    
    }
    
    @objc func saveCurrentDrawing() {
        dataModelController.updateDrawing(canvasView.drawing, at: drawingIndex)
    }
    
    @objc func showSideMenu() {
        delegate?.showSideMenu()
        performSegue(withIdentifier: "showSideMenu", sender: self)
       // print("Button Pressed")
    }
    
    
    func changeCurrentDrawing(imageName: String) {
        //let heroImageName = drawing.hero.rawValue
        
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        let imageToAdd = UIImage(named: imageName)
        let newImageView = UIImageView(image: imageToAdd)
        imageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        
        
        
        view.addSubview(newImageView)
        newImageView.anchors(top: view.topAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)
        
        view.addSubview(canvasView) //putting this above the anchors stops the constraint fatal error. this view needs to be added to subview BEFORE anchoring it.
       // view.bringSubviewToFront(canvasView)
                canvasView.anchors(top: view.topAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)
    }
  
    
    @objc func changeDrawing(_ sender: UIButton) {
       //let drawings = [airplane, car, cat, hero, shinkansen]
        let ac = UIAlertController(title: "Change Picture", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: drawing.airplane.imageName, style: .default, handler: { _ in
            self.imageView.removeFromSuperview()
            
            self.changeCurrentDrawing(imageName: drawing.airplane.imageName)
            
            self.viewDidLoad()
            
        }))
        ac.addAction(UIAlertAction(title: drawing.car.imageName, style: .default, handler: { _ in
           //self.view.addSubview(self.imageView)
        }))
        
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem  //caused NSException error because no popover vc declared here.
        present(ac, animated: true, completion: nil)
        
    }
    
    func createUIView() -> UIView {
        
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false //so we can draw over it.
        canvasView.maximumZoomScale = 5
        canvasView.minimumZoomScale = 1
        
        //let bundle = Bundle(path: "TraceImages")
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fileManager.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasSuffix("car"){
                //let imageView = UIImageView(image: UIImage(contentsOfFile: "car.png"))
                let imageView1 = UIImageView(image: UIImage(contentsOfFile: path))
                canvasView.addSubview(imageView1)
                canvasView.sendSubviewToBack(imageView1)
                
            }
        }
        
        
        let imageView = UIImageView(image: UIImage(contentsOfFile: "car.png"))
       // let contentView = Tool.getContentViewFromPKCanvasView(canvasView)
       canvasView.addSubview(imageView)
       canvasView.sendSubviewToBack(imageView)
        return view
    }
    
}


extension UIView {
   // we can create a function that handles the anchors and set this in the extension to UIView to handle all anchors. Super useful extension!
    func anchors(top: NSLayoutYAxisAnchor, bottom: NSLayoutYAxisAnchor, trailing: NSLayoutXAxisAnchor, leading: NSLayoutXAxisAnchor) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([ //like in previous projects we don't have to use .isActive after every constraint and can put ALL constraints in here

            //canvasView constraints
            topAnchor.constraint(equalTo: top, constant: 0),

            bottomAnchor.constraint(equalTo: bottom, constant: 0),

            leadingAnchor.constraint(equalTo: leading, constant: 0),

            trailingAnchor.constraint(equalTo: trailing, constant: 0)
            //Cannot find 'view' in scope because when copying from above, we can change this to the params above.

        ])
    }
    
    
}

