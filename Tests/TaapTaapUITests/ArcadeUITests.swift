import XCTest

@MainActor
final class ArcadeUITests: XCTestCase {
    func testThemesGameplayAndPause() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        for theme in ["studio", "sakura", "cyber"] {
            reveal(app.buttons["theme.\(theme)"], in: app, down: true)
            app.buttons["theme.\(theme)"].tap()
            capture("\(theme)-home", app: app)
            reveal(app.buttons["player.add"], in: app)
            app.buttons["player.add"].tap()
            let name = app.textFields["player.name"]
            XCTAssertTrue(name.waitForExistence(timeout: 5))
            name.tap()
            name.typeText("Arcade tester\n")
            reveal(app.buttons["mode.zen"], in: app)
            app.buttons["mode.zen"].tap()
            reveal(app.buttons["game.start"], in: app)
            app.buttons["game.start"].tap()
            XCTAssertTrue(app.buttons["game.pause"].waitForExistence(timeout: 5))
            let target = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "bright target")).firstMatch
            XCTAssertTrue(target.waitForExistence(timeout: 3))
            target.tap()
            capture("\(theme)-game", app: app)
            app.buttons["game.pause"].tap()
            XCTAssertTrue(app.buttons["game.resume"].waitForExistence(timeout: 3))
            capture("\(theme)-pause", app: app)
            app.buttons["game.resume"].tap()
            XCTAssertTrue(app.buttons["game.pause"].waitForExistence(timeout: 3))
            XCUIDevice.shared.orientation = .landscapeLeft
            waitForOrientation(landscape: true, app: app)
            // Synchronize through real interactions after the system rotation.
            app.buttons["game.pause"].tap()
            app.buttons["game.resume"].tap()
            capture("\(theme)-landscape", app: app)
            app.buttons["game.pause"].tap()
            app.buttons["game.leave"].tap()
            XCUIDevice.shared.orientation = .portrait
            waitForOrientation(landscape: false, app: app)
        }
    }

    private func waitForOrientation(landscape: Bool, app: XCUIApplication) {
        let settled = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            let frame = app.frame
            return landscape ? frame.width > frame.height : frame.height > frame.width
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [settled], timeout: 10), .completed)
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication, down: Bool = false) {
        for _ in 0..<8 {
            if element.isHittable { return }
            if down { app.swipeDown() } else { app.swipeUp() }
        }
        XCTAssertTrue(element.isHittable)
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
