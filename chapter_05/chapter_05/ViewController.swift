//
//  ViewController.swift
//  chapter_05
//
//  Created by Yongwoo Huh on 2019-08-25.
//  Copyright © 2019 Yongwoo. All rights reserved.
//

import UIKit
import RxSwift
//import RxRelay

class ViewController: UIViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        rxIgnoreElements()
//        rxElementAt()
//        rxFilter()
//        rxSkip()
//        rxSkipWhile()
//        rxSkipUntil()
//        rxTake()
//        rxTakeWhile()
//        rxTakeUntil()
//        rxDistinctUntilChanged()
//        rxDistinctUntilChangedCustomCompare()
        challenge01()
        
    }
    
    func rxIgnoreElements() {
        print("--- example of ignoreElements ---")
        
        let strikes = PublishSubject<String>()
        
        strikes
        .ignoreElements()
            .subscribe { _ in
                print("You're out!")
        }
        .disposed(by: disposeBag)
        
        strikes.onNext("X")
        strikes.onNext("X")
        strikes.onNext("X")
        
        strikes.onCompleted()
    }
    
    func rxElementAt() {
        print("--- example of: elementAt ---")
        
        let strikes = PublishSubject<String>()
        
        strikes
        .elementAt(2)
            .subscribe(onNext: { _ in
                print("You're out!")
            })
        .disposed(by: disposeBag)
        
        strikes.onNext("X")
        strikes.onNext("X")
        strikes.onNext("X")
    }
    
    func rxFilter() {
        print("--- example of: filter ---")
        
        Observable.of(1, 2, 3, 4, 5, 6)
            .filter { $0.isMultiple(of: 2) }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func rxSkip() {
        print("--- example of: skip ---")
        
        Observable.of("A", "B", "C", "D", "E", "F")
        .skip(4)
        .subscribe(onNext: {
                print($0)
        })
        .disposed(by: disposeBag)
    }
    
    func rxSkipWhile() {
        print("--- example of: skipWhile ---")
        
        Observable.of(2, 2, 3, 4, 4)
            .skipWhile { $0.isMultiple(of: 2) }
            .subscribe(onNext: {
                print($0)
            })
        .disposed(by: disposeBag)
    }
    
    func rxSkipUntil() {
        print("--- example of: skipUntil ---")
        
        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>()
        
        subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
        
        subject.onNext("A")
        subject.onNext("B")
        
        trigger.onNext("X")
        subject.onNext("C")
    }
    
    func rxTake() {
        print("--- example of: take ---")
        
        Observable.of(1, 2, 3, 4, 5, 6)
            .take(3)
            .subscribe(onNext: {
                print($0)
            })
        .disposed(by: disposeBag)
    }
    
    func rxTakeWhile() {
        print("--- example of: takeWhile ---")
        
        Observable.of(2, 2, 4, 4, 6, 6)
            .enumerated()
            .takeWhile { index, integer in
                integer.isMultiple(of: 2) && index < 3
            }
            .map { $0.element }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func rxTakeUntil() {
        print("--- example of: takeUntil ---")
        
        let subject = PublishSubject<String>()
        let trigger = PublishSubject<String>()
        
        subject
        .takeUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
        
        subject.onNext("1")
        subject.onNext("2")
        
        trigger.onNext("X")
        subject.onNext("3")
    }
    
    func rxDistinctUntilChanged() {
        print("--- example of: distinctUntilChanged ---")
        
        Observable.of("A", "A", "B", "B", "A", "A", "A")
            .distinctUntilChanged()
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func rxDistinctUntilChangedCustomCompare() {
        print("--- example of: distinctUntilChanged(_:) ---")
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        
        Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
            .distinctUntilChanged { a, b -> Bool in
                guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
                let bWords = formatter.string(from: b)?.components(separatedBy: " ")
                    else {
                        return false
                }
                var containsMatch = false
                
                for aWord in aWords where bWords.contains(aWord) {
                    containsMatch = true
                    break
                }
                
                return containsMatch
            }
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func challenge01() {
        print("--- example of: Challenge 1 ---")
        
        let contacts = [
            "603-555-1212": "Florent",
            "212-555-1212": "Junior",
            "408-555-1212": "Marin",
            "617-555-1212": "Scott"
        ]
        
        let input = PublishSubject<Int>()
        
        // Add your code here
        input
            .skipWhile { $0 == 0}
            .filter { $0 < 10 }
            .take(10)
            .toArray()
            .subscribe(
                onSuccess: { [weak self] single in
                    guard let self = self else { return }
                    let phone = self.phoneNumber(from: single)
                    
                    if let contact = contacts[phone] {
                        print("Dialing \(contact) (\(phone))...")
                    } else {
                        print("Contact not found")
                    }
            },
                onError: { error in
                    print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        
        input.onNext(0)
        input.onNext(603)
        
        input.onNext(2)
        input.onNext(1)
        
        // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
        input.onNext(2)
        
        "5551212".forEach {
            if let number = (Int("\($0)")) {
                input.onNext(number)
            }
        }
        
        input.onNext(9)
    }
    // challenge 1 helper function
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }

}
