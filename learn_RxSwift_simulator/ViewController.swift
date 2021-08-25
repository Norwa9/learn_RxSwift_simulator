//
//  ViewController.swift
//  learn_RxSwift_simulator
//
//  Created by yy on 2021/8/3.
//

import UIKit
import RxCocoa
import RxSwift
//import RxDataSources

class ViewController: UIViewController {
    var disposeBag = DisposeBag()
    @IBOutlet weak var nameTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    @IBOutlet weak var enterBtn:UIButton!
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var tableView:UITableView!
    
    
    ///demo：登录
    func login(){
        let usernameValid = nameTextField.rx.text.orEmpty
                // 用户名 -> 用户名是否有效
                .map { $0.count >= 6 }
                .share(replay: 1)
        
        let passwordValid = passwordTextField.rx.text.orEmpty
            .map { $0.count >= 6 }
            .share(replay: 1)
        
        let allValid = Observable.combineLatest(
            usernameValid,
            passwordValid
        ){$0 && $1}
        .share(replay: 1)
        
        
        let observer: Binder<Bool> = Binder(self.view) { (view, valid) in
            view.backgroundColor = valid ? .blue.withAlphaComponent(0.1) : .white
        }

        usernameValid.bind(to: observer)
        allValid.bind(to: enterBtn.rx.isEnabled)
        
        
        let username = nameTextField.rx.text.orEmpty.asObservable()
        let password = passwordTextField.rx.text.orEmpty.asObservable()
        let combinedText = Observable.combineLatest(username,password)
            .map { (s1, s2) in
                s1 + s2
            }
        
        let enterBtnObserver:AnyObserver<Void> = AnyObserver{ (event) in
            switch event{
            case .next():
                //combinedText.subscribe(){print($0)}
                print("获取到点击事件")
            case .error(let error):
                print("发生错误:\(error)")
            case .completed:
                print("完成")
            default:
                break
            }
        }
        
        enterBtn.rx.tap
            .subscribe { [weak self] in
                //combinedText.subscribe(){print($0)}
                print("获取到点击事件")
            } onError: { error in
                print("发生错误:\(error)")
            } onCompleted: {
                print("完成")
            } onDisposed: {

            }
        enterBtn.rx.tap.subscribe(enterBtnObserver)
        
        
    }

    func createSeq(){
        let numbers: Observable<Int> = Observable.create { observer -> Disposable in

            observer.onNext(0)
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onNext(4)
            observer.onNext(5)
            observer.onNext(6)
            observer.onNext(7)
            observer.onNext(8)
            observer.onNext(9)
            observer.onCompleted()

            return Disposables.create()
        }
        
        let observer = passwordTextField.rx.text
        numbers.map { value in
            return String(value)
        }.bind(to: observer)
    }
    
    var disposable:Disposable?
    func disposable_demo(){
        self.disposable = nameTextField.rx.text.orEmpty
            .subscribe(onNext: { text in
                print(text)
            }, onError: { _ in
                
            }, onCompleted: {
                
            }, onDisposed: {
                print("释放了")
            })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.disposable?.dispose()
        }
    }
    
    func retry_test(){
        //1.创建序列
        var a = 0
        let testSeq = Observable<Int>.create { observer in
            if a < 3{
                let error = NSError(domain: "RxSwift", code: 0, userInfo: nil)
                a += 1
                observer.onError(error)
            }else{
                observer.onNext(a)
            }
            return Disposables.create()
        }
        
        //2.有条件地重试
        let maxRetryCount = 3//最大重复次数
        let retryDelay = RxTimeInterval.seconds(1)//重试延时
        testSeq.retry { (rxError: Observable<Error>) in
            rxError.enumerated().flatMap { (index: Int, element: Error) -> Observable<Int> in
                guard index < maxRetryCount else {
                    let error = NSError(domain: "retry", code: 0, userInfo: nil)
                    return Observable.error(error)
                }
                return Observable<Int>.timer(retryDelay, scheduler: MainScheduler.instance)
            }
        }.subscribe { x in
            print(x)
        } onError: { error in
            print(error)
        } onCompleted: {

        } onDisposed: {

        }
    }
    
    func catchError_test(){
        //1.创建序列
        var a = 0
        let testSeq = Observable<Int>.create { observer in
            if a < 3{
                let error = NSError(domain: "RxSwift", code: 0, userInfo: nil)
                a += 1
                observer.onError(error)
            }else{
                observer.onNext(a)
            }
            return Disposables.create()
        }
        
        
        let replacementValue:Int = -1//1个替换元素
        let replacementValueArr:Observable<Int> = Observable.create { observer in
            observer.onNext(-1)
            observer.onNext(-2)
            observer.onNext(-3)
            observer.onCompleted()
            return Disposables.create()
        }
        testSeq
            .catch({ _ -> Observable<Int> in
                return replacementValueArr
            })
            .subscribe { value in
                print(value)
            } onError: { error in
                
            } onCompleted: {
                
            } onDisposed: {
                
            }
    }
    
    func Result_test(){
        enterBtn.rx.tap
            .flatMapLatest { _ -> Observable<Result<Void, Error>> in
                let randSeq = Observable<Result<Void,Error>>.create { o in
                    let rand = Int.random(in: 0...1)
                    if rand == 0{
                        o.onNext(.success({}()))
                        o.onCompleted()
                    }else{
                        let error = NSError(domain: "rand", code: 0, userInfo: nil)
                        o.onError(error)
                        o.onCompleted()
                    }
                    return Disposables.create()
                }
                return randSeq
                    .catch { error -> Observable<Result> in
                        return Observable.just(Result.failure(error))
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
                switch result {           // 处理 Result
                case .success:
                    print("用户信息更新成功")
                case .failure(let error):
                    print("用户信息更新失败： \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    func albumTap_test(){
        //注册代理（不知道为啥非要这么做）
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
        
        enterBtn.rx.tap
            .flatMapLatest { [weak self] _  in
                return UIImagePickerController.rx.createWithParent(self){ picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                    picker.delegate = self
                }.flatMap { picker in
                    picker.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
            }
            .map { info in
                if let image = info[.originalImage] as? UIImage{
                    print("image")
                    return image
                }else{
                    print("nil")
                    return UIImage()
                }
                
            }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    func RxSwift_MVVM(){
        var viewModel:LWViewModel = LWViewModel(
            username: nameTextField.rx.text.orEmpty.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            validationService: LWValidationService()
        )
        
        viewModel.allValid.bind(to: enterBtn.rx.isEnabled)
    }
    
    func PublishSubject_test(){
        let disposeBag = DisposeBag()
        
        let subject = PublishSubject<String>()

        subject
          .subscribe { print("Subscription: 1 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🐶")
        subject.onNext("🐱")

        subject
          .subscribe { print("Subscription: 2 Event:", $0) }
          .disposed(by: disposeBag)

        subject.onNext("🅰️")
        subject.onNext("🅱️")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //login()
        //createSeq()
        //disposable_demo()
        //retry_test()
        //catchError_test()
        //Result_test()
        //albumTap_test()
        //RxSwift_MVVM()
        //PublishSubject_test()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let whatNewVC = WhatsNewHelper.getWhatsNewViewController()
        if let vc = whatNewVC{
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
}

