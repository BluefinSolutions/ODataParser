//
//  ODataServiceManager.swift
//  Demo Jam
//
//  Created by Brenton O'Callaghan on 09/10/2014.
//  Completely open source without any warranty to do with what you like :-)
//

import Foundation

class ODataServiceManager: NSObject, ODataCollectionDelegate{
    
    internal var _entitiesAvailable: NSMutableArray = NSMutableArray()
    internal var _collectionListLoaded: Bool = false;
    
    // The local oData requestor.
    internal var _oDataRequester: ODataCollectionManager?

    
    // Callsback to the passed in function with a list of the available collections in the oData service.
    class func getCollectionList() -> NSMutableArray{
        
        // This would be so much better as a class variable with async calls but Swift does not
        // support class variables yet :-(
        /*var serviceManager: ODataServiceManager = ODataServiceManager()
        
        serviceManager._oDataRequester?.makeRequestToCollection(OdataFilter())
        
        while (!serviceManager._collectionListLoaded){
            sleep(1)
        }
        
        return serviceManager._entitiesAvailable*/
        return NSMutableArray()
    }
    
    // Create a collection manager object used to make all the requests to a particular collection.
    class func createCollectionManagerForCollection(collectionName:NSString, andDelegate:ODataCollectionDelegate) -> ODataCollectionManager{
        
        // New instance of a collection.
        var newCollectionManager: ODataCollectionManager = ODataCollectionManager();
        
        // Set the delegate and the collection name.
        newCollectionManager.setDelegate(andDelegate)
        newCollectionManager.setCollectionName(collectionName)
        
        // Return to the user :-)
        return newCollectionManager
    }
    
    // ======================================================================
    // MARK: - Internal Private instance methods.
    // ======================================================================
    
    
    override init() {
        
        // Always do the super.
        super.init()
        
        // Create an odata request to the service with no specific collection.
        self._oDataRequester = ODataServiceManager.createCollectionManagerForCollection("", andDelegate: self)
    }
    
    func didRecieveResponse(results: NSDictionary){
        
        let queryDictionary = results.objectForKey("d") as NSMutableDictionary
        let queryResults = queryDictionary.objectForKey("EntitySets") as NSMutableArray
        
        for singleResult in queryResults{
            
            // Create and initialise the new entity object.
            self._entitiesAvailable.addObject(singleResult as NSString)
        }
        
        // Very important if we want to exit the infinite loop above!
        // There has to be a better way to do this!!! :)
        self._collectionListLoaded = true
    }
    
    func requestFailedWithError(error: NSString){
        println("=== ERROR ERROR ERROR ===")
        println("Unable to request entity listing from OData service - is it an odata server??")
        println("Error: " + error)
    }

}