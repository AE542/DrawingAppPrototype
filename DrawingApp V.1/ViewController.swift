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
//2021/10/10 Ok, can now save images but drawings not being saved with images...may need to make a custom method to save the PKDrawing over the orignal image.

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
            }
        }
        
    }
    
    weak var delegate: MainViewControllerDelegate? //weak so we don't cause a memory leak
    //'weak' must not be applied to non-class-bound 'MainViewControllerDelegate'; consider adding a protocol conformance that has a class bound. = this means that we have to make the delegate conform to any object so we can use it.
    
    let canvasView = PKCanvasView()
    let toolPicker = PKToolPicker.init() //crucial! Allows us to create individual instances of the toolPicker.
    var currentDrawing = String()
    
   // let newCanvasView = PKCanvasView()
   // let views = Views()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let fingerDrawing = canvasView.drawingPolicy = .anyInput
        
        let fingerDraw = UIBarButtonItem(title: "Finger Draw", style: .plain, target: self, action: #selector(drawUsingFinger))
        //change with SF Symbols at later date.
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(clearCanvas))
        let share = UIBarButtonItem(image:share, style: .plain, target: self, action: #selector(shareImage))
        //remember just replace the title with image and you can use a UIImage instead of a text title
        let save = UIBarButtonItem(title: "Save Drawing", style: .plain, target: self, action: #selector(saveCurrentDrawing))
        let optionsMenu = UIBarButtonItem(title:"Options", style: .done, target: self, action: #selector(showSideMenu))
        let changePicture = UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(changeDrawing(_:)))
        
        navigationItem.leftBarButtonItems = [optionsMenu, share, fingerDraw, changePicture]
        navigationItem.rightBarButtonItems = [save, delete]
        //need to add save button and data model for saving picture progress.
      //  navigationController?.title = car
        
        canvasView.delegate = self
        canvasView.drawing = pkDrawing
       //canvasView.alwaysBounceVertical = true //this was calling the screen to bounce on the iPad.
        //canvasView.backgroundColor = .blue
        
//                if #available(iOS 13.0, *) { //need to check if its available for certain devices.
//                    toolPicker = PKToolPicker() //remember to put the var as a global var
//                } else {
                   // if let window = parent?.view.window {
                    
                    //toolPicker = PKToolPicker.shared(for: window)!
                    toolPicker.setVisible(true, forFirstResponder: canvasView)
                    toolPicker.addObserver(canvasView)
                    toolPicker.addObserver(self)
                    canvasView.becomeFirstResponder()
        
        
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false //so we can draw over it.
//        canvasView.maximumZoomScale = 2 //setting the maximum zoom scale to 1 prevents the weird behaviour where the image isn't zooming with the canvas view.
//        canvasView.minimumZoomScale = 1
        //canvasView.setNeedsDisplay()
        
        
        //canvasView.addTraceImageToCanvasView(imageName: drawing.hero.rawValue, contentMode: .scaleAspectFit)
               //}
               // }
        
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        canvasView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        
        let heroImageName = drawing.hero.rawValue
        let imageToAdd = UIImage(named: heroImageName)
        let newImageView = UIImageView(image: imageToAdd)
        imageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        
        view.addSubview(newImageView)
        newImageView.anchors(top: view.topAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)
        
        view.addSubview(canvasView) //putting this above the anchors stops the constraint fatal error. this view needs to be added to subview BEFORE anchoring it.
       // view.bringSubviewToFront(canvasView)
                canvasView.anchors(top: view.topAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)
        //YES this is working on all simulators and the iPad properly now!!
//        canvasView.backgroundColor = .clear
//        canvasView.isOpaque = false //so we can draw over it.
//        canvasView.maximumZoomScale = 2 //setting the maximum zoom scale to 1 prevents the weird behaviour where the image isn't zooming with the canvas view.
//        canvasView.minimumZoomScale = 1
//        //canvasView.setNeedsDisplay()
//        
//        
//        canvasView.addTraceImageToCanvasView(imageName: shinkansen, contentMode: .scaleAspectFit)
        
        //.redraw is keeping the image on the screen
        //self.canvasView.frame = self.setSize()
        
        
        //view.addSubview(canvasView)
//        let canvas = PKCanvasView(frame: view.bounds)
//        
//        view.addSubview(canvas)
//        canvas.tool = PKInkingTool(.pen, color: .black, width: 35)
        //simple canvas tool
        //canvasView.clipsToBounds = true
        
//        mainView.backgroundColor = .blue
//        //view.addSubview(mainView)
//        mainView.layer.cornerRadius = 10
////
//        mainView.clipsToBounds = true// determines whether the subviews are confined to the main UIView here...will need this for the images I'm gonna load later.
//        mainView.layer.borderWidth = 5
//        mainView.layer.borderColor = UIColor.lightGray.cgColor
//
//        mainView.anchors(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, leading: view.leadingAnchor)
        //view.addSubview(canvas)

//        Unable to activate constraint with anchors <NSLayoutYAxisAnchor:0x600000338ec0 "UIView:0x7fc23ce057f0.top"> and <NSLayoutYAxisAnchor:0x6000003398c0 "UILayoutGuide:0x600002f641c0'UIViewSafeAreaLayoutGuide'.top"> because they have no common ancestor.  Does the constraint or its anchors reference items in different view hierarchies?  That's illegal.' should have added view.addSubView here not in the func below
       
       // createUIView(context: canvasView as! CGContext) bad instruction cannot assign canvas view as a CGContext Image.
        
       // createUIView()
        
//        canvasView.backgroundColor = .clear
//        canvasView.isOpaque = false //so we can draw over it.
//        canvasView.maximumZoomScale = 10
//        canvasView.minimumZoomScale = 1
        //canvasView.addTraceImageToCanvasView(imageName: car)
        
        //let bundle = Bundle(path: "TraceImages")
//        let fileManager = FileManager.default
//        let path = Bundle.main.resourcePath!
//        let items = try! fileManager.contentsOfDirectory(atPath: path)
        
       // var filePath = Bundle.main.url(forResource: "car", withExtension: "png")
        
//        let height = UIScreen.main.bounds.size.height
//
//        let width = UIScreen.main.bounds.size.width
//        let backgroundDimensions = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        backgroundDimensions.image(UIImage(named: "car.png"))
//
//        backgroundDimensions.contentMode = UIViewContentMode
//     // let car = UIImageView(image: UIImage(named: "car.png")) //well...its loading the picture but not at the correct ratio
//
//
//     // let imageView = UIImageView(image: UIImage(contentsOfFile: items))
//        //let imageView1 = UIImageView(image: UIImage(contentsOfFile: filePath))
//       // let contentView = Tool.getContentViewFromPKCanvasView(canvasView)
//       canvasView.addSubview(car)
//       canvasView.sendSubviewToBack(car)
        
        //var car = "car.png"
        //canvasView.addTraceImageToCanvasView(imageName: car)
        
     //   self.canvasView.frame = self.setSize()
      canvasView.becomeFirstResponder()
    }
    
//    override func viewDidLayoutSubviews() {
//        //super.viewDidLayoutSubviews()
//
//        //this is one of the ways to keep the canvas view in portrait mdoe
//
//        let canvasScale = canvasView.bounds.width / mainViewWidth //we can use this to divide the width of the canvas to reset it
//   // this value was causing the CALayer position contains NaN: [590 nan] crash because it isn't possible to divide by 0. Reason for issue according to S.O. but still unable to update for rotation.
//        canvasView.minimumZoomScale = canvasScale
//        canvasView.maximumZoomScale = canvasScale
//        canvasView.zoomScale = canvasScale
//
//        //call updateView func here
//
//        updateContentSize()
//
//        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
//    }
    
//    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        updateContentSize()
//    }
    
    
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
//
    
    
    
    
    
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
//    override func viewDidAppear(_ animated: Bool) {
//        //setUpCanvas() //func should have been in viewdidappear
//        let canvas = PKCanvasView(frame: self.view.bounds)
//        canvasView.delegate = self
//        if #available(iOS 13.0, *) { //need to check if its available for certain devices.
//            toolPicker = PKToolPicker() //remember to put the var as a global var
//        } else {
//            //this part is a little confusing but we have to set the toolpicker, using the window of the parent view as its not been added directly to the window
//           let window = parent?.view.window //set the window to be the parent view
//            toolPicker = PKToolPicker.shared(for: window!)! //unwrapped but toolpicker should be available so won't cause an issue.
//            //PKToolPicker is used because we want to return the pktoolpicker into the parent view window
//    }
//        toolPicker.setVisible(true, forFirstResponder: canvas) //set the first responder to be th canvas view so it can be accessed immediately when touched
//        toolPicker.addObserver(canvas)//we then add an observer to make sure it notifies of changes when there are changes to the canvas view.
//        toolPicker.addObserver(self) //VC must conform to PKToolPicker observer so we need to add protocol inheritance
//        //updateLayout(for: toolPicker) //this method is going to change the view to accomodate for splitting the screen
//        canvasView.becomeFirstResponder() //Asks UIKit to make this object the first responder in its window. When touched it becomes the first responder.
//
//
//    }

//    func configureMainView() {
//        canvasView.clipsToBounds = true
//             //mainView.layer.cornerRadius = 20
//        //canvasView.clipsToBounds = false
//
//    }
    
   // func setUpCanvas() {
      //  let canvas = PKCanvasView(frame: self.view.bounds) //should be self because its this vc.
       // var toolPicker = PKToolPicker() //create as an unwrapped optional
       // canvasView.delegate = self
        //guard let window = view.window else { return }
        //Value of optional type 'UIWindow?' must be unwrapped to a value of type 'UIWindow' should be guard let unwrapped
        
        //var drawingPolicy = PKCanvasViewDrawingPolicy(rawValue: 1)
      //  view.addSubview(canvas)
        
        // let toolPicker = PKToolPicker.shared(for: window) else { return } //create general tool picker. This is deprecated, will need to create individual instance.
       // canvas.tool = PKInkingTool(.pen, color: .black, width: 25)
        //works for ink but doesn't work the right way I want.
        
        //canvas.drawing = PKDrawing()
    
        //canvas.tool = PKEraserTool(.vector)
        //ok this actually works on an actual device not on the simulator. Doesn't register fingers though, so need to add support for that.
        //toolPicker.isVisible == true
    //}
    
//    override func viewWillAppear(_ animated: Bool) {
//        //why use viewWillAppear on the view hierarchy? this method notifies the vc that the view is about to be added to the view hierarchy
//        super.viewWillAppear(animated)
//        //let canvas = PKCanvasView(frame: self.view.bounds)
//
//      let canvas = PKCanvasView()
//
//        //canvasView.frame(forAlignmentRect: self.view.bounds)
//
//        //canvasView.delegate = self
//        //canvasView.drawing = PKDrawing()
//       canvas.delegate = self
//       canvas.alwaysBounceVertical = true //A Boolean value that determines whether bouncing always occurs when vertical scrolling reaches the end of the content.
//
//
//
//        //canvas.drawing = PKDrawing()
//        if #available(iOS 13.0, *) { //need to check if its available for certain devices.
//            toolPicker = PKToolPicker() //remember to put the var as a global var
//        } else {
//            //this part is a little confusing but we have to set the toolpicker, using the window of the parent view as its not been added directly to the window
//           let window = parent?.view.window //set the window to be the parent view
//            toolPicker = PKToolPicker.shared(for: window!)! //unwrapped but toolpicker should be available so won't cause an issue.
//            //PKToolPicker is used because we want to return the pktoolpicker into the parent view window
//    }
//        toolPicker.setVisible(true, forFirstResponder: canvas) //set the first responder to be th canvas view so it can be accessed immediately when touched
//        toolPicker.addObserver(canvas)//we then add an observer to make sure it notifies of changes when there are changes to the canvas view.
//        toolPicker.addObserver(self) //VC must conform to PKToolPicker observer so we need to add protocol inheritance
//        //updateLayout(for: toolPicker) //this method is going to change the view to accomodate for splitting the screen
//        canvas.becomeFirstResponder() //Asks UIKit to make this object the first responder in its window. When touched it becomes the first responder.
//
//        view.addSubview(canvas)
//
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewDidDisappear(true)
//        clearCanvas()
//    }

    //func configureMainView() {
//        mainView.clipsToBounds = true
//             mainView.layer.cornerRadius = 20
//        //canvasView.clipsToBounds = false
        
    //}
    
//    func setUpCanvas() {
//        let canvas = PKCanvasView(frame: self.view.bounds) //should be self because its this vc.
//       // var toolPicker = PKToolPicker() //create as an unwrapped optional
//        canvasView.delegate = self
//        guard let window = view.window else { return }
//        //Value of optional type 'UIWindow?' must be unwrapped to a value of type 'UIWindow' should be guard let unwrapped
//
//        //var drawingPolicy = PKCanvasViewDrawingPolicy(rawValue: 1)
//        view.addSubview(canvas)
//
//        // let toolPicker = PKToolPicker.shared(for: window) else { return } //create general tool picker. This is deprecated, will need to create individual instance.
//       // canvas.tool = PKInkingTool(.pen, color: .black, width: 25)
//        //works for ink but doesn't work the right way I want.
//
//        //canvas.drawing = PKDrawing()
//
//        //canvas.tool = PKEraserTool(.vector)
//        //ok this actually works on an actual device not on the simulator. Doesn't register fingers though, so need to add support for that.
//        //toolPicker.isVisible == true
//
//}

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
        //performSegue(withIdentifier: <#T##String#>, sender: nil)
//        let ac = UIAlertController(title: "Share", message: nil, preferredStyle: .actionSheet)
//        let popOverVC = ac.popoverPresentationController
//        popOverVC?.sourceView = view
//        popOverVC?.sourceRect = CGRect(x: 32, y: 32, width: 64, height: 64)
//        present(ac, animated: true)
        //weird behaviour...closes the app and when I open it again it has the share ac title showing but it isn't interactable.
        
        //ok so create an array which has the share title and things you want to show
        let description = "Share your drawing"
        let currentImage = UIImage(named: drawing.hero.imageName)!
        
        //the image new property uses a getter to find the value and return it...but its not showing maybe because its optional.
        
        //let drawingImage = canvasView.drawing.image(from: imageView.frame, scale: 1.0)
        
//        guard let currentImage1 = imageView.image?.pngData() else {
//            print("No Image")
//            return
//        } //printing and not showing image.
        
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
        
      //  activityViewController.isModalInPresentation = true
        //activityViewController.popoverPresentationController?.sourceView = sender
        
        activityViewController.popoverPresentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
        //Ok seemed to have fixed the app freezing andnow it presents a share button with copy and save to file functions.r
        self.present(activityViewController, animated: true, completion: nil)
        
    
    }
    
    @objc func saveCurrentDrawing() {
        
    }
    
    @objc func showSideMenu() {
        delegate?.showSideMenu()
        performSegue(withIdentifier: "showSideMenu", sender: self)
       // print("Button Pressed")
    }
    
  
    
    @objc func changeDrawing(_ sender: UIButton) {
       //let drawings = [airplane, car, cat, hero, shinkansen]
        let ac = UIAlertController(title: "Change Picture", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: drawing.airplane.imageName, style: .default, handler: { _ in
            //self.canvasView.addTraceImageToCanvasView(imageName: drawing.airplane.imageName)
            //super.viewDidLoad()
            //self.viewDidAppear(true)
          //  self.view.didAddSubview(self.canvasView.self)
            
            
            
        }))
        ac.addAction(UIAlertAction(title: drawing.car.imageName, style: .default, handler: { _ in
            self.view.addSubview(self.imageView)
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

//class Tool {
//    static func getContentViewFromPKCanvasView(_ view: UIView) -> some UIView {
//        view.subviews[0]
//        //Instance member 'canvasView' cannot be used on type 'ViewController' should use a regular view
//    }
//}

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
    
    func addTraceImageToCanvasView(imageName: String, contentMode: UIView.ContentMode = .scaleAspectFit) {
        //.scaleAspectFit is keeping the original size of the image view. However one of its properties is Any remaining area of the view’s bounds is transparent. So its keeping the views (canvasView's) bounds empty.
        
//        let height = UIScreen.main.bounds.size.height
//
//        let width = UIScreen.main.bounds.size.width
//
//        let height = view.frame.size.height
//        let width = view.frame.size.width
        //let backgroundDimensions = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        let backgroundDimensions = UIImageView(frame: UIScreen.main.bounds)
        backgroundDimensions.image = (UIImage(named: imageName)) //Cannot call value of non-function type 'UIImage?' should just be the param AND = THE IMAGE NAME!! You forgot the = sign!
       // backgroundDimensions.translatesAutoresizingMaskIntoConstraints = false
        backgroundDimensions.clipsToBounds = true
        //backgroundDimensions.contentMode = contentMode
       // backgroundDimensions.translatesAutoresizingMaskIntoConstraints = false
        //backgroundDimensions.anchors(top: topAnchor, bottom: bottomAnchor, trailing: trailingAnchor, leading: leadingAnchor) causing crash as can't find the right view.
        addSubview(backgroundDimensions)
        sendSubviewToBack(backgroundDimensions)
    }
    
//    func adjustImageForCanvasView(imageForAdjustment: UIImageView, name: String) -> CGRect {
//        imageForAdjustment.image = (UIImage(named: name))
//        let containerRatio = imageForAdjustment.frame.size.height/imageForAdjustment.frame.size.width
//        let imageRatio = imageForAdjustment.
//    }
    
    
}

