package states;

import shaders.CRTShader;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import openfl.filters.ShaderFilter;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxPoint;
import flixel.addons.transition.FlxTransitionableState;

typedef CharacterCredentials = {
    var username:String;
    var password:String;
    var icon:String;
};

class LoginMenuState extends MusicBeatState {
    public var loginGroup:FlxSpriteContainer = new FlxSpriteContainer();
    public var backgroundLayer:FlxGroup = new FlxGroup();
    public var foregroundCloudGroup:FlxGroup = new FlxGroup();
    public var interfaceElements:FlxGroup = new FlxGroup();
    public var userIconButtons:FlxGroup = new FlxGroup();
    public var usernameGroup:FlxGroup = new FlxGroup();

    private var passwordField:FlxInputText;
    private var usernameField:FlxInputText;
    private var okBtn:FlxButton;
    public var loginHeader:FlxSprite;
    public var loginWindow:FlxSprite;

    private var loginWindowOpen:Bool = false;
    private var isWindowBeingDragged:Bool = false;
    private var windowDragOffset:FlxPoint = new FlxPoint();
    private var floatUp:Bool = true;
    private var loginTheme:String;
    private var createNewUser:Bool;
    private var selectedUser = "";

    public var crtEffect:CRTShader;

    public static final USER_CREDENTIALS:Map<String, CharacterCredentials> = [
        'bf' => { username: "Her Bf <3", password: "Beepbopbo", icon: "bf" },
        'gf' => { username: "His Gf <3", password: null, icon: "gf" },
        'darnell' => { username: "Darnell", password: null, icon: "darnell" },
        'father' => { username: "Daddy D.", password: null, icon: "father" },
        'mommy' => { username: "MOM CHANGE UR PFP", password: null, icon: "mommy" },
        'nene' => { username: "Nene", password: null, icon: "nene" },
        'pico' => { username: "pico", password: null, icon: "pico" },
        'senpai' => { username: "Sven", password: null, icon: "senpai" },
        'tank' => { username: "Steve", password: null, icon: "tank" },
        '87' => { username: "ITS ME", password: null, icon: "87" },
        'spooky' => { username: "SKID N' PUMP", password: null, icon: "spooky" },
    ];
    
    override function create() {
        loginTheme = ClientPrefs.data.desktopTheme;
        createNewUser = ClientPrefs.data.needToCreateNewUser;

        crtEffect = new CRTShader(0.3, 0.55);
        FlxG.camera.setFilters([new ShaderFilter(crtEffect)]);
        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;
        
        FlxG.sound.playMusic(Paths.music('loginMenu'), 0, true);
        FlxG.sound.music.fadeIn(4, 0, 0.7);
        FlxG.sound.play(Paths.sound('humming'), true);

        add(backgroundLayer);
        add(foregroundCloudGroup);
        add(interfaceElements);
        add(userIconButtons);
        add(usernameGroup);

        renderLoginMenu();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (loginWindowOpen && FlxG.mouse.justPressed && loginHeader.overlapsPoint(FlxG.mouse.getPosition())) {
            isWindowBeingDragged = true;
            windowDragOffset.set(FlxG.mouse.x - loginGroup.x, FlxG.mouse.y - loginGroup.y);
        }

        if (FlxG.mouse.justReleased) isWindowBeingDragged = false;

        if (isWindowBeingDragged) {
            loginGroup.setPosition(
                FlxG.mouse.x - windowDragOffset.x,
                FlxG.mouse.y - windowDragOffset.y
            );
        }
        
        if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
    }

    private function renderLoginMenu() {
        var theme = loginTheme;
    
        var loginBg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${theme}/bg'));
        var loginBgGradient:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${theme}/bg_gradient'));
        var borderSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${theme}/border'));
        var bgClouds:FlxSprite = new FlxSprite(488, 155).loadGraphic(Paths.image('loginmenu/${theme}/bg_clouds'));

        var welcomeSprite:FlxSprite = new FlxSprite(253, 276).loadGraphic(Paths.image('loginmenu/${theme}/welcome'));
        var loginPromptText:FlxSprite = new FlxSprite(229, 330).loadGraphic(Paths.image('loginmenu/${theme}/beginText'));
        var dividerSprite:FlxSprite = new FlxSprite(616, 203).loadGraphic(Paths.image('loginmenu/${theme}/divider'));

        var powerButton:FlxButton = new FlxButton(43, 629, handlePowerButtonClick);
        powerButton.loadGraphic(Paths.image('loginmenu/${theme}/off_switch'));

        backgroundLayer.add(loginBg);
        backgroundLayer.add(loginBgGradient);
        backgroundLayer.add(borderSprite);
        backgroundLayer.add(bgClouds);

        var cloudPositions:Array<{x:Int, y:Int}> = [
            {x: 248, y: 170},
            {x: 548, y: 185},
            {x: 968, y: 175}
        ];

        for (i in 0...cloudPositions.length) {
            var pos = cloudPositions[i];
            var cloud:FlxSprite = new FlxSprite(pos.x, pos.y).loadGraphic(Paths.image('loginmenu/${loginTheme}/foreground_cloud_${i + 1}'));
            foregroundCloudGroup.add(cloud);
        }

        interfaceElements.add(welcomeSprite);
        interfaceElements.add(loginPromptText);
        flashingEffect(loginPromptText, 2, 2);

        interfaceElements.add(dividerSprite);
        interfaceElements.add(powerButton);

        renderUsers();
    }

    function renderUsers() {
        final ICON_HEIGHT:Float = 59;
        final ICON_PADDING:Float = 3;
        final FONT_SIZE:Int = 30;
        final X_POS:Float = 794;
        var Y_POS:Float = 216;

        var users:Array<String> = ["bf", "gf"];
        var randomUsers:Array<String> = ["darnell", "father", "mommy", "nene", "pico", "senpai", "spooky", "tank"];
        FlxG.random.shuffle(randomUsers);

        if (FlxG.random.int(1, 100) == 87) randomUsers.push("87");
        users.push(randomUsers.pop());

        for (i in 0...users.length) {
            var icon:FlxButton = new FlxButton(X_POS, Y_POS, "", () -> {
                selectedUser = users[i];
                handleIconClick();
            });

            icon.loadGraphic(Paths.image('loginmenu/icons/${USER_CREDENTIALS[users[i]].icon}'));
            userIconButtons.add(icon);

            var usernameText = new FlxText(
                X_POS + ICON_HEIGHT,
                Y_POS + (ICON_HEIGHT / 2),
                USER_CREDENTIALS[users[i]].username,
                FONT_SIZE
            );

            usernameText.borderStyle = SHADOW;
            usernameText.y -= (usernameText.height / 2);
            usernameGroup.add(usernameText);

            Y_POS += (ICON_HEIGHT + ICON_PADDING);
        }
        
        var newUserIcon:FlxButton = new FlxButton(X_POS, Y_POS, "", () -> {
            selectedUser = "newUser";
            handleIconClick();
        });
        newUserIcon.loadGraphic(Paths.image(
            createNewUser ? 'loginmenu/icons/newUser' : 'loginmenu/icons/${ClientPrefs.data.userCreatedIcon}'
        ));
        userIconButtons.add(newUserIcon);

        var newUserText = new FlxText(
            X_POS + ICON_HEIGHT,
            Y_POS + (ICON_HEIGHT / 2),
            createNewUser ? "New User" : ClientPrefs.data.userCreatedName,
            FONT_SIZE
        );
        
        newUserText.borderStyle = SHADOW;
        newUserText.y -= (newUserText.height / 2);
        usernameGroup.add(newUserText);
    }

    private function handlePowerButtonClick():Void {
        FlxG.sound.music.stop();

        remove(interfaceElements);
        remove(userIconButtons);
        remove(usernameGroup);

        var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('friendzonedLogoSD${BootState.logoInt}'));
        logo.screenCenter(XY);
        add(logo);

        var text:FlxText = new FlxText(0, 0, 'FriendzonedOS is shutting down...', 15);
        text.x = (FlxG.width - text.width) / 2;
        text.y = logo.y + logo.height + 10;
        add(text);

        var loadingSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('loading'), true, 225, 225);
        loadingSprite.screenCenter(XY);
        loadingSprite.scale.set(0.5, 0.5);
        loadingSprite.y += 125;
        loadingSprite.animation.add("loading", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], 24);
        loadingSprite.animation.play("loading");
        add(loadingSprite);

        FlxG.sound.play(Paths.sound('shutdown'));

        new FlxTimer().start(3, function(timer:FlxTimer) {
            Sys.exit(1);
        });
    }

    private function handleIconClick():Void {
        if (loginWindowOpen) return;
    
        switch (selectedUser) {
            case "87":
                handleGoldenFreddyClick();
            case "newUser":
                if (createNewUser) {
                    openLoginWindow();
                } else {
                    // Handle existing custom user
                    selectedUser = ClientPrefs.data.userCreatedIcon;
                    openLoginWindow();
                }
            case "":
                trace("No user selected"); // Optional debug line
                return;
            default:
                openLoginWindow();
        }
    }

    private function handleGoldenFreddyClick():Void {
        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound('GoldenFreddyScream'));
        var goldenFreddy:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/Golden_Freddy'));
        add(goldenFreddy);
        new FlxTimer().start(3, function(timer:FlxTimer) {
            Sys.exit(1);
        });
    }

    private function openLoginWindow():Void {
        initLoginWindow();
        initLoginButtons();
        
        if (selectedUser == "newUser" && createNewUser) {
            initNewUser();
        } else {
            initPreExistingUser();
        }
    
        initLoginInputFields();
        add(loginGroup);
        loginWindowOpen = true;
    }

    private function initLoginWindow() {
        loginWindow = new FlxSprite().loadGraphic(Paths.image('loginmenu/login_window'));
        loginWindow.screenCenter(XY);

        var loginHeaderPadding:Int = 6;
        loginHeader = new FlxSprite().loadGraphic(Paths.image('loginmenu/login_header'));
        loginHeader.screenCenter(XY);
        loginHeader.y -= (loginWindow.height / 2) - loginHeader.height + loginHeaderPadding;

        loginGroup.add(loginHeader);
        loginGroup.add(loginWindow);
    }

    private function initLoginButtons() {
        var buttonPadding:Int = 15;
        var xBtnPadding:Int = 10;

        var cancelBtn:FlxButton = new FlxButton(0, 0, function() {
            closeFunction();
        });
        cancelBtn.loadGraphic(Paths.image('loginmenu/login_cancel'));
        cancelBtn.setPosition(
            (loginWindow.x + loginWindow.width) - (cancelBtn.width + buttonPadding),
            (loginWindow.y + loginWindow.height) - (cancelBtn.height + buttonPadding)
        );
    
        okBtn = new FlxButton(0, 0, function() {});
        okBtn.loadGraphic(Paths.image('loginmenu/login_dimmed_ok'));
        okBtn.setPosition(
            cancelBtn.x - (okBtn.width + buttonPadding),
            cancelBtn.y
        );
    
        var xBtn:FlxButton = new FlxButton(0, 0, function() {
            closeFunction();
        });
        xBtn.loadGraphic(Paths.image('loginmenu/login_x'));
        xBtn.setPosition(
            (loginWindow.x + loginWindow.width) - (xBtn.width + xBtnPadding),
            loginHeader.y + (loginHeader.height / 2) - (xBtn.height / 2)
        );

        loginGroup.add(cancelBtn);
        loginGroup.add(okBtn);
        loginGroup.add(xBtn);
    }

    private function initLoginInputFields() {
        var MAX_FIELD_LENGTH:Int = 10;
        var EREG_PATTERN = new EReg("[^a-zA-Z0-9]", "g");
        var FONT_SIZE:Int = 17;
    
        // Always create password field
        passwordField = new FlxInputText(510, 410, 350, "", FONT_SIZE, FlxColor.BLACK, FlxColor.WHITE);
        passwordField.callback = keyPressCallback;
        passwordField.customFilterPattern = EREG_PATTERN;
        passwordField.maxLength = MAX_FIELD_LENGTH;
        loginGroup.add(passwordField);
            
        // Only create username field for new users
        if (selectedUser == "newUser" && createNewUser) {
            usernameField = new FlxInputText(510, 368, 350, "", FONT_SIZE, FlxColor.BLACK, FlxColor.WHITE);
            usernameField.callback = keyPressCallback;
            usernameField.customFilterPattern = EREG_PATTERN;
            usernameField.maxLength = MAX_FIELD_LENGTH;    
            loginGroup.add(usernameField);
            usernameField.hasFocus = true;
        } else {
            passwordField.hasFocus = true;
        }
    }

    private function initNewUser() {
        var loginIcon = new FlxSprite().loadGraphic(Paths.image('loginmenu/icons/newUser'));
        loginIcon.scale.set(1.5, 1.5);
        loginIcon.screenCenter(XY);
    
        loginIcon.y -= 80;
        loginIcon.x -= 190;
    
        var welcomeText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('loginmenu/login_welcome'));
        welcomeText.screenCenter(XY);
        welcomeText.y -= 100;
        welcomeText.x += 50;
        loginGroup.add(welcomeText);
    
        var loginText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('loginmenu/login_text'));
        loginText.screenCenter(XY);
        loginText.y -= 60;
        loginText.x += 20;
        loginGroup.add(loginText);
    
        var newUsername:FlxSprite = new FlxSprite().loadGraphic(Paths.image('loginmenu/login_new_username'));
        newUsername.screenCenter(XY);
        newUsername.x -= 180;
        newUsername.y += 20;
        loginGroup.add(newUsername);
    
        loginGroup.add(loginIcon);
    }

    private function initPreExistingUser() {
        var userIcon:String = USER_CREDENTIALS.exists(selectedUser) ? selectedUser : ClientPrefs.data.userCreatedIcon;
        var userName:String = USER_CREDENTIALS.exists(selectedUser) ? USER_CREDENTIALS[selectedUser].username : ClientPrefs.data.userCreatedName;
    
        var loginIcon = new FlxSprite().loadGraphic(Paths.image('loginmenu/icons/${userIcon}'));
        loginIcon.scale.set(1.5, 1.5);
        loginIcon.screenCenter(XY);
    
        loginIcon.y -= 50;
    
        var usernameText = new FlxText(userName, 30);
        usernameText.borderStyle = SHADOW;
        usernameText.screenCenter(XY);
        usernameText.y += 20;
        
        loginGroup.add(usernameText);
        loginGroup.add(loginIcon);
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
            okBtn.loadGraphic(Paths.image('loginmenu/login_ok'));
            okBtn.onUp.callback = validateLogin;
        } else {
            okBtn.loadGraphic(Paths.image('loginmenu/login_dimmed_ok'));
            okBtn.onUp.callback = function() {};
        }
    }

    private function validateLogin():Void {
        if (selectedUser == "newUser" && createNewUser) {
            // Handle new user creation
            if (usernameField != null && usernameField.text.length > 0 && passwordField.text.length > 0) {
                ClientPrefs.data.userCreatedName = usernameField.text;
                ClientPrefs.data.userCreatedPassword = passwordField.text;
                ClientPrefs.data.userCreatedIcon = "default"; // Set default icon for new user
                ClientPrefs.data.needToCreateNewUser = false;
                ClientPrefs.saveSettings();
                
                // Transition to main menu or next state
                FlxG.sound.play(Paths.sound('confirmMenu'));
                // Add your transition code here
            } else {
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }
        } else {
            // Handle existing user login
            var credentials:CharacterCredentials = selectedUser == ClientPrefs.data.userCreatedIcon ? 
                { username: ClientPrefs.data.userCreatedName, password: ClientPrefs.data.userCreatedPassword, icon: ClientPrefs.data.userCreatedIcon } :
                USER_CREDENTIALS[selectedUser];

            if (passwordField.text == credentials.password) {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                    // Add your successful login transition code here
                trace("Logging in as " + credentials.username);
            } else {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                trace("Incorrect password");
                    // Optionally show error message
            }
        }
    }
    
    private function closeFunction():Void {
        loginGroup.clear();
        loginGroup.setPosition(0, 0);
        loginWindowOpen = false;
        selectedUser = "";

        if (passwordField != null) {
            passwordField.text = "";
        }
    
        if (usernameField != null) {
            usernameField.text = "";
            usernameField = null;
        }
    }

    override function beatHit() {
        super.beatHit();

        var floatInt:Int = floatUp ? 1 : -1;

        for (i in 0...4) {
            var icon:FlxSprite = cast userIconButtons.members[i];
            var username:FlxText = cast usernameGroup.members[i];
            icon.y += floatInt;
            username.y += floatInt;
        }

        floatUp = !floatUp;

        for (i in 0...foregroundCloudGroup.length) {
            var cloud:FlxSprite = cast foregroundCloudGroup.members[i];
            if (!cloud.isOnScreen()) {
                cloud.x = -cloud.width + 1;
            }
            
            switch (FlxG.random.int(0, 3)) {
                case 0:
                    cloud.y += 1;
                    cloud.x += 1;
                case 1:
                    cloud.y -= 1;
                    cloud.x += 1;
                case 2:
                    cloud.x += 1;
            }
        }
    }

    private function flashingEffect(sprite:FlxSprite, fadeInDuration:Float, fadeOutDuration:Float):Void {
        FlxSpriteUtil.fadeIn(sprite, fadeInDuration, true, function(tween:FlxTween):Void {
            FlxSpriteUtil.fadeOut(sprite, fadeOutDuration, function(tween:FlxTween):Void {
                flashingEffect(sprite, fadeInDuration, fadeOutDuration);
            });
        });
    }
}