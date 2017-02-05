//
//  Photo+CoreDataProperties.swift
//  FlickrPhotos
//
//  Created by Seab on 2/5/17.
//  Copyright © 2017 Seab Jackson. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var photoID: String?
    @NSManaged public var title: String?
    @NSManaged public var dateTaken: NSDate?
    @NSManaged public var remoteURL: NSURL?

}
