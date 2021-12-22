//
//  ViewController.swift
//  ShoppingList
//
//  Created by user195143 on 12/20/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var buttonSignup: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = Auth.auth().currentUser {
            guard let listTableViewController = storyboard?.instantiateViewController(withIdentifier: "ListTableViewController") else {return}
            navigationController?.pushViewController(listTableViewController, animated: false)
            
        }
    }

    @IBAction func signIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { (result, error) in
            guard let user = result?.user else { return }
            self.updateUserAndProceed(user: user)
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        // Criar conta
        Auth.auth().createUser(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { result, error in
            if let error = error {
                let authErrorCode = AuthErrorCode(rawValue: error._code)
                
                switch authErrorCode {
                case .emailAlreadyInUse:
                    print("Email já em uso!")
                case .weakPassword:
                    print("A senha escolhida é muito fraca!")
                default:
                    print(authErrorCode)
                }
            } else {
                print("Usuário criado com sucesso!")
                
                if let user = result?.user {
                    self.updateUserAndProceed(user: user)
                }
            }
        }
    }
    
    func updateUserAndProceed(user: User) {
        if textFieldName.text!.isEmpty {
            goToMainScreen()
        } else {
            let request = user.createProfileChangeRequest()
            request.displayName = textFieldName.text!
            request.commitChanges { (error) in
                if error != nil {
                    print("Erro ao atualizar o usuário!")
                } else {
                    self.goToMainScreen()
                }
            }
        }
    }
    
    func goToMainScreen(){
        guard let listTableViewController = storyboard?.instantiateViewController(withIdentifier: "ListTableViewController") else {return}
        show(listTableViewController, sender: nil)
    }
}

