import Foundation
import Compression

class Brotli: Compression {

    func decompress(_ data: Data) -> Data? {
        if data.isEmpty {
            return nil
        }

        var size = min(
            Constants.initialBufferSizeMultiplier * data.count
                + Constants.extraBufferSize,
            Constants.maxDecompressionBufferSize
        )

        while true {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)

            let read = data.withUnsafeBytes {
                compression_decode_buffer(
                    buffer,
                    size,
                    $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 1),
                    data.count,
                    nil,
                    COMPRESSION_BROTLI
                )
            }

            if read > 0 {
                let result = Data(bytes: buffer, count: read)
                buffer.deallocate()
                return result
            }

            buffer.deallocate()

            if size >= Constants.maxDecompressionBufferSize {
                return nil
            }

            size = min(
                size * 2,
                Constants.maxDecompressionBufferSize
            )
        }
    }

    func compress(data: Any) -> Data? {
        var sourceBuffer: [UInt8]

        if let stringData = data as? String {
            sourceBuffer = Array(stringData.utf8)
        } else if let byteArrayData = data as? [UInt8] {
            sourceBuffer = byteArrayData
        } else {
            return nil
        }

        let destinationBufferSize =
            sourceBuffer.count
            + (sourceBuffer.count / Constants.compressionRatioDenominator)
            + Constants.compressionOverhead

        let destinationBuffer =
            UnsafeMutablePointer<UInt8>.allocate(
                capacity: destinationBufferSize
            )

        defer {
            destinationBuffer.deallocate()
        }

        let compressedSize = compression_encode_buffer(
            destinationBuffer,
            destinationBufferSize,
            &sourceBuffer,
            sourceBuffer.count,
            nil,
            COMPRESSION_BROTLI
        )

        if compressedSize == 0 {
            return nil
        }

        return Data(
            bytes: destinationBuffer,
            count: compressedSize
        )
    }
}
