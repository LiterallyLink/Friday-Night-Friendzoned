import backend.window.composite.CompositeSprite;

class LoginSubState extends FlxSubState {
    private var windowComposite:CompositeSprite;
    private var windowManager:WindowManager;
    private var passwordField:FlxInputText;
    private var usernameField:FlxInputText;

    private var selectedUser:String;
    private var isNewUserRequired:Bool;

    private var okBtn:FlxButton;


    private function initWindow() {
        windowComposite = new CompositeSprite();
        
        var loginWindow = new FlxSprite().loadGraphic(Paths.image('menulogin/login_window'));
        loginWindow.screenCenter(XY);
        windowComposite.add(loginWindow);

        var loginHeader = new FlxSprite().loadGraphic(Paths.image('menulogin/login_header'));
        var headerPadding:Int = 6;
        loginHeader.y = -(loginHeader.height - headerPadding);
        windowComposite.add(loginHeader);

        windowComposite.screenCenter(XY);
        add(windowComposite);

        windowManager = new WindowManager(windowComposite);
        add(windowManager);
    }

    private function initLoginButtons() {
        var buttonPadding:Int = 15;
        var xBtnPadding:Int = 10;

        var cancelBtn:FlxButton = new FlxButton(0, 0, () -> {
            close();
        });
        cancelBtn.loadGraphic(Paths.image('menulogin/login_cancel'));
        cancelBtn.setPosition(
            windowComposite.width - (cancelBtn.width + buttonPadding),
            windowComposite.height - (cancelBtn.height + buttonPadding)
        );
    
        okBtn = new FlxButton(0, 0, () -> {});
        okBtn.loadGraphic(Paths.image('menulogin/login_dimmed_ok'));
        okBtn.setPosition(
            cancelBtn.x - (okBtn.width + buttonPadding),
            cancelBtn.y
        );
    
        var xBtn:FlxButton = new FlxButton(0, 0, () -> {
            close();
        });
        xBtn.loadGraphic(Paths.image('menulogin/login_x'));
        xBtn.setPosition(
            windowComposite.width - (xBtn.width + xBtnPadding),
            -(xBtn.height / 2)
        );

        windowComposite.add(cancelBtn);
        windowComposite.add(okBtn);
        windowComposite.add(xBtn);
    }

    private function initLoginInputFields() {
        var MAX_FIELD_LENGTH:Int = 14;
        var EREG_PATTERN = new EReg("[^a-zA-Z0-9]", "g");
        var FONT_SIZE:Int = 17;
        var FIELD_WIDTH:Int = 350;

        var xPos:Int = 185;
    
        passwordField = new FlxInputText(xPos, 185, FIELD_WIDTH, "", FONT_SIZE, FlxColor.BLACK, FlxColor.WHITE);
        passwordField.callback = keyPressCallback;
        passwordField.customFilterPattern = EREG_PATTERN;
        passwordField.maxLength = MAX_FIELD_LENGTH;
        windowComposite.add(passwordField);
            
        if (selectedUser == "newUser" && isNewUserRequired) {
            usernameField = new FlxInputText(xPos, 143, FIELD_WIDTH, "", FONT_SIZE, FlxColor.BLACK, FlxColor.WHITE);
            usernameField.callback = keyPressCallback;
            usernameField.customFilterPattern = EREG_PATTERN;
            usernameField.maxLength = MAX_FIELD_LENGTH;    
            windowComposite.add(usernameField);
            usernameField.hasFocus = true;
        } else {
            passwordField.hasFocus = true;
        }
    }

    private function initNewUser() {
        var loginIcon = new FlxSprite().loadGraphic(Paths.image('menulogin/icons/newUser'));
        loginIcon.scale.set(1.5, 1.5);
        loginIcon.x = 110;
        loginIcon.y = 70;
    
        var welcomeText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/login_welcome'));
        welcomeText.x = 315;
        welcomeText.y = 50;
    
        var loginText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/login_text'));
        loginText.x = 285;
        loginText.y = 90;
    
        var newUsername:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/login_new_username'));
        newUsername.x = 85;
        newUsername.y = 170;
    
        windowComposite.add(welcomeText);
        windowComposite.add(loginText);
        windowComposite.add(newUsername);
        windowComposite.add(loginIcon);
    }

    private function initPreExistingUser() {
        var userIcon:String = LoginState.USER_CREDENTIALS.exists(selectedUser) ? selectedUser : ClientPrefs.data.userCreatedIcon;
        var userName:String = LoginState.USER_CREDENTIALS.exists(selectedUser) ? LoginState.USER_CREDENTIALS[selectedUser].username : ClientPrefs.data.userCreatedName;
    
        var loginIcon = new FlxSprite().loadGraphic(Paths.image('menulogin/icons/${userIcon}'));
        loginIcon.scale.set(1.5, 1.5);
        loginIcon.x = windowComposite.width / 2 - loginIcon.width / 2;
        loginIcon.y = 100;
    
        var usernameText = new FlxText(userName, 30);
        usernameText.borderStyle = SHADOW;
        usernameText.x = windowComposite.width / 2 - usernameText.width / 2;
        usernameText.y = loginIcon.y + loginIcon.height + 20;
        
        windowComposite.add(usernameText);
        windowComposite.add(loginIcon);
    }

    private function keyPressCallback(text:String, action:String):Void {
        var randomInt:Int = FlxG.random.int(1, 5);
        FlxG.sound.play(Paths.sound('keyboard/keypress' + randomInt));
        updateOkButtonState();
    }
    
    private function updateOkButtonState():Void {
        var isActive:Bool = passwordField.text.length > 0;
        if (usernameField != null) {
            isActive = isActive && usernameField.text.length > 0;
        }
    
        if (isActive) {
            okBtn.loadGraphic(Paths.image('menulogin/login_ok'));
            okBtn.onUp.callback = validateLogin;
        } else {
            okBtn.loadGraphic(Paths.image('menulogin/login_dimmed_ok'));
            okBtn.onUp.callback = function() {};
        }
    }

    private function validateLogin():Void {
        if (selectedUser == "newUser" && isNewUserRequired) {
            handleNewUserCreation();
        } else {
            handleExistingUserLogin();
        }
    }
    
    private function handleNewUserCreation():Void {
        saveNewUserData();
        proceedToDesktop("Logging On...");
    }
    
    private function saveNewUserData():Void {
        ClientPrefs.data.userCreatedName = usernameField.text;
        ClientPrefs.data.userCreatedPassword = passwordField.text;
        ClientPrefs.data.userCreatedIcon = "default";
        ClientPrefs.data.needToCreateNewUser = false;
        ClientPrefs.saveSettings();
    }
    
    private function handleExistingUserLogin():Void {
        var expectedPassword = getExpectedPassword();
        
        if (passwordField.text == expectedPassword) {
            proceedToDesktop("Logging On...");
        } else {
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }
    }
    
    private function getExpectedPassword():String {
        return selectedUser == ClientPrefs.data.userCreatedIcon 
            ? ClientPrefs.data.userCreatedPassword
            : LoginState.USER_CREDENTIALS[selectedUser].password;
    }
    
    private function proceedToDesktop(loadingMessage:String):Void {
        close();
        var parentState = cast(FlxG.state, LoginState);
        parentState.initLoadingScreen(loadingMessage);
        FlxG.sound.play(Paths.sound('confirmMenu'));
        
        var randomDelay:Int = FlxG.random.int(1, 5);
        new FlxTimer().start(randomDelay, function(timer:FlxTimer) {
            LoadingState.loadAndSwitchState(new DesktopState());
        });
    }
}