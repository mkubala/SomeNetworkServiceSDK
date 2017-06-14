//
//  SomeNetworkServiceSDKTests.swift
//  SomeNetworkServiceSDKTests
//
//  Created by Marcin Kubala on 12/06/2017.
//  Copyright © 2017 Maku Software. All rights reserved.
//

import XCTest
import OHHTTPStubs
import SomeNetworkServiceSDK

import Quick
import Nimble

class SomeNetworkServiceSDKTests: QuickSpec {
    override func spec() {
        describe("the SomeNetworkServiceClient") {
            afterEach {
                OHHTTPStubs.removeAllStubs()
            }
            
            context("when asked for something") {
                it("sends GET request") {
                    let fakeHostname = "fakeHost.softwaremill.com"
                    let fakePort = 8080
                    let fakeId = 10
                    let fakeTemp = 23.0
                    
                    stub(condition: isHost(fakeHostname) && isPath("/sensors/\(fakeId)/temperature")) { _ in
                        var value = fakeTemp
                        let stubData = withUnsafePointer(to: &value) {
                            Data(bytes: UnsafePointer($0), count: MemoryLayout.size(ofValue: fakeTemp))
                        }
                        return OHHTTPStubsResponse(data: stubData, statusCode: 200, headers: nil)
                    }
                    
                    let client = SomeNetworkServiceClient(host: fakeHostname, port: fakePort)
                    
                    waitUntil { done in
                        let result: ()? = try? client.getCurrentTemperature(sensor: fakeId) { fetchResult in
                            expect(fetchResult).to(equal(FetchResult.success(SomeData(roomId: fakeId, currentTemp: fakeTemp))))
                            done()
                        }
                        expect(result).toNot(beNil())
                    }
                }
            }
        }
    }
    
}
