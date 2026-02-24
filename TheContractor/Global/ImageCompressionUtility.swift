//
//  ImageCompressionUtility.swift
//  TheContractor
//
//  Created by Warp AI
//

import UIKit

class ImageCompressionUtility {
    
    static let shared = ImageCompressionUtility()
    
    private init() {}
    
    // MARK: - Compression Quality Presets
    
    enum CompressionQuality {
        case high      // 0.8 quality, max 1024x768
        case medium    // 0.6 quality, max 816x612 (matches Android)
        case low       // 0.4 quality, max 640x480
        
        var jpegQuality: CGFloat {
            switch self {
            case .high: return 0.8
            case .medium: return 0.6
            case .low: return 0.4
            }
        }
        
        var maxDimensions: CGSize {
            switch self {
            case .high: return CGSize(width: 1024, height: 768)
            case .medium: return CGSize(width: 816, height: 612)
            case .low: return CGSize(width: 640, height: 480)
            }
        }
    }
    
    // MARK: - Main Compression Method
    
    /// Compresses an image to the specified quality preset
    /// - Parameters:
    ///   - image: The UIImage to compress
    ///   - quality: The compression quality preset (default: medium)
    /// - Returns: Compressed image data, or nil if compression fails
    func compressImage(_ image: UIImage, quality: CompressionQuality = .medium) -> Data? {
        // Fix orientation first
        let orientationFixedImage = image.fixOrientation()
        
        // Resize to max dimensions while maintaining aspect ratio
        let resizedImage = orientationFixedImage.resize(to: quality.maxDimensions)
        
        // Compress to JPEG with specified quality
        let compressedData = resizedImage.jpegData(compressionQuality: quality.jpegQuality)
        
        if let data = compressedData {
            let sizeInKB = Double(data.count) / 1024.0
            print("📸 Image compressed: \(String(format: "%.2f", sizeInKB)) KB")
        }
        
        return compressedData
    }
    
    /// Compresses an image and saves it to a temporary file
    /// - Parameters:
    ///   - image: The UIImage to compress
    ///   - quality: The compression quality preset (default: medium)
    ///   - fileName: Optional custom file name (default: timestamp-based)
    /// - Returns: URL of the compressed image file, or nil if saving fails
    func compressAndSaveImage(_ image: UIImage, quality: CompressionQuality = .medium, fileName: String? = nil) -> URL? {
        guard let compressedData = compressImage(image, quality: quality) else {
            return nil
        }
        
        // Generate file name
        let finalFileName = fileName ?? "compressed_\(Date().timeIntervalSince1970).jpg"
        
        // Get temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(finalFileName)
        
        do {
            try compressedData.write(to: fileURL)
            print("📁 Image saved to: \(fileURL.path)")
            return fileURL
        } catch {
            print("❌ Failed to save compressed image: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Compresses multiple images
    /// - Parameters:
    ///   - images: Array of UIImages to compress
    ///   - quality: The compression quality preset (default: medium)
    /// - Returns: Array of compressed image data
    func compressImages(_ images: [UIImage], quality: CompressionQuality = .medium) -> [Data] {
        return images.compactMap { compressImage($0, quality: quality) }
    }
    
    /// Gets a human-readable file size string
    /// - Parameter data: The data to measure
    /// - Returns: Formatted size string (e.g., "1.5 MB", "250 KB")
    func getFileSize(for data: Data) -> String {
        let bytes = Double(data.count)
        
        if bytes >= 1_048_576 { // >= 1 MB
            return String(format: "%.2f MB", bytes / 1_048_576)
        } else if bytes >= 1024 { // >= 1 KB
            return String(format: "%.2f KB", bytes / 1024)
        } else {
            return String(format: "%.0f B", bytes)
        }
    }
}

// MARK: - UIImage Extensions

extension UIImage {
    
    /// Fixes the orientation of an image
    /// Some images from camera or photo library have incorrect orientation metadata
    func fixOrientation() -> UIImage {
        // If image is already in correct orientation, return as is
        if imageOrientation == .up {
            return self
        }
        
        guard let cgImage = cgImage else { return self }
        
        // Calculate the transformation needed
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
            
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break
        }
        
        // Create context and draw
        guard let colorSpace = cgImage.colorSpace,
              let context = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: cgImage.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: cgImage.bitmapInfo.rawValue
              ) else {
            return self
        }
        
        context.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        guard let newCGImage = context.makeImage() else {
            return self
        }
        
        return UIImage(cgImage: newCGImage)
    }
    
    /// Resizes image to fit within max dimensions while maintaining aspect ratio
    /// - Parameter maxSize: Maximum width and height
    /// - Returns: Resized UIImage
    func resize(to maxSize: CGSize) -> UIImage {
        let actualHeight = size.height
        let actualWidth = size.width
        let maxHeight = maxSize.height
        let maxWidth = maxSize.width
        
        // If image is already smaller than max, return as is
        if actualHeight <= maxHeight && actualWidth <= maxWidth {
            return self
        }
        
        var imgRatio = actualWidth / actualHeight
        let maxRatio = maxWidth / maxHeight
        var newWidth = actualWidth
        var newHeight = actualHeight
        
        // Calculate new dimensions maintaining aspect ratio
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                imgRatio = maxHeight / actualHeight
                newWidth = imgRatio * actualWidth
                newHeight = maxHeight
            } else if imgRatio > maxRatio {
                imgRatio = maxWidth / actualWidth
                newHeight = imgRatio * actualHeight
                newWidth = maxWidth
            } else {
                newHeight = maxHeight
                newWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}
