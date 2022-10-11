//
//  Array2D.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

struct Array2D<T> {
    //<T> means that the array is generic, so it can hold any type T
    let columns: Int
    let rows: Int
    fileprivate var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeatElement(nil, count: rows*columns))
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
            //Must Investigate at some point
        }
        set {
            array[row*columns + column] = newValue
            //Must Investigate at some point
        }
        // Subscript allows me to index the array as follows: myBlock = blocks[column, row]
    }
}

