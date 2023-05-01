//
//  CodableExtensions.swift
//  CodableExtensions
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
    var asString:String {
        return String(describing: self)
    }
}

public class CodableExtensionsLogging {
    typealias LogEntry = (message: String, successful: Bool)
    public private(set) static var shared = CodableExtensionsLogging()
    
    fileprivate var logActions = [(LogEntry) -> Void]()
    
    public var shouldPrint = true
    
    private init() {}
    
    @MainActor func addLogAction(_ action: @escaping (LogEntry) -> Void) {
        self.logActions.append(action)
    }
}

fileprivate func log(_ message: String, success: Bool) {
    if CodableExtensionsLogging.shared.shouldPrint {
        print("[CodableExtensions] \(success ? "" : "ERROR") \(message)")
    }
    for logAction in CodableExtensionsLogging.shared.logActions {
        logAction((message, success))
    }
}

public extension Encodable {
    
    private var jSONSerializationDefaultReadingOptions:JSONSerialization.ReadingOptions {
        [JSONSerialization.ReadingOptions.allowFragments, JSONSerialization.ReadingOptions.mutableContainers, JSONSerialization.ReadingOptions.mutableLeaves]
    }
    
    var asString:String? {
        return self.jsonData?.toText
    }
    
    var jsonData:Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {}
        return nil
    }
    
    var asDictionary:[String: Any]? {
        if let data = self as? Data { return data.toDictionary as? [String: Any] } // is type IS Data.type, properly convert
        
        guard let json:Data  = self.jsonData,
              let jsonObject = try? JSONSerialization.jsonObject(with: json, options: jSONSerializationDefaultReadingOptions) else {
            log("[CodableExtensions] Couldn't represent type \(String(describing: type(of:self))) as Dictionary because of a problem with an intermediate JSON representation", success: false)
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
        log("[CodableExtensions] Couldn't represent type \(String(describing: type(of:self))) as Dictionary", success: false)
        return nil
    }
    
    var asArray:[Any]? {
        do {
            return try JSONSerialization.jsonObject(with: JSONEncoder().encode(self), options:jSONSerializationDefaultReadingOptions) as? [Any]
        } catch {
            log("[CodableExtensions] Couldn't represent type \(String(describing: type(of:self))) as Array.", success: false)
            log(error.localizedDescription, success: false)
        }
        return nil
    }
    
    func save(in file:String? = nil)throws {
        let url = try url(for: file)
        try self.save(in: url)
    }
    
    func save(in url:URL) throws {
        do {
            try JSONEncoder().encode(self).write(to: url)
            log("[CodableExtensions] Saved in \(String(describing: url))", success: true)
        } catch {
            log("[CodableExtensions] Couldn't save in \(String(describing: url)).", success: false)
            log(error.localizedDescription, success: false)
            throw FileManageError.canNotSaveInFile
        }
    }
    
    func url(for name:String? = nil)throws ->URL {
        let fileName = name ?? String(describing: type(of: self))
        let ext = fileName.hasSuffix(".json") ? "" : ".json"
        guard let url = URL.localPath(for: fileName+ext) else {
            log("[CodableExtensions] Invalid URL for \(fileName+ext).", success: false)
            throw FileManageError.invalidFileName
        }
        return url
    }
}

public extension Decodable {
    
        /// Mutating Loads
    mutating func load(from data:Data) throws { self = try Self.load(from: data) }
    
    mutating func load(from url:URL) throws { self = try Self.load(from: url) }
    
    mutating func load(from file:String? = nil) throws { self = try Self.load(from: file) }
    
    mutating func load(fromStringData stringData:String) throws { self = try Self.load(from: stringData) }
    
    mutating func load(from dictionary:[String:Any]) throws { try self = Self.load(from: dictionary) }
    
    mutating func load(from array:[Any]) throws { try self = Self.load(from: array) }
    
        /// Static Loads
    static func load(from data:Data)throws ->Self {
            // Try to read
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            log("[CodableExtensions] Couldn't decode from \(String(describing: data)).", success: false)
            log(error.localizedDescription, success: false)
            throw FileManageError.canNotConvertData
        }
    }
    
    static func load(from url:URL) throws  ->Self {
            // Try to read
        do {
            let data = try Data(contentsOf: url)
            return try Self.load(from: data)
        } catch {
            log("[CodableExtensions] Couldn't load from \(String(describing: url)).", success: false)
            log(error.localizedDescription, success: false)
            throw FileManageError.canNotReadFile
        }
    }
    
    static func load(from file:String? = nil)throws ->Self {
        return try Self.load(from: Self.urlOrJsonPath(from: file))
    }
    
    static func load(fromString stringData:String)throws ->Self{
        guard let data = stringData.data(using: .utf8) else {
            log("[CodableExtensions] Couldn't decode string \(stringData.debugDescription).", success: false)
            log("String is not formatted with valid UTF-8.", success: false)
            throw FileManageError.canNotConvertData
        }
        do {
            return try load(from: data)
        } catch {
            log("[CodableExtensions] Couldn't read from \(stringData.debugDescription).", success: false)
            log(error.localizedDescription, success: false)
            throw FileManageError.canNotConvertData
        }
    }
    
    static func load(from dictionary:[String:Any])throws ->Self{
        do {
            guard let data:Data =
                    (dictionary[String(describing: self)] as? [Any])?.asData ?? // if data is Array, or
                    dictionary.asData // if data is Dictionary
            else { throw FileManageError.canNotConvertData } // else throw error to catch
            return try Self.load(from: data)
        } catch let error {
            log("[CodableExtensions] Couldn't convert from dictionary to \(String(describing: Self.self)).", success: false)
            log(error.localizedDescription, success: false)
            throw error
        }
    }
    
    static func load(from array:[Any])throws ->Self{
        do {
            guard let data = array.asData else { throw FileManageError.canNotConvertData }
            return try Self.load(from: data)
        } catch {
            log("[CodableExtensions] Couldn't convert from array to \(String(describing: Self.self)).", success: false)
            log(error.localizedDescription, success: false)
            throw FileManageError.canNotConvertData
        }
    }
    /// Delete json file
    static func delete(file:String? = nil)throws {
        let url = try Self.urlOrJsonPath(from: file)
        try FileManager.default.removeItem(at: url)
    }
    
    static func urlOrJsonPath(from file:String? = nil)throws ->URL {
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
    
    var toText:String? {
        guard let resultAsText = String(data: self, encoding: .utf8) else {
            log("[CodableExtensions] Couldn't decode Data into String.", success: false)
            return nil
        }
        return resultAsText
    }
    
    var toDictionary:[AnyHashable:Any]? {
        if let dictionary = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [AnyHashable: Any] { return dictionary }
            // else
        
        if let array = self.asArray as? Codable { return ["Array":array] }
            // else
        log("[CodableExtensions] Couldn't decode Data into Dictionary.", success: false)
        return nil
    }
    
    var toArray:[Codable]? { try? JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? [Codable] }
    
    func convert<T>(to:T.Type) throws ->T where T:Codable {
            // Try to convert
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            log("[CodableExtensions] Couldn't convert this: \(String(describing: self)).", success: false)
            log(error.localizedDescription, success: false)
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
    var contentAsData:Data? {
        return try? Data(contentsOf: self)
    }
    
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
    
    static func jsonPath(for name:String? = nil)throws ->URL {
        let fileName = name ?? String(describing: type(of: self))
        let ext = fileName.hasSuffix(".json") ? "" : ".json"
        guard let url = URL.localPath(for: fileName+ext) else {
            log("[CodableExtensions] Invalid url for \(fileName+ext)", success: false)
            throw FileManageError.invalidFileName
        }
        return url
    }
    
}

public extension Array {
    var asData:Data? {
        guard let array = CertifiedCodableData(["Array":self]).dictionary["Array"] else {return nil}
        return try? JSONSerialization.data(withJSONObject: array, options: [])
    }
}

public extension String {
    var asData:Data? { self.data(using: .utf8) }
}


public extension Dictionary where Key == String {
    var asData:Data? {
        let dic = CertifiedCodableData(self).dictionary
        return try? JSONSerialization.data(withJSONObject: dic, options: [])
    }

}

public struct CertifiedCodableData:Codable {
    private var bool:[String:Bool] = [:]
    private var int:[String:Int] = [:]
    private var double:[String:Double] = [:]
    private var date:[String:Date] = [:]
    private var string:[String:String] = [:]
    private var data:[String:Data] = [:]
    private var custom:[String:CertifiedCodableData] = [:]

    private var boolArray:[String:[Bool]] = [:]
    private var intArray:[String:[Int]] = [:]
    private var doubleArray:[String:[Double]] = [:]
    private var dateArray:[String:[Date]] = [:]
    private var stringArray:[String:[String]] = [:]
    private var dataArray:[String:[Data]] = [:]
    private var customArray:[String:[CertifiedCodableData]] = [:]

    public var dictionary:[String:Any] {
        var dic:[String:Any] = [:]
        bool.forEach{dic[$0.key] = $0.value}
        int.forEach{dic[$0.key] = $0.value}
        double.forEach{dic[$0.key] = $0.value}
        date.forEach{dic[$0.key] = $0.value.timeIntervalSinceReferenceDate}
        string.forEach{dic[$0.key] = $0.value}
        data.forEach{dic[$0.key] = $0.value.base64EncodedString()}
        custom.forEach{dic[$0.key] = $0.value.dictionary}

        boolArray.forEach{dic[$0.key] = $0.value}
        intArray.forEach{dic[$0.key] = $0.value}
        doubleArray.forEach{dic[$0.key] = $0.value}
        dateArray.forEach{dic[$0.key] = $0.value.map{$0.timeIntervalSinceReferenceDate}}
        stringArray.forEach{dic[$0.key] = $0.value}
        dataArray.forEach{dic[$0.key] = $0.value.map{$0.base64EncodedString()}}
        customArray.forEach{dic[$0.key] = $0.value.map{$0.dictionary}}

        return dic
    }

    public init(_ originalData:[String:Any]) {
        for item in originalData {
            
            let value = (item.value as? (any RawRepresentable))?.rawValue ?? item.value // if Enum with rawvalue

            if      let dado = value as? Bool            { bool        [item.key] = dado}
            else if let dado = value as? Int             { int         [item.key] = Int(dado)}
            else if let dado = value as? Double          { double      [item.key] = Double(dado)}
            else if let dado = value as? Date            { date        [item.key] = dado}
            else if let dado = value as? String          { string      [item.key] = dado}
            else if let dado = value as? Data            { data        [item.key] = dado}

            else if let dado = value as? [Bool           ] { boolArray  [item.key] = dado}
            else if let dado = value as? [Int            ] { intArray   [item.key] = dado.map{Int($0)}}
            else if let dado = value as? [Double         ] { doubleArray[item.key] = dado.map{Double($0)}}
            else if let dado = value as? [Date           ] { dateArray  [item.key] = dado}
            else if let dado = value as? [String         ] { stringArray[item.key] = dado}
            else if let dado = value as? [Data           ] { dataArray  [item.key] = dado}

            else if let dado = value as? CKAsset   { data[item.key] = dado.fileURL?.contentAsData}
            else if let dado = value as? [CKAsset] { dataArray[item.key] = dado.compactMap{$0.fileURL?.contentAsData} }

            else if let dado = value as? [String:Any]   { custom      [item.key] = CertifiedCodableData(dado)}
            else if let dado = value as? [[String:Any]] { customArray[item.key] = dado.map{CertifiedCodableData($0)} }

            else if let _ = item.value as? [Any         ] { stringArray[item.key] = []}

            else {
                debugPrint("[CodableExtensions] Unknown type in originalData:   \(item.key) = \(item.value)   -> trying to decode into string")
                string      [item.key] = "\(item.value)"
            }
        }
    }
}
