import Foundation
import UIKit
import Vision

enum TextRecognitionError: Error {
    case noImage
    case recognitionFailed
}

enum TextRecognitionService {
    static func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { throw TextRecognitionError.noImage }
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: TextRecognitionError.recognitionFailed)
                    return
                }
                let strings = observations.compactMap { $0.topCandidates(1).first?.string }
                let result = strings.joined(separator: " ")
                    .replacingOccurrences(of: "\n", with: " ")
                    .replacingOccurrences(of: "- ", with: "")
                    .replacingOccurrences(of: " +", with: " ", options: .regularExpression)
                    .trimmingCharacters(in: .whitespaces)
                continuation.resume(returning: result)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ro", "en-US"]
            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: CGImagePropertyOrientation(image.imageOrientation),
                options: [:]
            )
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

private extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
