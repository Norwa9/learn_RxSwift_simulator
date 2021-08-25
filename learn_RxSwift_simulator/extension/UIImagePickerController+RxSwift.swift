//
//  UIImagePickerController+RxSwift.swift
//  learn_RxSwift_simulator
//
//  Created by yy on 2021/8/5.
//

import Foundation
import RxSwift
import RxCocoa

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }

        return
    }

    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

#if os(iOS)
    
    import RxSwift
    import RxCocoa
    import UIKit

    extension Reactive where Base: UIImagePickerController {

        /**
         Reactive wrapper for `delegate` message.
         */
        public var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey : AnyObject]> {
            return delegate
                .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
                .map({ (a) in
                    return try castOrThrow(Dictionary<UIImagePickerController.InfoKey, AnyObject>.self, a[1])
                })
        }

        /**
         Reactive wrapper for `delegate` message.
         */
        public var didCancel: Observable<()> {
            return delegate
                .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
                .map {_ in () }
        }
        
    }
    
#endif


extension Reactive where Base:UIImagePickerController{
    ///创建UIImagePickerController实例序列
    ///- parameter parent:添加到的父视图控制器
    ///- parameter animated:是否使用动画
    ///- parameter configureImagePicker:闭包，用来对创建出来的picker实例对象进行一些配置
    static func createWithParent(_ parent:UIViewController?,animated:Bool = true,configureImagePicker: @escaping (UIImagePickerController) throws -> Void = { x in }) -> Observable<UIImagePickerController>{
        return Observable.create { [weak parent] observer in
            let imagePicker = UIImagePickerController()
            let dismissDisposable = imagePicker.rx
                .didCancel
                .subscribe { [weak imagePicker] _ in
                    guard let imagePicker = imagePicker else{
                        return
                    }
                    dismissViewController(imagePicker, animated: true)
                } onError: { _ in
                    print("dismiss发生错误")
                } onCompleted: {
                    print("dismiss完成")
                } onDisposed: {
                    print("dismiss回收")
                }
            
            do{
                try configureImagePicker(imagePicker)
            }
            catch let error{
                observer.onError(error)
                return Disposables.create()
            }
            
            guard let parent = parent else{
                observer.on(.completed)
                return Disposables.create()
            }
            
            parent.present(imagePicker, animated: animated, completion: nil)
            observer.on(.next(imagePicker))
            
            return Disposables.create(dismissDisposable,Disposables.create {
                dismissViewController(imagePicker, animated: animated)
            })
                
        }
    }
}
