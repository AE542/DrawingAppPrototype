//
//  DataModel.swift
//  DrawingApp V.1
//
//  Created by Mohammed Qureshi on 2021/12/11.
//

//ok so PKDrawing adheres to the Codable Protocol and you can fetch its data object through it's dataRepresentation() method.

//using computed properties here remember from HWS a computed property is one that runs some code in order to calculate a value, as opposed to a static property which stores a value for later use.

import UIKit
import PencilKit
//this DataModel has the drawings that make up the data model including multiple image drawings. You can use a signature drawing to save images in the state they're left in.

struct DataModel: Codable {
//tonnes of errors because...static is only available on type properties NOT DATA MODELS! this should be a struct
    
    //this is used to initialise the data model
    
    
    //remember static allows you to create properties that belong to a type rather than instances of a type. Helpful for storing shared data. You can access them with dot notation if you've declared them! This is specifically for stored properties and cannot be accessed by non static properties.
    
static let defaultTraceImageNames: [String] = ["TraceImages"]

    //we need to use the width of the current canvas as a part of the data model
    
    static let canvasWidth: CGFloat = 768
    
    //we need to use the drawings that make up the current data model. So create an empty array of pkdrawings, and a signature.
    
    var drawings: [PKDrawing] = []
    //var signature = PKDrawing()
    //if we wanted we could add a signature, the way it works is making a small vc pop up that has a PKDrawing canvas in it so you can make a signature.

}

//creating a protocol that monitors when data changes happen is very useful.

protocol DataModelControllerObserver {
    func dataModelChanged()//this is what allows images to be saved
}


class DataModelController {
    
    //we declare the struct here
    
    var dataModel = DataModel()
    
        //we can also can create thumbnail images that represent the drawings in the data model itself
    
    var thumbnails = [UIImage]()
    //need to also set the thumbnailTraitCollection here
    var thumbnailTraitCollection = UITraitCollection() {
        didSet {
            if oldValue.userInterfaceStyle != thumbnailTraitCollection.userInterfaceStyle {
                generateAllThumbnails()
            }
        }
    }
    
    var observers = [DataModelControllerObserver]() //we can create an array that handles the protocol as objects
    
    //we can declare the thumbnails here with a default size.
    
    //you can set set constants for the dispatchQueues for this controller here
    
    private let serializationQueue = DispatchQueue(label: "SerializationQueue", qos: .background)
    //Background tasks have the lowest priority of all tasks. Assign this class to tasks or dispatch queues that you use to perform work while your app is running in the background.
    
    static let thumbnailSize = CGSize(width: 192, height: 256)
    
    //creating a computed property that allows access to the drawings inside the dataModel. Here we use a getter and a setter
    var drawings: [PKDrawing] {
    get { dataModel.drawings }
        //remember a getter is used to perform a computation when requested
    set { dataModel.drawings = newValue}
        //newValue of type PKDrawing
        //Cannot assign value of type 'PKDrawing' to type '[PKDrawing] because signauture PK should be an array!
        //remember a setter can be added optionally, here we use it to modify the dataModel.drawings with a new value
    }

    
    //we then initialise the new data model
    init() {
        loadDataModel()
    }
    
    //we need to now create a function that saves the data.
    
    //this allows the thumnail to be updated with the drawings' thumbnails correctly.
    func updateDrawing(_ drawing: PKDrawing, at index: Int) {
        dataModel.drawings[index] = drawing
       // Thread 1: Fatal error: Index out of range
        //this allows the index of the collectionView thumbnails to be initialised
        generateThumbnail(index)
        //this func generates the thumbnail at the index
        saveDataModel()
        //saves changes to the dataModel
    }
    
    //MARK: - Helper Methods
    private func generateAllThumbnails() {
        for index in drawings.indices {
            generateThumbnail(index)
        }
                //we need this so it updates the thumbnails in ascending order
    }
    
    private func generateThumbnail(_ index: Int) {
        //remember this func doesn't have an initial param name so just add an underscore to replace it
        //Index is of type Int! Not Index!
        
        let drawing = drawings[index]
        let aspectRatio = DataModelController.thumbnailSize.width / DataModelController.thumbnailSize.height
        //divide the width by the height to get the correct aspect ratio
        let thumbnailRect = CGRect(x: 0, y: 0, width: DataModel.canvasWidth, height: DataModel.canvasWidth / aspectRatio)
        //this sets the thumbnailRectangle by calling the data model struct's canvas width constant and then dividing that by the aspect ratio to get the images to show correctly.
        let traitCollection = thumbnailTraitCollection
        
       //when using async, it's a good idea to declare dispatch queues as constants above to access them inside functions
        
        //add these later
        
    }
    
    //add helper function to notify observer that the data model has changed.
    
    private func dataModelDidChange() {
        for observer in self.observers {
            observer.dataModelChanged()
        }
    }
    
    //we can get the url of the file where the data model is saved
    
    private var saveURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first!
        return documentsDirectory.appendingPathComponent("DrawingApp_V.1.data")
        //this might fail so check it out later.
    }
    
    //ok so this is the main thing I wanted to do saving the data into a dataModel
    private func saveDataModel() {
        let savingDataModel = dataModel
        let url = saveURL
        serializationQueue.async {
            
            do {
            let encoder = PropertyListEncoder() //encodes data to plist
            let data = try
            encoder.encode(savingDataModel)
            try data.write(to: url)
        } catch {
            //unused closure expression should be a do try catch.
            print(error.localizedDescription)
        }
        //need to set the serializationQueue as a var
        
        
    }
    

}
    //the data model is saved in persistent storage so just like with some of the older projects and persisting data, we can load it from its file here
    private func loadDataModel() {
        let url = saveURL
        
        serializationQueue.async {
            let dataModel: DataModel
            //declare this to load the data
            
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    let decoder = PropertyListDecoder()
                    let data = try Data(contentsOf: url)
                    dataModel = try decoder.decode(DataModel.self, from: data)
                } catch {
                    print(error.localizedDescription)
                    dataModel = self.loadDefaultDrawings()
                }
               
            } else {
                dataModel = self.loadDefaultDrawings()
            }
            DispatchQueue.main.async {
                self.setLoadedDataModel(dataModel)
                //Constant 'dataModel' captured by a closure before being initialized. Needed to be declared in the catch block above also.
            }
        }
    }
    
    //we need to create an initialDataModel when one doesn't exist (first time an app is downloaded for example)
    
    private func loadDefaultDrawings() -> DataModel {
        var defaultDataModel = DataModel()
        for sampleDataName in DataModel.defaultTraceImageNames {
            guard let data = NSDataAsset(name: sampleDataName)?.data else { continue }
            if let drawing = try? PKDrawing(data: data) {
                defaultDataModel.drawings.append(drawing)
            }
        }
        return defaultDataModel
    }
    
    private func setLoadedDataModel(_ dataModel: DataModel) {
        self.dataModel = dataModel
        //add thumbnails code here for ui collection view
        thumbnails = Array(repeating: UIImage(), count: dataModel.drawings.count)
        generateAllThumbnails()
    }
    
    //create a new drawing in the data model.
    
    func createNewDrawing() {
        let newDrawing = PKDrawing()
        dataModel.drawings.append(newDrawing)
        thumbnails.append( UIImage())
        updateDrawing(newDrawing
                      , at: drawings.count - 1)
    }

}
