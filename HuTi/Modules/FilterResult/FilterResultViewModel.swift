//
//  FilterResultViewModel.swift
//  HuTi
//
//  Created by Nguyễn Thịnh on 07/03/2023.
//

import Foundation
import RxCocoa
import RxSwift

class FilterResultViewModel: BaseViewModel {
    var optionsList = [String]()
    let post = BehaviorRelay<[Post]>(value: [])
    let options = BehaviorRelay<[String]>(value: [])
    var tabBarItemTitle = TabBarItemTitle.sell
    var mainTabBarItemTitle = MainTitle.sell
    var tuppleOptionsList = [(key: Int, value: String)]()
    
    func getPost(isSell: Bool) -> Observable<[Post]> {
        return postService.getPosts(isSell: isSell)
    }
    
    func parseOptionTuppleToArray() {
        optionsList = []
        for (_, element) in tuppleOptionsList.enumerated() {
            optionsList.append(element.value)
        }
        options.accept(optionsList)
    }
    
    func getImage(remoteName: String, completion: @escaping(UIImage) -> Void) {
        awsService.getImage(remoteName: remoteName) { data in
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            print("download image successfully")
            completion(image)
        }
    }
}
