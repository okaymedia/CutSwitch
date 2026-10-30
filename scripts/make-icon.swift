#!/usr/bin/env swift
import AppKit

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let iconset = root.appendingPathComponent("build/AppIcon.iconset")
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: root.appendingPathComponent("Resources"), withIntermediateDirectories: true)

func render(pixels: Int, to url: URL) throws {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                              bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                              isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    let scale = CGFloat(pixels) / 1024
    let transform = AffineTransform(scale: scale)
    (transform as NSAffineTransform).concat()

    let background = NSBezierPath(roundedRect: NSRect(x: 20, y: 20, width: 984, height: 984),
                                  xRadius: 220, yRadius: 220)
    NSGradient(starting: NSColor(calibratedRed: 0.13, green: 0.14, blue: 0.21, alpha: 1),
               ending: NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.09, alpha: 1))!
        .draw(in: background, angle: -90)

    // Kesilecek çizgi: mor → mavi, eşit aralıklı kesikler.
    for i in 0..<9 {
        let t = CGFloat(i) / 8
        NSColor(calibratedRed: 0.68 * (1 - t) + 0.18 * t, green: 0.30 + 0.25 * t,
                blue: 1, alpha: 1).setStroke()
        let dash = NSBezierPath()
        dash.lineWidth = 22
        dash.lineCapStyle = .round
        dash.move(to: NSPoint(x: 480 + i * 45, y: 512))
        dash.line(to: NSPoint(x: 500 + i * 45, y: 512))
        dash.stroke()
    }
    NSColor.white.setStroke()
    for y in [325, 699] {
        let ring = NSBezierPath(ovalIn: NSRect(x: 205, y: y - 78, width: 156, height: 156))
        ring.lineWidth = 38
        ring.stroke()
    }
    let blades = NSBezierPath()
    blades.lineWidth = 46
    blades.lineCapStyle = .round
    blades.move(to: NSPoint(x: 345, y: 375))
    blades.line(to: NSPoint(x: 755, y: 755))
    blades.move(to: NSPoint(x: 345, y: 649))
    blades.line(to: NSPoint(x: 755, y: 269))
    blades.stroke()
    NSColor(calibratedWhite: 0.65, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: 477, y: 497, width: 30, height: 30)).fill()
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])!.write(to: url)
}

for size in [16, 32, 128, 256, 512] {
    try render(pixels: size, to: iconset.appendingPathComponent("icon_\(size)x\(size).png"))
    try render(pixels: size * 2, to: iconset.appendingPathComponent("icon_\(size)x\(size)@2x.png"))
}
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconset.path, "-o", root.appendingPathComponent("Resources/AppIcon.icns").path]
try process.run()
process.waitUntilExit()
if process.terminationStatus != 0 {
    // Bazı kısıtlı ortamlarda iconutil geçerli PNG'leri de "Invalid Iconset" diye reddeder.
    // Aynı PNG'leri standart ICNS bloklarına koy; harici bağımlılık gerekmez.
    fputs("⚠ iconutil dönüşümü başarısız; standart PNG/ICNS paketlemesi kullanılıyor.\n", stderr)
    func lengthData(_ value: Int) -> Data {
        var bigEndian = UInt32(value).bigEndian
        return withUnsafeBytes(of: &bigEndian) { Data($0) }
    }
    let entries = [
        ("icp4", "16x16"), ("icp5", "32x32"), ("icp6", "32x32@2x"),
        ("ic07", "128x128"), ("ic08", "256x256"), ("ic09", "512x512"),
        ("ic10", "512x512@2x"), ("ic11", "16x16@2x"), ("ic12", "32x32@2x"),
        ("ic13", "128x128@2x"), ("ic14", "256x256@2x")
    ]
    var body = Data()
    for (type, name) in entries {
        let png = try Data(contentsOf: iconset.appendingPathComponent("icon_\(name).png"))
        body.append(Data(type.utf8))
        body.append(lengthData(png.count + 8))
        body.append(png)
    }
    var file = Data("icns".utf8)
    file.append(lengthData(body.count + 8))
    file.append(body)
    try file.write(to: root.appendingPathComponent("Resources/AppIcon.icns"))
}
print("✓ Resources/AppIcon.icns (1024 px)")
