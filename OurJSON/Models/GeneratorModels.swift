import Foundation
import SwiftUI

// MARK: - Target Language

enum TargetLanguage: String, CaseIterable, Identifiable, Hashable {
    case dart = "Dart"
    case kotlin = "Kotlin"
    case swift = "Swift"

    // MARK: Identity

    var id: String {
        rawValue
    }

    // MARK: Keyboard Shortcut

    var shortcut: KeyEquivalent {
        switch self {
        case .dart:
            return "1"
        case .kotlin:
            return "2"
        case .swift:
            return "3"
        }
    }

    // MARK: Brand Accent

    var accent: String {
        switch self {
        case .dart:
            return "0175C2"
        case .kotlin:
            return "7F52FF"
        case .swift:
            return "F05138"
        }
    }
}

// MARK: - Generator Configuration

enum ConstructKind: String, CaseIterable, Identifiable, Hashable {
    case `struct` = "Struct"
    case `class` = "Class"

    var id: String {
        rawValue
    }
}

struct GeneratorOptions {
    var construct: ConstructKind = .struct
    var makeTypesPublic = false
    var plainTypesOnly = false
    var generateInitializers = false
    var explicitCodingKeys = true
    var useVarProperties = false
    var unknownEnumValuesAreNull = false
    var markSendable = false
    var optionalProperties = false
}

// MARK: - Inferred JSON Type

indirect enum JSONType: Equatable {
    case object(name: String, fields: [(String, JSONType)])
    case array(JSONType)
    case string
    case integer
    case number
    case boolean
    case null
    case mixed

    // MARK: Equality

    static func == (lhs: JSONType, rhs: JSONType) -> Bool {
        switch (lhs, rhs) {
        case let (.object(leftName, leftFields), .object(rightName, rightFields)):
            return leftName == rightName
                && fieldNames(in: leftFields) == fieldNames(in: rightFields)

        case let (.array(leftElement), .array(rightElement)):
            return leftElement == rightElement

        case (.string, .string),
             (.integer, .integer),
             (.number, .number),
             (.boolean, .boolean),
             (.null, .null),
             (.mixed, .mixed):
            return true

        default:
            return false
        }
    }

    private static func fieldNames(
        in fields: [(String, JSONType)]
    ) -> [String] {
        fields.map(\.0)
    }
}

// MARK: - Inference Result

struct InferenceResult {
    let root: JSONType
    let models: [JSONType]
}

// MARK: - Inference Errors

enum JSONInferenceError: LocalizedError {
    case invalid(String)

    var errorDescription: String? {
        switch self {
        case .invalid(let message):
            return message
        }
    }
}
