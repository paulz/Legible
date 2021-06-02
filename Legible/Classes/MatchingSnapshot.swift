import Quick
import Nimble
import SwiftUI

public class SnapshotConfiguration {
    public var windowScale = 1
    public var snapshotsFolderUrl: URL?

    public func folderUrl(testFile: URL) -> URL {
        if let configured = snapshotsFolderUrl {
            return configured
        }
        return testFile
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
    }
}

public class MatchingSnapshot: Behavior<Snapshotting> {
    public static var configuration = SnapshotConfiguration()

    public override class func spec(_ aContext: @escaping () -> Snapshotting) {
        var snapshotUrl: URL!
        var window: NSWindow!
        var subject: NSView!
        var size: NSSize!
        beforeEach {
            let exampleFileUrl = URL(fileURLWithPath: $0.example.callsite.file)
            snapshotUrl = Self.configuration
                .folderUrl(testFile: exampleFileUrl)
                .appendingPathComponent(aContext().name)
                .appendingPathExtension("png")

            subject = aContext().view
            window = StandardScaleWindow(scale: Self.configuration.windowScale)
            window.colorSpace = .sRGB
            window.contentView = subject
            size = aContext().size ?? subject.fittingSize
        }
        
        it(aContext().name + " should match snapshot") {
            let frame = NSRect(origin: .zero, size: size)
            subject.frame = frame
            let bitmap: NSBitmapImageRep! = subject.bitmapImageRepForCachingDisplay(in: frame)
            expect(bitmap).notTo(beNil())
            subject.cacheDisplay(in: frame, to: bitmap)
            let pngData: Data! = bitmap.representation(using: .png, properties: [:])
            XCTContext.runActivity(named: "compare png") {
                let attachment = XCTAttachment(
                    data: pngData,
                    uniformTypeIdentifier: String(kUTTypePNG)
                )
                attachment.name = "actual-" + aContext().name
                $0.add(attachment)
                if let existingPng = try? Data(contentsOf: snapshotUrl) {
                    let existing = XCTAttachment(
                        data: existingPng,
                        uniformTypeIdentifier: String(kUTTypePNG)
                    )
                    existing.name = "expected-" + aContext().name
                    $0.add(existing)
                    if existingPng != pngData {
                        // TODO: fail when bitmap.cgImage is nil
                        if significantlyDifferentImages(existingPng, bitmap.cgImage!) {
                            let diffImage = diff(existingPng, bitmap.cgImage!, size: frame.size)
                            let diffAttachment = XCTAttachment(image: diffImage)
                            diffAttachment.name = "diff-" + aContext().name
                            $0.add(diffAttachment)
                            // TODO: extract to write failure
                            try! pngData.write(to: snapshotUrl)
                            fail("\(snapshotUrl.lastPathComponent) was different, now recorded")
                        }
                    }
                } else {
                    try! pngData.write(to: snapshotUrl)
                    fail("\(snapshotUrl.lastPathComponent) was missing, now recorded")
                }
            }
        }
    }
}