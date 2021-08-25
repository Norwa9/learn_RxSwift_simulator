//
//  RxImagePickerDelegateProxy.swift
//  learn_RxSwift_simulator
//
//  Created by yy on 2021/8/5.
//

import RxSwift
import RxCocoa
import UIKit

open class RxImagePickerDelegateProxy
    : RxNavigationControllerDelegateProxy, UIImagePickerControllerDelegate {

    public init(imagePicker: UIImagePickerController) {
        super.init(navigationController: imagePicker)
    }

}
