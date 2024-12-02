import Testing
import Foundation
@testable import CodableExtensions



@Suite struct CodableExtensionsTests {
    
    @Test("Can Encode TestStructAllDataType")
    func testStruct() async throws {
        let object = TestStructAllDataType()
        let TestType = type(of: object)
        let TestArrayType = type(of: [object])
        
        let testObjectArray = [object, object]
        // Encoding of all kinds
        let data          = try #require(object.jsonData)
        let asString      = try #require(object.asString)
        let asDictionary  = try #require(object.asDictionary)
        let asArray       = try #require(testObjectArray.asArray)
        
        var defaultSavingURL: URL
        #expect(throws: Never.self) {
            defaultSavingURL = try object.url()
        }
            
        #expect(throws: Never.self) {
            // Decoding of all kinds and compare results
            let loadedFromData       = try TestType.load(from: data)
            #expect(object == loadedFromData)
        }
        
        #expect(throws: Never.self) {
            let loadedFromStringData = try TestType.load(fromStringData: asString)
            #expect(object == loadedFromStringData)
        }
            
        #expect(throws: Never.self) {
            let loadedFromDictionary = TestType.load(from: asDictionary)
            #expect(object == loadedFromDictionary)
        }
        
        #expect(throws: Never.self) {
            let loadedFromArray      = TestArrayType.load(from: asArray)
            #expect(testObjectArray == loadedFromArray)
        }
            
            //Saves
        #expect(throws: Never.self) {
            let savedURL = try object.save()
            #expect(savedURL == defaultSavingURL)
        }
            
            // LoadFromFile
        #expect(throws: Never.self) {
            let loadedFromFile = try TestType.load()
            #expect(object == loadedFromFile)
        }
    }

    @Test("Can Encode TestClassAllDataType_A")
    func testClassA() async throws {
        let object = TestClassAllDataType_A()
        let TestType = type(of: object)
        let TestArrayType = type(of: [object])
        
        let testObjectArray = [object, object]
        // Encoding of all kinds
        let data          = try #require(object.jsonData)
        let asString      = try #require(object.asString)
        let asDictionary  = try #require(object.asDictionary)
        let asArray       = try #require(testObjectArray.asArray)
        
        var defaultSavingURL: URL
        #expect(throws: Never.self) {
            defaultSavingURL = try object.url()
        }
            
        #expect(throws: Never.self) {
            // Decoding of all kinds and compare results
            let loadedFromData       = try TestType.load(from: data)
            #expect(object == loadedFromData)
        }
        
        #expect(throws: Never.self) {
            let loadedFromStringData = try TestType.load(fromStringData: asString)
            #expect(object == loadedFromStringData)
        }
            
        #expect(throws: Never.self) {
            let loadedFromDictionary = TestType.load(from: asDictionary)
            #expect(object == loadedFromDictionary)
        }
        
        #expect(throws: Never.self) {
            let loadedFromArray      = TestArrayType.load(from: asArray)
            #expect(testObjectArray == loadedFromArray)
        }
            
            //Saves
        #expect(throws: Never.self) {
            let savedURL = try object.save()
            #expect(savedURL == defaultSavingURL)
        }
            
            // LoadFromFile
        #expect(throws: Never.self) {
            let loadedFromFile = try TestType.load()
            #expect(object == loadedFromFile)
        }
    }

    @Test("Can Encode TestClassAllDataType_B")
    func testClassB() async throws {
        let object = TestClassAllDataType_B()
        let TestType = type(of: object)
        let TestArrayType = type(of: [object])
        
        let testObjectArray = [object, object]
        // Encoding of all kinds
        let data          = try #require(object.jsonData)
        let asString      = try #require(object.asString)
        let asDictionary  = try #require(object.asDictionary)
        let asArray       = try #require(testObjectArray.asArray)
        
        var defaultSavingURL: URL
        #expect(throws: Never.self) {
            defaultSavingURL = try object.url()
        }
            
        #expect(throws: Never.self) {
            // Decoding of all kinds and compare results
            let loadedFromData       = try TestType.load(from: data)
            #expect(object == loadedFromData)
        }
        
        #expect(throws: Never.self) {
            let loadedFromStringData = try TestType.load(fromStringData: asString)
            #expect(object == loadedFromStringData)
        }
            
        #expect(throws: Never.self) {
            let loadedFromDictionary = TestType.load(from: asDictionary)
            #expect(object == loadedFromDictionary)
        }
        
        #expect(throws: Never.self) {
            let loadedFromArray      = TestArrayType.load(from: asArray)
            #expect(testObjectArray == loadedFromArray)
        }
            
            //Saves
        #expect(throws: Never.self) {
            let savedURL = try object.save()
            #expect(savedURL == defaultSavingURL)
        }
            
            // LoadFromFile
        #expect(throws: Never.self) {
            let loadedFromFile = try TestType.load()
            #expect(object == loadedFromFile)
        }
    }
    
    @Test("Can Encode TestClassAllDataType_C")
    func testClassC() async throws {
        let object = TestClassAllDataType_C()
        let TestType = type(of: object)
        let TestArrayType = type(of: [object])
        
        let testObjectArray = [object, object]
        // Encoding of all kinds
        let data          = try #require(object.jsonData)
        let asString      = try #require(object.asString)
        let asDictionary  = try #require(object.asDictionary)
        let asArray       = try #require(testObjectArray.asArray)
        
        var defaultSavingURL: URL
        #expect(throws: Never.self) {
            defaultSavingURL = try object.url()
        }
            
        #expect(throws: Never.self) {
            // Decoding of all kinds and compare results
            let loadedFromData       = try TestType.load(from: data)
            #expect(object == loadedFromData)
        }
        
        #expect(throws: Never.self) {
            let loadedFromStringData = try TestType.load(fromStringData: asString)
            #expect(object == loadedFromStringData)
        }
            
        #expect(throws: Never.self) {
            let loadedFromDictionary = TestType.load(from: asDictionary)
            #expect(object == loadedFromDictionary)
        }
        
        #expect(throws: Never.self) {
            let loadedFromArray      = TestArrayType.load(from: asArray)
            #expect(testObjectArray == loadedFromArray)
        }
            
            //Saves
        #expect(throws: Never.self) {
            let savedURL = try object.save()
            #expect(savedURL == defaultSavingURL)
        }
            
            // LoadFromFile
        #expect(throws: Never.self) {
            let loadedFromFile = try TestType.load()
            #expect(object == loadedFromFile)
        }
    }
    

}



