import Foundation

/// Einstellung „Player-Engine“ (gleiche Werte wie in beiden Prototypen).
public enum EngineSetting: Int, Sendable, CaseIterable {
    case automatic = 0, avPlayer = 1, vlc = 2
}

/// Tatsächlich verwendete Engine.
public enum EngineKind: String, Sendable {
    case avPlayer = "AVPlayer"
    case vlc = "VLC"
}

public enum EngineSelector {
    /// „Automatisch“: HLS → AVPlayer, alles andere (MPEG-TS, MKV …) → VLC.
    public static func engine(for url: URL, setting: EngineSetting) -> EngineKind {
        switch setting {
        case .avPlayer: return .avPlayer
        case .vlc: return .vlc
        case .automatic: return isHLS(url) ? .avPlayer : .vlc
        }
    }

    public static func isHLS(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == "m3u8" || url.absoluteString.lowercased().contains(".m3u8?")
    }
}

/// Deinterlacing-Modi, Reihenfolge wie in den Einstellungen.
public enum Deinterlace: Int, Sendable, CaseIterable {
    case automatic = 0, off, discard, blend, bob, yadif, yadif2x

    /// Wert für die VLC-Option `:deinterlace-mode=` (nil = aus).
    public var vlcMode: String? {
        switch self {
        case .automatic, .yadif2x: return "yadif2x"
        case .off: return nil
        case .discard: return "discard"
        case .blend: return "blend"
        case .bob: return "bob"
        case .yadif: return "yadif"
        }
    }
}

public struct PlaybackOptions: Sendable {
    public var deinterlace: Deinterlace
    /// Live-Puffer in Sekunden (Bauplan 3a: 0,5–1 s).
    public var liveBuffer: TimeInterval
    public var userAgent: String?

    public init(deinterlace: Deinterlace = .automatic, liveBuffer: TimeInterval = 1, userAgent: String? = nil) {
        self.deinterlace = deinterlace
        self.liveBuffer = liveBuffer
        self.userAgent = userAgent
    }
}

public struct Track: Identifiable, Hashable, Sendable {
    public let id: Int
    public var name: String
    public var language: String?
    public init(id: Int, name: String, language: String? = nil) {
        self.id = id
        self.name = name
        self.language = language
    }
}

public struct StreamStats: Sendable {
    public var width = 0, height = 0
    public var framesPerSecond = 0.0
    public var codec = ""
    public var bitrateMbps = 0.0
    public var droppedFrames = 0
    public var bufferSeconds = 0.0
    public init() {}
}

/// Gemeinsame Schnittstelle für AVPlayer und VLCKit. Die konkreten Engines
/// liegen in den App-Targets, weil sie plattformspezifische Views brauchen.
public protocol PlayerEngine: AnyObject {
    func load(_ url: URL, options: PlaybackOptions)
    func play()
    func pause()
    func stop()
    var stats: StreamStats { get }
    var audioTracks: [Track] { get }
    func selectAudio(_ id: Int)
    var subtitleTracks: [Track] { get }
    func selectSubtitle(_ id: Int?)
}
