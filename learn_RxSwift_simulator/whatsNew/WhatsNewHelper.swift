//
//  whatsNewVC.swift
//  learn_RxSwift_simulator
//
//  Created by yy on 2021/8/6.
//

import Foundation
import WhatsNewKit

class WhatsNewHelper{
    static func getWhatsNewViewController()->WhatsNewViewController?{
        //MARK:-1.WhatsNew()
        let whatsNewInfo = WhatsNew(
            version:WhatsNew.Version.current(),
            title: "新特性",
            items: [
                WhatsNew.Item(
                  title: "新功能",
                subtitle: "描述",
                    image: UIImage(named: "pencil")
                ),
            ]
        )
        
        //MARK:-2.Configuration()
        var configuration = WhatsNewViewController.Configuration()
        configuration.backgroundColor = .white
        configuration.titleView.titleColor = .orange
        configuration.itemsView.titleFont = .systemFont(ofSize: 20)
        configuration.detailButton?.titleColor = .orange
        configuration.completionButton.backgroundColor = .orange
        configuration.apply(theme: .green)//自适应IOS13黑夜模式
        configuration.detailButton = WhatsNewViewController.DetailButton(
            title: "wechat:n0rway99",
            action: .custom(action: { vc in
            })
        )
        
        //MARK:-3.KeyValueWhatsNewVersionStore()
        let keyValueVersionStore = KeyValueWhatsNewVersionStore(
            keyValueable: UserDefaults.standard
        )
        
        //MARK:-4.WhatsNewViewController()
        //使用versionStore初始化WhatsNewViewController时，返回的实例是optional的
        let whatsNewViewController:WhatsNewViewController? = WhatsNewViewController(
            whatsNew: whatsNewInfo,
            configuration: configuration,
            versionStore: InMemoryWhatsNewVersionStore()//debug用，每次安装都会显示whatNew
//            versionStore: keyValueVersionStore
        )
        
        return whatsNewViewController
    }
}
