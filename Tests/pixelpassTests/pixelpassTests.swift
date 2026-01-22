import XCTest
import Foundation
@testable import pixelpass


class PixelPassTests: XCTestCase {
    var pixelPass: PixelPass!
    
    override func setUp() {
        super.setUp()
        pixelPass = PixelPass()
    }
    
    override func tearDown() {
        pixelPass = nil
        super.tearDown()
    }
    
    func testEncodeStandardInput() {
        let inputString = "Hello, World!"
        let encoded = pixelPass.generateQRData(inputString)
        let expectedEncodedString="V7F0YUV0QBNP:AAT8QZPP+AAV00./JG2"
        XCTAssertNotNil(encoded, "The encoded output should not be nil for standard input.")
        XCTAssertTrue(encoded!.count > 0, "The encoded string should have length greater than zero.")
        XCTAssert((encoded != nil),expectedEncodedString,file: "Encoded string should be same as expected encoded string")
    }
    
    func testEncodeEmptyInput() {
        let emptyInput = ""
        let encoded = pixelPass.generateQRData(emptyInput)
        XCTAssertNil(encoded, "Encoding should return nil for an empty string.")
    }
    
    func testDecodeValidInput() {
        let inputString = "V7F0YUV0QBNP:AAT8QZPP+AAV00./JG2"
        let decodedData = pixelPass.decode(data: inputString)
        
        let expectedDecodedString="Hello, World!"
        XCTAssertNotNil(decodedData, "Decoding should succeed for valid encoded input.")
        let decodedString = String(data: decodedData!, encoding: .utf8)
        XCTAssertEqual(decodedString, expectedDecodedString, "The decoded string should match the expected decoded string.")
        
    }
    
    func testDecodeInvalidInput() {
        let invalidBase45String = "#$%^&*()_+"
        let decodedData = pixelPass.decode(data: invalidBase45String)
        XCTAssertNil(decodedData, "Decode should return nil for invalid Base45 input.")
    }
    
    func testEncodeAndDecodeCycle() {
        // Test case for non-empty string
        let inputString = "Hello, this is a test string for PixelPass encoding and decoding."
        if let encoded = pixelPass.generateQRData(inputString),
           let decodedData = pixelPass.decode(data: encoded),
           let decodedString = String(data: decodedData, encoding: .utf8) {
            XCTAssertEqual(decodedString, inputString, "The decoded string should match the original input string.")
        } else {
            XCTFail("Encoding or decoding failed.")
        }
        
        // Test case for empty string
        let emptyInput = ""
        XCTAssertNil(pixelPass.generateQRData(emptyInput), "Encoding should return nil for an empty string.")
    }
    
    func testGenerateQRCode() {
        let inputString = "Test QR Code generation"
        let qrCodeImage = pixelPass.generateQRCode( data: inputString,ecc: ECC.M)
        
        XCTAssertNotNil(qrCodeImage, "QR Code generation should succeed and return a non-nil UIImage.")
    }
    
    func testDecodeErrorHandling() {
        let incorrectBase45String = "This is not a Base45 string"
        XCTAssertNil(pixelPass.decode(data: incorrectBase45String), "Decode should return nil for incorrect Base45 encoded strings.")
    }
    
    func testDecodeValidInputCBOR() {
        let inputString = "V7F3QBXJA5NJRCOC004 QN4"
        let decodedData = pixelPass.decode(data: inputString)
        let expectedDecodedString="{\"temp\":15}"
        XCTAssertNotNil(decodedData, "Decoding should succeed for valid encoded input.")
        let decodedString = String(data: decodedData!, encoding: .utf8)
        XCTAssertEqual(decodedString, expectedDecodedString, "The decoded string should match the expected decoded string.")
    }
    
    func testEncodeValidInputCBOR() {
        let inputString = "{\"temp\":15}"
        let encoded = pixelPass.generateQRData(inputString)
        let expectedEncodedString = "V7F3QBXJA5NJRCOC004 QN4"
        XCTAssertNotNil(encoded!, "The encoded output should not be nil for standard input.")
        XCTAssertTrue(encoded!.count > 0, "The encoded string should have length greater than zero.")
        XCTAssertEqual(encoded,expectedEncodedString, "Encoded string should be same as expected encoded string")
    }
    
    func testEncodeAndDecodeInputCBOR() {
        let inputString = "{\"temp\":123}],\"bool\":true,\"arryF\":[1,2.5,3,-4,\"hello\",{\"temp\":123}],\"arryE\":[]}"
        let encoded = pixelPass.generateQRData(inputString)!
        let decoded = pixelPass.decode(data: encoded)
        let decodedString = String(data: decoded!, encoding: .utf8)
        XCTAssertNotNil(decodedString, "Decoding should succeed for valid encoded input.")
        XCTAssertEqual(inputString,decodedString, "Decoded string should be same as expected input string")
    }
    
    func testJsonMappedCBOREncode() {
        let jsonData = "{\"id\": \"207\"}"
        let mapper = ["id": "1"]
        let expectedCborEncodedString = "a1613163323037"
        let cborEncodedData = pixelPass.getMappedData(stringData: jsonData,mapper: mapper,cborEnable: true)
        
        XCTAssertNotNil(cborEncodedData, "JSON mapping should succeed for valid input.")
        XCTAssertEqual(cborEncodedData,expectedCborEncodedString, "Encoded string should be same as expected string")
    }
    
    func testJsonMappedEncode() {
        let jsonData = "{\"id\": \"207\"}"
        let mapper = ["id": "1"]
        let expectedMappedData = "{\"1\":\"207\"}"
        let mappedData = pixelPass.getMappedData(stringData: jsonData,mapper: mapper)
        
        XCTAssertNotNil(mappedData, "JSON mapping should succeed for valid input.")
        XCTAssertEqual(mappedData,expectedMappedData, "Encoded string should be same as expected string")
    }
    
    func testJsonMappedCBORDecode() {
        let expected = ["id": "207", "name": "Jhon", "l_name": "Honay"]
        let mapper = ["1": "id", "2": "name", "3": "l_name"]
        let data = "a302644a686f6e01633230370365486f6e6179"
        let jsonData = pixelPass.decodeMappedData(stringData: data, mapper: mapper)
        XCTAssertNotNil(jsonData, "JSON mapping should succeed for valid input.")
        XCTAssertEqual(jsonData,expected, "Decoded JSON should be same as expected JSON")
    }
    
    func testJsonMappedDecode() {
        let expected = ["id": "207", "name": "Jhon", "l_name": "Honay"]
        let mapper = ["1": "id", "2": "name", "3": "l_name"]
        let data = "{\"1\": \"207\", \"2\": \"Jhon\", \"3\": \"Honay\"}"
        let jsonData = pixelPass.decodeMappedData(stringData: data, mapper: mapper)
        XCTAssertNotNil(jsonData, "JSON mapping should succeed for valid input.")
        XCTAssertEqual(jsonData,expected, "Decoded JSON should be same as expected JSON")
    }
    
    func testByteArrayValidInput() {
        
        clearTemporaryDirectory()
        
        let fileManager = FileManager.default
        let tempdir = FileManager.default.temporaryDirectory
        let inputString = "Hello, World!"
        let fileURL = tempdir.appendingPathComponent("certificate.json")
        let zipURL = tempdir.appendingPathComponent("temp.zip")
        
        var decodedString = ""
        do {
            try inputString.write(to: fileURL, atomically: true, encoding: .utf8)
            try fileManager.zipItem(at: fileURL, to: zipURL)
            let fileData = try Data(contentsOf: zipURL)
            let byetArray = [UInt8](fileData)
            decodedString = try pixelPass.decodeBinary(data: byetArray)!
        } catch {
            print(error)
        }
        XCTAssertNotNil(decodedString, "The decoded string should not be empty.")
        XCTAssertEqual(inputString, decodedString, "The decoded string should match the expected decoded string.")
    }
    
    func testByteArrayInvalidInput() {
        
        clearTemporaryDirectory()
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempTxtFileURL = tempDirectory.appendingPathComponent("temp.txt")
        let content = "This is a test text file."
        
        do {
            try content.write(to: tempTxtFileURL, atomically: true, encoding: .utf8)
            let fileData = try Data(contentsOf: tempTxtFileURL)
            XCTAssertThrowsError(try PixelPass().decodeBinary(data: [UInt8](fileData))) { error in
                switch error {
                case decodeByteArrayError.UnknownBinaryFileTypeException:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Unexpected error type: \(error)")
                }
            }
        } catch {
            XCTFail("Error reading text file: \(error)")
        }
    }
    
    func testBase64EncodedCborDataToJsonConversionSuccess() {
        do {
            let data = "qmx1bnNpZ25lZF9pbnQYKmxuZWdhdGl2ZV9pbnQma2J5dGVfc3RyaW5nRN6tvu9rdGV4dF9zdHJpbmdlaGVsbG9lYXJyYXmDAQIDY21hcKJhYQFhYgJjdGFn2QPobHRhZ2dlZF92YWx1ZWVmbG9hdPtACR64UeuFH2ZzaW1wbGX2c2VtYmVkZGVkX2Nib3JfdGFnMjTYGEloZW1iZWRkZWQ="
            let jsonData = try pixelPass.toJson(base64UrlEncodedCborEncodedString: data)
            let expectedData: [String: Any] = ["text_string": "hello", "unsigned_int": 42, "array": [1, 2, 3], "float": 3.14, "embedded_cbor_tag24": "embedded", "map": ["a": 1, "b": 2], "tag": "tagged_value", "negative_int": -7, "simple": NSNull(), "byte_string": "\u{07AD}��"]
            
            XCTAssertEqualDictionaries(expectedData, jsonData as! [String : Any])
        } catch let error {
            XCTFail("Expected success, but got error: \(error)")
        }
    }
    
    func testBase64EncodedCborDataToJsonConversionThrowsErrorWhenDecodingFails() {
        let data = "omd2ZXJzaW9uYzEuMGRkYXRhgaJiazFidjFiazKiZGsyLjGhZmsyLjEuMYHYGEmhZmsyLjEuMQFkazIuMoRDoQEmoRghWQFjMIIBXzCCAQSgAwIBAgIGAYwpA4_aMAoGCCqGSM49BAMCMDYxNDAyBgNVBAMMKzNfd1F3Y3Qxd28xQzBST3FfWXRqSTRHdTBqVXRiVTJCQXZteEltQzVqS3MwHhcNMjMxMjAyMDUzMjI4WhcNMjQwOTI3MDUzMjI4WjA2MTQwMgYDVQQDDCszX3dRd2N0MXdvMUMwUk9xX1l0akk0R3UwalV0YlUyQkF2bXhJbUM1aktzMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQw7367PjIwU17ckX_G4ZqLW2EjPG0efV0cYzhvq2Ujkymrc33RVkgEE6q9iAAeLhl85IraAzT39SjOBV6w"
        
        XCTAssertThrowsError(try pixelPass.toJson(base64UrlEncodedCborEncodedString: data)) { error in
            guard case let decodeByteArrayError.customError(message) = error else {
                return XCTFail("Expected decodeError.customError, but got a different error")
            }
            
            XCTAssertEqual(message, "error occurred while parsing  data - The operation couldn’t be completed. (pixelpass.decodeError error 0.)", "The error message does not match")
        }
    }
    
    func testGenerateQRImageDataProducesPNG() {
        let text = "Hello QR"
        guard let data = pixelPass.generateQRImageData(qrText: text, ecc: ECC.L) else {
            return XCTFail("Expected non-nil PNG data for valid input")
        }
        // PNG signature: 89 50 4E 47 0D 0A 1A 0A
        let pngMagic: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        let prefix = Array(data.prefix(8))
        XCTAssertEqual(prefix, pngMagic, "Generated data should start with PNG signature")
        XCTAssertTrue(data.count > 0, "Generated PNG should be non-empty")
    }
    
    func testGenerateQRImageDataAllECCLevels() {
        let text = "ECC levels"
        for level in [ECC.L, .M, .Q, .H] {
            let data = pixelPass.generateQRImageData(qrText: text, ecc: level)
            XCTAssertNotNil(data, "Expected PNG data for ECC level \(level)")
        }
    }
    
    func testClaim169Default_ObjectRoundTrip() throws {
        let originalJson = """
        {
          "ID":"102030",
          "Full Name":"John",
          "Gender":"Male",
          "Left Middle Finger":{
            "Data":"9988",
            "Data format":"Template",
            "Data sub format":"Fingerprint Template NIST"
          }
        }
        """

        let jsonObject = try JSONSerialization.jsonObject(
            with: Data(originalJson.utf8)
        ) as! [String: Any]

        let encoded = pixelPass.getMappedData(
            jsonData: jsonObject,
            cborEnable: true
        ) as! String

        XCTAssertFalse(encoded.isEmpty)

        let decoded = pixelPass.decodeMappedData(data: encoded)

        let decodedJson = try JSONSerialization.jsonObject(
            with: Data(decoded.utf8)
        ) as! [String: Any]

        
        XCTAssertEqual(decodedJson["ID"] as? String, "102030")
        XCTAssertEqual(decodedJson["Full Name"] as? String, "John")
        XCTAssertEqual(decodedJson["Gender"] as? String, "Male")

        
        let biometric = decodedJson["Left Middle Finger"] as! [String: Any]

        XCTAssertEqual(biometric["Data"] as? String, "9988")
        XCTAssertEqual(biometric["Data format"] as? String, "Template")
        XCTAssertEqual(
            biometric["Data sub format"] as? String,
            "Fingerprint Template NIST"
        )
    }

    
    func testClaim169_UsesIntegerKeys() {
        let json: [String: Any] = [
            "Full Name": "John Doe",
            "Gender": "Male"
        ]

        let mapped = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: false
        ) as! [AnyHashable: Any]

        XCTAssertTrue(mapped.keys.allSatisfy { $0 is Int })
    }
    
    func testClaim169_MixedKnownAndUnknown_RoundTrip() throws {
        let json: [String: Any] = [
            "Full Name": "John Doe",
            "Issuer Note": "Verified at source"
        ]

        let encoded = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: true
        ) as! String

        let decoded = pixelPass.decodeMappedData(data: encoded)

        let decodedJson = try JSONSerialization.jsonObject(
            with: Data(decoded.utf8)
        ) as! [String: Any]

        XCTAssertEqual(decodedJson["Full Name"] as? String, "John Doe")
        XCTAssertEqual(decodedJson["Issuer Note"] as? String, "Verified at source")
    }
    
    func testClaim169_ArrayOfObjects_BatchEncodeAndDecode() throws {
        let json1: [String: Any] = [
            "Full Name": "John Doe",
            "Gender": "Male"
        ]

        let json2: [String: Any] = [
            "Full Name": "John",
            "Gender": "Female"
        ]

        let jsonArray: [[String: Any]] = [
            json1,
            json2
        ]

        let encodedBatch = pixelPass.getMappedData(
            jsonArray: jsonArray,
            cborEnable: true
        ) as! [String]

        XCTAssertEqual(encodedBatch.count, 2)
        XCTAssertFalse(encodedBatch[0].isEmpty)
        XCTAssertFalse(encodedBatch[1].isEmpty)

        let decodedBatch = pixelPass.decodeMappedData(
            dataArray: encodedBatch
        )

        XCTAssertEqual(decodedBatch.count, 2)

        
        let decoded1 = try JSONSerialization.jsonObject(
            with: Data(decodedBatch[0].utf8)
        ) as! [String: Any]

        let decoded2 = try JSONSerialization.jsonObject(
            with: Data(decodedBatch[1].utf8)
        ) as! [String: Any]

        XCTAssertEqual(decoded1["Full Name"] as? String, "John Doe")
        XCTAssertEqual(decoded1["Gender"] as? String, "Male")

        XCTAssertEqual(decoded2["Full Name"] as? String, "John")
        XCTAssertEqual(decoded2["Gender"] as? String, "Female")
    }

    func testClaim169_CBOR_IsDeterministic() {
        let json: [String: Any] = [
            "Full Name": "John Doe",
            "Gender": "Male"
        ]

        let encoded1 = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: true
        ) as! String

        let encoded2 = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: true
        ) as! String

        XCTAssertEqual(encoded1, encoded2)
    }

    func testClaim169_EmptyObject_DoesNotEncodeToNull() {
        let encoded = pixelPass.getMappedData(
            jsonData: [:],
            cborEnable: true
        ) as! String

        XCTAssertNotEqual(encoded.lowercased(), "f6")
    }
 
    func testClaim169_SingleVsBatchParity() throws {
        let json: [String: Any] = [
            "Full Name": "John Doe",
            "Gender": "Male"
        ]

        let singleEncoded = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: true
        ) as! String

        let batchEncoded = pixelPass.getMappedData(
            jsonArray: [json],
            cborEnable: true
        ) as! [String]

        XCTAssertEqual(batchEncoded.count, 1)
        XCTAssertEqual(batchEncoded[0], singleEncoded)
    }
    
    func testClaim169_BatchDecode_OrderIsPreserved() throws {
        let jsonArray: [[String: Any]] = [
            ["Full Name": "First"],
            ["Full Name": "Second"],
            ["Full Name": "Third"]
        ]

        let encodedBatch = pixelPass.getMappedData(
            jsonArray: jsonArray,
            cborEnable: true
        ) as! [String]

        let decodedBatch = pixelPass.decodeMappedData(
            dataArray: encodedBatch
        )

        let decoded0 = try JSONSerialization.jsonObject(
            with: Data(decodedBatch[0].utf8)
        ) as! [String: Any]

        let decoded1 = try JSONSerialization.jsonObject(
            with: Data(decodedBatch[1].utf8)
        ) as! [String: Any]

        XCTAssertEqual(decoded0["Full Name"] as? String, "First")
        XCTAssertEqual(decoded1["Full Name"] as? String, "Second")
    }

    func testClaim169_UnknownEnumValue_Preserved() throws {
        let json: [String: Any] = [
            "Gender": "NonBinary"
        ]

        let encoded = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: true
        ) as! String

        let decoded = pixelPass.decodeMappedData(data: encoded)

        let decodedJson = try JSONSerialization.jsonObject(
            with: Data(decoded.utf8)
        ) as! [String: Any]

        XCTAssertEqual(decodedJson["Gender"] as? String, "NonBinary")
    }
    
    func testClaim169_MultipleBiometrics_RoundTrip() throws {
        let json: [String: Any] = [
            "ID": "5001",
            "Right Thumb": [
                "Data": "AAA",
                "Data format": "Image",
                "Data sub format": "PNG"
            ],
            "Left Iris": [
                "Data": "BBB",
                "Data format": "Image",
                "Data sub format": "JPEG"
            ]
        ]

        let encoded = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: true
        ) as! String

        let decoded = pixelPass.decodeMappedData(data: encoded)

        let decodedJson = try JSONSerialization.jsonObject(
            with: Data(decoded.utf8)
        ) as! [String: Any]

        XCTAssertEqualDictionaries(json, decodedJson)
    }
    
    func testClaim169_BiometricWithUnknownNestedFields() throws {
        let json: [String: Any] = [
            "Full Name": "Alice",
            "Face": [
                "Data": "FACE123",
                "Data format": "Image",
                "Data sub format": "JPEG",
                "Capture Device": "Canon EOS"
            ]
        ]

        let encoded = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: true
        ) as! String

        let decoded = pixelPass.decodeMappedData(data: encoded)

        let decodedJson = try JSONSerialization.jsonObject(
            with: Data(decoded.utf8)
        ) as! [String: Any]

        XCTAssertEqualDictionaries(json, decodedJson)
    }
    
    
    func testClaim169_DeepMixedDocument_RoundTrip() throws {
        let json: [String: Any] = [
            "ID": "9009",
            "Version": "1.0",
            "Language": "en",
            "Gender": "Female",
            "Left Thumb": [
                "Data": "LT123",
                "Data format": "Template",
                "Data sub format": "Fingerprint Template ISO 19794-2"
            ],
            "Right Iris": [
                "Data": "RI456",
                "Data format": "Image",
                "Data sub format": "JPEG2000"
            ],
            "Issuer Note": "Verified manually"
        ]

        let encoded = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: true
        ) as! String

        let decoded = pixelPass.decodeMappedData(data: encoded)

        let decodedJson = try JSONSerialization.jsonObject(
            with: Data(decoded.utf8)
        ) as! [String: Any]

        XCTAssertEqualDictionaries(json, decodedJson)
    }

    func testClaim169_MappedOutput_UsesIntegerKeys() {
        let json = [
            "Full Name": "John",
            "Gender": "Male"
        ]

        let mapped = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: false
        ) as! [AnyHashable: Any]

        XCTAssertTrue(mapped.keys.allSatisfy { $0 is Int })
    }

    func testClaim169_MappedOutput_BiometricEnumsAreInts() {
        let json: [String: Any] = [
            "Left Thumb": [
                "Data": "123",
                "Data format": "Template",
                "Data sub format": "Fingerprint Template NIST"
            ]
        ]

        let mapped = pixelPass.getMappedData(
            jsonData: json,
            cborEnable: false
        ) as! [AnyHashable: Any]

        
        let bio = mapped[55] as! [AnyHashable: Any]

        XCTAssertTrue(bio[1] is Int)

        XCTAssertTrue(bio[2] is Int)

        XCTAssertEqual(bio[1] as? Int, 1)
        XCTAssertEqual(bio[2] as? Int, 2)
    }



}

func XCTAssertEqualDictionaries(_ expected: [String: Any], _ actual: [String: Any], file: StaticString = #file, line: UInt = #line) {
    let expectedData = try? JSONSerialization.data(withJSONObject: expected, options: [.sortedKeys])
    let actualData = try? JSONSerialization.data(withJSONObject: actual, options: [.sortedKeys])
    
    XCTAssertEqual(expectedData, actualData, "The dictionaries do not match", file: file, line: line)
}
