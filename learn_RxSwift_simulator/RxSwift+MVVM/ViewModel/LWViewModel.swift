//
//  LWViewModel.swift
//  learn_RxSwift_simulator
//
//  Created by yy on 2021/8/5.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class LWViewModel{
    var usernameValid:Observable<Bool>
    var passwordValid:Observable<Bool>
    var allValid:Observable<Bool>
    
    init(
        // 输入
            username: Observable<String>,
            password: Observable<String>,
        // 服务
            validationService: LWValidationServiceProtocol
    ){
        usernameValid = username
            .flatMap({ name in
                return validationService.validateUsername(name)
            })
        
        passwordValid = password
            .flatMap({ psd in
                return validationService.validatePassword(psd)
            })

        allValid = Observable.combineLatest(usernameValid,passwordValid){
            return $0 && $1
        }
    }
}
