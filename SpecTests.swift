import UIKit
import XCTest

class SpecTests: XCTestCase {

    var vc: ViewController!

    override func setUp() {
        super.setUp()
        let board = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        vc = board.instantiateInitialViewController() as ViewController
        // trigger the view to load by accessing the view property ...
        vc.view.subviews
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testGameControls() {
        XCTAssert(vc.stepper.isMemberOfClass(UIStepper.self), "The stepper property should be an UIStepper")
        XCTAssertEqual(vc.stepper.value, 4, "the stepper should default to 4")
        XCTAssertEqual(vc.stepper.maximumValue, 10, "the stepper's max value is 10")
        XCTAssertEqual(vc.stepper.minimumValue, 1, "the stepper's min value is 1")
        XCTAssertEqual(vc.stepper.stepValue, 1, "teh stepper changes value by 1")
        XCTAssert(vc.revealButton.isMemberOfClass(UIButton.self), "The revealButton property should be an UIButton")
        XCTAssert(vc.shuffleButton.isMemberOfClass(UIButton.self), "The shuffleButton property should be an UIButton")
    }
    
}
