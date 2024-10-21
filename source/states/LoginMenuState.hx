package states;

import shaders.CRTShader;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import openfl.filters.ShaderFilter;

class LoginMenuState extends MusicBeatState {
    public var shader:CRTShader;

    public var loginMenuBg:FlxGroup = new FlxGroup();
    public var foregroundCloudGroup:FlxGroup = new FlxGroup();
    public var loginMenuUI:FlxGroup = new FlxGroup();
    public var loginIconGroup:FlxGroup = new FlxGroup();
    public var usernameGroup:FlxGroup = new FlxGroup();

    public var loginBg:FlxSprite;
    public var loginBgGradient:FlxSprite;
    public var borderSprite:FlxSprite;
    public var bgClouds:FlxSprite;
    public var welcomeSprite:FlxSprite;
    public var clickToBegin:FlxSprite;
    public var dividerSprite:FlxSprite;
    public var foregroundCloud:FlxSprite;
    public var desktopTheme:String;

    public var randomUser:String = "";

    private var floatUp:Bool = true;
    private var loginWindowOpen:Bool = false;

    private var loginWindow:FlxSprite;
    private var cancelBtn:FlxButton;
    private var okBtn:FlxButton;
    private var xBtn:FlxButton;
    public var shutdownBtn:FlxButton;

    override function create() {
        desktopTheme = ClientPrefs.data.desktopTheme;

        shader = new CRTShader(0.3, 0.55);
        FlxG.camera.setFilters([new ShaderFilter(shader)]);

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;

        var hummingAmbience:FlxSound = FlxG.sound.load(Paths.sound('humming'));
        hummingAmbience.looped = true;
        hummingAmbience.play();

        add(loginMenuBg);
        add(foregroundCloudGroup);
        add(loginMenuUI);
        add(loginIconGroup);
        add(usernameGroup);

        renderLoginMenu(desktopTheme);
    }

    override function destroy() {
        super.destroy();
    }

    override function update(elapsed:Float) {
        updateSongPosition();
        super.update(elapsed);
    }

    private function updateSongPosition():Void {
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
    }

    private function handleMouseClick(sprite:String = ""):Void {
        switch (sprite) {
            case "newUser":
                return;
            case "shutdown":
                handlePowerButtonClick();
            case "87":
                handleGoldenFreddyClick();
            default:
                if (!loginWindowOpen) {
                    openLoginWindow();
                }
        }
    }

    private function openLoginWindow():Void {
        loginWindow = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/login_window'));
        loginWindow.scale.set(1.5, 1.5);
        loginWindow.screenCenter(XY);
        add(loginWindow);

        cancelBtn = new FlxButton(825, 495, function() {
            closeFunction();
        });
        cancelBtn.loadGraphic(Paths.image('loginmenu/login_cancel'));
        cancelBtn.scale.set(1.5, 1.5);
        add(cancelBtn);

        okBtn = new FlxButton(740, 495, function() {
            closeFunction();
        });
        okBtn.loadGraphic(Paths.image('loginmenu/login_ok'));
        okBtn.scale.set(1.5, 1.5);
        add(okBtn);

        xBtn = new FlxButton(880, 197, function() {
            closeFunction();
        });
        xBtn.loadGraphic(Paths.image('loginmenu/login_x'));
        xBtn.scale.set(1.5, 1.5);
        add(xBtn);

        loginWindowOpen = true;
    }

    private function closeFunction():Void {
        loginWindow.kill();
        cancelBtn.kill();
        okBtn.kill();
        xBtn.kill();
        loginWindowOpen = false;
    }

    private function handlePowerButtonClick():Void {
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

        new FlxTimer().start(3, function(timer:FlxTimer) {
            Sys.exit(1);
        });
    }

    private function handleGoldenFreddyClick():Void {
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

        moveClouds();

        floatUp = !floatUp;
    }

    private function moveClouds():Void {
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

    function renderUsers() {
        var usernameMap:Map<String, String> = [
            'darnell' => "Darnell",
            'father' => "Daddy D.",
            'mommy' => "MOM CHANGE UR PFP",
            'nene' => "Nene",
            'pico' => "pico",
            'senpai' => "Sven",
            'tank' => "Steve",
            '87' => "ITS ME",
            'spooky' => "SKID N' PUMP"
        ];

        var icons:Array<String> = ["bf", "gf"];
        var usernames:Array<String> = ["Her Bf <3", "His Gf <3"];

        var randomUserArray:Array<String> = ["darnell", "father", "mommy", "nene", "pico", "senpai", "spooky", "tank"];
        FlxG.random.shuffle(randomUserArray);

        if (FlxG.random.int(1, 100) == 87) {
            randomUser = "87";
        } else {
            randomUser = randomUserArray.pop();
        }

        icons.push(randomUser);
        usernames.push(usernameMap[randomUser]);

        icons.push("newUser");
        usernames.push("New User");

        var iconHeight:Float = 59;
        var iconPadding:Float = 3;
        var xPos:Float = 794;
        var yPos:Float = 216;

        for (i in 0...icons.length) {
            var iconName = icons[i];
            var icon:FlxButton = new FlxButton(xPos, yPos, function() {
                handleMouseClick(iconName);
            });

            icon.loadGraphic(Paths.image('loginmenu/icons/' + icons[i]));
            loginIconGroup.add(icon);

            var usernameText = new FlxText(xPos + 59, yPos + (iconHeight / 2), usernames[i], 30);
            usernameText.borderStyle = SHADOW;
            usernameText.y -= (usernameText.height / 2);
            usernameGroup.add(usernameText);

            yPos += (iconHeight + iconPadding);
        } 
    }

    function renderLoginMenu(desktopTheme:String) {
        loginBg = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${desktopTheme}/bg'));
        loginBgGradient = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${desktopTheme}/bg_gradient'));
        borderSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${desktopTheme}/border'));
        bgClouds = new FlxSprite(488, 155).loadGraphic(Paths.image('loginmenu/${desktopTheme}/bg_clouds'));

        welcomeSprite = new FlxSprite(253, 276).loadGraphic(Paths.image('loginmenu/${desktopTheme}/welcome'));
        clickToBegin = new FlxSprite(229, 330).loadGraphic(Paths.image('loginmenu/${desktopTheme}/beginText'));
        dividerSprite = new FlxSprite(616, 203).loadGraphic(Paths.image('loginmenu/${desktopTheme}/divider'));

        shutdownBtn = new FlxButton(43, 629, function() {
            handleMouseClick("shutdown");
        });

        shutdownBtn.loadGraphic(Paths.image('loginmenu/${desktopTheme}/off_switch'));

        loginMenuBg.add(loginBg);
        loginMenuBg.add(loginBgGradient);
        loginMenuBg.add(borderSprite);
        loginMenuBg.add(bgClouds);

        addForegroundClouds(desktopTheme);

        loginMenuUI.add(welcomeSprite);
        loginMenuUI.add(clickToBegin);
        flashingEffect(clickToBegin, 2, 2);

        loginMenuUI.add(dividerSprite);
        loginMenuUI.add(shutdownBtn);

        renderUsers();
    }

    private function addForegroundClouds(desktopTheme:String):Void {
        var cloudPositions:Array<{x:Int, y:Int}> = [
            {x: 248, y: 170},
            {x: 548, y: 185},
            {x: 968, y: 175}
        ];

        for (i in 0...cloudPositions.length) {
            var pos = cloudPositions[i];
            var cloud:FlxSprite = new FlxSprite(pos.x, pos.y).loadGraphic(Paths.image('loginmenu/${desktopTheme}/foreground_cloud_${i + 1}'));
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
