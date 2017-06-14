//
//  SomeNetworkServiceSDK.swift
//  SomeNetworkServiceSDK
//
//  Created by Marcin Kubala on 12/06/2017.
//  Copyright © 2017 Maku Software. All rights reserved.
//

import Foundation

public class SomeNetworkServiceClient {
    
    let host: String
    let port: Int
    
    public init(host: String, port: Int?) {
        self.host = host
        self.port = port ?? 80
    }
    
    public func getCurrentTemperature(sensor id: Int, handler callback: @escaping (FetchResult<SomeData>) -> ()) throws {
        let url = URL(string: "http://\(host):\(port)/sensors/\(id)/temperature")
        try doFetch(url: url!, callback: callback) { data in
            let temperature = data.withUnsafeBytes { (ptr: UnsafePointer<Double>) -> Double in
                ptr.pointee
            }
            return SomeData(roomId: id, currentTemp: temperature)
        }
    }
    
    func doFetch<Result>(url: URL, callback: @escaping (FetchResult<Result>) -> (), deserialize: @escaping (Data) -> Result) throws {
        URLSession.shared.dataTask(with: url) { (dataOpt, responseOpt, errorOpt) in
            switch (dataOpt, responseOpt, errorOpt) {
            case (.none, .none, .some):
                callback(.networkError(.networkIoError))
            case (.some(let data), .some, .none):
                callback(.success(deserialize(data)))
            default:
                callback(.notFound)
            }
        }.resume()
    }
    
}

public enum FetchResult<Wrapped: Equatable>: Equatable {
    case notFound
    case networkError(SomeNetworkServiceError)
    case success(Wrapped)

    public static func ==(lhs: FetchResult<Wrapped>, rhs: FetchResult<Wrapped>) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound):
            return true
        case (.networkError(let firstError), .networkError(let secondError)):
            return firstError == secondError
        case (.success(let firstValue), .success(let secondValue)):
            return firstValue == secondValue
        default:
            return false
        }
    }
}

public class SomeData {
    public let currentTemp: Double
    public let roomId: Int
    
    public init(roomId: Int, currentTemp: Double) {
        self.roomId = roomId
        self.currentTemp = currentTemp
    }
}

extension SomeData: Equatable {
    public static func ==(lhs: SomeData, rhs: SomeData) -> Bool {
        return lhs.roomId == rhs.roomId && lhs.currentTemp == rhs.currentTemp
    }
}

public enum SomeNetworkServiceError {
    case networkIoError
}

extension SomeNetworkServiceError: Equatable {
    public static func ==(lhs: SomeNetworkServiceError, rhs: SomeNetworkServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.networkIoError, .networkIoError):
            return true
        }
    }
}
