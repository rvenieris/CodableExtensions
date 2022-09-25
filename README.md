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
try ? ricardo.save() // saving in Person.json file

// or

try ? ricardo.save(in: "ricardovenieris")  // saving in ricardovenieris.json file
```

it also be loaded simply running the load() function
```swift
try ? ricardo.load() // loading from Person.json file

// or

try ? ricardo.load(from: "ricardovenieris")  // loading from ricardovenieris.json file

// or

try ? let ricardo = Person.load() // loading from Person.json file

// or

try ? let ricardo = Person.load(from: "ricardovenieris")  // loading from ricardovenieris.json file
```






```swift
extension Encodable {

var asString:String? { get }

var jsonData:Data? { get }

var asDictionary:[String: Any]? { get }

var asArray:[Any]? { get }

func save() throws

func save(in file:String?) throws

func save(in url:URL) throws
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

static func load()throws ->Self

static func load(from file:String?)throws ->Self

static func load(fromString stringData:String)throws ->Self

static func load(from dictionary:[String:Any])throws ->Self

static func load(from array:[Any])throws ->Self

static func url()->URL

static func url(from file:String?)->URL

}

/// Type Extensions
extension Data {

var toText:String { get }

var toDictionary:[AnyHashable:Any] { get }

var toArray:[Codable]? { get }

func convert<T>(to:T.Type) throws ->T where T:Codable

}

extension URL {
var contentAsData:Data? { get }
}


extension Array {
var asData:Data? { get }
}

extension Dictionary where Key == String { 
var asData:Data? { get }

}

struct CertifiedCodableData:Codable {

var dictionary:[String:Any] { get }

init(_ originalData:[String:Any])

}

```
