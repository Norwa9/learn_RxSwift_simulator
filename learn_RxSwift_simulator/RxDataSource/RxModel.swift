//
//  RxModel.swift
//  learn_RxSwift_simulator
//
//  Created by yy on 2021/8/5.
//
import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Foundation

struct LWModel {
    var anInt: Int = 0
    var aString: String = ""
    var aCGPoint: CGPoint = .zero
}

struct SectionOfLWModel{
    var header:String
    var items: [Item]
}

extension SectionOfLWModel:SectionModelType{
    typealias Item = LWModel
    
    init(original: SectionOfLWModel, items: [LWModel]) {
        self = original
        self.items = items
    }
}

