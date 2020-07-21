//
//  PostDetailController.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import UIKit

class PostDetailController: UIViewController {

    static let identifier = "\(PostDetailController.self)"

    var viewModel: PostDetailViewModel
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var postDetailLabel: UILabel!
    
    @IBOutlet weak var commentsTable: UITableView!
    init(coder: NSCoder, aViewModel: PostDetailViewModel) {
        self.viewModel = aViewModel
        super.init(coder: coder)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = self.viewModel.starred.value ? "star.fill" : "star"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: image), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.starAction))
        
        self.viewModel.starred.observe(on: self, observerBlock: { value in
            let image = value ? "star.fill" : "star"
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: image)
        })
        
        self.viewModel.user.observe(on: self, observerBlock: { [weak self] value in
            guard let newUser = value else {return}
            self?.nameLabel.text = newUser.name
            self?.emailLabel.text = newUser.email
            self?.phoneLabel.text = newUser.phone
        })
        
        self.viewModel.comments.observe(on: self, observerBlock: { [weak self] value in
            guard let comments = value else {return}
            
            self?.commentsTable.reloadData()
        })
        
        self.viewModel.waiting.observe(on: self, observerBlock: { [weak self] value in
            print("Waiting detail: \(value)")
            if value {
                self?.waitStartAnimation()
            } else {
                self?.waitStopAnimation()
            }
        })
        
        self.viewModel.errorMessage.observe(on: self, observerBlock: { [weak self] value in
            self?.showError(value)
        })
        self.postDetailLabel.text = self.viewModel.postModel.body
        self.commentsTable.dataSource = self
        self.commentsTable.estimatedRowHeight = 44
        self.commentsTable.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update as readed
        viewModel.updateAsReaded()
        viewModel.loadData()
    }
    
    @IBAction func starAction(_ sender: Any) {
        self.viewModel.starred.value = !self.viewModel.starred.value
    }
    
    private func showError(_ msg: String) {
        let alert = self.createErrorController(message: msg)
        self.present(alert, animated: true)
    }
}

extension PostDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.comments.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier) as? CommentCell, let comments = self.viewModel.comments.value else {
            fatalError("No comment cell!")
        }
        
        let model = comments[indexPath.row]
        cell.setup(model: model)
        return cell
    }
    
    
}
