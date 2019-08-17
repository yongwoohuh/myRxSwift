//
//  ViewController.swift
//  my rxSwift
//
//  Created by Yongwoo Huh on 2019-08-17.
//  Copyright © 2019 Yongwoo. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    enum FileReadError: Error {
        case fileNotFound, unredable, encodingFailed
    }
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
//        let one = 1
//        let two = 2
//        let three = 3
//
//        let observable = Observable.of(one, two, three)
//
//        observable.subscribe(onNext: { element in
//            print(element)
//        })
        
        // example of "empty"
//        print("--- Example of empty ---" )
//        let observable = Observable<Void>.empty()
//
//        observable.subscribe(
//
//            onNext: {element in
//                print(element)
//        },
//            onCompleted: {
//                print("Completed")
//        })
        
//        print("--- Example of never ---" )
//        let observable = Observable<Any>.never()
//
//        observable.subscribe(
//            onNext: { element in
//                print(element)
//        },
//            onCompleted: {
//                print("Completed")
//        }
//    )
        
//     print("--- Example of range ---" )
//    let observable = Observable<Int>.range(start: 1, count: 10)
//
//        observable
//            .subscribe(onNext: { i in
//                let n = Double(i)
//                let fibonacci = Int( ((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded() )
//                print(fibonacci)
//            })
        
//        print("--- Example of dispose ---" )
//        let observable = Observable.of("A", "B", "C")
//            .subscribe {
//                print($0)
//        }
//        .disposed(by: disposeBag)
        
//        print("--- Example of create ---" )
//        Observable<String>.create { observer in
//
//            observer.onNext("1")
////            observer.onError(ViewController.MyError.anError)
//
////            observer.onCompleted()
//
//            observer.onNext("?")
//
//            return Disposables.create()
//        }
//        .subscribe(
//            onNext: { print($0) },
//            onError: { print($0) },
//            onCompleted: { print( "Compledted") },
//            onDisposed: { print("Disposed") }
//        )
//        .disposed(by: disposeBag)
        
        
//        print("--- Example of: deferred ---" )
//        var flip = false
//        let factory: Observable<Int> = Observable.deferred {
//            flip.toggle()
//
//            if flip {
//                return Observable.of(1, 2, 3, 7, 8, 9)
//            } else {
//                return Observable.of(4, 5, 6)
//            }
//        }
//
//        for _ in 0...3 {
//            factory.subscribe(onNext: {
//                print($0, terminator: "")
//            })
//            .disposed(by: disposeBag)
//
//            print()
//        }
        
//        print("--- Example of: Single ---" )
//        loadText(from: "Copyright")
//            .subscribe {
//                switch $0 {
//                case .success(let string):
//                    print(string)
//                case .error(let error):
//                    print(error)
//                }
//        }
//        .disposed(by: disposeBag)
        
        // Challenge 1
        print("--- Challenge 1 ---" )
        let observable = Observable<Any>.never()
        
        observable
           .debug("chapter 2")
            .do(onDispose: {
                print("do onDispose")
            })
            .subscribe(
                onNext: { element in
                    print(element)
            },
                onCompleted: {
                    print("Completed")
            },
                onDisposed: {
                    print("Disposed")
            }
        )
        .disposed(by: disposeBag)
        
        
    } // end of viewDidLoad
    
    func loadText(from name: String) -> Single<String> {
        
        return Single.create { single in
            let disposable = Disposables.create()
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unredable))
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            single(.success(contents))
            return disposable
        }
    }


}


