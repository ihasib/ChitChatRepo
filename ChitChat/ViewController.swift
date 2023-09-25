//
//  ViewController.swift
//  ChitChat
//
//  Created by S. M. Hasibur Rahman on 19/9/23.
//

import UIKit
//todo import progresshud's toast

class ViewController: UIViewController {

    enum InputState {
        case login, signup, forgotPass
    }
    //MARK: IBOutlets
    //labels
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var dontHavAccLabel: UILabel!
    
    //text fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //separator views
    @IBOutlet weak var repeatPassSeparatorView: UIView!


    //buttons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var resendMailButton: UIButton!
    
    //state variable
    var isLogin = true

    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setupTextFieldDelegates()
        backgroundTapSetup()
        setupUiForAccountState(for: true)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        emailTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self
    }


    //MARK: IBActions
    @IBAction func forgotPassButtonTapped(_ sender: Any) {
        let isFilled = isInputFilledUp(for: .forgotPass)
        if !isFilled {
            let alert = UIAlertController(title: "Alert", message: "Email field required", preferredStyle: .alert)
            self.present(alert, animated: true) {
                sleep(1)
                self.dismiss(animated: true)
            }
            print("Email field required")
        }
    }

    @IBAction func resendMailButtonTapped(_ sender: Any) {
        let isFilled = isInputFilledUp(for: .forgotPass)
        if !isFilled {
            let alert = UIAlertController(title: "Alert", message: "Email field required", preferredStyle: .alert)
            self.present(alert, animated: true) {
                sleep(1)
                self.dismiss(animated: true)
            }
            print("Email field required")
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let isFilled = isInputFilledUp(for: isLogin ? .login : .signup)
        if !isFilled {
            let alert = UIAlertController(title: "Alert", message: "All fields required", preferredStyle: .alert)
            self.present(alert, animated: true) {
                sleep(1)
                self.dismiss(animated: true)
            }
            print("All fields required")
            return
        }
        if !isLogin {//signup
            if passwordTextField.text != repeatPasswordTextField.text {
                let alert = UIAlertController(title: "Alert", message: "Password Missmatched", preferredStyle: .alert)
                self.present(alert, animated: true) {
                    sleep(1)
                    self.dismiss(animated: true)
                }
                print("Password Missmatched")
                return
            }
        }

        registerUser()
        goToHomeView()
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        isLogin.toggle()
        setupUiForAccountState(for: sender.titleLabel?.text == "Login")
    }

    //MARK:
    func setupTextFieldDelegates() {
        emailTextField.addTarget(self, action: #selector(emailUpdated), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(emailUpdated), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(emailUpdated), for: .editingChanged)
    }
    @objc func emailUpdated(sender: UITextField) {

        print("\(sender.text)")
        updatePlaceholderLabels(textField: sender)
    }

    func updatePlaceholderLabels(textField: UITextField) {
        switch textField {
            case emailTextField:
                emailLabel.text = textField.hasText ? "Email" : ""
            case passwordTextField:
                passwordLabel.text = textField.hasText ? "Password" : ""
            case repeatPasswordTextField:
                repeatPasswordLabel.text = textField.hasText ? "Repeat" : ""
            default:
                print()

        }
    }

    func setupUiForAccountState(for login: Bool) {
        print("+++ \(login)")
        print(loginLabel.text)
        print(dontHavAccLabel.text)
        print(signupButton.titleLabel?.text)
        loginLabel.text = login ? "Login" : "Sign Up"
        loginButton.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        dontHavAccLabel.text = login ? "Don't have an account?" : "Have an account?"
        signupButton.setTitle(login ? "Sign up" : "Login", for: .normal)

        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordTextField.isHidden = login
            self.repeatPassSeparatorView.isHidden = login
        }
    }
    
    private func loginUser() {
        FUserListener.shared
    }

    private func registerUser() {
        FUserListener.shared.registerUser(email: emailTextField.text!, password: passwordTextField.text!) {error in
            if error == nil {
                print("Verification email sent")
                self.resendMailButton.isHidden = false
            } else {
                print("Registration failed due to \(error?.localizedDescription)")
            }

        }
    }

    var jump = 0.0
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            self.view.frame.origin.y -= keyboardHeight
//            let h1 = self.view.frame.height
//            let h2 = loginLabel.frame.origin.y
//            let h3 = emailLabel.frame.origin.y
//            let h4 = passwordLabel.frame.origin.y
//            let h5 = repeatPasswordLabel.frame.origin.y
//            let h6 = repeatPassSeparatorView.frame.origin.y
//            let y = self.repeatPassSeparatorView.frame.origin.y
//            let separatorBelowSpace = keyboardRectangle.origin.y - self.repeatPassSeparatorView.frame.origin.y
            let autoSuggesstionKeyboardHeight = 83.0///314-231
            let new = (keyboardRectangle.origin.y - autoSuggesstionKeyboardHeight)
            if self.repeatPassSeparatorView.frame.origin.y >= new {
                jump = (keyboardRectangle.origin.y-repeatPassSeparatorView.frame.origin.y)// + autoSuggesstionKeyboardHeight//314-231 + height
                self.view.frame.origin.y -= jump
            }

        }
    }

    func backgroundTapSetup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func viewTapped() {
        print("view tapped")
        view.endEditing(true)
    }

    func isInputFilledUp(for inputType: InputState) -> Bool {
        switch inputType {
            case .login:
                return emailTextField.hasText && passwordTextField.hasText
            case .signup:
                return emailTextField.hasText && passwordTextField.hasText && repeatPasswordTextField.hasText
            case .forgotPass:
                return emailTextField.hasText
        }
    }

    //Navigation
    private func goToHomeView() {
        let homeView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeView") as UITabBarController
        homeView.modalPresentationStyle = .fullScreen
        present(homeView, animated: true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.5) {
        textField.resignFirstResponder()
            self.view.frame.origin.y += self.jump
        }
        
        jump = 0
        return true
    }
}
