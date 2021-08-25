//
//  LWValidationService.swift
//  learn_RxSwift_simulator
//
//  Created by yy on 2021/8/5.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

// 输入验证服务
protocol LWValidationServiceProtocol {
    func validateUsername(_ username: String) -> Observable<Bool>
    func validatePassword(_ password: String) -> Observable<Bool>
}

class LWValidationService:LWValidationServiceProtocol {
    func validateUsername(_ username: String) -> Observable<Bool> {
        if username.count > 6{
            return Observable.just(true)
        }else{
            return Observable.just(false)
        }
    }
    
    func validatePassword(_ password: String) -> Observable<Bool> {
        if password.count > 6{
            return Observable.just(true)
        }else{
            return Observable.just(false)
        }
    }
    
    
}
