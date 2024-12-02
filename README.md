# CodableExtensions
This package add saving and loading capabilities to Codable Types

e.g.: 

If you have the followig struct:
```swift
import CodableExtensions

struct Person:Codable {
	var name:String
	var age:Int
}
```
and the object
```swift
let ricardo = Person(name: "Ricardo", age: 45)
```

it ca be saved simply running the save() function
```swift
try? ricardo.save() // saving in Person.json file

// or

try? ricardo.save(in: "ricardovenieris")  // saving in ricardovenieris.json file
```

it also be loaded simply running the load() function
```swift
try? ricardo.load() // loading from Person.json file

// or

try? ricardo.load(from: "ricardovenieris")  // loading from ricardovenieris.json file

// or

try? let ricardo = Person.load() // loading from Person.json file

// or

try? let ricardo = Person.load(from: "ricardovenieris")  // loading from ricardovenieris.json file
```


##Important

Some basic types are certified working with Codable and some aren't

Working:
    Bool  
    Int
    Doubl
    String
    - And all composed structs and classes using those

Not Working:
    Date
    Data
    UUID
    URL




```swift
extension Encodable {

    var jsonData:Data? { get }
    
    var asString:String? { get }
    
    var asDictionary:[String: Any]? { get }
    
    var asArray:[Any]? { get }
    
    @discardableResult    
    func save() throws -> URL
    
    @discardableResult
    func save(in fileName:String?) throws -> URL
    
    func save(in url:URL) throws
    
    func save(encryptWith key: SymmetricKey , to url: URL) throws
    
    func url(for fileName:String? = nil)throws -> URL
}

extension Decodable {

    /// Mutating Loads
    mutating func load(from data:Data) throws

    mutating func load(from url:URL) throws

    mutating func load() throws

    mutating func load(from file:String?) throws

    mutating func load(fromStringData stringData:String) throws

    mutating func load(from dictionary:[String:Any]) throws

    mutating func load(from array:[Any]) throws

    /// Static Loads
    static func load(from data:Data)throws ->Self

    static func load(from url:URL) throws  ->Self

    static func load(from url: URL, decryptionKey: SymmetricKey) throws ->Self 

    static func load()throws ->Self

    static func load(from fileName:String?)throws ->Self

    static func load(fromStringData stringData:String)throws ->Self

    static func load(from dictionary:[String:Any])throws ->Self

    static func load(from array:[Any])throws ->Self

    /// Static delete json file
    static func delete(fileNamed file:String?)throws ->Self

    static func urlOrJsonPath(from fileName:String? = nil)throws ->URL

    /// url helpers
    static func url()->URL

    static func url(from file:String?)->URL

}

/// Type Extensions
extension Data {

    var jsonObject:Any?
        
    var toText:String { get }
    
    var toDictionary:[AnyHashable:Any] { get }
    
    var toArray:[Codable]? { get }
    
    func convert<T>(to:T.Type) throws ->T where T:Codable
    
    func saveInTemp()throws->URL
    
    @discardableResult
    func saveInLocalDir(naming file:String?, extension ext:String? = nil)->Bool

}

extension URL {
    var contentAsData:Data? { get }
    
    /// returns URL in document directory
    static func localPath(for fileName: String?, extension ext:String? = nil)->URL?
    
    /// returns URL if file exists in document directory
    static func ifExists(file fileName: String?, extension ext:String? = nil)->URL?
    
    static func jsonPath(for fileName:String)throws ->URL
}

extension Array {
    var asData:Data? { get }
}

extension Dictionary where Key == String { 
    var asData:Data? { get }

}


extension Mirror {
    var array: [Any]? { get }

    var dictionary: [String: Any]? { get }
}

extension Mirror.Children {
    var isBasicType: Bool { get }
    
    var isDictionary: Bool { get } // else is Array or Set
    
    var dictionary: [String: Any]? { get }
    
    var array: [Any]? { get }
    
    /// Process single child, returning a value, a dictionary or an array
    func process(_ child: (label: String?, value: Any)) -> Any?
}

/// log using os_log if available or print if not.
func log(_ message: StaticString, type: OSLogType = .default, _ args: any CVarArg...)



```

## What's new on v2.0
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
