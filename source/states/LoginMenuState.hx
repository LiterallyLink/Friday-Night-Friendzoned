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

class LoginMenuState extends MusicBeatState {
    private var passwordInput:FlxInputText;
    private var usernameInput:FlxInputText;
    private var okBtn:FlxButton;
    public var loginHeader:FlxSprite;
    public var loginGroup:FlxSpriteContainer = new FlxSpriteContainer();

    public var loginMenuBg:FlxGroup = new FlxGroup();
    public var foregroundCloudGroup:FlxGroup = new FlxGroup();
    public var loginMenuUI:FlxGroup = new FlxGroup();
    public var loginIconGroup:FlxGroup = new FlxGroup();
    public var usernameGroup:FlxGroup = new FlxGroup();

    public var shader:CRTShader;
    private var floatUp:Bool = true;

    public var loginWindow:FlxSprite;
    private var loginWindowOpen:Bool = false;
    private var loginTheme:String;

    private var isDragging:Bool = false;
    private var dragOffset:FlxPoint = new FlxPoint();

    public static final USERNAME_MAP:Map<String, String> = [
        'bf' => "Her Bf <3",
        'gf' => "His Gf <3",
        'darnell' => "Darnell",
        'father' => "Daddy D.",
        'mommy' => "MOM CHANGE UR PFP",
        'nene' => "Nene",
        'pico' => "pico",
        'senpai' => "Sven",
        'tank' => "Steve",
        '87' => "ITS ME",
        'spooky' => "SKID N' PUMP",
        "newUser" => "New User"
    ];
    
    override function create() {
        var sound:FlxSound = null;
        loginTheme = ClientPrefs.data.desktopTheme;

        shader = new CRTShader(0.3, 0.55);
        FlxG.camera.setFilters([new ShaderFilter(shader)]);

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;
        
        FlxG.sound.playMusic(Paths.music('loginMenu'), 0, true);
        FlxG.sound.music.fadeIn(4, 0, 0.7);

        FlxG.sound.play(Paths.sound('humming'), true);

        add(loginMenuBg);
        add(foregroundCloudGroup);
        add(loginMenuUI);
        add(loginIconGroup);
        add(usernameGroup);

        renderLoginMenu(loginTheme);
    }

    override function destroy() {
        super.destroy();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (loginWindowOpen) {
            handleDragging();
        }
        
        updateSongPosition();
    }
    
    private function handleDragging():Void {
        if (FlxG.mouse.justPressed && loginHeader.overlapsPoint(FlxG.mouse.getPosition())) {
            isDragging = true;
            dragOffset.set(
                FlxG.mouse.x - loginGroup.x,
                FlxG.mouse.y - loginGroup.y
            );
        }
        
        if (FlxG.mouse.justReleased) {
            isDragging = false;
        }
        
        if (isDragging) {
            loginGroup.setPosition(
                FlxG.mouse.x - dragOffset.x,
                FlxG.mouse.y - dragOffset.y
            );
        }
    }
    
    private function updateSongPosition():Void {
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
    }

    private function handleMouseClick(sprite:String = ""):Void {
        if (loginWindowOpen) return;

        switch (sprite) {
            case "newUser":
                openLoginWindow(true, sprite);
            case "shutdown":
                handlePowerButtonClick();
            case "87":
                handleGoldenFreddyClick();
            default:
                openLoginWindow(false, sprite);
        }
    }

    private function openLoginWindow(?newUser:Bool = false, userIcon:String):Void {
        initLoginWindow();
        initLoginButtons();
        initInputFields(newUser);
        initUserSpecificElements(newUser, userIcon);
        loginWindowOpen = true;
    }
    
    private function initLoginWindow():Void {
        loginWindow = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/login_window'));
        loginWindow.screenCenter(XY);

        loginHeader = new FlxSprite().loadGraphic(Paths.image('loginmenu/login_header'));
        loginHeader.screenCenter(XY);
        loginHeader.y -= (loginWindow.height / 2) - loginHeader.height + 6;

        loginGroup.add(loginHeader);
        loginGroup.add(loginWindow);
    }
    
    private function initLoginButtons():Void {
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
    
        trace(loginWindow.width - (cancelBtn.width + buttonPadding));
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

    private function inputCallback(text:String, action:String):Void {
        var randomInt:Int = FlxG.random.int(1, 5);
        FlxG.sound.play(Paths.sound('keyboard/keypress' + randomInt));
        updateOkButtonState();
    }
    
    private function initInputFields(newUser:Bool):Void {
        passwordInput = new FlxInputText(510, 410, 350, "", 17, FlxColor.BLACK, FlxColor.WHITE);
        passwordInput.customFilterPattern = new EReg("[^a-zA-Z0-9]", "g");
        passwordInput.maxLength = 10;
        loginGroup.add(passwordInput);
    
        passwordInput.callback = inputCallback;
        
        if (newUser) {
            usernameInput = new FlxInputText(510, 368, 350, "", 17, FlxColor.BLACK, FlxColor.WHITE);
            usernameInput.customFilterPattern = new EReg("[^a-zA-Z0-9]", "g");
            usernameInput.maxLength = 10;
            usernameInput.hasFocus = true;
            loginGroup.add(usernameInput);
    
            usernameInput.callback = inputCallback;
        } else {
            passwordInput.hasFocus = true;
        }
    }
    
    private function initUserSpecificElements(newUser:Bool, userIcon:String):Void {
        var loginIcon = new FlxSprite().loadGraphic(Paths.image('loginmenu/icons/' + userIcon));
        loginIcon.scale.set(1.5, 1.5);
        loginIcon.screenCenter(XY);
    
        if (newUser) {
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
        } else {
            loginIcon.y -= 50;
    
            var usernameText = new FlxText(USERNAME_MAP[userIcon], 30);
            usernameText.borderStyle = SHADOW;
            usernameText.screenCenter(XY);
            usernameText.y += 20;
            loginGroup.add(usernameText);
        }
    
        loginGroup.add(loginIcon);
        add(loginGroup);
    }
    
    private function updateOkButtonState():Void {
        var isActive:Bool = passwordInput.text.length > 0;
        if (usernameInput != null) {
            isActive = isActive && usernameInput.text.length > 0;
        }
    
        if (isActive) {
            okBtn.loadGraphic(Paths.image('loginmenu/login_ok'));
            okBtn.onUp.callback = function() {
                LoadingState.loadAndSwitchState(new DesktopState());
            }
        } else {
            okBtn.loadGraphic(Paths.image('loginmenu/login_dimmed_ok'));
            okBtn.onUp.callback = function() {};
        }
    }
    
    private function closeFunction():Void {
        loginGroup.clear();
        loginGroup.setPosition(0, 0);
        loginWindowOpen = false;

        if (passwordInput != null) {
            passwordInput.text = "";
        }
    
        if (usernameInput != null) {
            usernameInput.text = "";
            usernameInput = null;
        }
    }

    private function handlePowerButtonClick():Void {
        FlxG.sound.music.stop();
        remove(loginMenuUI);
        remove(loginIconGroup);
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

    private function handleGoldenFreddyClick():Void {
        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound('GoldenFreddyScream'));
        var goldenFreddy:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/Golden_Freddy'));
        add(goldenFreddy);
        new FlxTimer().start(3, function(timer:FlxTimer) {
            Sys.exit(1);
        });
    }

    override function beatHit() {
        super.beatHit();

        var floatInt:Int = floatUp ? 1 : -1;

        for (i in 0...4) {
            var icon:FlxSprite = cast loginIconGroup.members[i];
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

    function renderLoginMenu(loginTheme:String) {
        var loginBg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${loginTheme}/bg'));
        var loginBgGradient:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${loginTheme}/bg_gradient'));
        var borderSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${loginTheme}/border'));
        var bgClouds:FlxSprite = new FlxSprite(488, 155).loadGraphic(Paths.image('loginmenu/${loginTheme}/bg_clouds'));

        var welcomeSprite:FlxSprite = new FlxSprite(253, 276).loadGraphic(Paths.image('loginmenu/${loginTheme}/welcome'));
        var clickToBegin:FlxSprite = new FlxSprite(229, 330).loadGraphic(Paths.image('loginmenu/${loginTheme}/beginText'));
        var dividerSprite:FlxSprite = new FlxSprite(616, 203).loadGraphic(Paths.image('loginmenu/${loginTheme}/divider'));

        var shutdownBtn:FlxButton = new FlxButton(43, 629, function() {
            handleMouseClick("shutdown");
        });

        shutdownBtn.loadGraphic(Paths.image('loginmenu/${loginTheme}/off_switch'));

        loginMenuBg.add(loginBg);
        loginMenuBg.add(loginBgGradient);
        loginMenuBg.add(borderSprite);
        loginMenuBg.add(bgClouds);

        addForegroundClouds(loginTheme);

        loginMenuUI.add(welcomeSprite);
        loginMenuUI.add(clickToBegin);
        flashingEffect(clickToBegin, 2, 2);

        loginMenuUI.add(dividerSprite);
        loginMenuUI.add(shutdownBtn);

        renderUsers();
    }

    function renderUsers() {
        var icons:Array<String> = ["bf", "gf"];
        var randomUserArray:Array<String> = ["darnell", "father", "mommy", "nene", "pico", "senpai", "spooky", "tank"];
        FlxG.random.shuffle(randomUserArray);

        if (FlxG.random.int(1, 100) == 87) randomUserArray.push("87");
        var randomUser:String = randomUserArray.pop();

        icons.push(randomUser);
        icons.push("newUser");

        var iconHeight:Float = 59;
        var iconPadding:Float = 3;
        var xPos:Float = 794;
        var yPos:Float = 216;

        for (i in 0...icons.length) {
            var iconName = icons[i];
            var icon:FlxButton = new FlxButton(xPos, yPos, function() {
                handleMouseClick(iconName);
            });

            icon.loadGraphic(Paths.image('loginmenu/icons/' + iconName));
            loginIconGroup.add(icon);

            var usernameText = new FlxText(xPos + 59, yPos + (iconHeight / 2), USERNAME_MAP[iconName], 30);
            usernameText.borderStyle = SHADOW;
            usernameText.y -= (usernameText.height / 2);
            usernameGroup.add(usernameText);

            yPos += (iconHeight + iconPadding);
        } 
    }

    private function addForegroundClouds(loginTheme:String):Void {
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
    }

    private function flashingEffect(sprite:FlxSprite, fadeInDuration:Float, fadeOutDuration:Float):Void {
        FlxSpriteUtil.fadeIn(sprite, fadeInDuration, true, function(tween:FlxTween):Void {
            FlxSpriteUtil.fadeOut(sprite, fadeOutDuration, function(tween:FlxTween):Void {
                flashingEffect(sprite, fadeInDuration, fadeOutDuration);
            });
        });
    }
}