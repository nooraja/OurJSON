import Foundation

struct JSONInference {
    // MARK: Public API

    func infer(data: Data, rootName: String) throws -> InferenceResult {
        let object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
        var models: [JSONType] = []
        let root = inferValue(object, name: rootName, models: &models)
        return InferenceResult(root: root, models: models)
    }

    // MARK: Inference

    private func inferValue(_ value: Any, name: String, models: inout [JSONType]) -> JSONType {
        if let dict = value as? [String: Any] {
            let type = JSONType.object(name: name, fields: dict.keys.sorted().map { key in
                (key, inferValue(dict[key]!, name: modelName(for: key), models: &models))
            })
            if !models.contains(where: { $0 == type }) { models.append(type) }
            return type
        }
        if let array = value as? [Any] {
            guard let first = array.first else { return .array(.mixed) }
            return .array(inferValue(first, name: singularize(name), models: &models))
        }
        if let number = value as? NSNumber {
            return inferNumber(number)
        }

        switch value {
        case is String:
            return .string
        case is NSNull:
            return .null
        default:
            return .mixed
        }
    }

    private func inferNumber(_ number: NSNumber) -> JSONType {
        if CFGetTypeID(number) == CFBooleanGetTypeID() {
            return .boolean
        }

        let value = number.doubleValue
        return value.rounded(.towardZero) == value ? .integer : .number
    }

    private func modelName(for key: String) -> String {
        key.split(separator: "_", omittingEmptySubsequences: true).map { $0.capitalized }.joined().ifEmpty("Model")
    }

    private func singularize(_ name: String) -> String {
        let value = name.isEmpty ? "Item" : name
        if value.hasSuffix("ies") { return String(value.dropLast(3)) + "y" }
        if value.hasSuffix("s") && !value.hasSuffix("ss") { return String(value.dropLast()) }
        return value
    }
}

private extension String {
    func ifEmpty(_ fallback: String) -> String { isEmpty ? fallback : self }
}
