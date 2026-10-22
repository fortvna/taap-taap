import XCTest

@MainActor
final class ArcadeUITests: XCTestCase {
    func testThemesGameplayAndPause() throws {
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
            name.typeText("Arcade tester")
            app.buttons["player.create"].tap()
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
            capture("\(theme)-landscape", app: app)
            app.buttons["game.pause"].tap()
            app.buttons["game.leave"].tap()
            XCUIDevice.shared.orientation = .portrait
        }
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication, down: Bool = false) {
        for _ in 0..<8 {
            if element.isHittable { return }
            if down { app.swipeDown() } else { app.swipeUp() }
        }
        XCTAssertTrue(element.isHittable)
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
