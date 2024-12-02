//
//  TestClasses.swift
//  TesteMirrorSubclasse
//
//  Created by Ricardo Almeida Venieris on 01/12/24.
//

import Foundation

let staticTestDate = Date()

public struct TestStructAllDataType:Codable {
    public var bool  :Bool     = true
    public var int   :Int      = 1
    public var double:Double   = 1.0
//    public var date  :Date     = staticTestDate
    public var string:String   = "ABC abc"
//    public var data  :Data     = "ABCabc123".data(using: .utf8)!
//    public var otherStruct:OtherStruct = OtherStruct()
    
    public var optional_bool  :Bool?   = nil
    public var optional_int   :Int?    = nil
    public var optional_double:Double? = nil
//    public var optional_date  :Date?   = nil
    public var optional_string:String? = nil
//    public var optional_data  :Data?   = nil
//    
    public var array_bool  :[Bool]     = [true, false, true , false]
    public var array_int   :[Int]      = [0, 1, 2, 3]
    public var array_double:[Double]   = [0.1, 1.2, 2.3, 3.4]
//    public var array_date  :[Date]     = [staticTestDate, staticTestDate, staticTestDate]
    public var array_string:[String]   = ["", "ABC", "abc", "123"]
//    public var array_data  :[Data]     = [Data(), Data(repeating: 1, count: 5), "ABCabc123".data(using: .utf8)!]
//    
    public var empty_array_bool  :[Bool]     = []
    public var empty_array_int   :[Int]      = []
    public var empty_array_double:[Double]   = []
//    public var empty_array_date  :[Date]     = []
    public var empty_array_string:[String]   = []
//    public var empty_array_data  :[Data]     = []
//    
    public var set   :Set<Int> = [0, 1, 2, 3]
    public var dictionary:[String:Int] = ["a":0, "b":1, "c":2, "d":3]
//    
//    
    public struct OtherStruct:Codable {
        public var bool  :Bool     = true
        public var int   :Int      = 2
        public var double:Double   = 1.2
//        public var date  :Date     = staticTestDate.addingTimeInterval(1000)
        public var string:String   = "ABC abc"
//        public var data  :Data     = Data()
        public var otherOtherStruct:OtherOtherStruct = OtherOtherStruct()

    }

    public struct OtherOtherStruct:Codable {
        public var bool  :Bool     = false
        public var int   :Int      = 3
        public var double:Double   = 1.3
//        public var date  :Date     = staticTestDate.addingTimeInterval(2000)
        public var string:String   = "ABC abc"
//        public var data  :Data     = Data()
    }

}

public class TestClassAllDataType_A:Codable {
    public var bool  :Bool     = true
    public var int   :Int      = 1
    public var double:Double   = 1.0
//    public var date  :Date     = staticTestDate
    public var string:String   = "ABC abc"
//    public var data  :Data     = Data()
    public var otherClass:OtherClass = OtherClass()
    
    public var optional_bool  :Bool?   = nil
    public var optional_int   :Int?    = nil
    public var optional_double:Double? = nil
//    public var optional_date  :Date?   = nil
    public var optional_string:String? = nil
//    public var optional_data  :Data?   = nil
    
    public var array_bool  :[Bool]     = [true, false, true , false]
    public var array_int   :[Int]      = [0, 1, 2, 3]
    public var array_double:[Double]   = [0.1, 1.2, 2.3, 3.4]
//    public var array_date  :[Date]     = [staticTestDate, staticTestDate, staticTestDate]
    public var array_string:[String]   = ["", "ABC", "abc", "123"]
//    public var array_data  :[Data]     = [Data(), Data(repeating: 1, count: 5), "ABCabc123".data(using: .utf8)!]
    
    public var empty_array_bool  :[Bool]     = []
    public var empty_array_int   :[Int]      = []
    public var empty_array_double:[Double]   = []
//    public var empty_array_date  :[Date]     = []
    public var empty_array_string:[String]   = []
//    public var empty_array_data  :[Data]     = []
    
    public var set   :Set<Int> = [0, 1, 2, 3]
    public var dictionary:[String:Int] = ["a":0, "b":1, "c":2, "d":3]
    
    
    public class OtherClass:Codable {
        public var bool  :Bool     = true
        public var int   :Int      = 2
        public var double:Double   = 1.2
//        public var date  :Date     = staticTestDate.addingTimeInterval(1000)
        public var string:String   = "ABC abc"
//        public var data  :Data     = Data()
        public var otherOtherClass:OtherOtherClass = OtherOtherClass()

    }

    public class OtherOtherClass:Codable {
        public var bool  :Bool     = false
        public var int   :Int      = 3
        public var double:Double   = 1.3
//        public var date  :Date     = staticTestDate.addingTimeInterval(2000)
        public var string:String   = "ABC abc"
//        public var data  :Data     = Data()
    }

}

public class TestClassAllDataType_B:TestClassAllDataType_A {
    public var b_extra_data_bool   :Bool   = false
    public var b_extra_data_int    :Int    = 2
    public var b_extra_data_double :Double = 2.2
//    public var b_extra_data_date   :Date   = staticTestDate.addingTimeInterval(200)
    public var b_extra_data_string :String = "DEF def"
//    public var b_extra_data_data   :Data   = "Q!@#$%^&*()".data(using: .utf8)!
    public var a_double_data = TestClassAllDataType_A()

}

public class TestClassAllDataType_C:TestClassAllDataType_B {
    public var c_extra_data_bool   :Bool   = true
    public var c_extra_data_int    :Int    = 3
    public var c_extra_data_double :Double = 2.4
//    public var c_extra_data_date   :Date   = Date(timeIntervalSince1970: 0)
    public var c_extra_data_string :String = "GHI ghi"
//    public var c_extra_data_data   :Data   = "Q1!2@3#4$5%6^7&8*()".data(using: .utf8)!
    
    public var b_double_data = TestClassAllDataType_B()

}

extension TestStructAllDataType:Equatable {
    public static func == (lhs: TestStructAllDataType, rhs: TestStructAllDataType) -> Bool {
        lhs.bool                == rhs.bool               &&
        lhs.int                 == rhs.int                &&
        lhs.double              == rhs.double             &&
//        lhs.date                == rhs.date               &&
        lhs.string              == rhs.string             &&
//        lhs.data                == rhs.data               &&
//        lhs.otherStruct         == rhs.otherStruct        &&
        
        lhs.optional_bool       == rhs.optional_bool      &&
        lhs.optional_int        == rhs.optional_int       &&
        lhs.optional_double     == rhs.optional_double    &&
//        lhs.optional_date       == rhs.optional_date      &&
        lhs.optional_string     == rhs.optional_string    &&
//        lhs.optional_data       == rhs.optional_data      &&
//        
        lhs.array_bool          == rhs.array_bool         &&
        lhs.array_int           == rhs.array_int          &&
        lhs.array_double        == rhs.array_double       &&
//        lhs.array_date          == rhs.array_date         &&
        lhs.array_string        == rhs.array_string       &&
//        lhs.array_data          == rhs.array_data         &&
//        
        lhs.empty_array_bool    == rhs.empty_array_bool   &&
        lhs.empty_array_int     == rhs.empty_array_int    &&
        lhs.empty_array_double  == rhs.empty_array_double &&
//        lhs.empty_array_date    == rhs.empty_array_date   &&
        lhs.empty_array_string  == rhs.empty_array_string &&
//        lhs.empty_array_data    == rhs.empty_array_data   &&
//        
        lhs.set                 == rhs.set                &&
        lhs.dictionary          == rhs.dictionary         &&
        true
    }
}

extension TestStructAllDataType.OtherStruct:Equatable {
    public static func == (lhs: TestStructAllDataType.OtherStruct, rhs: TestStructAllDataType.OtherStruct) -> Bool {
        lhs.bool                == rhs.bool               &&
        lhs.int                 == rhs.int                &&
        lhs.double              == rhs.double             &&
//        lhs.date                == rhs.date               &&
        lhs.string              == rhs.string             &&
//        lhs.data                == rhs.data               &&
        lhs.otherOtherStruct    == rhs.otherOtherStruct
    }
}

extension TestStructAllDataType.OtherOtherStruct:Equatable {
    public static func == (lhs: TestStructAllDataType.OtherOtherStruct, rhs: TestStructAllDataType.OtherOtherStruct) -> Bool {
        lhs.bool                == rhs.bool               &&
        lhs.int                 == rhs.int                &&
        lhs.double              == rhs.double             &&
//        lhs.date                == rhs.date               &&
        lhs.string              == rhs.string             &&
//        lhs.data                == rhs.data
        true
    }
    
    
}

extension TestClassAllDataType_A:Equatable {
    public static func equals(_ lhs: TestClassAllDataType_A,
                              _ rhs: TestClassAllDataType_A) -> Bool {
        
        lhs.bool        == rhs.bool         &&
        lhs.int         == rhs.int          &&
        lhs.double      == rhs.double       &&
//        lhs.date        == rhs.date         &&
        lhs.string      == rhs.string       &&
//        lhs.data        == rhs.data         &&
        lhs.otherClass  == rhs.otherClass   &&
        
        lhs.optional_bool   == rhs.optional_bool   &&
        lhs.optional_int    == rhs.optional_int    &&
        lhs.optional_double == rhs.optional_double &&
//        lhs.optional_date   == rhs.optional_date   &&
        lhs.optional_string == rhs.optional_string &&
//        lhs.optional_data   == rhs.optional_data   &&
        
        lhs.array_bool      == rhs.array_bool   &&
        lhs.array_int       == rhs.array_int    &&
        lhs.array_double    == rhs.array_double &&
//        lhs.array_date      == rhs.array_date   &&
        lhs.array_string    == rhs.array_string &&
//        lhs.array_data      == rhs.array_data   &&
        
        lhs.empty_array_bool   == rhs.empty_array_bool   &&
        lhs.empty_array_int    == rhs.empty_array_int    &&
        lhs.empty_array_double == rhs.empty_array_double &&
//        lhs.empty_array_date   == rhs.empty_array_date   &&
        lhs.empty_array_string == rhs.empty_array_string &&
//        lhs.empty_array_data   == rhs.empty_array_data   &&
        
        lhs.set        == rhs.set         &&
        lhs.dictionary == rhs.dictionary
        
        
    }
    
    public static func == (lhs: TestClassAllDataType_A, rhs: TestClassAllDataType_A) -> Bool {
        equals(lhs, rhs)
    }
}

extension TestClassAllDataType_A.OtherClass:Equatable {
    public static func == (lhs: TestClassAllDataType_A.OtherClass, rhs: TestClassAllDataType_A.OtherClass) -> Bool {
        return  lhs.bool == rhs.bool        &&
        lhs.int         == rhs.int          &&
        lhs.double      == rhs.double       &&
//        lhs.date        == rhs.date         &&
        lhs.string      == rhs.string       &&
//        lhs.data        == rhs.data         &&
        lhs.otherOtherClass == rhs.otherOtherClass
    }
}

extension TestClassAllDataType_A.OtherOtherClass:Equatable {
    public static func == (lhs: TestClassAllDataType_A.OtherOtherClass, rhs: TestClassAllDataType_A.OtherOtherClass) -> Bool {   lhs.bool        == rhs.bool         &&
        lhs.int         == rhs.int          &&
        lhs.double      == rhs.double       &&
//        lhs.date        == rhs.date         &&
        lhs.string      == rhs.string       &&
//        lhs.data        == rhs.data
        true
    }
    
    
}

extension TestClassAllDataType_B {
    public static func equals(_ lhs: TestClassAllDataType_B, _ rhs: TestClassAllDataType_B) -> Bool {
        super.equals(lhs, rhs) &&
        lhs.b_extra_data_bool   == rhs.b_extra_data_bool    &&
        lhs.b_extra_data_int    == rhs.b_extra_data_int     &&
        lhs.b_extra_data_double == rhs.b_extra_data_double  &&
//        lhs.b_extra_data_date   == rhs.b_extra_data_date    &&
        lhs.b_extra_data_string == rhs.b_extra_data_string  &&
//        lhs.b_extra_data_data   == rhs.b_extra_data_data    &&
        lhs.a_double_data       == rhs.a_double_data
    }
    public static func == (lhs: TestClassAllDataType_B, rhs: TestClassAllDataType_B) -> Bool {
        equals(lhs, rhs)
    }
}

extension TestClassAllDataType_C {
    public static func equals(_ lhs: TestClassAllDataType_C, _ rhs: TestClassAllDataType_C) -> Bool {
        super.equals(lhs, rhs) &&
        lhs.c_extra_data_bool   == rhs.c_extra_data_bool    &&
        lhs.c_extra_data_int    == rhs.c_extra_data_int     &&
        lhs.c_extra_data_double == rhs.c_extra_data_double  &&
//        lhs.c_extra_data_date   == rhs.c_extra_data_date    &&
        lhs.c_extra_data_string == rhs.c_extra_data_string  &&
//        lhs.c_extra_data_data   == rhs.c_extra_data_data    &&
        lhs.b_double_data       == rhs.b_double_data
    }
    
    public static func == (lhs: TestClassAllDataType_C, rhs: TestClassAllDataType_C) -> Bool {
        equals(lhs, rhs)
    }
}


extension TestStructAllDataType:Sendable {}
extension TestClassAllDataType_A:@unchecked Sendable {}
extension TestClassAllDataType_B:@unchecked Sendable {}
extension TestClassAllDataType_C:@unchecked Sendable {}
