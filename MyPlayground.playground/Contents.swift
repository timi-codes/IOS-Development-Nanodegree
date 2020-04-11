import Foundation

var json = """
{
    "name": "Neha",
    "studentId": 326156,
    "academics": {
        "field": "iOS",
        "grade": "A"
    }
}
""".data(using: .utf8)!

struct Academics: Codable {
    let field: String
    let grade: String
}

// define model objects here
struct Student: Codable {
    let id : Int
    let name: String
    let academics: Academics
    
    enum CodingKeys: String, CodingKey {
        case id = "studentId"
        case name
        case academics
    }
}

let decoder = JSONDecoder()
let student: Student

do {
    // decode the JSON into the "student" constant
    student = try decoder.decode(Student.self, from: json)
    print(student)
} catch {
    print(error)
}
