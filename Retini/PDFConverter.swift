//
//  PDFConverter.swift
//  Retini
//
//  Created by Pascal Ambrosini on 09/05/21.
//  Copyright © 2021 ET-ID. All rights reserved.
//

import Foundation
import Cocoa

@objc class PDFUtils: NSObject {
    @objc static func drawPDFfromURL(url: URL, multiplier: CGFloat = 1) -> NSImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }

        var pageRect = page.getBoxRect(.mediaBox)
        pageRect = CGRect(origin: pageRect.origin, size: CGSize(width: pageRect.size.width * multiplier, height: pageRect.size.height * multiplier))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
              let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil, width: Int(pageRect.size.width), height: Int(pageRect.size.height), bitsPerComponent: 8,
                                            bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        //context.translateBy(x: 0, y: pageRect.size.height)
        context.scaleBy(x: multiplier, y: multiplier)
        context.drawPDFPage(page)
        guard let image = context.makeImage() else {
            return nil
        }
        return NSImage(cgImage: image, size: pageRect.size)
    }
}

extension NSImage {
    @objc func writeToFile(file: String, atomically: Bool, usingType type: NSBitmapImageRep.FileType) -> Bool {
        let properties = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
        guard
            let imageData = tiffRepresentation,
            let imageRep = NSBitmapImageRep(data: imageData),
            let fileData = imageRep.representation(using: type, properties: properties) else {
                return false
        }
        do {
            try fileData.write(to: URL(fileURLWithPath: file))
            return true
        } catch _ {
            return false
        }
    }
}
