//
//  ViewController.swift
//  chapter_03
//
//  Created by Yongwoo Huh on 2019-08-17.
//  Copyright © 2019 Yongwoo. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

fileprivate func myPrint<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, (event.element ?? event.error) ?? event)
}

class ViewController: UIViewController {
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        example_PublishSubject()
//        example_BehaviorSubject()
//        example_ReplaySubject()
//        example_PublishRelay()
//        example_BehaviorRelay()
//        challenge_01()
        challenge_02()
    }
    


    func example_PublishSubject() {
        print("--- example of: PublishSubject ---")
        let subject = PublishSubject<String>()
        // subject에 listening하는 사람이 없어 출력되는게 없다.
        subject.onNext("Is anyone listening?")
        
        let subscriptionOne = subject
            .debug("subscriptionOne")
            .subscribe(onNext: { string in
                print(string)
            })
        
        subject.on(.next("1"))
        subject.onNext("2")
        
        let subscriptionTwo = subject
        .debug("subscriptionTwo")
            .subscribe { event in
                print("2)", event.element ?? event)
        }
        
        subject.onNext("3")
        subscriptionOne.dispose()
        subject.onNext("4")
        subject.onCompleted()
        subject.onNext("5")
        subscriptionTwo.dispose()
        
        subject
            .subscribe {
                print("3", $0.element ?? $0)
        }
        .disposed(by: disposeBag)
        
        subject.onNext("?")
    }
    
    func example_BehaviorSubject() {
        print("--- example of: BehaviorSubject ---")
        
        let subject = BehaviorSubject(value: "Initial value")
        
        subject.onNext("X")
        
        subject
            .subscribe {
                myPrint(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
        
        subject.onError(MyError.anError)
        
        subject
            .subscribe {
                myPrint(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
    }
    
    func example_ReplaySubject() {
        print("--- example of: ReplaySubject ---")
        
        let subject = ReplaySubject<String>.create(bufferSize: 2)
        
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        
        subject
            .subscribe {
                myPrint(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
        
        print()
        
        subject
            .subscribe {
                myPrint(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
        
        subject.onNext("4")
        subject.onError(MyError.anError)
        // 3)에서는 오류 발생
//        subject.dispose()
        
        print()
        
        subject
            .subscribe {
                myPrint(label: "3)", event: $0)
        }
        .disposed(by: disposeBag)
    }
    
    func example_PublishRelay() {
        print("--- example of: PublishRelay ---")
        
        let relay = PublishRelay<String>()
        
        relay.accept("Knock knowk, anyone home?")
        
        relay
            .subscribe(onNext: {
                print($0)
            })
        .disposed(by: disposeBag)
        
        relay.accept("1")
        
        // PublishRelay는 .error .completed을 추가할 수 없다 컴파일 오류
//        relay.accept(MyError.anError)
//        relay.onCompleted()
    }
    
    func example_BehaviorRelay() {
        print("--- example of: BehaviorRelay ---")
        
        let relay = BehaviorRelay(value: "Initial value")
        
        relay.accept("New initial value")
        
        relay
            .subscribe {
                myPrint(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)
        
        relay.accept("1")
        
        relay
            .subscribe {
                myPrint(label: "2)", event: $0)
        }
        .disposed(by: disposeBag)
        
        relay.accept("2")
        
        print(relay.value)
    }
    
    func challenge_01() {
        print("--- example of: PublishSubject ---")
        
        let dealtHand = PublishSubject<[(String, Int)]>()
        
        func deal(_ cardCount: UInt) {
            var deck = cards
            var cardsRemaining = deck.count
            var hand = [(String, Int)]()
            
            for _ in 0..<cardCount {
                let randomIndex = Int.random(in: 0..<cardsRemaining)
                hand.append(deck[randomIndex])
                deck.remove(at: randomIndex)
                cardsRemaining -= 1
            }
            
            // Add code to update dealtHand here
            let handPoints = points(for: hand)
            if handPoints > 21 {
                dealtHand.onError(HandError.busted(points: handPoints))
            } else {
                dealtHand.onNext(hand)
            }
        }
        
        // Add subscription to dealtHand here
        dealtHand
            .subscribe(
                onNext: {
                    print(cardString(for: $0), "for", points(for: $0), "points")
            },
                onError: {
                    print(String(describing: $0).capitalized)
            })
            .disposed(by: disposeBag)
        
        
        deal(3)
    }
    
    func challenge_02() {
        enum UserSession {
            case loggedIn, loggedOut
        }
        
        enum LoginError: Error {
            case invalidCredentials
        }
        
        // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
        let userSession = BehaviorRelay<UserSession>(value: .loggedOut)
        
        // Subscribe to receive next events from userSession
        userSession
            .subscribe(onNext: {
                print("userSession changed:", $0)
            })
        .disposed(by: disposeBag)
        
        func logInWith(username: String, password: String, completion: (Error?) -> Void) {
            guard username == "johnny@appleseed.com",
                password == "appleseed" else {
                    completion(LoginError.invalidCredentials)
                    return
            }
            
            // Update userSession
            userSession.accept(.loggedIn)
        }
        
        func logOut() {
            // Update userSession
            userSession.accept(.loggedOut)
        }
        
        func performActionRequiringLoggedInUser(_ action: () -> Void) {
            // Ensure that userSession is loggedIn and then execute action()
            guard userSession.value == .loggedIn else {
                print("You can't do that!")
                return
            }
            
            action()
        }
        
        for i in 1...2 {
            let password = i % 2 == 0 ? "appleseed" : "password"
            
            logInWith(username: "johnny@appleseed.com", password: password) { error in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                print("User logged in.")
            }
            
            performActionRequiringLoggedInUser {
                print("Successfully did something only a logged in user can do.")
            }
        }
    }
}

