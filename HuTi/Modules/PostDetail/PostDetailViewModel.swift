//
//  PostDetailViewModel.swift
//  HuTi
//
//  Created by Nguyễn Thịnh on 01/04/2023.
//

import Foundation
import RxSwift
import RxRelay

class PostDetailViewModel: BaseViewModel {
    var postId = ""
    let images = BehaviorRelay<[String]>(value: [])
    var postDetail: PostDetail?
    var project: Project?
    var isFavorite = false
    let reportService = ReportService()
    
    func getPostDetail(postId: String) -> Observable<PostDetail> {
        return postService.getPostById(postId: postId)
    }
    
    func getProjectById(projectId: String) -> Observable<Project> {
        return projectService.getProjectById(projectId: projectId)
    }
    
    func likePost() -> Observable<String> {
        return authService.likePost(postId: postId)
    }
    
    func dislikePost() -> Observable<String> {
        return authService.dislikePost(postId: postId)
    }
    
    func addReport(content: String) -> Observable<String> {
        let params = ["postId": postId, "content": content]
        return reportService.addReport(params: params)
    }
}
