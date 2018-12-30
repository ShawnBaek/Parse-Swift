//
//  Synchronous.swift
//  ParseSwift (iOS)
//
//  Created by Florent Vilmart on 17-08-20.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation

typealias ResultCapturing<T> = (Result<T>) -> Void
// Mark it private for now
private func await<T>(block: (@escaping ResultCapturing<T>) -> Void) throws -> T {
    let sema = DispatchSemaphore(value: 0)
    var result: Result<T>!
    block({
        result = $0
        sema.signal()
    })
    sema.wait()
    switch result! {
    case .success(let value):
        return value
    case .error(let error):
        throw error
    default:
        fatalError()
    }
}

public struct Synchronous<T> {
    let object: T
}

extension Synchronous where T: Saving {
    public func save(options: API.Option = []) throws -> T.SavingType {
        return try await { done in
            _ = object.save(options: options, callback: done)
        }
    }
}

extension Synchronous where T: Fetching {
    public func fetch(options: API.Option = []) throws -> T.FetchingType {
        return try await { done in
            _ = object.fetch(options: options, callback: done)
        }
    }
}

extension Synchronous where T: Querying {
    public func find(options: API.Option = []) throws -> [T.ResultType] {
        return try await { done in
            _ = object.find(options: options, callback: done)
        }
    }
    public func first(options: API.Option = []) throws -> T.ResultType? {
        return try await { done in
            _ = object.first(options: options, callback: done)
        }
    }
    public func count(options: API.Option = []) throws -> Int {
        return try await { done in
            _ = object.count(options: options, callback: done)
        }
    }
}

public extension Saving {
    var sync: Synchronous<Self> {
        return Synchronous(object: self)
    }
}

public extension Fetching {
    var sync: Synchronous<Self> {
        return Synchronous(object: self)
    }
}

// Force implementation for ObjectType as Feching and Saving makes it ambiguous
public extension ObjectType {
    var sync: Synchronous<Self> {
        return Synchronous(object: self)
    }
}

public extension Query {
    var sync: Synchronous<Query> {
        return Synchronous(object: self)
    }
}

// Temporary, just for demo
public extension ObjectType {
    public static func saveAllSync(options: API.Option = [], _ objects: Self...) throws -> [(Self, ParseError?)] {
        return try await { done in
            _ = objects.saveAll(options: options, callback: done)
        }
    }
}

public extension Sequence where Element: ObjectType {
    public func saveAllSync(options: API.Option = []) throws -> [(Element, ParseError?)] {
        return try await { done in
            _ = self.saveAll(options: options, callback: done)
        }
    }
}
