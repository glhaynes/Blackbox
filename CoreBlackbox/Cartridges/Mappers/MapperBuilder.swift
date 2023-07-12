//
//  MapperBuilder.swift
//  CoreBlackbox
//
//  Created by Grady Haynes on 10/6/22.
//  Copyright © 2022 Grady Haynes. All rights reserved.
//

import Foundation

struct MapperBuilder {
    
    private static let mapperTypes: [Int: Mapper.Type] = [
        0: Mapper000.self,
        //4: Mapper004.self
    ]
    
    static func mapper(forID id: Int) -> (any Mapper)? {
        mapperTypes[id]?.init()
    }
}
