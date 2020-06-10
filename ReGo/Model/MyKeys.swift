//
//  MyKeys.swift
//  ReGo
//
//  Created by Анна Мельхова on 01.05.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import Foundation

//MARK:- MyKeys:
class MyKeys {
    
    init() {
       changeToEng()
    }
    var alert = Alert()
    var editProfile = EditProfileControllerLabels()
    var map = MapViewControllerLabels()
    var home = HomeViewControllerLabels()
    var loginRegistration = LogInRegistrationViewControllerLabels()
    var addAndEdit = AddAndEditPlaceViewControllerLabels()
    var placeInfo = PlaceInfoViewControllerLabels()
    var list = ListOfPlacesViewControllerLabels()
    var image = ImageControllerLabels()
    var about = About()
    
    func changeToEng() {
        alert.changeToEng()
        editProfile.changeToEng()
        map.changeToEng()
        home.changeToEng()
        loginRegistration.changeToEng()
        addAndEdit.changeToEng()
        placeInfo.changeToEng()
        list.changeToEng()
        image.changeToEng()
        about.changeToEng()
        language = "ENG"
        UserDefaults.standard.set(language, forKey: "Lang")
        
    }
    func changeToRus() {
        alert.changeToRus()
        editProfile.changeToRus()
        map.changeToRus()
        home.changeToRus()
        loginRegistration.changeToRus()
        addAndEdit.changeToRus()
        placeInfo.changeToRus()
        list.changeToRus()
        image.changeToRus()
        about.changeToRus()
        language = "RUS"
        UserDefaults.standard.set(language, forKey: "Lang")
    }
}

//MARK:- controllers:

//MARK:MapView:
class MapViewControllerLabels {
    init() {
        changeToEng()
    }
    
    var doneButton = String()
    var moreInfoButton = String()
    var back = String()
    
    func changeToEng(){
        doneButton = " Done"
        moreInfoButton = "More Info"
        back = " Back"
    }
    func changeToRus() {
        doneButton = " Готово"
        moreInfoButton = "Подробнее"
        back = " Назад"
    }
}
//MARK:HomeView:
class HomeViewControllerLabels {
    init() {
        changeToEng()
    }
    
    var titleLabel = String()
    var logOutButton = String()
    var loginRequest = String()
    var logInButton = String()
    var signUpButton = String()
    
    var usernameLabel = String()
    var emailLabel = String()
    var aboutButton = String()
    var changeLangButton = String()
    var editPofileButton = String()
    
    var placesAddedLabel = String()
    
    func changeToEng(){
        titleLabel = "Information"
        logOutButton = "Log Out"
        loginRequest = "Log in to be able to add new places"
        logInButton = "Log In"
        signUpButton = "Sing Up"
        
        usernameLabel = "Username"
        emailLabel = "Email: "
        aboutButton = " About the App"
        changeLangButton = " Change to Russian"
        editPofileButton = " Edit Profile"
        placesAddedLabel = "Places added: "
        
    }
    func changeToRus() {
        titleLabel = "Информация"
        logOutButton = "Выйти"
        loginRequest = "Войдите в приложение чтобы добавлять новые места"
        logInButton = "Войти"
        signUpButton = "Регистрация"
        
        usernameLabel = "Имя"
        emailLabel = "Почта: "
        aboutButton = " О Приложении"
        changeLangButton = " Изменить на Английский"
        editPofileButton = " Редактировать Профиль"
        placesAddedLabel = "Добавленных мест: "
    }
}
//MARK:LoginRegistration:
class LogInRegistrationViewControllerLabels {
    init() {
        changeToEng()
    }
    
    var logInTitleLabel = String()
    var registrationTitleLabel = String()
    var usenameLabel = String()
    var usernameTextField = String()
    var emailLabel = String()
    var emailTextField = String()
    var passwordLabel = String()
    var signUpButton = String()
    var logInButton = String()
    var forgotPasswordButton = String()
    var passwordSentToEmail = String()
    var enterTheEmail = String()
    
    func changeToEng(){
        logInTitleLabel = "Log In"
        registrationTitleLabel = "Registration"
        usenameLabel = "Username:"
        usernameTextField = "Flora123"
        emailLabel = "Email:"
        emailTextField = "flora@gmail.com"
        passwordLabel = "Password:"
        signUpButton = "Sign Up"
        logInButton = "Log In"
        forgotPasswordButton = "Forgot Password?"
        passwordSentToEmail = "The link to change your password was sent to your email"
        enterTheEmail = "Please, enter your email:"
    }
    func changeToRus() {
        logInTitleLabel = "Вход"
        registrationTitleLabel = "Регистрация"
        usenameLabel = "Имя:"
        usernameTextField = "Флора123"
        emailLabel = "Электронная почта:"
        emailTextField = "flora@mail.ru"
        passwordLabel = "Пароль:"
        signUpButton = "Регистрация"
        logInButton = "Войти"
        forgotPasswordButton = "Забыли пароль?"
        passwordSentToEmail = "Ссылка на смену пароля была отправлена Вам на электронную почту"
        enterTheEmail = "Пожалуйста, введите свою почту:"
    }
}
//MARK:AddAndEditPlace:
class AddAndEditPlaceViewControllerLabels {
    init() {
        changeToEng()
    }
    
    var addNewPlaceTitleLabel = String()
    var editPlaceTitleLabel = String()
    var enableMapButton = String()
    var disableMapButton = String()
    var whatDoesItCollectLabel = String()
    var bottlesButton = String()
    var batteriesButton  = String()
    var bulbsButton = String()
    var otherButton = String()
    var otherTextField = String()
    var addPhotoButton = String()
    var changePhotoButton = String()
    var titleLabel = String()
    var titleTextField = String()
    var addressLabel = String()
    var addressTextField = String()
    var sendButton = String()
    var sendChangesButton = String()
    
    
    func changeToEng(){
        addNewPlaceTitleLabel = "Add New Place"
        editPlaceTitleLabel = "Edit Place"
        enableMapButton = " Enable Map"
        disableMapButton = " Disable Map"
        whatDoesItCollectLabel = "What does it collect"
        bottlesButton = "Bottles"
        batteriesButton  = "Batteries"
        bulbsButton = "Bulbs"
        otherButton = "Other"
        otherTextField = "Write here what other things it collects?"
        addPhotoButton = "Add Photo"
        changePhotoButton = "Change Photo"
        titleLabel = "Title:"
        titleTextField = "Container for plastic"
        addressLabel = "Address:"
        addressTextField = "Гагарина 57/2"
        sendButton = "Send"
        sendChangesButton = "Send Changes"
        
    }
    func changeToRus() {
        addNewPlaceTitleLabel = "Добавить Место"
        editPlaceTitleLabel = "Редактировать Место"
        enableMapButton = " Активировать"
        disableMapButton = " Дезактивировать"
        whatDoesItCollectLabel = "Что можно приносить?"
        bottlesButton = "Бутылки"
        batteriesButton  = "Батарейки"
        bulbsButton = "Лампы"
        otherButton = "Другое"
        otherTextField = "Запишите сюда что конкретно другое можно принести"
        addPhotoButton = "+ Фото"
        changePhotoButton = "+ Фото"
        titleLabel = "Название:"
        titleTextField = "Контейне для пластика"
        addressLabel = "Адрес:"
        addressTextField = "Гагарина 57/2"
        sendButton = "Отправить"
        sendChangesButton = "Отправить изменения"
        
    }
}
//MARK:PlaceInfo:
class PlaceInfoViewControllerLabels {
    init() {
        changeToEng()
    }
    
    var infoTitleLabel = String()
    var goThereButton = String()
    var distanceFromYou = String()
    var titleLabel = String()
    var titleTextField = String()
    var addressLabel = String()
    var addressTextField = String()
    var whatItCollectsLabel = String()
    var otherTextField = String()
    var editButton = String()
    var regRequestForEditing = String()
    
    func changeToEng(){
        infoTitleLabel = "Information"
        goThereButton = "Go There"
        distanceFromYou = "km from you"
        titleLabel = "Title:"
        titleTextField = "Container for plastic"
        addressLabel = "Address:"
        addressTextField = "Гагарина 57/2"
        whatItCollectsLabel = "What it collects:"
        otherTextField = "It does not collect any specific things"
        editButton = "Edit"
        regRequestForEditing = "You need to log in to edit the information about places"
    }
    func changeToRus() {
        infoTitleLabel = "Информация"
        goThereButton = " Идти"
        distanceFromYou = "км от Вас"
        titleLabel = "Название:"
        titleTextField = "Контейнер для пластика"
        addressLabel = "Адрес:"
        addressTextField = "Гагарина 57/2"
        whatItCollectsLabel = "Что можно приносить:"
        otherTextField = "Нельзя приносить какие-либо другие вещи кроме перечисленных"
        editButton = "Изменить"
        regRequestForEditing = "Вам нужно зарегистрироваться в приложении чтобы вносить изменения о местах"
    }
}
//MARK:ListOfPlaces:
class ListOfPlacesViewControllerLabels {
    init() {
        changeToEng()
    }
    
    var listOfPlacesTitle = String()
    var all = String()
    var bottles = String()
    var batteries = String()
    var bulbs = String()
    var km = String()
    
    func changeToEng(){
        listOfPlacesTitle = "List of places"
        all = "All"
        bottles = "Bottles"
        batteries = "Batteries"
        bulbs = "Bulbs"
        km = "km from you"
    }
    func changeToRus() {
        listOfPlacesTitle = "Список мест"
        all = "Все"
        bottles = "Бутылки"
        batteries = "Батарейки"
        bulbs = "Лампочки"
        km = "км от Вас"
    }
}

//MARK: EditProfile
class EditProfileControllerLabels {
    init() {
        changeToEng()
    }
    
    var editProfileTitleLabel = String()
    var usernameLabel = String()
    var userNameTextField  = String()
    var emailLabel = String()
    var emailTextField = String()
    var saveChangesButton = String()
    var oldPasswordLabel = String()
    var newPasswordLabel = String()
    var changePasswordButton = String()
    var forgotPasswordButton = String()
    
    func changeToEng() {
        editProfileTitleLabel = "Edit Profile"
        usernameLabel = "Username:"
        userNameTextField  = "Flora123"
        emailLabel = "Email:"
        emailTextField = "flora123@gmail.com"
        saveChangesButton = "Save Changes"
        oldPasswordLabel = "Old password:"
        newPasswordLabel = "New password:"
        changePasswordButton = "Change Password"
        forgotPasswordButton = "Forgot Password?"
    }
    func changeToRus() {
        editProfileTitleLabel = "Изменение Профиля"
        usernameLabel = "Имя:"
        userNameTextField  = "Флора123"
        emailLabel = "Электронная почта:"
        emailTextField = "flora123@mail.ru"
        saveChangesButton = "Сохранить Изменения"
        oldPasswordLabel = "Старый Пароль:"
        newPasswordLabel = "Новый Пароль:"
        changePasswordButton = "Изменить Пароль"
        forgotPasswordButton = "Забыли Пароль?"
    }
}

// MARK:- Image
class ImageControllerLabels {
    init() {
        changeToEng()
    }
    
    var back = String()
    
    func changeToEng() {
        back = " Back"
    }
    func changeToRus() {
        back = " Назад"
    }
}

//MARK:- About
class About {
    init() {
        changeToEng()
    }
    
    var title = String()
    var sendReviewButton = String()
    var superUserButton = String()
    var userIsSuperMessage = String()
    var requestForReason = String()
    var requestForReasonTitle = String()
    var infoText = String()
    var superuserRequestSent = String()
    var requestExists = String()
    var thanksForRating = String()
    var stars = String()
    var commentRequest = String()
    var stillRate1 = String()
    var stillRate2 = String()
    
    func changeToEng() {
        title = "About"
        sendReviewButton = " Send review"
        superUserButton = " Apply for Superuser"
        userIsSuperMessage = "You are already superuser"
        requestForReason = "Tell us your reason"
        requestForReason = "Why do you want to become a Superuser?"
        superuserRequestSent = "Your request has been successfully sent"
        requestExists = "You've already sent a request. Please wait for the answer by email"
        thanksForRating = "Thank you for your rating!"
        stars = "stars"
        commentRequest = "Please insert your comment for the rating:"
        stillRate1 = "You have already rated the app with"
        stillRate2 = "stars. Do you want to change it?"
        infoText = "This app is developed to make the recycling system in Ufa easier and more available.\nYou can see places with containers where you can bring plastic, batteries, glass etc. on the map. You can get the route to those places and recycle your garbage to make our city healthier =)\nWe want to contribute to it together, that is why if you register in our app you can send us information about new places for recycling and send us the changes in the existing ones if you see some mistakes.\nAlso there is an opportunity to become a superuser to be able to make the changes directly on the map. To do so you just need to send us the request and we will email you about the following steps =)\n\nAnd of course you can send us a review about the app, which can help up improve, just press a button below.\n\nFor now the app rating is:"
    }
    func changeToRus() {
        title = "О приложении"
        sendReviewButton = " Отправить отзыв"
        superUserButton = " Стать суперпользователем"
        userIsSuperMessage = "Вы уже суперпользователь"
        requestForReason = "Какова ваша причина?"
        requestForReason = "Почему вы хотите стать суперпользователем?"
        superuserRequestSent = "Ваша заявка была успешно отправлена"
        requestExists = "Вы уже отправили запрос. Пожалуста подождите ответа по электронной почту"
        thanksForRating = "Cпасибо за вашу оценку!"
        stars = "звезд"
        commentRequest = "Пожалуйста, добавьте комментарий к вашей оценке:"
        stillRate1 = "Вы уже оценили наше приложение поставив"
        stillRate2 = "звезд. Вы хотите изменить оценку?"
        infoText = "Это приложение разработано чтобы переработка отходов стала легче и доступнее для жителей Уфы.\nНа карте можно видеть места с контейнерами для сдачи пластика, батареек, стекла и т.д. проложить к ним дорогу и сдать сырье на переработку чтобы наш город стал суть экологичнее =)\nМы хотим влиять на это вместе, поэтому зарегистрировавшись в приложении Вы можете отправлять нам данные о новых контейнерах, месторасположения которых Вы знаете, либо отправлять изменение в данных о уже существующих местах, если видите ошибку.\nТак же есть возможность стать суперпользователем, чтобы получить доступ к изменениям карты напрямую. Для этого Вы можете послать нам запрос на становление суперпользователем, нажав кнопку ниже, и мы свяжемся с Вами по электронной почте =)\n\nНу и конечно Вы можете отправить отзыв о приложении, нажав кнопку внизу, что поможет нам становиться лучше.\n\nНа данный момент рейтинг приложения:"
    }
    
}

//MARK:- Alert
class Alert {
    init() {
        changeToEng()
    }
    var errTitle = String()
    var successTitle =  String()
    var passwordIsRequiredTitle  = String()
    var passwordIsRequiredMessage = String()
    var passwordErrorMessage = String()
    var linkSentTo = String()
    var checkEmail = String()
    var cancelButton =  String()
    var okButton = String()
    var doneButton = String()
    var tryAgainButton = String()
    var sendByEmailButton = String()
    var cameraButton = String()
    var galleryButton = String()
    var cameraErrorMessage = String()
    var valuesChanged = String()
    var passwordChanged = String()
    var chooseNewProfileImageTitle = String()
    var saveImageToDatabaseErrorMessage = String()
    var somethingWendWrong = String()
    var imageSaved = String()
    var enterTitle = String()
    var enterAddress = String()
    var whatRecycle = String()
    var writeOther = String()
    var thankYou = String()
    var placeEdited = String()
    var placeAdded = String()
    var loginReminder = String()
    var createNewPlaceTitle = String()
    var createNewPlaceMessage = String()
    var logoutTitle = String()
    var logoutQuestion = String()
    var loggedoutMessage = String()
    var yesButton = String()
    var noButton = String()
    var noUsernameLabel = String()
    var noPasswordLabel = String()
    var noEmailLabel = String()
    var noUsernameMessage = String()
    var noPasswordMessage = String()
    var noEmailMessage = String()
    var successfulRefistrataion = String()
    var successfullLogin = String()
    var changeLangTitle = String()
    var changeLangQuestion = String()
    var setLangTitle = String()
    var setLangRequest = String()
    var rus = "Русский"
    var eng = "English"
    var attention = String()
    
    func changeToEng() {
        errTitle = "Error"
        successTitle = "Success"
        passwordIsRequiredTitle = "Password is required"
        passwordIsRequiredMessage = "To change the email please insert your password below:"
        passwordErrorMessage = "Your old password is incorrect. Do you want to try again or we can send a link to reset your password by email?"
        linkSentTo = "Your link to change password was sent to "
        checkEmail = ". Check your email."
        cancelButton = "Cancel"
        okButton = "Ok"
        doneButton = "Done!"
        tryAgainButton = "Try again"
        sendByEmailButton = "Send by email"
        cameraButton = "Camera"
        galleryButton = "Gallery"
        cameraErrorMessage = "We don't have access to your camera"
        valuesChanged = "Data has been sucessfully changed"
        passwordChanged = "Your password has been successfully changed"
        chooseNewProfileImageTitle = "Choose new profile image"
        saveImageToDatabaseErrorMessage = "Something went wrong with saving your image to the storage.Please try again."
        somethingWendWrong = "Something went wrong..."
        imageSaved = "Image was saved to the database"
        enterTitle = "Enter the title of the place"
        enterAddress = "Enter the address of the place"
        whatRecycle = "Select what you can recycle at that place"
        writeOther = "You have chosen option OTHER. Please enter ehat exaclty you can recycle at the place"
        thankYou = "Thank you!"
        placeEdited = "The place has been edited successfully"
        placeAdded = "The place has been added successfully"
        loginReminder = "To add new places you have to log in"
        createNewPlaceTitle = "Create a new place"
        createNewPlaceMessage = "Choose the location for  new place"
        logoutTitle = "Log Out"
        logoutQuestion = "Are you sure you want to log out?"
        loggedoutMessage = "You've logged out uccessfully"
        yesButton = "Yes"
        noButton = "No"
        noUsernameLabel = "No username is found"
        noPasswordLabel = "No password is found"
        noEmailLabel = "No email is found"
        noUsernameMessage = "Please insert the username"
        noPasswordMessage = "Please insert the password. At least 6 characters long"
        noEmailMessage = "Please insert the email"
        successfulRefistrataion = "You have been registered successfully"
        successfullLogin = "You have logged in successfully"
        changeLangTitle = "Change Language"
        changeLangQuestion = "Do you want to change the language of the app to Russian?"
        setLangTitle = "Language Settings"
        setLangRequest = "What language do you want to use in the app?"
        attention = "Attention"
    }
    func changeToRus(){
        errTitle = "Ошибка"
        successTitle = "Успешно"
        passwordIsRequiredTitle = "Требуется пароль"
        passwordIsRequiredMessage = "Чтобы сменить электронную почту, пожалуйста, введите Ваш пароль ниже:"
        passwordErrorMessage = "Неправильно введен старый пароль. Хотите попробовать снова или мы можем отправить ссылку на смену пароля по почте?"
        linkSentTo = "Ваша ссылка для смены пароля была послана на "
        checkEmail = ". Проверьте электронную почту."
        cancelButton = "Отмена"
        okButton = "Ок"
        doneButton = "Готово!"
        tryAgainButton = "Попробовать снова"
        sendByEmailButton = "Отправить по почте"
        cameraButton = "Камера"
        galleryButton = "Галлерея"
        cameraErrorMessage = "Приложение не может найти доступ к Вашей камере"
        valuesChanged = "Данные были успещно изменены"
        passwordChanged = "Ваш пароль был успешно изменен"
        chooseNewProfileImageTitle = "Выбрать новую фотографию профиля"
        saveImageToDatabaseErrorMessage = "Что-то пошло не атк с сохранением вашей фотографии в памяти. Пожалуйста, попробуйте еще раз."
        somethingWendWrong = "Что-то пошло не так..."
        imageSaved = "Фотография была сохранена"
        enterTitle = "Введите название места"
        enterAddress = "Укажите адрес места"
        whatRecycle = "Укажите материалы, которые можно приносить сюда"
        writeOther = "Вы выбрали опцию ДРУГОЕ. Пожалуйста, укажите какие именно другие предметы можно сюда приносить"
        thankYou = "Спасибо!"
        placeEdited = "Место было успешно изменено"
        placeAdded = "Место было успено добавлено"
        loginReminder = "Чтобы добавить новое место Вам нужно войти в свой аккаунт"
        createNewPlaceTitle = "Добавление нового места"
        createNewPlaceMessage = "Выберите локацию нового места"
        logoutTitle = "Выйти"
        logoutQuestion = "Вы уверенны что хотите выйти?"
        loggedoutMessage = "Вы успешно вышли из профиля"
        yesButton = "Да"
        noButton = "Нет"
        noUsernameLabel = "Не найдено имя пользователя"
        noPasswordLabel = "Не найден пароль"
        noEmailLabel = "Не найдена электронная почта"
        noUsernameMessage = "Пожалуйста, введите имя"
        noPasswordMessage = "Пожалуйста, введите пароль. Не менее 6 символов в длину"
        noEmailMessage = "Пожалуйста, введите электронную почту"
        successfulRefistrataion = "Вы успешно зарегистрировались"
        successfullLogin = "Вы успешно вошли в приложение"
        changeLangTitle = "Изменить язык приложения"
        changeLangQuestion = "Вы точно хотите изменить язык приложения на английский?"
        setLangTitle = "Настройки языка"
        setLangRequest = "Какой язык Вы хотите использовать в приложении?"
        attention = "Внимание"
    }
}
