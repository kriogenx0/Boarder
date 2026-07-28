import SwiftUI
import AppKit

/// A fish-shaped surfboard silhouette: full nose and tail with a pinched waist partway down each
/// rail. The waist pinch is a side-boundary feature (rather than a tail notch), giving a shape
/// that's unmistakably organic/board-like and clearly distinct at small menu-bar sizes.
struct SurfboardShape: Shape {
    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let top = rect.minY
        let bottom = rect.maxY
        let h = rect.height
        let w = rect.width

        let chestHalf = w * 0.5
        let waistHalf = w * 0.30
        let hipHalf = w * 0.40
        let chestY = top + h * 0.32
        let waistY = top + h * 0.62
        let hipY = top + h * 0.80

        let nose = CGPoint(x: midX, y: top)
        let rightChest = CGPoint(x: midX + chestHalf, y: chestY)
        let leftChest = CGPoint(x: midX - chestHalf, y: chestY)
        let rightWaist = CGPoint(x: midX + waistHalf, y: waistY)
        let leftWaist = CGPoint(x: midX - waistHalf, y: waistY)
        let rightHip = CGPoint(x: midX + hipHalf, y: hipY)
        let leftHip = CGPoint(x: midX - hipHalf, y: hipY)
        let tail = CGPoint(x: midX, y: bottom)

        var path = Path()
        path.move(to: nose)
        path.addCurve(
            to: rightChest,
            control1: CGPoint(x: midX + chestHalf * 0.85, y: top + h * 0.04),
            control2: CGPoint(x: midX + chestHalf, y: chestY - h * 0.10)
        )
        path.addCurve(
            to: rightWaist,
            control1: CGPoint(x: midX + chestHalf, y: chestY + h * 0.14),
            control2: CGPoint(x: midX + waistHalf, y: waistY - h * 0.08)
        )
        path.addCurve(
            to: rightHip,
            control1: CGPoint(x: midX + waistHalf, y: waistY + h * 0.08),
            control2: CGPoint(x: midX + hipHalf, y: hipY - h * 0.05)
        )
        path.addQuadCurve(to: tail, control: CGPoint(x: midX + hipHalf * 0.4, y: bottom))
        path.addQuadCurve(to: leftHip, control: CGPoint(x: midX - hipHalf * 0.4, y: bottom))
        path.addCurve(
            to: leftWaist,
            control1: CGPoint(x: midX - hipHalf, y: hipY - h * 0.05),
            control2: CGPoint(x: midX - waistHalf, y: waistY + h * 0.08)
        )
        path.addCurve(
            to: leftChest,
            control1: CGPoint(x: midX - waistHalf, y: waistY - h * 0.08),
            control2: CGPoint(x: midX - chestHalf, y: chestY + h * 0.14)
        )
        path.addCurve(
            to: nose,
            control1: CGPoint(x: midX - chestHalf, y: chestY - h * 0.10),
            control2: CGPoint(x: midX - chestHalf * 0.85, y: top + h * 0.04)
        )
        path.closeSubpath()
        return path
    }
}

enum SurfboardIcon {
    /// Renders the surfboard shape as a template NSImage suitable for NSStatusItem.button.image -
    /// template mode lets AppKit tint it automatically for light/dark menu bars and highlight state.
    @MainActor
    static func renderTemplateImage(pointHeight: CGFloat = 18) -> NSImage {
        let size = CGSize(width: pointHeight * 0.56, height: pointHeight)
        let renderer = ImageRenderer(
            content: SurfboardShape()
                .fill(Color.black)
                .frame(width: size.width, height: size.height)
        )
        renderer.scale = 2

        guard let image = renderer.nsImage else {
            return NSImage(size: NSSize(width: size.width, height: size.height))
        }
        image.isTemplate = true
        return image
    }
}
