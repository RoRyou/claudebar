import SwiftUI
import AppKit

@main
struct ClaudeBarApp: App {
    @State private var model = UsageModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView()
                .environment(model)
        } label: {
            MenuBarLabel(model: model)
        }
        .menuBarExtraStyle(.window)
    }
}

private struct MenuBarLabel: View {
    let model: UsageModel

    var body: some View {
        HStack(spacing: 4) {
            Image(nsImage: tokenImage)
            if model.lastUpdated != nil {
                Text("\(model.session)%")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
            } else {
                Text("--")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
            }
        }
    }

    private var tokenImage: NSImage {
        let size = CGSize(width: 16, height: 18)
        let img = NSImage(size: size)
        img.lockFocus()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 9),
            .foregroundColor: NSColor.labelColor
        ]

        ("To" as NSString).draw(at: CGPoint(x: 0, y: 9), withAttributes: attrs)
        ("ken" as NSString).draw(at: CGPoint(x: 0, y: 0), withAttributes: attrs)

        img.unlockFocus()
        img.isTemplate = false
        return img
    }
}
