//
//  ListTableViewController.swift
//  ShoppingList
//
//  Created by user195143 on 12/21/21.
//

import UIKit
import Firebase

class ListTableViewController: UITableViewController {

    let collection = "shoppingList"
    var shoppingList: [ShoppingItem] = []
    lazy var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        let firestore = Firestore.firestore()
        firestore.settings = settings
        
        return firestore
    }()
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadShoppingList()
    }

    func loadShoppingList(){
        listener = firestore.collection(collection).order(by: "name", descending: false).addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
            if let error = error {
                print(error)
                return
            } else {
                guard let snapshot = snapshot else { return }
                print("Total de documentos alterados: \(snapshot.documentChanges.count)")
                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                    self.showItemsFrom(snapshot)
                }
            }
        })
    }
    
    func showItemsFrom(_ snapshot: QuerySnapshot) {
        shoppingList.removeAll()
        for document in snapshot.documents {
            let data = document.data()
            if let name = data["name"] as? String,
               let quantity = data["quantity"] as? Int {
                let shoppingItem = ShoppingItem(name: name, quantity: quantity, id: document.documentID)
                shoppingList.append(shoppingItem)
            }
        }
        
        tableView.reloadData()
    }
    
    func showAlertForItem(_ item: ShoppingItem? = nil) {
        let alert = UIAlertController(title: "Produto", message: "Entre com as informações do produto", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome"
            textField.text = item?.name
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Quantidade"
            textField.keyboardType = .numberPad
            textField.text = item?.quantity.description
        }
        
        let saveAction = UIAlertAction(title: "Salvar", style: .default) { (_) in

            guard let name = alert.textFields?.first?.text,
                  let quantityStr = alert.textFields?.last?.text,
                  let quantity = Int(quantityStr) else { return }

            let data: [String: Any] = [
                "name": name,
                "quantity": quantity
            ]
            
            if let item = item {
                self.firestore.collection(self.collection).document(item.id).updateData(data)
            } else {
                self.firestore.collection(self.collection).addDocument(data: data)
            }
        }
        
        alert.addAction(saveAction)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addItem(_ sender: Any) {
        showAlertForItem()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let shoppingItem = shoppingList[indexPath.row]
        cell.textLabel?.text = shoppingItem.name
        cell.detailTextLabel?.text = "\(shoppingItem.quantity)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shoppingItem = shoppingList[indexPath.row]
        showAlertForItem(shoppingItem)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let shoppingItem = shoppingList[indexPath.row]
            firestore.collection(collection).document(shoppingItem.id).delete()
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
