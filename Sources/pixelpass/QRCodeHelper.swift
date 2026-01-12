import CoreImage
#if canImport(UIKit)
import UIKit

enum QRCodeHelper {

    static func generateQRImage(
    qrText: String,
    ecc: ECC = .L
    ) -> Data? {

        let data = qrText.data(using: .ascii)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(ecc.rawValue, forKey: "inputCorrectionLevel")

        guard let qrImage = filter.outputImage else {
            return nil
        }

        let context = CIContext()
        guard let cgImage = context.createCGImage(qrImage, from: qrImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage).pngData()
    }
}

#endif

