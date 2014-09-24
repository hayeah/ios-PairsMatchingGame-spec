import UIKit
import XCTest

class SpecTests: XCTestCase {

    var vc: ViewController!

    override func setUp() {
        super.setUp()
        let board = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        vc = board.instantiateInitialViewController() as ViewController
        // trigger the view to load by accessing the view property ...
        UIApplication.sharedApplication().keyWindow.rootViewController = vc
        // vc.view.subviews
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

    func testAssignRandomCards() {
        for cardView in findCardViews() {
            XCTAssertNotNil(cardView.card, "Should assign a card to cardView")

            // try to find another random card
            var anotherCard: Card = cardView.card!
            while anotherCard == cardView.card! {
                anotherCard = Card.random()
            }

            let oldImage = cardView.frontLayer.contents as CGImageRef
            cardView.card = anotherCard
            let newImage = cardView.frontLayer.contents as CGImageRef
            XCTAssert(oldImage !== newImage, "Changing the card should change the frontLayer's contents")
        }
    }

    func testAssignRandomPairs() {
        matchPairs()
    }

    func testShuffleCards() {
        let card = Card(rank: .Ace, suit: .Spade)
        // Put the cards in an invalid state. We will expect shuffle to put it back to a valid state.
        eachCardViews { $0.card = card }
        vc.shuffleButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        matchPairs()
        // Don't want to slow things down by doing async testing...
//        let expect = expectationWithDescription("Will hide cards")
//        delay(1.2) {
//            self.eachCardViews {
//                XCTAssertFalse($0.selected, "Should hide cardView after shuffle.")
//                println("assert not selected")
//            }
//            expect.fulfill()
//        }
//        self.waitForExpectationsWithTimeout(2, nil)
    }

    func testShuffleWhenLayoutChanged() {
        let card = Card(rank: .Ace, suit: .Spade)
        eachCardViews { $0.card = card }
        setPairs(10)
        matchPairs()
    }

    private func matchPairs() {
        var matches = [String:Int]()

        for cardView in findCardViews() {
            let key = cardView.card!.imageName()
            if let n = matches[key] {
                matches[key] = n + 1
            } else {
                matches[key] = 1
            }
        }

        XCTAssertEqual(matches.count, vc.pairsCount, "Should find \(vc.pairsCount) different kinds, but found: \(matches.count).")

        for (k,v) in matches {
            XCTAssertEqual(v, 2, "Should find two of \(k) but found: \(v)")
        }
    }

    private func assignKnownCards(cardViews: [CardView]) {
        var deck = Card.fullDeck()
        var cards = [Card]()
        for i in 0..<vc.pairsCount {
            let card = deck[i]
            cards.append(card)
            cards.append(card)
        }

        for (i,cardView) in enumerate(cardViews) {
            cardView.card = cards[i]
        }
    }

    private func tap(view: UIControl) {
        view.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }

    func testMatchSelectedPairs() {
        setPairs(2)
        let cardViews = findCardViews()
        assignKnownCards(cardViews)

        func tapCard(index: Int) {
            tap(cardViews[index])
        }

        XCTAssertEqual(vc.matchedPairs, 0, "Should have 0 matched pairs initially")

        // 1. Select the same card many times should keep it selected.
        tapCard(0)
        XCTAssertTrue(cardViews[0].selected, "Tap a card once should select it")
        tapCard(0)
        XCTAssertTrue(cardViews[0].selected, "Tap a card twice should keep it selected")
        XCTAssertEqual(vc.matchedPairs, 0, "Select the same card shouldn't be a match")

        // 2. Should match a pair.
        tapCard(1)
        XCTAssertEqual(vc.matchedPairs, 1, "Selecting matching cards should increment matchedPairs")
        XCTAssertTrue(cardViews[0].selected, "Card should be kept selected after match")
        XCTAssertTrue(cardViews[1].selected, "Card should be kept selected after match")

        tapCard(2)
        tapCard(3)
        XCTAssertEqual(vc.matchedPairs, 2, "Selecting matching cards should increment matchedPairs")



    }

    func testResetScoreAfterShuffle() {
        setPairs(2)
        let cardViews = findCardViews()
        assignKnownCards(cardViews)

        func tapCard(index: Int) {
            tap(cardViews[index])
        }

        tapCard(0)
        tapCard(1)
        XCTAssertEqual(vc.matchedPairs, 1, "Should have 1 matching pair.")
        vc.shuffleCards()
        XCTAssertEqual(vc.matchedPairs, 0, "Should reset matchedPairs after shuffle.")

    }

    func testWinGame() {
        setPairs(2)
        let cardViews = findCardViews()
        assignKnownCards(cardViews)

        func tapCard(index: Int) {
            tap(cardViews[index])
        }

        tapCard(0);tapCard(1)
        tapCard(2);tapCard(3)

        // Show alert controller
        XCTAssertNotNil(vc.presentedViewController, "Should present the alert controller after winning game")
        if let alert = vc.presentedViewController {
            XCTAssert(alert.isMemberOfClass(UIAlertController.self), "Should present the alert controller after winning game.")
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

    private func setPairs(pairs: Int) {
        vc.stepper.value = Double(pairs)
        vc.stepper.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        vc.hideCards() // immediately hide cards
    }

    private func eachCardViews(block: (CardView) -> ()) {
        for cardView in findCardViews() {
            block(cardView)
        }
    }
    
}
