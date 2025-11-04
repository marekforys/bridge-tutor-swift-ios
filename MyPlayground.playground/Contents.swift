import AppKit  // For macOS Playground

// MARK: - Enhanced Green Felt Generator
func generateGreenFelt(size: CGSize) -> NSImage? {
    let bitmap = NSBitmapImageRep(width: Int(size.width), height: Int(size.height), hasAlpha: false, bitsPerSample: 8, samplesPerPixel: 4, bytesPerRow: 0, colorSpaceName: .deviceRGB)!
    NSGraphicsContext.saveGraphicsState()
    if let context = NSGraphicsContext(bitmapImageRep: bitmap) {
        NSGraphicsContext.current = context
        
        // Base green (deeper casino vibe)
        let baseColor = NSColor(calibratedRed: 0.15, green: 0.40, blue: 0.15, alpha: 1.0)
        baseColor.setFill()
        NSBezierPath.fill(NSRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Enhanced noise (more granular)
        drawNoise(in: NSRect(x: 0, y: 0, width: size.width, height: size.height), scale: 1.8, opacity: 0.10)
        
        // Richer fibers (more lines, varied lengths)
        drawFibers(in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        
        NSGraphicsContext.restoreGraphicsState()
        return NSImage(size: size).copy() as? NSImage ?? NSImage(data: bitmap.representation(using: .png, properties: [:])!)
    }
    return nil
}

func drawNoise(in rect: NSRect, scale: CGFloat, opacity: CGFloat) {
    let white = NSColor(white: 1.0, alpha: opacity)
    let dark = NSColor(white: 0.8, alpha: opacity)
    for _ in 0..<Int(rect.width * rect.height * 0.12 / scale * scale) {
        let x = CGFloat.random(in: rect.minX...rect.maxX)
        let y = CGFloat.random(in: rect.minY...rect.maxY)
        let isDark = Bool.random()
        (isDark ? dark : white).setFill()
        let path = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: scale, height: scale))
        path.fill()
    }
}

func drawFibers(in rect: NSRect) {
    let fiberColor = NSColor(white: 0.95, alpha: 0.25)
    fiberColor.setStroke()
    let path = NSBezierPath()
    path.lineWidth = 0.8
    path.lineCapStyle = .roundLineCapStyle
    for _ in 0..<400 {  // More fibers for texture
        let startX = CGFloat.random(in: rect.minX...rect.maxX)
        let startY = CGFloat.random(in: rect.minY...rect.maxY)
        let length = CGFloat.random(in: 30...120)
        let angle = CGFloat.random(in: -CGFloat.pi...CGFloat.pi)
        let endX = startX + length * cos(angle)
        let endY = startY + length * sin(angle)
        path.move(to: NSPoint(x: startX, y: startY))
        path.line(to: NSPoint(x: endX, y: endY))
    }
    path.stroke()
}

// MARK: - Save to Desktop
func saveToDesktop(_ image: NSImage, name: String) -> URL? {
    guard let tiffRep = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffRep),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return nil }
    let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let fileURL = desktopURL.appendingPathComponent(name)
    try? pngData.write(to: fileURL)
    return fileURL
}

// MARK: - Run It
let size = CGSize(width: 2048, height: 2048)
if let felt = generateGreenFelt(size: size),
   let url = saveToDesktop(felt, name: "CardTableBackground@2x.png") {
    print("✅ Generated & saved: \(url.path)")
    print("Drag to Assets.xcassets → CardTableBackground (2x)")
} else {
    print("❌ Generation failed—check console.")
}
