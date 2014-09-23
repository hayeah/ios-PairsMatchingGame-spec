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

    func testPairsCount() {
        vc.stepper.value = 3
        XCTAssertEqual(vc.pairsCount, 3, "pairsCount should be equal to stepper value")
        vc.stepper.value = 6
        XCTAssertEqual(vc.pairsCount, 6, "pairsCount should be equal to stepper value")

        XCTAssertEqual(vc.cardsCount, vc.pairsCount * 2, "cardsCount should be 2x of pairsCount")
    }

    func testGameGrid() {
        vc.stepper.value = 10
        vc.stepper.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        XCTAssertEqual(vc.cardViews.count, 20, "There should")
        for cardView in vc.cardViews {
            XCTAssertEqual(cardView.superview!, vc.view, "Should add cardView to the view hierarchy")
            XCTAssert(cardView.isMemberOfClass(CardView.self), "CardView should be instances of CardView")
        }
    }

    func testVariableLayout() {
        func testLayout(pairs: Int) {
            vc.stepper.value = Double(pairs)
            vc.stepper.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            XCTAssertEqual(vc.cardViews.count, vc.cardsCount, "cardViews count should be \(vc.cardsCount)")
            XCTAssertEqual(vc.cardViews.count, findCardViews().count, "cardViews is not in sync with view hierarchy")

        }

        testLayout(4)
        // Test increase in cards count
        testLayout(8)
        // Test decrease in cards count
        testLayout(2)
    }

    func testCardViewWithBorderAndPadding() {
        for cardView in findCardViews() {
            XCTAssertEqual(cardView.frontLayer.superlayer, cardView.layer, "frontLayer should be a sublayer of the view's layer")
            XCTAssertEqual(cardView.layer.borderWidth, 1, "The view layer should draw a border")

            cardView.layoutSubviews()
            XCTAssertEqual(cardView.frontLayer.frame, CGRectInset(cardView.layer.bounds, 2, 2) , "The frontLayer should be insetted 2 points")
        }
    }

    func testRevealCards() {
        for cardView in findCardViews() {
            XCTAssertFalse(cardView.selected, "cardView should initially be unselected.")
            XCTAssertTrue(cardView.frontLayer.hidden,"should initially hide the front of the card.")
            XCTAssertFalse(cardView.backLayer.hidden,"should initially show the back of the card.")
            // tap it
            cardView.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            XCTAssertTrue(cardView.selected, "cardView should be selected after tap.")
            XCTAssertFalse(cardView.frontLayer.hidden,"should show the front of the card if selected.")
            XCTAssertTrue(cardView.backLayer.hidden,"should hide the back of the card if selected.")
        }
    }

    func testRevealAllButton() {
        vc.revealButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        for cardView in findCardViews() {
            XCTAssertTrue(cardView.selected,"Reveal button should select all cardViews")
        }
    }

    // return the card views actually in root view
    private func findCardViews() -> [CardView] {
        var cardViews = [CardView]()
        for view in vc.view.subviews {
            if let cardView = view as? CardView {
                cardViews.append(cardView)
            }
        }
        return cardViews
    }
    
}
