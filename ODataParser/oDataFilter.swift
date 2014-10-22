//
//  oDataFilter.swift
//  Demo Jam
//
//  Created by Brenton O'Callaghan on 07/10/2014.
//  Completely open source without any warranty to do with what you like :-)
//

import Foundation

class OdataFilter{
    
    internal var _top: NSString = ""
    internal var _orderBy: NSMutableArray = NSMutableArray()
    internal var _filter: NSMutableArray = NSMutableArray() // Should be an array of Odata filter objects.
    
    // oData standard URL parameters
    internal let _conjunctionCharacter: NSString = "&"
    
    // oData standard identifiers (Odata Identifiers ODI)
    internal let _topODI: NSString = "&$top="
    internal let _filterODI: NSString = "&$filter="
    internal let _orderODI: NSString = "&$orderby="
    
    // Return a valid filter URL
    func getFilterString() -> NSString {
        return self._getFilterString()
    }
    
    // MARK: Set and clear the TOP
    
    // Set the number of items to be returned e.g. $top=10
    func setTop(topCount: Int){
        self._top = NSString(format: "%i", topCount)
    }
    
    // Clear out the selection of top values
    func clearTop(){
        self._top = ""
    }
    
    // MARK: Set and clear the OrderBy
    
    // Add an order by clause
    func addOrderBy(fieldName: NSString, ascDesc: NSString){
        self._orderBy.addObject(NSString(format: "%@ %@", fieldName, ascDesc))
    }
    
    // Remove all order by clauses
    func clearOrderBy(){
        self._orderBy.removeAllObjects()
    }
    
    // MARK: Set and clear the Filter
    
    // Add a filter clause
    func addFilter(filterName: NSString, filterValue: NSString, filterOperand: NSString, clauseOperand: NSString){
        
        // Need to format the clause operand correctly - e.g. make sure there is a space before
        // a eq b and c eq d and - note the space beterrn b and the word and.
        var localClauseOperand: NSString = clauseOperand
        if localClauseOperand.length > 0{
            localClauseOperand = NSString(format: " %@", localClauseOperand)
        }
        
        self._filter.addObject(NSString(format: "%@ %@ %@ %@", localClauseOperand, filterName, filterOperand, filterValue ))
    }
    
    // Remove all order by clauses
    func clearFilters(){
        self._filter.removeAllObjects()
    }
    
    // ======================================================================
    // MARK: - Internal/Private Functions
    
    internal func _getFilterString() -> NSString {
        
        var validQuery: Bool = false
        
        var orderBy: NSString = ""
        var top: NSString = ""
        var filter: NSString = ""
        
        // First we check for an order by sxtatement
        if(self._orderBy.count > 0){
            validQuery = true
            orderBy = self._orderODI
            
            for orderByOption in self._orderBy {
                orderBy = NSString(format: "%@%@", orderBy, orderByOption as NSString)
            }
            
        }
        
        // Now we check for a $top statement
        if(self._top.length > 0){
            validQuery = true
            top = NSString(format: "%@%@", self._topODI, self._top)
            
        }
        
        // Finally we check for a filter statement
        if(self._filter.count > 0){
            validQuery = true
            filter = self._filterODI
            
            for filterByOption in self._filter {
                filter = NSString(format: "%@%@", filter, filterByOption as NSString)
            }
        }
        
        if(validQuery){
            return NSString(format: "%@%@%@",orderBy, top, filter)
        }
        
        return ""
    }
    
}