import XCTest
@testable import OndaCore

final class M3UParserTests: XCTestCase {

    let sample = """
    #EXTM3U
    #EXTINF:-1 tvg-id="srf1.ch" tvg-name="SRF 1" tvg-logo="https://example.org/srf1.png" group-title="Schweiz",SRF 1 HD
    http://anbieter.example:8080/live/user/pass/101.ts
    #EXTINF:-1 tvg-id="" group-title="Deutschland",ZDF, das Zweite
    http://anbieter.example:8080/live/user/pass/202.ts
    #EXTINF:-1,Ohne Gruppe
    #EXTGRP:Sport
    http://anbieter.example:8080/live/user/pass/303.m3u8
    #EXTINF:-1 group-title="Filme",DE | Inception (2010) 4K
    http://anbieter.example:8080/movie/user/pass/9001.mkv
    """

    func testParsesEntriesAndAttributes() {
        let entries = M3UParser.parse(sample)
        XCTAssertEqual(entries.count, 4)
        XCTAssertEqual(entries[0].title, "SRF 1 HD")
        XCTAssertEqual(entries[0].tvgID, "srf1.ch")
        XCTAssertEqual(entries[0].group, "Schweiz")
        XCTAssertEqual(entries[0].logoURL?.absoluteString, "https://example.org/srf1.png")
        XCTAssertEqual(entries[1].title, "ZDF, das Zweite")
        XCTAssertNil(entries[1].tvgID)
        XCTAssertEqual(entries[2].group, "Sport")
    }

    func testChannelsUseStableKeysAndSkipMovies() {
        let channels = M3UParser.channels(from: M3UParser.parse(sample))
        XCTAssertEqual(channels.count, 3)
        XCTAssertEqual(channels[0].id, "tvg:srf1.ch")
        XCTAssertEqual(channels[1].id, "n:deutschland|zdf, das zweite")
    }

    func testEngineSelection() {
        let ts = URL(string: "http://x.example/live/1.ts")!
        let hls = URL(string: "http://x.example/live/1.m3u8")!
        XCTAssertEqual(EngineSelector.engine(for: ts, setting: .automatic), .vlc)
        XCTAssertEqual(EngineSelector.engine(for: hls, setting: .automatic), .avPlayer)
        XCTAssertEqual(EngineSelector.engine(for: ts, setting: .avPlayer), .avPlayer)
        XCTAssertEqual(Deinterlace.automatic.vlcMode, "yadif2x")
        XCTAssertNil(Deinterlace.off.vlcMode)
    }
}
