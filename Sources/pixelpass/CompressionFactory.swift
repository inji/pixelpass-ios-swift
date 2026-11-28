import Foundation

enum CompressionError: Error {
    case unsupportedCompression
}

class CompressionFactory {

    static func create(type: CompressionType) throws -> Compression {

        switch type {

        case .zlib:
            return Zlib()

        case .brotli:
            if #available(iOS 15.0, *) {
                return Brotli()
            } else {
                throw CompressionError.unsupportedCompression
            }
        }
    }
}
