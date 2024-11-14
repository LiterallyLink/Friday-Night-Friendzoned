package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.group.FlxSpriteContainer;
import flixel.addons.ui.FlxInputText;
import flixel.math.FlxPoint;

import states.LoginState;
import states.DesktopState;

import backend.DragManager;

class LoginWindowSubState extends FlxSubState {
    private var loginWindowContainer:FlxSpriteContainer = new FlxSpriteContainer();
    private var passwordField:FlxInputText;
    private var usernameField:FlxInputText;
    private var loginHeader:FlxSprite;
    private var loginWindow:FlxSprite;

    private var isWindowBeingDragged:Bool = false;
    private var dragOffset:FlxPoint = new FlxPoint();
    private var selectedUser:String;
    private var isNewUserRequired:Bool;

    private var okBtn:FlxButton;

    public function new(selectedUser:String, isNewUserRequired:Bool) {
        super();

        this.selectedUser = selectedUser;
        this.isNewUserRequired = isNewUserRequired;
    }

    override function create() {
        super.create();
        initLoginWindow();
        initLoginButtons();
        
        if (selectedUser == "newUser" && isNewUserRequired) {
            initNewUser();
        } else {
            initPreExistingUser();
        }
    
        initLoginInputFields();
        add(loginWindowContainer);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    private function initLoginWindow() {
        loginWindow = new FlxSprite().loadGraphic(Paths.image('menulogin/login_window'));
        loginWindow.screenCenter(XY);

        var loginHeaderPadding:Int = 6;
        loginHeader = new FlxSprite().loadGraphic(Paths.image('menulogin/login_header'));
        loginHeader.screenCenter(XY);
        loginHeader.y -= (loginWindow.height / 2) - loginHeader.height + loginHeaderPadding;

        loginWindowContainer.add(loginHeader);
        loginWindowContainer.add(loginWindow);
    }

    private function initLoginButtons() {
        var buttonPadding:Int = 15;
        var xBtnPadding:Int = 10;

        var cancelBtn:FlxButton = new FlxButton(0, 0, () -> {
            close();
        });
        cancelBtn.loadGraphic(Paths.image('menulogin/login_cancel'));
        cancelBtn.setPosition(
            (loginWindow.x + loginWindow.width) - (cancelBtn.width + buttonPadding),
            (loginWindow.y + loginWindow.height) - (cancelBtn.height + buttonPadding)
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
            (loginWindow.x + loginWindow.width) - (xBtn.width + xBtnPadding),
            loginHeader.y + (loginHeader.height / 2) - (xBtn.height / 2)
        );

        loginWindowContainer.add(cancelBtn);
        loginWindowContainer.add(okBtn);
        loginWindowContainer.add(xBtn);
    }

    private function initLoginInputFields() {
        var MAX_FIELD_LENGTH:Int = 14;
        var EREG_PATTERN = new EReg("[^a-zA-Z0-9]", "g");
        var FONT_SIZE:Int = 17;
        var FIELD_WIDTH:Int = 350;

        var xPos:Int = 510;
    
        passwordField = new FlxInputText(xPos, 410, FIELD_WIDTH, "", FONT_SIZE, FlxColor.BLACK, FlxColor.WHITE);
        passwordField.callback = keyPressCallback;
        passwordField.customFilterPattern = EREG_PATTERN;
        passwordField.maxLength = MAX_FIELD_LENGTH;
        loginWindowContainer.add(passwordField);
            
        if (selectedUser == "newUser" && isNewUserRequired) {
            usernameField = new FlxInputText(xPos, 368, FIELD_WIDTH, "", FONT_SIZE, FlxColor.BLACK, FlxColor.WHITE);
            usernameField.callback = keyPressCallback;
            usernameField.customFilterPattern = EREG_PATTERN;
            usernameField.maxLength = MAX_FIELD_LENGTH;    
            loginWindowContainer.add(usernameField);
            usernameField.hasFocus = true;
        } else {
            passwordField.hasFocus = true;
        }
    }

    private function initNewUser() {
        var loginIcon = new FlxSprite().loadGraphic(Paths.image('menulogin/icons/newUser'));
        loginIcon.scale.set(1.5, 1.5);
        loginIcon.screenCenter(XY);
    
        loginIcon.y -= 80;
        loginIcon.x -= 190;
    
        var welcomeText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/login_welcome'));
        welcomeText.screenCenter(XY);
        welcomeText.y -= 100;
        welcomeText.x += 50;
        loginWindowContainer.add(welcomeText);
    
        var loginText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/login_text'));
        loginText.screenCenter(XY);
        loginText.y -= 60;
        loginText.x += 20;
        loginWindowContainer.add(loginText);
    
        var newUsername:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/login_new_username'));
        newUsername.screenCenter(XY);
        newUsername.x -= 180;
        newUsername.y += 20;
        loginWindowContainer.add(newUsername);
    
        loginWindowContainer.add(loginIcon);
    }

    private function initPreExistingUser() {
        var userIcon:String = LoginState.USER_CREDENTIALS.exists(selectedUser) ? selectedUser : ClientPrefs.data.userCreatedIcon;
        var userName:String = LoginState.USER_CREDENTIALS.exists(selectedUser) ? LoginState.USER_CREDENTIALS[selectedUser].username : ClientPrefs.data.userCreatedName;
    
        var loginIcon = new FlxSprite().loadGraphic(Paths.image('menulogin/icons/${userIcon}'));
        loginIcon.scale.set(1.5, 1.5);
        loginIcon.screenCenter(XY);
    
        loginIcon.y -= 50;
    
        var usernameText = new FlxText(userName, 30);
        usernameText.borderStyle = SHADOW;
        usernameText.screenCenter(XY);
        usernameText.y += 20;
        
        loginWindowContainer.add(usernameText);
        loginWindowContainer.add(loginIcon);
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