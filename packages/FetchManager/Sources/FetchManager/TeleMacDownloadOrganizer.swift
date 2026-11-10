import Foundation

public enum TeleMacDownloadCategory: String, CaseIterable {
    case images = "Images"
    case videos = "Videos"
    case audio = "Audio"
    case documents = "Documents"
    case archives = "Archives"
    case voiceNotes = "Voice Notes"
    case other = "Other"
    
    public static func category(for fileName: String, isVoice: Bool = false) -> TeleMacDownloadCategory {
        if isVoice {
            return .voiceNotes
        }
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "jpg", "jpeg", "png", "heic", "heif", "webp", "gif", "tiff", "bmp", "svg", "raw", "cr2", "nef":
            return .images
        case "mp4", "mov", "avi", "mkv", "m4v", "wmv", "flv", "webm", "3gp", "ts":
            return .videos
        case "mp3", "m4a", "flac", "aac", "wav", "ogg", "opus", "aiff", "alac", "wma":
            return .audio
        case "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf", "pages", "numbers", "key", "csv", "md", "epub":
            return .documents
        case "zip", "rar", "7z", "tar", "gz", "bz2", "xz", "dmg", "pkg", "iso":
            return .archives
        default:
            return .other
        }
    }
}

public final class TeleMacDownloadOrganizer {
    public static let shared = TeleMacDownloadOrganizer()
    
    private let kCustomDownloadPath = "telemac_custom_download_path"
    private let kParallelDownloadSlots = "telemac_parallel_download_slots"
    
    public var parallelDownloadSlots: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: kParallelDownloadSlots)
            return (val >= 1 && val <= 4) ? val : 4
        }
        set {
            let clamped = max(1, min(4, newValue))
            UserDefaults.standard.set(clamped, forKey: kParallelDownloadSlots)
        }
    }
    
    public var rootDownloadDirectory: URL {
        if let custom = UserDefaults.standard.string(forKey: kCustomDownloadPath), !custom.isEmpty {
            let url = URL(fileURLWithPath: custom)
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                return url
            }
        }
        let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let telemacDir = downloads.appendingPathComponent("TeleMac", isDirectory: true)
        try? FileManager.default.createDirectory(at: telemacDir, withIntermediateDirectories: true)
        return telemacDir
    }
    
    public func setCustomDownloadDirectory(_ path: String?) {
        if let path = path, !path.isEmpty {
            UserDefaults.standard.set(path, forKey: kCustomDownloadPath)
        } else {
            UserDefaults.standard.removeObject(forKey: kCustomDownloadPath)
        }
    }
    
    public func destinationDirectory(for category: TeleMacDownloadCategory) -> URL {
        let dir = rootDownloadDirectory.appendingPathComponent(category.rawValue, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    public func resolvedDestinationURL(for fileName: String, isVoice: Bool = false) -> URL {
        let category = TeleMacDownloadCategory.category(for: fileName, isVoice: isVoice)
        let targetDir = destinationDirectory(for: category)
        let fileManager = FileManager.default
        
        var destination = targetDir.appendingPathComponent(fileName)
        if !fileManager.fileExists(atPath: destination.path) {
            return destination
        }
        
        let nameWithoutExt = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        var counter = 2
        
        while true {
            let newName = ext.isEmpty ? "\(nameWithoutExt) (\(counter))" : "\(nameWithoutExt) (\(counter)).\(ext)"
            destination = targetDir.appendingPathComponent(newName)
            if !fileManager.fileExists(atPath: destination.path) {
                return destination
            }
            counter += 1
        }
    }
}
