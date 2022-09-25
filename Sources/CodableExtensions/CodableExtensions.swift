    //
    //  CodableExtension.swift
    //  JsonClassSaver
    //
    //  Created by Ricardo Venieris on 30/11/18.
    //  Copyright © 2018 LES.PUC-RIO. All rights reserved.
    //

import Foundation
import CloudKit // For decode CKAsset as a valid Data type convertible to otiginal asset type
import os.log

public enum FileManageError:Error {
    case canNotSaveInFile
    case canNotReadFile
    case canNotConvertData
    case canNotDecodeData
    case canNotEncodeData
    case invalidFileName
}

public extension Error {
    public var asString:String {
        return String(describing: self)
    }
}

public extension Encodable {
    
    private var jSONSerializationDefaultReadingOptions:JSONSerialization.ReadingOptions {
        [JSONSerialization.ReadingOptions.allowFragments, JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.mutableLeaves]
    }
    
    public var asString:String? {
        return self.jsonData?.toText
    }
    
    public var jsonData:Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {}
        return nil
    }
    
    public var asDictionary:[String: Any]? {
        if let data = self as? Data { return data.toDictionary as? [String: Any] } // is type IS Data.type, properly convert
        
        guard let json:Data  = self.jsonData,
              let jsonObject = try? JSONSerialization.jsonObject(with: json, options: jSONSerializationDefaultReadingOptions) else {
            if #available(macOS 10.12, *) {
                os_log("Cannot Decode %@ type as Dictionary", type:.error, String(describing: type(of:self)))
            } else {
                    // Fallback on earlier versions
            }
            return nil
        }
            // if jsonObject is OK
        if let dic = jsonObject as? [String: Any] {
            return dic
        }
            // else if is an Array
        if let value = jsonObject as? [Any] {
            let key = String(describing: type(of:self))
            return [key:value]
        }
            // else
        os_log("Cannot Decode this type as Dictionary", type:.error)
        return nil
    }
    
    public var asArray:[Any]? {
        do {
            return try JSONSerialization.jsonObject(with: JSONEncoder().encode(self), options:jSONSerializationDefaultReadingOptions) as? [Any]
        } catch {
            os_log("Cannot Decode %@ type as Array", type:.error, String(describing: type(of:self)))
        }
        return nil
    }
    
    public func save(in file:String? = nil)throws {
        let url = try url(for: file)
        try self.save(in: url)
    }
    
    public func save(in url:URL) throws {
        do {
            try JSONEncoder().encode(self).write(to: url)
            os_log("Saved in %@", type:.info, String(describing: url))
        } catch {
            os_log("Can not save in %@", type:.error, String(describing: url))
            throw FileManageError.canNotSaveInFile
        }
    }
    
    public func url(for name:String? = nil)throws ->URL {
        let fileName = name ?? String(describing: type(of: self))
        let ext = fileName.hasSuffix(".json") ? "" : ".json"
        guard let url = URL.localPath(for: fileName+ext) else {
            os_log("invalud url for %@", type:.error, fileName+ext)
            throw FileManageError.invalidFileName
        }
        return url
    }
}

public extension Decodable {
    
        /// Mutating Loads
    public mutating func load(from data:Data) throws {
        self = try Self.load(from: data)
    }
    
    public mutating func load(from url:URL) throws {
        self = try Self.load(from: url)
    }
    
    public mutating func load(from file:String? = nil) throws {
        self = try Self.load(from: file)
    }
    
    public mutating func load(fromStringData stringData:String) throws {
        self = try Self.load(from: stringData)
    }
    
    public mutating func load(from dictionary:[String:Any]) throws {
        try self = Self.load(from: dictionary)
    }
    
    public mutating func load(from array:[Any]) throws {
        try self = Self.load(from: array)
    }
    
        /// Static Loads
    public static func load(from data:Data)throws ->Self {
            // Try to read
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            os_log("Can not read from %@", type:.error, String(describing: data))
            throw FileManageError.canNotConvertData
        }
    }
    
    public static func load(from url:URL) throws  ->Self {
            // Try to read
        do {
            let data = try Data(contentsOf: url)
            return try Self.load(from: data)
        } catch {
            os_log("Can not read from %@", type:.error, String(describing: url))
            throw FileManageError.canNotReadFile
        }
    }
    
    public static func load(from file:String? = nil)throws ->Self {
        return try Self.load(from: Self.urlOrJsonPath(from: file))
    }
    
    public static func load(fromString stringData:String)throws ->Self{
        guard let data = stringData.data(using: .utf8) else {
            os_log("Can not read from %@", type:.error, stringData)
            throw FileManageError.canNotConvertData
        }
        do {
            return try load(from: data)
        } catch {
            os_log("Can not read from %@", type:.error, stringData)
            throw FileManageError.canNotConvertData
        }
    }
    
    public static func load(from dictionary:[String:Any])throws ->Self{
        do {
            guard let data:Data =
                    (dictionary[String(describing: self)] as? [Any])?.asData ?? // if data is Array, or
                    dictionary.asData // if data is Dictionary
            else { throw FileManageError.canNotConvertData } // else throw error to catch
            return try Self.load(from: data)
        } catch let error {
            os_log("Can not convert from dictionary to %@", type:.error, String(describing: Self.self))
            throw error
        }
    }
    
    public static func load(from array:[Any])throws ->Self{
        do {
            guard let data = array.asData else { throw FileManageError.canNotConvertData }
            return try Self.load(from: data)
        } catch {
            os_log("Can not convert from array to %@", type:.error, String(describing: Self.self))
            throw FileManageError.canNotConvertData
        }
    }
    
    public static func urlOrJsonPath(from file:String? = nil)throws ->URL {
            // generates URL for documentDir/file.json
        let fileName = file ?? String(describing: Self.self)
        
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
    
    public var toText:String {
        return String(data: self, encoding: .utf8) ?? #""ERROR": "cannot decode into String"""#
    }
    
    public var toDictionary:[AnyHashable:Any] {
        if let dictionary = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [AnyHashable: Any] {
            return dictionary
        }
            // else
        
        if let array = self.asArray as? Codable {
            return ["Array":array]
        }
            // else
        return ["ERROR":"cannot decode into dictionary"]
    }
    
    public var toArray:[Codable]? {
        return try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [Codable]
    }
    
    public func convert<T>(to:T.Type) throws ->T where T:Codable {
            // Try to convert
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            os_log("Can not convert this: %@", type:.error, String(describing: self))
            throw FileManageError.canNotDecodeData
        }
    }
    
        /// Saves data in a file in default.temporaryDirectory, returning URL
    public func saveInTemp()throws->URL {
        let tmpDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString+".data")
        try self.write(to: tmpDirURL)
        return tmpDirURL
    }
    
        /// save in localDir, returning success
    @discardableResult
    public func saveInLocalDir(naming file:String?, extension ext:String? = nil)->Bool {
        guard let url = URL.localPath(for: file, extension: ext) else {return false}
        do {
            try self.write(to: url)
            return true
        } catch {
            return false
        }
    }
    
}

extension URL {
    public var contentAsData:Data? {
        return try? Data(contentsOf: self)
    }
    
        /// returns URL in document directory
    public static func localPath(for fileName: String?, extension ext:String? = nil)->URL? {
        var ext = ext ?? ""
        ext = ext.isEmpty ? "" : "."+ext
        guard let fileName = fileName else {return nil}
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return URL(fileURLWithPath: documentDir.appendingPathComponent(fileName+ext))
    }
    
        /// returns URL if file exists in document directory
    public static func ifExists(file fileName: String?, extension ext:String? = nil)->URL? {
        guard let url = URL.localPath(for: fileName, extension: ext),
              FileManager.default.fileExists(atPath: url.path) else {return nil}
        return url
    }
    
    public static func jsonPath(for name:String? = nil)throws ->URL {
        let fileName = name ?? String(describing: type(of: self))
        let ext = fileName.hasSuffix(".json") ? "" : ".json"
        guard let url = URL.localPath(for: fileName+ext) else {
            os_log("invalud url for %@", type:.error, fileName+ext)
            throw FileManageError.invalidFileName
        }
        return url
    }
    
}

extension Array {
    public var asData:Data? {
        guard let array = CertifiedCodableData(["Array":self]).dictionary["Array"] else {return nil}
        return try? JSONSerialization.data(withJSONObject: array, options: [])
    }
}

extension Dictionary where Key == String {
    public var asData:Data? {
        let dic = CertifiedCodableData(self).dictionary
        return try? JSONSerialization.data(withJSONObject: dic, options: [])
    }
    
}

extension String {
    public var asData:Data? {
        return self.data(using: .utf8)
    }
}

public struct CertifiedCodableData:Codable {
    private var bool:[String:Bool] = [:]
    private var number:[String:Double] = [:]
    private var date:[String:Date] = [:]
    private var string:[String:String] = [:]
    private var data:[String:Data] = [:]
    private var custom:[String:CertifiedCodableData] = [:]
    
    private var boolArray:[String:[Bool]] = [:]
    private var numberArray:[String:[Double]] = [:]
    private var dateArray:[String:[Date]] = [:]
    private var stringArray:[String:[String]] = [:]
    private var dataArray:[String:[Data]] = [:]
    private var customArray:[String:[CertifiedCodableData]] = [:]
    
    public var dictionary:[String:Any] {
        var dic:[String:Any] = [:]
        bool.forEach{dic[$0.key] = $0.value}
        number.forEach{dic[$0.key] = $0.value}
        date.forEach{dic[$0.key] = $0.value.timeIntervalSinceReferenceDate}
        string.forEach{dic[$0.key] = $0.value}
        data.forEach{dic[$0.key] = $0.value.base64EncodedString()}
        custom.forEach{dic[$0.key] = $0.value.dictionary}
        
        boolArray.forEach{dic[$0.key] = $0.value}
        numberArray.forEach{dic[$0.key] = $0.value}
        dateArray.forEach{dic[$0.key] = $0.value.map{$0.timeIntervalSinceReferenceDate}}
        stringArray.forEach{dic[$0.key] = $0.value}
        dataArray.forEach{dic[$0.key] = $0.value.map{$0.base64EncodedString()}}
        customArray.forEach{dic[$0.key] = $0.value.map{$0.dictionary}}
        
        return dic
    }
    
    public init(_ originalData:[String:Any]) {
        for item in originalData {
            
            if let dado = item.value as? Bool            { bool        [item.key] = dado}
            else if let dado = item.value as? Int             { number      [item.key] = Double(dado)}
            else if let dado = item.value as? Double          { number      [item.key] = dado}
            else if let dado = item.value as? Date            { date        [item.key] = dado}
            else if let dado = item.value as? String          { string      [item.key] = dado}
            else if let dado = item.value as? Data            { data        [item.key] = dado}
            
            else if let dado = item.value as? [Bool           ] { boolArray  [item.key] = dado}
            else if let dado = item.value as? [Int            ] { numberArray[item.key] = dado.map{Double($0)}}
            else if let dado = item.value as? [Double         ] { numberArray[item.key] = dado}
            else if let dado = item.value as? [Date           ] { dateArray  [item.key] = dado}
            else if let dado = item.value as? [String         ] { stringArray[item.key] = dado}
            else if let dado = item.value as? [Data           ] { dataArray  [item.key] = dado}
            
            else if let dado = item.value as? CKAsset   { data[item.key] = dado.fileURL?.contentAsData}
            else if let dado = item.value as? [CKAsset] { dataArray[item.key] = dado.compactMap{$0.fileURL?.contentAsData} }
            
            else if let dado = item.value as? [String:Any]   { custom      [item.key] = CertifiedCodableData(dado)}
            else if let dado = item.value as? [[String:Any]] { customArray[item.key] = dado.map{CertifiedCodableData($0)} }
            
            else if let _ = item.value as? [Any         ] { stringArray[item.key] = []}
            
            else {
                debugPrint("Unknown Type in originalData:   \(item.key) = \(item.value)   -> trying to decode into string")
                string      [item.key] = "\(item.value)"
            }
        }
    }
}
