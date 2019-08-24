/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RxSwift
import RxRelay

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!
  
  private let bag = DisposeBag()
  private let images = BehaviorRelay<[UIImage]>(value: [])

  override func viewDidLoad() {
    super.viewDidLoad()
    
    images
      .subscribe(onNext: { [weak imagePreview] photos in
        guard let preview = imagePreview else { return }
        
        preview.image = photos.collage(size: preview.frame.size)
      })
    .disposed(by: bag)
    
    images.asObservable()
      .subscribe(onNext: { [weak self] photos in
        self?.updateUI(photos: photos)
        
      })
      .disposed(by: bag)

  }
  
  @IBAction func actionClear() {
    images.accept([])
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }
    
    PhotoWriter.save(image)
    .subscribe(
      onSuccess: { [weak self] id in
        self?.showMessage("Saved")
        self?.actionClear()
    },
      onError: { [weak self] error in
        self?.showMessage("Error", description: error.localizedDescription)
      }
    )
    .disposed(by: bag)
  }

  @IBAction func actionAdd() {
//    let newImage = images.value + [UIImage(named: "IMG_1907.jpg")!]
    let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
    
    photosViewController.selectedPhotos
    .subscribe(
      onNext: { [weak self] newImage in
        guard let images = self?.images else { return }
        images.accept(images.value + [newImage])
    },
      onDisposed: {
        print("completed photo selection")
    })
    .disposed(by: bag)
    
    navigationController!.pushViewController(photosViewController, animated: true)
    
  }

  func showMessage(_ title: String, description: String? = nil) {
    presentAlert(title: title, message: description)
    .subscribe()
    .disposed(by: bag)
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count.isMultiple(of: 2)
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
}


extension UIViewController {
  func presentAlert(title: String, message: String?) -> Completable {
    return Completable.create { [weak self] completable in
      let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
        completable(.completed)
      }))
      self?.present(alertVC, animated: true, completion: nil)
      return Disposables.create {
        self?.dismiss(animated: true, completion: nil)
      }
    }
  }
}
