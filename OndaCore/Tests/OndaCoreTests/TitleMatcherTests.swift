import XCTest
@testable import OndaCore

/// Gleiche Fälle wie im Prototyp: Trend-Titel gegen typische Playlist-Einträge.
final class TitleMatcherTests: XCTestCase {

    let playlist = [
        "DE | Inception (2010) 4K",
        "EN | Black Adam - IMAX Edition (2022) 4K",
        "MULTI: A MINECRAFT MOVIE [2025] HEVC",
        "EN | Ted (2012) FHD",
        "DE | Dune: Part Two (2024)",
        "EN | F1 (2025) FHD"
    ]

    func testNormalize() {
        XCTAssertEqual(TitleMatcher.normalize("EN | Black Adam - IMAX Edition (2022) 4K"), "black adam")
        XCTAssertEqual(TitleMatcher.normalize("MULTI: A MINECRAFT MOVIE [2025] HEVC"), "a minecraft movie")
        XCTAssertEqual(TitleMatcher.normalize("Dune: Part Two"), "dune part two")
        XCTAssertEqual(TitleMatcher.normalize("Amélie"), "amelie")
    }

    func testYear() {
        XCTAssertEqual(TitleMatcher.year(in: "DE | Inception (2010) 4K"), 2010)
        XCTAssertEqual(TitleMatcher.year(in: "MULTI: X [2025]"), 2025)
        XCTAssertNil(TitleMatcher.year(in: "Ohne Jahr"))
    }

    func testFindsAvailableTitles() {
        XCTAssertEqual(TitleMatcher.bestMatch(title: "Black Adam", year: 2022, isMovie: true, in: playlist)?.index, 1)
        XCTAssertEqual(TitleMatcher.bestMatch(title: "A Minecraft Movie", year: 2025, isMovie: true, in: playlist)?.index, 2)
        XCTAssertEqual(TitleMatcher.bestMatch(title: "Dune: Part Two", year: 2024, isMovie: true, in: playlist)?.index, 4)
        XCTAssertEqual(TitleMatcher.bestMatch(title: "F1", year: 2025, isMovie: true, in: playlist)?.index, 5)
    }

    func testRejectsMissingOrWrongYear() {
        XCTAssertNil(TitleMatcher.bestMatch(title: "Toy Story 5", year: 2026, isMovie: true, in: playlist))
        // Gleicher Titel, aber ein anderer Film (Jahr weicht ab)
        XCTAssertNil(TitleMatcher.bestMatch(title: "Ted", year: 2024, isMovie: true, in: playlist))
    }

    func testDice() {
        XCTAssertEqual(TitleMatcher.dice("abc", "abc"), 1, accuracy: 0.0001)
        XCTAssertEqual(TitleMatcher.dice("", "abc"), 0)
    }
}
