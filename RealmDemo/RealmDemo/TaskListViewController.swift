//
//  TaskListViewController.swift
//  RealmDemo
//
//  Created by Xuanyi Liu on 2017/2/6.
//  Copyright © 2017年 Xuanyi Liu. All rights reserved.
//

import UIKit
import RealmSwift

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var isEditingMode = false {
        didSet {
            tableView.setEditing(isEditingMode, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readTasksAndUpdateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            lists = lists.sorted(byKeyPath: "name")
        } else {
            lists = lists.sorted(byKeyPath: "createAt", ascending: false)
        }
        tableView.reloadData()
    }

    @IBAction func didClickOnEditBtn(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
    }
    
    @IBAction func didClickOnAddBtn(_ sender: UIBarButtonItem) {
        displayAlertToAddTaskList(nil)
    }
    
    func listNameFieldDidChange(_ textField: UITextField) {
        currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    var lists: Results<TaskList>!
    
    func readTasksAndUpdateUI() {
        lists = uiRealm.objects(TaskList.self)
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
    }
    
    var currentCreateAction: UIAlertAction!
    
    func displayAlertToAddTaskList(_ updateList: TaskList?) {
        
        var title = "New Tasks List"
        var doneTitle = "Create"
        
        var isUpdate = false
        
        if let _ = updateList {
            title = "Update Tasks List"
            doneTitle = "Update"
            isUpdate = true
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your tasks list.", preferredStyle: .alert)
        let createAction = UIAlertAction(title: doneTitle, style: .default) { action in
            if let listName = alertController.textFields?.first?.text {
                if isUpdate {
                    try! uiRealm.write {
                        updateList?.name = listName
                        self.readTasksAndUpdateUI()
                    }
                }
                else {
                    let taskList = TaskList()
                    taskList.name = listName
                    try! uiRealm.write {
                        uiRealm.add(taskList)
                        self.readTasksAndUpdateUI()
                    }
                }
                print(listName)
            }
        }
        alertController.addAction(createAction)
        createAction.isEnabled = false
        currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { (textField) in
            textField.placeholder = "Task List Name"
            textField.addTarget(self, action: #selector(TaskListViewController.listNameFieldDidChange(_:)), for: .editingChanged)
            if isUpdate {
                textField.text = updateList?.name
            }
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tasksList = lists {
            return tasksList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let list = lists[indexPath.row]
        cell?.textLabel?.text = list.name
        cell?.detailTextLabel?.text = "\(list.tasks.count) Task"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (deleteAction, indexPath) in
            let listToBeDelete = self.lists[indexPath.row]
            try! uiRealm.write {
                uiRealm.delete(listToBeDelete)
                self.readTasksAndUpdateUI()
            }
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (editAction, indexPath) in
            let listToBeEdit = self.lists[indexPath.row]
            self.displayAlertToAddTaskList(listToBeEdit)
        }
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let list = lists {
            performSegue(withIdentifier: "openTasks", sender: list[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier {
            if segueId == "openTasks" {
                let taskVC = segue.destination as! TasksViewController
                taskVC.selectedList = sender as! TaskList
            }
        }
    }

}
