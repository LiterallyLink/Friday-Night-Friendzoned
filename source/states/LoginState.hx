package states;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import openfl.filters.ShaderFilter;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.addons.transition.FlxTransitionableState;
import substates.LoginWindowSubState;
import shaders.CRTShader;

typedef CharacterCredentials = {
    var username:String;
    var password:String;
    var icon:String;
}

class LoginState extends MusicBeatState {
    public var backgroundElements:FlxGroup = new FlxGroup();
    public var foregroundCloudGroup:FlxGroup = new FlxGroup();
    public var interfaceElements:FlxGroup = new FlxGroup();
    public var userIcons:FlxGroup = new FlxGroup();
    public var usernameGroup:FlxGroup = new FlxGroup();

    private var floatUp:Bool = true;
    private var loginTheme:String;
    private var isNewUserRequired:Bool;
    private var selectedUser:String = "";

    public var crtShader:CRTShader;

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
        isNewUserRequired = ClientPrefs.data.needToCreateNewUser;

        FlxTransitionableState.skipNextTransIn = true;
        persistentUpdate = true;
        persistentDraw = true;

        crtShader = new CRTShader(0.3, 0.55);
        FlxG.camera.setFilters([new ShaderFilter(crtShader)]);
        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;
        
        FlxG.sound.playMusic(Paths.music('loginMenu'), 0, true);
        FlxG.sound.music.fadeIn(4, 0, 0.7);
        FlxG.sound.play(Paths.sound('humming'), true);

        add(backgroundElements);
        add(foregroundCloudGroup);
        add(interfaceElements);
        add(userIcons);
        add(usernameGroup);

        renderLoginMenu();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
    }

    private function renderLoginMenu() {
        var theme = loginTheme;
    
        var loginBg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menulogin/${theme}/bg'));
        var loginBgGradient:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menulogin/${theme}/bg_gradient'));
        var borderSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menulogin/${theme}/border'));
        var bgClouds:FlxSprite = new FlxSprite(488, 155).loadGraphic(Paths.image('menulogin/${theme}/bg_clouds'));

        var welcomeSprite:FlxSprite = new FlxSprite(253, 276).loadGraphic(Paths.image('menulogin/${theme}/welcome'));
        var loginPromptText:FlxSprite = new FlxSprite(229, 330).loadGraphic(Paths.image('menulogin/${theme}/beginText'));
        var dividerSprite:FlxSprite = new FlxSprite(616, 203).loadGraphic(Paths.image('menulogin/${theme}/divider'));

        var powerButton:FlxButton = new FlxButton(43, 629, handlePowerButtonClick);
        powerButton.loadGraphic(Paths.image('menulogin/${theme}/off_switch'));

        // add a button adjacent to powerButton that runs clearUserData()

        var resetButton:FlxButton = new FlxButton(powerButton.x + powerButton.width, powerButton.y, "Refresh Login Menu", () -> {
                ClientPrefs.data.userCreatedName = "";
                ClientPrefs.data.userCreatedPassword = "";
                ClientPrefs.data.userCreatedIcon = "";
                ClientPrefs.data.needToCreateNewUser = true;
                ClientPrefs.saveSettings();
        
                FlxG.switchState(new LoginState());
        });
        interfaceElements.add(resetButton);

        backgroundElements.add(loginBg);
        backgroundElements.add(loginBgGradient);
        backgroundElements.add(borderSprite);
        backgroundElements.add(bgClouds);

        var cloudPositions:Array<{x:Int, y:Int}> = [
            {x: 248, y: 170},
            {x: 548, y: 185},
            {x: 968, y: 175}
        ];

        for (i in 0...cloudPositions.length) {
            var pos = cloudPositions[i];
            var cloud:FlxSprite = new FlxSprite(pos.x, pos.y).loadGraphic(Paths.image('menulogin/${loginTheme}/foreground_cloud_${i + 1}'));
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

        if (FlxG.random.int(1, 100) == 87) {
            randomUsers.push("87");
        }
 
        users.push(randomUsers.pop());

        for (i in 0...users.length) {
            var currentUser = users[i];
            var credentials = USER_CREDENTIALS[currentUser];

            var icon:FlxButton = new FlxButton(X_POS, Y_POS, "", () -> {
                if (subState != null) return;
                selectedUser = currentUser;
                handleIconClick();
            });

            icon.loadGraphic(Paths.image('menulogin/icons/${credentials.icon}'));
            userIcons.add(icon);

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
            if (subState != null) return;
            selectedUser = "newUser";
            handleIconClick();
        });
        newUserIcon.loadGraphic(Paths.image(
            isNewUserRequired ? 'menulogin/icons/newUser' : 'menulogin/icons/${ClientPrefs.data.userCreatedIcon}'
        ));
        userIcons.add(newUserIcon);

        var newUserText = new FlxText(
            X_POS + ICON_HEIGHT,
            Y_POS + (ICON_HEIGHT / 2),
            isNewUserRequired ? "New User" : ClientPrefs.data.userCreatedName,
            FONT_SIZE
        );
        
        newUserText.borderStyle = SHADOW;
        newUserText.y -= (newUserText.height / 2);
        usernameGroup.add(newUserText);
    }

    private function handlePowerButtonClick():Void {
        if (subState != null) return;

        FlxG.sound.music.stop();
        initLoadingScreen("FriendzonedOS is shutting down...");

        FlxG.sound.play(Paths.sound('shutdown'));

        new FlxTimer().start(3, function(timer:FlxTimer) {
            Sys.exit(1);
        });
    }

    private function handleIconClick():Void {
        if (selectedUser == "87") {
            handleGoldenFreddyClick();
            return;
        }
        
        if (selectedUser == "newUser" && !isNewUserRequired) {
            selectedUser = ClientPrefs.data.userCreatedIcon;
        }
        
        openSubState(new LoginWindowSubState(selectedUser, isNewUserRequired));
    }

    private function handleGoldenFreddyClick():Void {
        remove(interfaceElements);
        remove(userIcons);
        remove(usernameGroup);
        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound('GoldenFreddyScream'));
        var goldenFreddy:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menulogin/fnaf/Golden_Freddy'));
        add(goldenFreddy);
        new FlxTimer().start(3, function(timer:FlxTimer) {
            Sys.exit(1);
        });
    }

    public function initLoadingScreen(message:String):Void {
        remove(interfaceElements);
        remove(userIcons);
        remove(usernameGroup);

        var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logos/friendzonedLoadingLogo${BootState.logoVariant}'));
        logo.screenCenter(XY);
        add(logo);

        var text:FlxText = new FlxText(0, 0, message, 15);
        text.borderStyle = SHADOW;
        text.x = (FlxG.width - text.width) / 2;
        text.y = logo.y + logo.height + 10;
        add(text);

        var loadingSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('loading'), true, 225, 225);
        loadingSprite.screenCenter(XY);
        loadingSprite.scale.set(0.5, 0.5);
        loadingSprite.y += 125;
        loadingSprite.animation.add("loading", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 24);
        loadingSprite.animation.play("loading");
        add(loadingSprite);
    }

    override function beatHit() {
        super.beatHit();

        var floatInt:Int = floatUp ? 1 : -1;

        for (i in 0...4) {
            var icon:FlxSprite = cast userIcons.members[i];
            var username:FlxText = cast usernameGroup.members[i];
            icon.y += floatInt;
            username.y += floatInt;
            trace(floatInt);
        }

        floatUp = !floatUp;

        var cloudDirections:Array<Int> = [for (i in 0...foregroundCloudGroup.length) FlxG.random.int(0, 2)];
        var CLOUD_SPEED:Float = 1.0;

        for (i in 0...foregroundCloudGroup.length) {
            var cloud:FlxSprite = cast foregroundCloudGroup.members[i];
            if (!cloud.isOnScreen()) {
                cloud.x = -cloud.width + 1;
                cloudDirections[i] = FlxG.random.int(0, 2);
            }
            
            switch (cloudDirections[i]) {
                case 0:
                    cloud.y += CLOUD_SPEED;
                    cloud.x += CLOUD_SPEED;
                case 1:
                    cloud.y -= CLOUD_SPEED;
                    cloud.x += CLOUD_SPEED;
                case 2:
                    cloud.x += CLOUD_SPEED;
            }

            trace(cloud.y, cloud.x);
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