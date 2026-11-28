import Foundation

protocol Compression {

    func compress(data: Any) -> Data?

    func decompress(_ data: Data) -> Data?

}
