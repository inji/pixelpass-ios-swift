import Foundation


func mapJsonWithKeyAndValueMapper(
    _ json: [String: Any],
    keyMapper: [String: Any] = [:],
    valueMapper: [String: [AnyHashable: Any]] = [:]
) -> [AnyHashable: Any] {

    let normalizedKeyMapper = normalizeKeyMapper(keyMapper)
    let normalizedValueMapper = normalizeValueMapper(valueMapper)

    var result: [AnyHashable: Any] = [:]

    for (originalKey, originalValue) in json {
        let normalizedKey = originalKey.lowercased()

        let mappedKey: AnyHashable =
        (normalizedKeyMapper[normalizedKey] as? AnyHashable) ?? originalKey as AnyHashable

        let processedValue = processValue(
            originalValue,
            fieldKey: normalizedKey,
            normalizedValueMapper: normalizedValueMapper,
            keyMapper: keyMapper,
            valueMapper: valueMapper
        )

            result[mappedKey] = processedValue
        
    }

    return result
}

func mapArrayWithKeyAndValueMapper(
    _ array: [Any],
    keyMapper: [String: Any] = [:],
    valueMapper: [String: [AnyHashable: Any]] = [:]
) -> [Any] {

    return array.map { value in
        processValue(
            value,
            fieldKey: nil,
            normalizedValueMapper: normalizeValueMapper(valueMapper),
            keyMapper: keyMapper,
            valueMapper: valueMapper
        )
    }
}


private func processValue(
    _ value: Any,
    fieldKey: String?,
    normalizedValueMapper: [String: [AnyHashable: Any]],
    keyMapper: [String: Any],
    valueMapper: [String: [AnyHashable: Any]]
) -> Any {

    if value is NSNull {
        return NSNull()
    }

    if let dict = value as? [String: Any] {
        return mapJsonWithKeyAndValueMapper(
            dict,
            keyMapper: keyMapper,
            valueMapper: valueMapper
        )
    }

    if let array = value as? [Any] {
        return mapArrayWithKeyAndValueMapper(
            array,
            keyMapper: keyMapper,
            valueMapper: valueMapper
        )
    }


    if let fieldKey = fieldKey,
       let fieldValueMapper = normalizedValueMapper[fieldKey] {

        let lookupKey: AnyHashable? =
            (value as? String)?.lowercased() as AnyHashable? ??
            (value as? AnyHashable)

        if let lookupKey,
           let mappedValue = fieldValueMapper[lookupKey] {
            return mappedValue
        }
    }

    return value
}

private func normalizeKeyMapper(_ mapper: [String: Any]) -> [String: Any] {
    var result: [String: Any] = [:]
    for (key, value) in mapper {
        result[key.lowercased()] = value
    }
    return result
}

private func normalizeValueMapper(
    _ mapper: [String: [AnyHashable: Any]]
) -> [String: [AnyHashable: Any]] {

    var result: [String: [AnyHashable: Any]] = [:]

    for (fieldKey, valueMap) in mapper {
        var normalizedValueMap: [AnyHashable: Any] = [:]

        for (valueKey, mappedValue) in valueMap {
            if let stringKey = valueKey as? String {
                normalizedValueMap[stringKey.lowercased()] = mappedValue
            } else {
                normalizedValueMap[valueKey] = mappedValue
            }
        }

        result[fieldKey.lowercased()] = normalizedValueMap
    }

    return result
}
