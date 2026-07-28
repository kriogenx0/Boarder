import SwiftUI
import AppKit

/// An elongated surfboard silhouette with a swallow/fish tail notch - the notch is what reads as
/// "surfboard" specifically rather than a generic oval/leaf, even at small menu-bar sizes.
struct SurfboardShape: Shape {
    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let top = rect.minY
        let bottom = rect.maxY
        let h = rect.height
        let w = rect.width

        let chestHalf = w * 0.5
        let tailHalf = w * 0.32
        let tailShoulderHalf = w * 0.36
        let noseTuck = h * 0.05
        let chestY = top + h * 0.40
        let tailY = bottom - h * 0.03
        let notchDepth = h * 0.10

        let nose = CGPoint(x: midX, y: top)
        let rightChest = CGPoint(x: midX + chestHalf, y: chestY)
        let leftChest = CGPoint(x: midX - chestHalf, y: chestY)
        let rightTail = CGPoint(x: midX + tailHalf, y: tailY)
        let leftTail = CGPoint(x: midX - tailHalf, y: tailY)
        let notch = CGPoint(x: midX, y: tailY - notchDepth)

        var path = Path()
        path.move(to: nose)
        path.addCurve(
            to: rightChest,
            control1: CGPoint(x: midX + chestHalf * 0.85, y: top + noseTuck),
            control2: CGPoint(x: midX + chestHalf, y: chestY - h * 0.16)
        )
        path.addCurve(
            to: rightTail,
            control1: CGPoint(x: midX + chestHalf, y: chestY + h * 0.34),
            control2: CGPoint(x: midX + tailShoulderHalf, y: tailY - h * 0.07)
        )
        path.addLine(to: notch)
        path.addLine(to: leftTail)
        path.addCurve(
            to: leftChest,
            control1: CGPoint(x: midX - tailShoulderHalf, y: tailY - h * 0.07),
            control2: CGPoint(x: midX - chestHalf, y: chestY + h * 0.34)
        )
        path.addCurve(
            to: nose,
            control1: CGPoint(x: midX - chestHalf, y: chestY - h * 0.16),
            control2: CGPoint(x: midX - chestHalf * 0.85, y: top + noseTuck)
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
