// AppIcon source generator for Boarder.app - renders the icon at every size macOS expects into
// an .iconset directory. Run with: swift Scripts/generate_app_icon.swift <output .iconset dir>
// Not part of the app target - duplicates SurfboardShape's geometry since it must run
// standalone outside the package.
import SwiftUI
import AppKit

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

struct HibiscusPetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let base = CGPoint(x: rect.midX, y: rect.maxY)
        let tip = CGPoint(x: rect.midX, y: rect.minY)

        var path = Path()
        path.move(to: base)
        path.addCurve(
            to: tip,
            control1: CGPoint(x: rect.midX - w * 0.62, y: rect.maxY - h * 0.62),
            control2: CGPoint(x: rect.midX - w * 0.30, y: rect.minY + h * 0.06)
        )
        path.addCurve(
            to: base,
            control1: CGPoint(x: rect.midX + w * 0.30, y: rect.minY + h * 0.06),
            control2: CGPoint(x: rect.midX + w * 0.62, y: rect.maxY - h * 0.62)
        )
        path.closeSubpath()
        return path
    }
}

struct HibiscusStamenShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - w * 0.5, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + w * 0.5, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX - w * 0.5, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY + h * 0.12)
        )
        path.closeSubpath()
        return path
    }
}

struct FlowerShape: View {
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let petalHeight = size * 0.68
            let petalWidth = size * 0.46

            ZStack {
                ForEach(0..<5) { i in
                    HibiscusPetalShape()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.98, green: 0.55, blue: 0.80),
                                    Color(red: 0.93, green: 0.10, blue: 0.55),
                                    Color(red: 0.65, green: 0.0, blue: 0.38)
                                ],
                                center: UnitPoint(x: 0.5, y: 1.0),
                                startRadius: 0,
                                endRadius: petalHeight * 0.9
                            )
                        )
                        .frame(width: petalWidth, height: petalHeight)
                        .offset(y: -petalHeight * 0.30)
                        .rotationEffect(.degrees(Double(i) * 72))
                }

                // Curved stamen tube rising from the throat, ending in a cluster of anthers -
                // the single most recognizable hibiscus feature, distinguishing it from a generic
                // 5-petal flower.
                ZStack {
                    HibiscusStamenShape()
                        .fill(Color(red: 0.80, green: 0.15, blue: 0.45))
                        .frame(width: size * 0.065, height: size * 0.32)

                    ForEach(0..<5) { i in
                        Ellipse()
                            .fill(Color(red: 0.98, green: 0.80, blue: 0.20))
                            .frame(width: size * 0.07, height: size * 0.045)
                            .rotationEffect(.degrees(Double(i) * 30 - 60))
                            .offset(
                                x: [-1.0, -0.5, 0, 0.5, 1.0][i] * size * 0.05,
                                y: -size * 0.015
                            )
                    }
                }
                .offset(y: -size * 0.28)
                .rotationEffect(.degrees(-10))

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.75, green: 0.05, blue: 0.42),
                                Color(red: 0.55, green: 0.0, blue: 0.32)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.09
                        )
                    )
                    .frame(width: size * 0.17, height: size * 0.17)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct AppIconView: View {
    let size: CGFloat

    var body: some View {
        let boardHeight = size * 0.80
        let boardWidth = boardHeight * 0.42

        ZStack {
            RoundedRectangle(cornerRadius: size * 0.225, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.22),
                            Color(white: 0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            ZStack {
                Color(red: 0.96, green: 0.94, blue: 0.88)

                FlowerShape()
                    .frame(width: boardWidth * 0.78, height: boardWidth * 0.78)
                    .offset(x: -boardWidth * 0.06, y: -boardHeight * 0.32)

                FlowerShape()
                    .frame(width: boardWidth * 0.78, height: boardWidth * 0.78)
                    .offset(x: boardWidth * 0.06, y: boardHeight * 0.28)
            }
            .frame(width: boardWidth, height: boardHeight)
            .clipShape(SurfboardShape())
        }
        .frame(width: size, height: size)
    }
}

@MainActor
func renderPNG(pixelSize: CGFloat, to path: String) {
    let renderer = ImageRenderer(content: AppIconView(size: 1024).frame(width: 1024, height: 1024))
    renderer.scale = pixelSize / 1024
    guard let cgImage = renderer.cgImage else {
        FileHandle.standardError.write("Failed to render icon at \(pixelSize)px\n".data(using: .utf8)!)
        exit(1)
    }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        FileHandle.standardError.write("Failed to encode PNG at \(pixelSize)px\n".data(using: .utf8)!)
        exit(1)
    }
    try! data.write(to: URL(fileURLWithPath: path))
}

// (base point size, scale, iconset filename) for every slot Apple's iconutil expects.
let specs: [(CGFloat, Int, String)] = [
    (16, 1, "icon_16x16.png"),
    (16, 2, "icon_16x16@2x.png"),
    (32, 1, "icon_32x32.png"),
    (32, 2, "icon_32x32@2x.png"),
    (128, 1, "icon_128x128.png"),
    (128, 2, "icon_128x128@2x.png"),
    (256, 1, "icon_256x256.png"),
    (256, 2, "icon_256x256@2x.png"),
    (512, 1, "icon_512x512.png"),
    (512, 2, "icon_512x512@2x.png")
]

guard CommandLine.arguments.count > 1 else {
    FileHandle.standardError.write("Usage: swift generate_app_icon.swift <output .iconset dir>\n".data(using: .utf8)!)
    exit(1)
}
let outDir = CommandLine.arguments[1]
try! FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

MainActor.assumeIsolated {
    for (points, scale, filename) in specs {
        let pixelSize = points * CGFloat(scale)
        renderPNG(pixelSize: pixelSize, to: "\(outDir)/\(filename)")
    }
}
print("Wrote iconset to \(outDir)")