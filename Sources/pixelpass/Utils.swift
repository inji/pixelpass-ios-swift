import Foundation

public func clearTemporaryDirectory() {
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory

    do {
        let tempFiles = try fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        for file in tempFiles {
            try fileManager.removeItem(at: file)
        }
    } catch {
        print("Error clearing temporary directory: \(error)")
    }
}

public func replaceValuesForClaim169(_ json: [String: Any]) -> [String: Any] {
    var result = json

    for (field, reverseMap) in Constants.claim169RootReverseValueMapper {
        if let rawValue = result[field],
           let normalized = normalize(rawValue),
           let mapped = reverseMap[normalized] {
            result[field] = mapped
        }
    }

    for biometricKey in Constants.claim169BiometricKeys {
        guard var biometricData = result[biometricKey] as? [String: Any] else { continue }

        if let rawFormat = biometricData[Constants.claim169BiometricDataFormatKey] {
            let formatLabel: String?

            if let i = rawFormat as? Int {
                formatLabel = Constants.claim169BiometricFormatReverseValueMapper[i]
            } else if let u = rawFormat as? UInt {
                formatLabel = Constants.claim169BiometricFormatReverseValueMapper[Int(u)]
            } else if let u64 = rawFormat as? UInt64 {
                formatLabel = Constants.claim169BiometricFormatReverseValueMapper[Int(u64)]
            } else {
                formatLabel = nil
            }

            if let formatLabel {
                biometricData[Constants.claim169BiometricDataFormatKey] = formatLabel

                if let rawSub = biometricData[Constants.claim169BiometricDataSubFormatKey],
                   let subMap = Constants.claim169BiometricSubFormatReverseValueMapper[formatLabel] {

                    if let i = rawSub as? Int, let label = subMap[i] {
                        biometricData[Constants.claim169BiometricDataSubFormatKey] = label
                    } else if let u = rawSub as? UInt, let label = subMap[Int(u)] {
                        biometricData[Constants.claim169BiometricDataSubFormatKey] = label
                    } else if let u64 = rawSub as? UInt64, let label = subMap[Int(u64)] {
                        biometricData[Constants.claim169BiometricDataSubFormatKey] = label
                    }
                }
            }
        }

        result[biometricKey] = biometricData
    }


    return result
}

func replaceKeysAtDepth(
    json: Any,
    mapper: [String: String],
    targetDepth: Int,
    currentDepth: Int = 0
) -> Any {
    
    if let dict = json as? [String: Any] {
        var result: [String: Any] = [:]

        for (key, value) in dict {
            let newKey: String =
                (currentDepth == targetDepth) ? (mapper[key] ?? key) : key

            let processedValue: Any = replaceKeysAtDepth(
                json: value,
                mapper: mapper,
                targetDepth: targetDepth,
                currentDepth: currentDepth + 1
            )
            result[newKey] = processedValue
        }
        return result
    }

    
    if let array = json as? [Any] {
        return array.map {
            replaceKeysAtDepth(
                json: $0,
                mapper: mapper,
                targetDepth: targetDepth,
                currentDepth: currentDepth
            )
        }
    }

    
    return json
}


func normalize(_ value: Any) -> AnyHashable? {
    if let str = value as? String {
        return str.lowercased()
    }
    return value as? AnyHashable
}


