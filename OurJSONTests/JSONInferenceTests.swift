import XCTest
@testable import OurJSON

// MARK: - JSON Inference Tests

final class JSONInferenceTests: XCTestCase {
    // MARK: Model Inference

    func testInfersNestedModels() throws {
        let result = try JSONInference().infer(data: Data(#"{"users":[{"id":1,"name":"Ada"}]}"#.utf8), rootName: "Root")
        XCTAssertEqual(result.models.count, 2)
        XCTAssertTrue(CodeGenerator().generate(result, language: .swift, options: GeneratorOptions()).contains("struct User"))
    }

    func testInvalidJSONThrows() {
        XCTAssertThrowsError(try JSONInference().infer(data: Data("oops".utf8), rootName: "Root"))
    }

    func testDistinguishesIntegerOneFromBooleanTrue() throws {
        let json = #"{"sort_order":1,"is_active":true}"#
        let result = try JSONInference().infer(
            data: Data(json.utf8),
            rootName: "Metric"
        )

        guard case let .object(_, fields) = result.root else {
            return XCTFail("Expected an object root")
        }

        XCTAssertEqual(type(for: "sort_order", in: fields), .integer)
        XCTAssertEqual(type(for: "is_active", in: fields), .boolean)
    }

    // MARK: Swift Code Generation

    func testSwiftConvertsSnakeCasePropertiesAndGeneratesCodingKeys() throws {
        let json = #"{"metric_key":"technical","sort_order":1,"id":2}"#
        let result = try JSONInference().infer(
            data: Data(json.utf8),
            rootName: "Metric"
        )

        let output = CodeGenerator().generate(
            result,
            language: .swift,
            options: GeneratorOptions()
        )

        XCTAssertTrue(output.contains("let metricKey: String"))
        XCTAssertTrue(output.contains("let sortOrder: Int"))
        XCTAssertFalse(output.contains("let metric_key"))
        XCTAssertFalse(output.contains("let sort_order"))
        XCTAssertTrue(output.contains("enum CodingKeys: String, CodingKey"))
        XCTAssertTrue(output.contains(#"case metricKey = "metric_key""#))
        XCTAssertTrue(output.contains(#"case sortOrder = "sort_order""#))
        XCTAssertTrue(output.contains(#"case id = "id""#))
    }

    func testSwiftKeepsRequiredCodingKeysWhenExplicitValuesAreDisabled() throws {
        let json = #"{"metric_key":"technical","id":2}"#
        let result = try JSONInference().infer(
            data: Data(json.utf8),
            rootName: "Metric"
        )
        var options = GeneratorOptions()
        options.explicitCodingKeys = false

        let output = CodeGenerator().generate(
            result,
            language: .swift,
            options: options
        )

        XCTAssertTrue(output.contains(#"case metricKey = "metric_key""#))
        XCTAssertTrue(output.contains("case id"))
        XCTAssertFalse(output.contains(#"case id = "id""#))
    }

    // MARK: Bundled Default Input

    @MainActor
    func testWorkspaceViewModelLoadsTestIniAsDefaultInput() {
        let viewModel = WorkspaceViewModel()

        XCTAssertEqual(viewModel.rootName, "TestIni")
        XCTAssertTrue(viewModel.input.contains(#""metric_key": "technical""#))
        XCTAssertTrue(viewModel.input.contains(#""sort_order": 1"#))
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertGreaterThan(viewModel.modelCount, 0)
    }

    // MARK: Project Fixture

    func testLargeProjectFixture() throws {
        let fixtureURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("test_json/test_ini.json")
        let data = try Data(contentsOf: fixtureURL)
        let result = try JSONInference().infer(data: data, rootName: "TestIni")

        XCTAssertFalse(result.models.isEmpty)

        let output = CodeGenerator().generate(
            result,
            language: .swift,
            options: GeneratorOptions()
        )

        XCTAssertTrue(output.contains("let metricKey: String"))
        XCTAssertTrue(output.contains("let sortOrder: Int"))
        XCTAssertTrue(output.contains(#"case metricKey = "metric_key""#))
        XCTAssertTrue(output.contains(#"case sortOrder = "sort_order""#))
    }

    // MARK: Test Helpers

    private func type(
        for key: String,
        in fields: [(String, JSONType)]
    ) -> JSONType? {
        fields.first { fieldName, _ in fieldName == key }?.1
    }
}
