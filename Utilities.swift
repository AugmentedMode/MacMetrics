import Foundation

extension UInt64 {
    func formatBytes() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useGB, .useMB]
        byteCountFormatter.countStyle = .memory
        return byteCountFormatter.string(fromByteCount: Int64(self))
    }
} 