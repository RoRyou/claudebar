import SwiftUI

struct PopoverView: View {
    @Environment(UsageModel.self) var model

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            row("session", value: model.session)
            row("extra   ", value: model.extra)
            Divider().opacity(0.3)
            HStack(spacing: 0) {
                Text("resets  ").foregroundStyle(.secondary)
                Text(model.resetTime)
            }
            HStack(spacing: 0) {
                Text("updated ").foregroundStyle(.secondary)
                Text(model.lastUpdatedString)
                Spacer()
                if model.isLoading {
                    Text("...").foregroundStyle(.secondary)
                } else {
                    Button("↻") { Task { await model.refresh() } }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                }
            }
            if let err = model.errorMessage {
                Text("! \(err)").foregroundStyle(.red).lineLimit(1)
            }
        }
        .font(.system(size: 11, design: .monospaced))
        .padding(12)
        .frame(width: 220)
    }

    private func row(_ label: String, value: Int) -> some View {
        HStack(spacing: 0) {
            Text(label).foregroundStyle(.secondary)
            Text("  ")
            bar(value)
            Text("  \(value)%")
        }
    }

    private func bar(_ value: Int) -> some View {
        let filled = value / 10
        let color: Color = value < 60 ? .green : value < 85 ? .orange : .red
        return Text(String(repeating: "█", count: filled) + String(repeating: "░", count: 10 - filled))
            .foregroundStyle(color)
    }
}
