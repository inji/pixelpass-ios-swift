import Foundation
 public struct Constants{
     static let headerSize = 2
     static let initialBufferSizeMultiplier = 4
     static let extraBufferSize = 8 * 1024
    
     static let compressionHeader: [UInt8] = [0x78, 0x01]
     static let checksumSize = MemoryLayout<UInt32>.size
     static let compressionOverhead = 12
     static let compressionRatioDenominator = 1000
    
     static let adlerBase: UInt32 = 65521
     
     static let zipHeader = "PK"
     static let defaultZipFileName = "certificate.json"
     
     public static let claim169KeyMapper: [String: Int] = [
         "ID": 1,
         "Version": 2,
         "Language": 3,
         "Full Name": 4,
         "First Name": 5,
         "Middle Name": 6,
         "Last Name": 7,
         "Date of Birth": 8,
         "Gender": 9,
         "Address": 10,
         "Email ID": 11,
         "Phone Number": 12,
         "Nationality": 13,
         "Marital Status": 14,
         "Guardian": 15,
         "Binary Image": 16,
         "Binary Image Format": 17,
         "Best Quality Fingers": 18,
         "Right Thumb": 50,
         "Right Pointer Finger": 51,
         "Right Middle Finger": 52,
         "Right Ring Finger": 53,
         "Right Little Finger": 54,
         "Left Thumb": 55,
         "Left Pointer Finger": 56,
         "Left Middle Finger": 57,
         "Left Ring Finger": 58,
         "Left Little Finger": 59,
         "Right Iris": 60,
         "Left Iris": 61,
         "Face": 62,
         "Right Palm Print": 63,
         "Left Palm Print": 64,
         "Voice": 65,
         "Data": 0,
         "Data format": 1,
         "Data sub format": 2,
         "Data issuer": 3
     ]
     
     public static let claim169ValueMapper: [String: [AnyHashable: Int]] = [
         "Data format": [
             "Image": 0,
             "Template": 1,
             "Sound": 2,
             "Bio Hash": 3
         ],
         "Data sub format": [
             
             "PNG": 0,
             "JPEG": 1,
             "JPEG2000": 2,
             "AVIF": 3,
             "WEBP": 4,
             "TIFF": 5,
             "WSQ": 6,
             
             "Fingerprint Template ANSI 378": 0,
             "Fingerprint Template ISO 19794-2": 1,
             "Fingerprint Template NIST": 2,

             "WAV": 0,
             "MP3": 1
         ],
         "Gender": [
             "Male": 1,
             "Female": 2,
             "Others": 3
         ],
         "Marital Status": [
             "Unmarried": 1,
             "Married": 2,
             "Divorced": 3
         ],
         "Binary Image Format": [
             "JPEG": 1,
             "JPEG2": 2,
             "AVIF": 3,
             "WEBP": 4
         ]
     ]

     
     public static let claim169ReverseKeyMapper: [[String: String]] = [
         [
             "1": "ID",
             "2": "Version",
             "3": "Language",
             "4": "Full Name",
             "5": "First Name",
             "6": "Middle Name",
             "7": "Last Name",
             "8": "Date of Birth",
             "9": "Gender",
             "10": "Address",
             "11": "Email ID",
             "12": "Phone Number",
             "13": "Nationality",
             "14": "Marital Status",
             "15": "Guardian",
             "16": "Binary Image",
             "17": "Binary Image Format",
             "18": "Best Quality Fingers",
             "50": "Right Thumb",
             "51": "Right Pointer Finger",
             "52": "Right Middle Finger",
             "53": "Right Ring Finger",
             "54": "Right Little Finger",
             "55": "Left Thumb",
             "56": "Left Pointer Finger",
             "57": "Left Middle Finger",
             "58": "Left Ring Finger",
             "59": "Left Little Finger",
             "60": "Right Iris",
             "61": "Left Iris",
             "62": "Face",
             "63": "Right Palm Print",
             "64": "Left Palm Print",
             "65": "Voice"
         ],
         [
             "0": "Data",
             "1": "Data format",
             "2": "Data sub format",
             "3": "Data issuer"
         ]
     ]
     
     static let claim169RootReverseValueMapper: [String: [AnyHashable: String]] = [
         "Data format": [0: "Image", 1: "Template", 2: "Sound", 3: "Bio Hash"],
         "Gender": [1: "Male", 2: "Female", 3: "Others"],
         "Marital Status": [1: "Unmarried", 2: "Married", 3: "Divorced"],
         "Binary Image Format": [1: "JPEG", 2: "JPEG2", 3: "AVIF", 4: "WEBP"]
     ]

     static let claim169BiometricKeys = [
         "Right Thumb", "Right Pointer Finger", "Right Middle Finger", "Right Ring Finger", "Right Little Finger",
         "Left Thumb", "Left Pointer Finger", "Left Middle Finger", "Left Ring Finger", "Left Little Finger",
         "Right Iris", "Left Iris", "Face", "Right Palm Print", "Left Palm Print", "Voice"
     ]

     static let claim169BiometricFormatReverseValueMapper: [AnyHashable: String] = [
         0: "Image", 1: "Template", 2: "Sound", 3: "Bio Hash"
     ]

     static let claim169BiometricSubFormatReverseValueMapper: [String: [AnyHashable: String]] = [
         "Image": [
             0: "PNG", 1: "JPEG", 2: "JPEG2000", 3: "AVIF", 4: "WEBP", 5: "TIFF", 6: "WSQ"
         ],
         "Template": [
             0: "Fingerprint Template ANSI 378",
             1: "Fingerprint Template ISO 19794-2",
             2: "Fingerprint Template NIST"
         ],
         "Sound": [
             0: "WAV", 1: "MP3"
         ]
     ]

     static let claim169BiometricDataFormatKey = "Data format"
     static let claim169BiometricDataSubFormatKey = "Data sub format"


}
