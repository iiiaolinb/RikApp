//
//  RealmFileItem.swift
//  BusinessLogicFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation
import RealmSwift
import NetworkLayerFramework

public final class RealmFileItem: Object {
    @Persisted public var id: Int = 0
    @Persisted public var url: String = ""
    @Persisted public var type: String = ""
    
    public convenience init(from fileItem: FileItem) {
        self.init()
        self.id = fileItem.id
        self.url = fileItem.url
        self.type = fileItem.type.rawValue
    }
    
    public func toFileItem() -> FileItem? {
        guard let fileType = FileType(rawValue: type) else {
            return nil
        }
        return FileItem(id: id, url: url, type: fileType)
    }
}

