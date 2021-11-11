//
//  ViewController.swift
//  instagram
//
//  Created by 장은석 on 2021/10/27.
//

import FirebaseAuth
import UIKit

struct HomeFeedRenderViewModel {
    let header: PostRenderViewmodel
    let post: PostRenderViewmodel
    let actions: PostRenderViewmodel
    let comments: PostRenderViewmodel
}

class HomeViewController: UIViewController {
    
    private var feedrRenderModels = [HomeFeedRenderViewModel]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        // Register cells
        tableView.register(IGFeedPostTableViewCell.self, forCellReuseIdentifier: IGFeedPostTableViewCell.identifier)
        tableView.register(IGFeedPostHeaderTableViewCell.self, forCellReuseIdentifier: IGFeedPostHeaderTableViewCell.identifier)
        tableView.register(IGFeedPostActionsTableViewCell.self, forCellReuseIdentifier: IGFeedPostActionsTableViewCell.identifier)
        tableView.register(IGFeedPostGeneralTableViewCell.self, forCellReuseIdentifier: IGFeedPostGeneralTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMockModels()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func createMockModels() {
        let user = User(username: "joe",
                        bio: "",
                        name: (first: "", last: ""),
                        profilePhoto: URL(string: "https://www.google.com")!,
                        birthDate: Date(),
                        gender: .male,
                        counts: USerCount(followers: 1, following: 1, posts: 1),
                        joinDate: Date())
        let post = UserPost(identifier: "",
                            postType: .photo,
                            thumbnailImage: URL(string: "https://www.google.com/")!,
                            postURL: URL(string: "https://www.google.com")!,
                            caption: nil,
                            likeCount: [],
                            comments: [],
                            createdDate: Date(),
                            taggedUsers: [],
                            owner: user)
        
        var comments = [PostComment]()
        for x in 0 ..< 2 {
            comments.append(PostComment(identifier: "\(x)",
                                        username: "@jenny",
                                        text: "This is the best post I've seen",
                                        createdDate: Date(),
                                        likes: []))
        }
        
        for _ in 0 ..< 5 {
            let viewModel = HomeFeedRenderViewModel(header: PostRenderViewmodel(renderType: .header(provider: user)),
                                                    post: PostRenderViewmodel(renderType: .primaryContent(provide: post)),
                                                    actions: PostRenderViewmodel(renderType: .actions(provider: "")),
                                                    comments: PostRenderViewmodel(renderType: .comments(comments: comments)))
            feedrRenderModels.append(viewModel)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleNotAuthenticated()
    }
    
    private func handleNotAuthenticated() {
        // Check auth status
        if Auth.auth().currentUser == nil {
            // Show log in
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedrRenderModels.count * 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let x = section
        let model: HomeFeedRenderViewModel
        if x == 0 {
            model = feedrRenderModels[0]
        } else {
            let position = x % 4 == 0 ? x/4 : ((x - (x % 4)) / 4)
            model = feedrRenderModels[position]
        }
        
        let subSction = x % 4
        
        if subSction == 0 {
            // header
            return 1
            
        } else if subSction == 1 {
            // post
            return 1
            
        } else if subSction == 2 {
            // actions
            return 1
            
        } else if subSction == 3 {
            // comments
            let commentsModel = model.comments
            switch commentsModel.renderType {
            case .comments(let comments): return comments.count > 2 ? 2 : comments.count
            case .header, .actions, .primaryContent: return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let x = indexPath.section
        let model: HomeFeedRenderViewModel
        if x == 0 {
            model = feedrRenderModels[0]
        } else {
            let position = x % 4 == 0 ? x/4 : ((x - (x % 4)) / 4)
            model = feedrRenderModels[position]
        }
        
        let subSction = x % 4
        
        if subSction == 0 {
            // header
            let headerModel = model.header
            switch headerModel.renderType {
            case .header(let user):
                let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostHeaderTableViewCell.identifier,  for: indexPath) as! IGFeedPostHeaderTableViewCell
                return cell
            case .comments, .actions, .primaryContent: return UITableViewCell()
            }
            
        } else if subSction == 1 {
            // post
            switch model.post.renderType {
            case .primaryContent(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostTableViewCell.identifier,  for: indexPath) as! IGFeedPostTableViewCell
                return cell
            case .comments, .actions, .header: return UITableViewCell()
            }
            
        } else if subSction == 2 {
            // actions
            switch model.actions.renderType {
            case .actions(let provider):
                let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostActionsTableViewCell.identifier,  for: indexPath) as! IGFeedPostActionsTableViewCell
                return cell
            case .comments, .header, .primaryContent: return UITableViewCell()
            }
            
        } else if subSction == 3 {
            // comments
            switch model.comments.renderType {
            case .comments(let comments):
                let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostGeneralTableViewCell.identifier,  for: indexPath) as! IGFeedPostGeneralTableViewCell
                return cell
            case .header, .actions, .primaryContent: return UITableViewCell()
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subSection = indexPath.section % 4
        if subSection == 0 {
            // Header
            return 70
        } else if subSection == 1 {
            // Post
            return tableView.width
        } else if subSection == 2 {
            // Actions (like/Comment)
            return 60
        } else if subSection == 3 {
            // Comment row
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let subSection = section % 4
        return subSection == 3 ? 70 : 0
        
        return 0
    }
}

