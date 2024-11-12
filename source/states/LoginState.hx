package states;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;

import backend.ShaderManager;
import backend.Achievements;
import flixel.addons.transition.FlxTransitionableState;

import substates.LoginWindowSubState;

typedef CharacterCredentials = {
    var username:String;
    var password:String;
    var icon:String;
}

class LoginState extends MusicBeatState {
    public var backgroundElements:FlxGroup = new FlxGroup();
    public var interfaceElements:FlxGroup = new FlxGroup();
    public var userElements:FlxGroup = new FlxGroup();

    public var foregroundCloudGroup:FlxGroup = new FlxGroup();
    private var floatUp:Bool = true;

    private var loginTheme:String;
    private var isNewUserRequired:Bool;
    private var selectedUser:String = "";

    private var dayCycleSprite:FlxSprite;
    private var clockText:FlxText;
    private var clockTimer:FlxTimer;
    private var updateTimer:FlxTimer;

    public static final USER_CREDENTIALS:Map<String, CharacterCredentials> = [
        'bf' => { username: "Her Bf <3", password: "Bopeebo", icon: "bf" },
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
        ShaderManager.getInstance().applyShaders();

        persistentUpdate = true;
        persistentDraw = true;

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;
        
        FlxG.sound.playMusic(Paths.music('loginMenu'), 0, true);
        FlxG.sound.music.fadeIn(4, 0, 0.7);

        FlxG.sound.play(Paths.sound('humming'), true);

        add(backgroundElements);
        add(foregroundCloudGroup);
        add(interfaceElements);
        add(userElements);

        renderLoginMenu();
        checkGoldenFreddyAchievement();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
    }

    private function renderLoginMenu() {
        var theme = loginTheme;
    
        var loginBg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/${theme}/bg'));
        var loginBgGradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/${theme}/bg_gradient'));
        var borderSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menulogin/${theme}/border'));
        var bgClouds:FlxSprite = new FlxSprite(488, 155).loadGraphic(Paths.image('menulogin/${theme}/bg_clouds'));

        var welcomeSprite:FlxSprite = new FlxSprite(253, 276).loadGraphic(Paths.image('menulogin/${theme}/welcome'));
        var loginPromptText:FlxSprite = new FlxSprite(229, 330).loadGraphic(Paths.image('menulogin/${theme}/beginText'));
        var dividerSprite:FlxSprite = new FlxSprite(616, 203).loadGraphic(Paths.image('menulogin/${theme}/divider'));

        dayCycleSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menulogin/sun'));
        dayCycleSprite.x = FlxG.width - (dayCycleSprite.width * 2);
        dayCycleSprite.y = dayCycleSprite.height / 1.5;

        clockText = new FlxText(0, 0, "00:00");
        clockText.setFormat(null, 15, FlxColor.WHITE, CENTER);
        clockText.x = dayCycleSprite.x + (dayCycleSprite.width / 2) - (clockText.width / 2);
        clockText.y = dayCycleSprite.y + dayCycleSprite.height + 5;

        updateTimeDisplay();

        final powerButton:FlxButton = new FlxButton(43, 629, () -> {
            handlePowerButtonClick();
        });
        powerButton.loadGraphic(Paths.image('menulogin/${theme}/off_switch'));

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

        interfaceElements.add(clockText);
        interfaceElements.add(dayCycleSprite);

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
            userElements.add(icon);

            var usernameText = new FlxText(
                X_POS + ICON_HEIGHT,
                Y_POS + (ICON_HEIGHT / 2),
                USER_CREDENTIALS[users[i]].username,
                FONT_SIZE
            );

            usernameText.borderStyle = SHADOW;
            usernameText.y -= (usernameText.height / 2);
            userElements.add(usernameText);

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
        userElements.add(newUserIcon);

        var newUserText = new FlxText(
            X_POS + ICON_HEIGHT,
            Y_POS + (ICON_HEIGHT / 2),
            isNewUserRequired ? "New User" : ClientPrefs.data.userCreatedName,
            FONT_SIZE
        );
        
        newUserText.borderStyle = SHADOW;
        newUserText.y -= (newUserText.height / 2);
        userElements.add(newUserText);
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
        remove(userElements);
        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound('GoldenFreddyScream'));
        var goldenFreddy:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menulogin/fnaf/Golden_Freddy'));
        add(goldenFreddy);

        if (ClientPrefs.data.ITSME == false) {
            ClientPrefs.data.ITSME = true;
            ClientPrefs.saveSettings();
        }

        new FlxTimer().start(3, function(timer:FlxTimer) {
            Sys.exit(1);
        });
    }

    private function checkGoldenFreddyAchievement():Void {
        if (ClientPrefs.data.ITSME) {
            Achievements.unlock("five_night_feddy", true);
        }
    }

    public function initLoadingScreen(message:String):Void {
        remove(interfaceElements);
        remove(userElements);

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

        for (i in 0...userElements.length) {
            var elements:FlxSprite = cast userElements.members[i];
            elements.y += floatInt;
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
        }
    }

    private function updateTimeDisplay(?timer:FlxTimer):Void {
        var currentDate = Date.now();
        var currentHour = currentDate.getHours();
        var currentMinute = currentDate.getMinutes();
        var currentSeconds = currentDate.getSeconds();
        var currentMillis = currentDate.getTime() % 1000;
    
        var cycleSprite = (currentHour >= 7 && currentHour < 19)
            ? Paths.image('menulogin/sun')
            : Paths.image('menulogin/moon');
        
        var nextUpdateTime = new Date(
            currentDate.getFullYear(),
            currentDate.getMonth(),
            currentDate.getDate() + ((currentHour >= 19) ? 1 : 0),
            (currentHour >= 7 && currentHour < 19) ? 19 : 7,
            0,
            0
        );
    
        var msUntilNextUpdate = nextUpdateTime.getTime() - currentDate.getTime();
        
        dayCycleSprite.loadGraphic(cycleSprite);
    
        var formattedHour = StringTools.lpad(Std.string(currentHour), "0", 2);
        var formattedMinute = StringTools.lpad(Std.string(currentMinute), "0", 2);
        clockText.text = '${formattedHour}:${formattedMinute}';
    
        var msUntilNextMinute = (60 - currentSeconds) * 1000 - currentMillis;
        
        new FlxTimer().start(msUntilNextMinute / 1000, (_) -> {
            updateTimeDisplay();
        });
    }

    private function flashingEffect(sprite:FlxSprite, fadeInDuration:Float, fadeOutDuration:Float):Void {
        FlxSpriteUtil.fadeIn(sprite, fadeInDuration, true, function(tween:FlxTween):Void {
            FlxSpriteUtil.fadeOut(sprite, fadeOutDuration, function(tween:FlxTween):Void {
                flashingEffect(sprite, fadeInDuration, fadeOutDuration);
            });
        });
    }
}