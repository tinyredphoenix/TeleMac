import Cocoa
import Foundation

public struct IINABridge {
    public static let bundleId = "com.colliderli.iina"
    
    public static var isInstalled: Bool {
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) != nil
    }
    
    @discardableResult
    public static func open(localPath: String) -> Bool {
        guard isInstalled else { return false }
        let fileURL = URL(fileURLWithPath: localPath)
        return NSWorkspace.shared.open([fileURL], withAppBundleIdentifier: bundleId, options: [], additionalEventParamDescriptor: nil, launchIdentifiers: nil)
    }
    
    @discardableResult
    public static func open(url: URL) -> Bool {
        guard isInstalled else { return false }
        if url.isFileURL {
            return open(localPath: url.path)
        }
        let encoded = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let iinaURL = URL(string: "iina://open?url=\(encoded)") {
            return NSWorkspace.shared.open(iinaURL)
        }
        return false
    }
}
