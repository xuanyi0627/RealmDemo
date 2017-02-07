//
//  TasksViewController.swift
//  RealmDemo
//
//  Created by Xuanyi Liu on 2017/2/6.
//  Copyright © 2017年 Xuanyi Liu. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var selectedList : TaskList!
    var openTasks: Results<Task>!
    var completedTasks: Results<Task>!
    var currentCreateAction: UIAlertAction!
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    var isEditingMode = false {
        didSet {
            tableView.setEditing(isEditingMode, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEditingMode = false
        title = selectedList.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readTasksAndUpdateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readTasksAndUpdateUI() {
        completedTasks = selectedList.tasks.filter("isCompleted = true")
        openTasks = selectedList.tasks.filter("isCompleted = false")
        tableView.reloadData()
    }
    
    func displayAlertToAddTask(_ updateTask: Task?) {
        
        var title = "New Tasks"
        var doneTitle = "Create"
        
        var isUpdate = false
        
        if let _ = updateTask {
            title = "Update Tasks"
            doneTitle = "Update"
            isUpdate = true
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your tasks.", preferredStyle: .alert)
        let createAction = UIAlertAction(title: doneTitle, style: .default) { action in
            if let listName = alertController.textFields?.first?.text {
                if isUpdate {
                    try! uiRealm.write {
                        updateTask?.name = listName
                        self.readTasksAndUpdateUI()
                    }
                }
                else {
                    let taskList = Task()
                    taskList.name = listName
                    try! uiRealm.write {
                        self.selectedList.tasks.append(taskList)
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
            textField.placeholder = "Task Name"
            textField.addTarget(self, action: #selector(TasksViewController.listNameFieldDidChange(_:)), for: .editingChanged)
            if isUpdate {
                textField.text = updateTask?.name
            }
        }
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func didClickOnEditBtn(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
    }
    
    @IBAction func didClickOnAddBtn(_ sender: UIBarButtonItem) {
        displayAlertToAddTask(nil)
    }
    
    func listNameFieldDidChange(_ textField: UITextField) {
        currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return openTasks.count
        } else {
            return completedTasks.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "OPEN TASKS"
        } else {
            return "COMPLETED TASKS"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var task: Task!
        if indexPath.section == 0 {
            task = openTasks[indexPath.row]
        } else {
            task = completedTasks[indexPath.row]
        }
        cell.textLabel?.text = task.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var task: Task!
        if indexPath.section == 0 {
            task = self.openTasks[indexPath.row]
        }
        else {
            task = self.completedTasks[indexPath.row]
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (deleteAction, indexPath) in
            try! uiRealm.write {
                uiRealm.delete(task)
                self.readTasksAndUpdateUI()
            }
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (editAction, indexPath) in
            self.displayAlertToAddTask(task)
        }
        
        var completedAction: UITableViewRowAction!
        
        if indexPath.section == 0 {
            completedAction = UITableViewRowAction(style: .normal, title: "Done") { (doneAction, indexPath) in
                try! uiRealm.write {
                    task.isCompleted = true
                    self.readTasksAndUpdateUI()
                }
            }
        } else {
            completedAction = UITableViewRowAction(style: .normal, title: "unDone") { (doneAction, indexPath) in
                try! uiRealm.write {
                    task.isCompleted = false
                    self.readTasksAndUpdateUI()
                }
            }
        }
        
        return [deleteAction, editAction, completedAction]
    }

}
