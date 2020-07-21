//
//  PostLsitController.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/19/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import UIKit

class PostListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postTypeControl: UISegmentedControl!
    
    let viewModel: PostListViewModel = PostListViewModelImpl()
    
    var model: [PostListItemViewModel] {
        viewModel.items.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.viewModel.items.observe(on: self, observerBlock: { [weak self] value in
            self?.tableView.reloadData()
        })
        
        self.viewModel.waiting.observe(on: self, observerBlock: { [weak self] value in
            if value {
                self?.waitStartAnimation()
            } else {
                self?.waitStopAnimation()
            }
        })
        
        self.viewModel.errorMessage.observe(on: self, observerBlock: { [weak self] value in
            self?.showError(value)
        })
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.loadPosts(loadAll: true)
    }
    
    @IBAction func onPostTypeChanged(_ sender: Any) {
        self.viewModel.starredOnly.value = self.postTypeControl.selectedSegmentIndex == 1
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        
        let alert = self.createOkCancelController(title: "Warning", message: "Are you sure you want to delete all items?", okBlock: { [weak self] in
            self?.viewModel.deleteAll()
        })
        
        self.present(alert, animated: true)
    }
    
    private func showError(_ msg: String) {
        let alert = self.createErrorController(message: msg)
        self.present(alert, animated: true)
    }
}

extension PostListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Posts VM/count: \(self.viewModel.items.value.count)")
        return self.viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostItemViewCell.identifier) as? PostItemViewCell else {
            fatalError("No cell")
        }
        
        let itemModel = model[indexPath.row]
        cell.setup(model: itemModel)
        
        return cell
    }
}

extension PostListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show detail for current post
        let model = self.viewModel.items.value[indexPath.row]
        let controller = UIStoryboard.main.instantiateViewController(identifier: PostDetailController.identifier) { coder in
            PostDetailController(coder: coder, aViewModel: PostDetailViewModelImpl(forPost: model))
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let model = self.viewModel.items.value[indexPath.row]
        if editingStyle == .delete {
            self.viewModel.deletePost(postId: model.postId)
        }
    }
}
