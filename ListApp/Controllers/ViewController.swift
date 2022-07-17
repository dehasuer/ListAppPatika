//
//  ViewController.swift
//  ListApp
//
//  Created by Deha Süer on 15.07.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController  {
    
    
    
    @IBOutlet weak var tableView: UITableView!

    
    var data = [NSManagedObject]()
    var alertController = UIAlertController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.fetch()
        
     
    }

    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentAlert(title: "Uyarı!",
                     message: "Listedeki bütün elemanları silmek istediğinze emin misiniz?",
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç") { _ in
            self.data.removeAll()
            self.tableView.reloadData()
        }
     
    }
    @IBAction func didBarButtonItemTapped(_ sender: UIBarButtonItem){
   
        presentAddAlert()
        
    }
    func presentAddAlert(){
        
        presentAlert(title: "Yeni Eleman Ekle!",
                     message: nil,
                     defaultButtonTitle: "Ekle",
                     cancelButtonTitle: "Vazgeç",
                     isTextFieldAvailable: true,
                     defaultButtonHandler: {_ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                //self.data.append((text)!)
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entitiy = NSEntityDescription.entity(forEntityName: "Listitem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entitiy!, insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                self.fetch()
                
            }else{
                self.presentWarningAlert()
            }
        }
                    )

    }
    func presentWarningAlert(){
        presentAlert(title: "Uyarı",
                     message: "Liste boş olamaz!",
                     cancelButtonTitle: "Tamam")
    }
    func presentAlert(title: String?,
                      message: String?,
                      prefferedStyle: UIAlertController.Style = .alert ,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable:Bool = false,
                      defaultButtonHandler: ((UIAlertAction) -> Void)? = nil){
         alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: prefferedStyle)
        if defaultButtonTitle != nil {
         let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                          style: .default,
                                          handler: defaultButtonHandler)
            alertController.addAction(defaultButton)

        }
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvailable {
            alertController.addTextField()
        }
        alertController.addAction(cancelButton)
        present(alertController, animated: true)

    }
    func fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Listitem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
}



extension ViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count //To generate cells in the tableview
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { _, _, _ in
                //self.data.remove(at: indexPath.row)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        deleteAction.backgroundColor = .systemRed
        
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Elemanı Düzenle!",
                         message: nil,
                         defaultButtonTitle: "Düzenle",
                         cancelButtonTitle: "Vazgeç",
                         isTextFieldAvailable: true,
                         defaultButtonHandler: {_ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    //self.data[indexPath.row] = text!
                    
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if ((managedObjectContext?.hasChanges) != nil) {
                        try? managedObjectContext?.save()
                    }
                    
                    self.tableView.reloadData()
                }else{
                    self.presentWarningAlert()
                }
            }
            )
        }
        editAction.backgroundColor = .systemBrown
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction , editAction])
        return config
    }
}

