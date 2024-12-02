//
//  CodableExtension.swift
//  JsonSaver
//
//  Created by Ricardo Venieris on 30/11/2018.
//  Copyright © 2018. All rights reserved.
//  v2.0 Created at 30/11/2020
//

/*
 Updates:
    v2.0
        - Removed struct CertifiedCodableData and Import CludKit. This is not place for deal with CloudKit issues
            - Dictionary and Array 'asData' transformation no longer is a CertifiedCodableData
        - Added Mirror extensions
            - Now 'jsonData' is synthesized from Mirroing classes
        - Mirror extension adds 'array' and 'dictionary'
        - Mirror.Children extension adds isBasicType, isDictionary, dictionary, array and func process(_ child: (label: String?, value: Any))
 
        - 'asDictionary' no longer return ["Array": any Array] when trying to convert an Array to Dictionary
        - Minor bugs fixed
*/

import Foundation
import CryptoKit
import os.log

public enum FileManageError:Error {
    case canNotSaveInFile
    case canNotReadFile
    case canNotConvertData
    case canNotDecodeData
    case canNotEncodeData
    case invalidFileName
    case cannotEncriptData
}

public extension Error {
    var asString:String {
        return String(describing: self)
    }
}

public extension Encodable {
    
    var jsonData:Data? {
        if let dictionary = Mirror(reflecting: self).dictionary {
            return try? JSONSerialization.data(withJSONObject: dictionary)
        } else if let array = Mirror(reflecting: self).array {
            return try? JSONSerialization.data(withJSONObject: array)
        }
        return nil
    }
    
    var asString:String? { return self.jsonData?.toText }
    
    var asDictionary:[String: Any]? {
        if let data = self as? Data { return data.toDictionary as? [String: Any] } // is type IS Data.type, properly convert
        
        guard let jsonData,
              let jsonObject = jsonData.jsonObject,
              let dic = jsonObject as? [String: Any] else {
            log("Cannot Decode %@ type as Dictionary", type:.error, String(describing: type(of:self)))
            return nil
        }
        return dic
    }
    
    var asArray:[Any]? {
        if let data = self as? Data { return data.toArray } // is type IS Data.type, properly convert
        
        guard let jsonData,
              let jsonObject = jsonData.jsonObject,
              let value = jsonObject as? [Any] else {
            log("Cannot Decode %@ type as Array", type:.error, String(describing: type(of:self)))
            return nil
        }
        return value
    }
    
    @discardableResult
    func save(in fileName:String? = nil)throws -> URL{
        let url = try url(for: fileName)
        try self.save(in: url)
        return url
    }
    
    func save(in url:URL) throws {
        do {
            guard let data = self.jsonData else { throw FileManageError.canNotConvertData }
            try data.write(to: url)
            log("Saved in %@", type:.info, String(describing: url))
        } catch {
            log("Can not save in %@", type:.error, String(describing: url))
            throw FileManageError.canNotSaveInFile
        }
    }
    
    @available(iOS 13.0, *)
    @available(OSX 10.15, *)
    @available(watchOS 6.0, *)
    func save(encryptWith key: SymmetricKey , to url: URL) throws {
        do {
            guard let data = self.jsonData else { throw FileManageError.canNotConvertData }
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combinedData = sealedBox.combined else { throw FileManageError.canNotConvertData }
            try combinedData.write(to: url)
            log("Saved in %@", type: .info, String(describing: url))
        } catch {
            log("Cannot save in %@", type: .error, String(describing: url))
            throw FileManageError.canNotSaveInFile
        }
    }
    
    func url(for fileName:String? = nil)throws ->URL {
        let fileName = fileName ?? String(describing: type(of: self))
        let url = try URL.jsonPath(for: fileName)
        return url
    }
}

public extension Decodable {
    
        /// Mutating Loads
    mutating func load(from data:Data) throws { self = try Self.load(from: data) }
    
    mutating func load(from url:URL) throws { self = try Self.load(from: url) }
    
    mutating func load(from fileName:String? = nil) throws { self = try Self.load(from: fileName) }
    
    mutating func load(fromStringData stringData:String) throws { self = try Self.load(from: stringData) }
    
    mutating func load(from dictionary:[String:Any]) throws { try self = Self.load(from: dictionary) }
    
    mutating func load(from array:[Any]) throws { try self = Self.load(from: array) }
    
        /// Static Loads
    static func load(from data:Data)throws ->Self {
            // Try to read
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            log("Can not read from %@", type:.error, String(describing: data))
            throw FileManageError.canNotConvertData
        }
    }
    
    static func load(from url:URL) throws  ->Self {
            // Try to read
        do {
            let data = try Data(contentsOf: url)
            return try Self.load(from: data)
        } catch {
            log("Can not read from %@", type:.error, String(describing: url))
            throw FileManageError.canNotReadFile
        }
    }
    
    @available(iOS 13.0, *)
    @available(OSX 10.15, *)
    @available(watchOS 6.0, *)
    static func load(from url: URL, decryptionKey: SymmetricKey) throws -> Self {
        do {
            // Read the encrypted data from the specified URL
            let encryptedData = try Data(contentsOf: url)

            // Decrypt the data using the provided decryption key
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: decryptionKey)

            // Decode the decrypted data into your object
            return try Self.load(from: decryptedData)
        } catch {
            log("Cannot read or decrypt data from %@", type: .error, String(describing: url))
            throw FileManageError.canNotReadFile
        }
    }

    static func load(from fileName:String? = nil)throws ->Self {
        return try Self.load(from: Self.urlOrJsonPath(from: fileName))
    }
    
    static func load(fromStringData stringData:String)throws ->Self{
        guard let data = stringData.data(using: .utf8) else {
            log("Can not read from %@", type:.error, stringData)
            throw FileManageError.canNotConvertData
        }
        do {
            return try load(from: data)
        } catch {
            log("Can not read from %@", type:.error, stringData)
            throw FileManageError.canNotConvertData
        }
    }
    
    static func load(from dictionary:[String:Any])throws ->Self{
        do {
            guard let data:Data = dictionary.asData else { throw FileManageError.canNotConvertData }
            return try Self.load(from: data)
        } catch let error {
            log("Can not convert from dictionary to %@", type:.error, String(describing: Self.self))
            throw error
        }
    }
    
    static func load(from array:[Any])throws ->Self{
        do {
            guard let data = array.asData else { throw FileManageError.canNotConvertData }
            return try Self.load(from: data)
        } catch {
            log("Can not convert from array to %@", type:.error, String(describing: Self.self))
            throw FileManageError.canNotConvertData
        }
    }
    /// Delete json file
    static func delete(fileNamed file:String? = nil)throws {
        let url = try Self.urlOrJsonPath(from: file)
        try FileManager.default.removeItem(at: url)
    }
    
    static func urlOrJsonPath(from fileName:String? = nil)throws ->URL {
            // generates URL for documentDir/file.json
        let fileName = fileName ?? String(describing: Self.self)
        
        if fileName.lowercased().hasPrefix("http") {
            return URL(string: fileName) ?? URL(fileURLWithPath: fileName)
        } //else
        if fileName.lowercased().hasPrefix("file") {
            return URL(fileURLWithPath: String(fileName.dropFirst("file://".count)))
        } // else
        let url = try URL.jsonPath(for: fileName)
        return url
    }
}

    /// Type Extensions
public extension Data {
    
    private var jSONSerializationDefaultReadingOptions:JSONSerialization.ReadingOptions {
        [JSONSerialization.ReadingOptions.allowFragments, JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.mutableLeaves]
    }
    
    var jsonObject:Any? {
        try? JSONSerialization.jsonObject(with: self, options: jSONSerializationDefaultReadingOptions)
    }

    
    var toText:String {
        return String(data: self, encoding: .utf8) ?? #""ERROR": "cannot decode into String"""#
    }
    
    var toDictionary:[AnyHashable:Any]? {
        return try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [AnyHashable: Any]
    }
    
    var toArray:[Codable]? { try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [Codable] }
    
    func convert<T>(to:T.Type) throws ->T where T:Codable {
            // Try to convert
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            os_log("Can not convert this: %@", type:.error, String(describing: self))
            throw FileManageError.canNotDecodeData
        }
    }
    
        /// Saves data in a file in default.temporaryDirectory, returning URL
    func saveInTemp()throws->URL {
        let tmpDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString+".data")
        try self.write(to: tmpDirURL)
        return tmpDirURL
    }
    
        /// save in localDir, returning success
    @discardableResult
    func saveInLocalDir(naming file:String?, extension ext:String? = nil)->Bool {
        guard let url = URL.localPath(for: file, extension: ext) else {return false}
        do {
            try self.write(to: url)
            return true
        } catch {
            return false
        }
    }
    
}

public extension URL {
    var contentAsData:Data? { try? Data(contentsOf: self) }
    
        /// returns URL in document directory
    static func localPath(for fileName: String?, extension ext:String? = nil)->URL? {
        var ext = ext ?? ""
        ext = ext.isEmpty ? "" : "."+ext
        guard let fileName = fileName else {return nil}
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return URL(fileURLWithPath: documentDir.appendingPathComponent(fileName+ext))
    }
    
        /// returns URL if file exists in document directory
    static func ifExists(file fileName: String?, extension ext:String? = nil)->URL? {
        guard let url = URL.localPath(for: fileName, extension: ext),
              FileManager.default.fileExists(atPath: url.path) else {return nil}
        return url
    }
    
    static func jsonPath(for fileName:String)throws ->URL {
        let ext = fileName.hasSuffix(".json") ? "" : ".json"
        guard let url = URL.localPath(for: fileName+ext) else {
            os_log("invalid url for %@", type:.error, fileName+ext)
            throw FileManageError.invalidFileName
        }
        return url
    }
    
}

public extension Array {
    var asData:Data? { try? JSONSerialization.data(withJSONObject: self, options: []) }
}

public extension String {
    var asData:Data? { self.data(using: .utf8) }
}

public extension Dictionary where Key == String {
    var asData:Data? { try? JSONSerialization.data(withJSONObject: self, options: []) }

}

public protocol URLForCodableFiles {}
public extension URLForCodableFiles {
    func url(for name:String? = nil)throws -> URL {
        let fileName = name ?? String(describing: type(of: self))
        let ext = fileName.hasSuffix(".json") ? "" : ".json"
        guard let url = URL.localPath(for: fileName+ext) else {
            log("invalid url for %@", type:.error, fileName+ext)
            throw FileManageError.invalidFileName
        }
        return url
    }
}


public extension Mirror {
    var array: [Any]? { self.children.array }

    var dictionary: [String: Any]? {
        guard var result = self.children.dictionary else { return nil }
        
        if let superclassDictionary = superclassMirror?.dictionary {
            result.merge(superclassDictionary, uniquingKeysWith: {$1})
        }
        return result
    }
    
}

public extension Mirror.Children {
    var isBasicType: Bool { isEmpty }
    var isDictionary: Bool { !self.compactMap(\.label).isEmpty } // else is Array or Set
    
    var dictionary: [String: Any]? {
        guard isDictionary else { return nil }
        
        return reduce(into: [:]) { result, child in
            if let key = child.label,
               let value = process(child) {
                result[key] = value
            }
        }
    }
    
    var array: [Any]? {
        guard !isDictionary else { return nil }
        
        return reduce(into: []) { result, child in
            if let value = process(child) { result.append(value) }
        }
    }
    
    func process(_ child: (label: String?, value: Any)) -> Any? {
        guard child.label != "_$observationRegistrar" else { return nil }
        
        let value = child.value
        let valueMirror = Mirror(reflecting: value)
        let valueChildren = valueMirror.children

        // if is Basic type (Int, String...), get value
             if valueChildren.isBasicType               { return value }
        else if let dictionary = valueMirror.dictionary { return dictionary }
        else if let array = valueMirror.array           { return array }
        // else
        return nil

    }
}

public func log(_ message: StaticString, type: OSLogType = .default, _ args: any CVarArg...) {
    if #available(macOS 10.12, *) {
        os_log(message, type:type, args)
    } else {
        print(message, args)
    }
}
