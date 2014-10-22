//
//  ODataParser.swift
//  Demo Jam
//
//  Created by Brenton O'Callaghan on 19/09/2014.
//  Completely open source without any warranty to do with what you like :-)
//

import Foundation

protocol ODataCollectionDelegate{
    func didRecieveResponse(results: NSDictionary)
    func requestFailedWithError(error: NSString)
}

class ODataCollectionManager: NSObject {
    
    // Temp variable for any received data through the connection.
    internal var _data: NSMutableData = NSMutableData()
    
    // Callback delegate for any oData requests.
    internal var _delegate: ODataCollectionDelegate?
    
    // NSUserDefaults for accessing the stored username and password if required.
    internal var _userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    // oData components
    internal var _collection: NSString = ""
    
    // oData query filter
    internal let _formatString: NSString = "?$format=json"     // We always use Json for efficiency.
    internal var _filter: OdataFilter = OdataFilter()
    
    func setDelegate(newDelegate:ODataCollectionDelegate){
        self._delegate = newDelegate
    }
    
    func setCollectionName(collectionName:NSString){
        self._collection = collectionName
    }
    
    // Make a request to the configured collection.
    func makeRequestToCollection(filter: OdataFilter) {
                                
        self._filter = filter
        
        var urlString: NSString = self._constructOdataRequestURL().stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                                
        var url: NSURL = NSURL(string: urlString)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self,startImmediately: false)!
    
        println("Making request to OData service:  <**censored**> for demojam on stage")
    
        connection.start()
    }
    
    // ======================================================================
    // MARK: - Internal/Private Methods
    
    internal func _constructOdataRequestURL() -> NSString{
        
        // FIXME: Change the base URL.
        
        // Always start as the Base URL with the collection and the format string.
        var baseURL: NSString = "www.yourURL.com" + self._collection + self._formatString

        
        // Finally we format all the values into the final URL.
        return NSString(format: "%@%@", baseURL, self._filter.getFilterString())
    }
    
    // ======================================================================
    // MARK: - NSURLConnection delegate methods
    
    // Called when the connection fails.
    internal func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        println("Failed with error:\(error.localizedDescription)")
        self._delegate?.requestFailedWithError(error.localizedDescription)
    }
    
    // Called when a response is received so we prepare the receiving variables.
    internal func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        
        var newResponse: NSHTTPURLResponse = response as NSHTTPURLResponse
        
        if(newResponse.statusCode != 200){
            didReceiveResponse.cancel()
            self.connection(didReceiveResponse, didFailWithError: NSError(domain: NSHTTPURLResponse.localizedStringForStatusCode(newResponse.statusCode), code: newResponse.statusCode, userInfo: nil))
            return
        }
        
        //New request so we need to clear the data object
        self._data = NSMutableData()
    }
    
    // Called when data is received through the connection.
    internal func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        //Append incoming data
        self._data.appendData(data)
    }
    
    // Called when the connection finishes - so we prepare and return the response.
    internal func connectionDidFinishLoading(connection: NSURLConnection!) {
        //Finished receiving data and convert it to a JSON object
        var err: NSError = NSError()
        
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(self._data,
            options:NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        // Need to return the result to someone.
        self._delegate?.didRecieveResponse(jsonResult)
    }
    
    // Called when authentication is required for the oData service.
    internal func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        
        // FIXME: Change the default username and password
        var username: NSString = "username"
        var password: NSString = "password"

        if (username.length == 0 || password.length == 0){
            connection.cancel()
            self._delegate?.requestFailedWithError("You must provide a username and password in the settings app.")
        }
        
        var cred: NSURLCredential = NSURLCredential(user: username, password: password, persistence: NSURLCredentialPersistence.None)
        
        challenge.sender.useCredential(cred, forAuthenticationChallenge: challenge)
    }
    
}