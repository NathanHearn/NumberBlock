//
//  Extensions.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import Foundation

extension Dictionary {
    //MUST! learn what this method is doing, somthing to do with throwing and catching data
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        var dataOK: Data
        var dictionaryOK: NSDictionary = NSDictionary()
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions()) as Data!
                dataOK = data!
            }
            catch {
                print("Could not load level file:\(filename), error\(error)")
                return nil
            }
            do {
                let dictionary = try JSONSerialization.jsonObject(with: dataOK, options: JSONSerialization.ReadingOptions()) as AnyObject!
                dictionaryOK = (dictionary as! NSDictionary as? Dictionary<String, AnyObject>)! as NSDictionary
            }
            catch {
                print("Level file \(filename) is not a valid JSON: \(error)")
                return nil
            }
        }
        print(dictionaryOK)
        return dictionaryOK as? Dictionary<String, AnyObject>
    }
}
