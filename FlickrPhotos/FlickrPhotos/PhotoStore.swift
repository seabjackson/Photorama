//
//  PhotoStore.swift
//  FlickrPhotos
//
//  Created by Seab on 2/2/17.
//  Copyright © 2017 Seab Jackson. All rights reserved.
//

import UIKit
import CoreData

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

enum TagsResult {
    case success([Tag])
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

class PhotoStore {
    
    let imageStore = ImageStore()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container        
    }()
    
    private let session: URLSession = {
       let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            var result = self.processPhotosRequest(data: data, error: error)
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    // download the image data from the remote url provided by the json
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID")
        }
        
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        guard let photoURL = photo.remoteURL else {
            preconditionFailure("Photo expected to have a remote URL.")
        }
        let request = URLRequest(url: photoURL as URL)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            let result = self.processImageRequest(data: data, error: error)
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrAPI.photos(fromJSON: jsonData, into: persistentContainer.viewContext)
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                // couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
    
    func fetchAllPhotos(completion: @escaping (PhotosResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        
        fetchRequest.sortDescriptors = [sortByDateTaken]
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // fetch all tags from the view context
    func fetchAllTags(completion: @escaping (TagsResult) -> Void) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allTags = try fetchRequest.execute()
                completion(.success(allTags))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

















































