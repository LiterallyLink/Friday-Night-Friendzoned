package states;

import shaders.CRTShader;
import flixel.FlxG;
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
    public var powerBtnSprite:FlxSprite;
    public var foregroundCloud:FlxSprite;
    public var desktopTheme:String;

    public var randomUser:String = "";

    private var floatUp:Bool = true;

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
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        if (FlxG.mouse.justPressed) {
            handleMouseClick();
        }

        super.update(elapsed);
    }

    private function handleMouseClick():Void {
        for (i in 0...loginIconGroup.length) {
            if (FlxG.mouse.overlaps(loginIconGroup.members[i])) {
                trace('Icon ' + i + ' clicked');

                if (i == 2 && randomUser == "87") {
                    handleGoldenFreddyClick();
                }
            }
        }

        if (FlxG.mouse.overlaps(powerBtnSprite)) {
            handlePowerButtonClick();
        }
    }

    private function handlePowerButtonClick():Void {
        remove(loginMenuUI);
        remove(loginIconGroup);
        remove(usernameGroup);

        var friendzonedLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('friendzonedLogoSD${BootState.logoInt}'));
        friendzonedLogo.screenCenter(XY);
        add(friendzonedLogo);

        var shutdownText:FlxText = new FlxText(0, 0, 'FriendzonedOS is shutting down...', 15);
        shutdownText.x = (FlxG.width - shutdownText.width) / 2;
        shutdownText.y = friendzonedLogo.y + friendzonedLogo.height + 10;
        add(shutdownText);

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

        floatUp = !floatUp;
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
            var icon = new FlxSprite(xPos, yPos).loadGraphic(Paths.image('loginmenu/icons/' + icons[i]));
            loginIconGroup.add(icon);

            var usernameText = new FlxText(xPos + 59, yPos + (iconHeight / 2), usernames[i], 30);
            usernameText.borderStyle = SHADOW;
            usernameText.y -= (usernameText.height / 2);
            usernameGroup.add(usernameText);

            yPos += (iconHeight + iconPadding);
        }
    }

    function renderLoginMenu(desktopTheme) {
        loginBg = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${desktopTheme}/bg'));
        loginBgGradient = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${desktopTheme}/bg_gradient'));
        borderSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('loginmenu/${desktopTheme}/border'));
        bgClouds = new FlxSprite(488, 155).loadGraphic(Paths.image('loginmenu/${desktopTheme}/bg_clouds'));

        welcomeSprite = new FlxSprite(253, 276).loadGraphic(Paths.image('loginmenu/${desktopTheme}/welcome'));
        clickToBegin = new FlxSprite(229, 330).loadGraphic(Paths.image('loginmenu/${desktopTheme}/beginText'));
        dividerSprite = new FlxSprite(616, 203).loadGraphic(Paths.image('loginmenu/${desktopTheme}/divider'));
        powerBtnSprite = new FlxSprite(43, 629).loadGraphic(Paths.image('loginmenu/${desktopTheme}/off_switch'));

        loginMenuBg.add(loginBg);
        loginMenuBg.add(loginBgGradient);
        loginMenuBg.add(borderSprite);
        loginMenuBg.add(bgClouds);

        addForegroundClouds(desktopTheme);

        loginMenuUI.add(welcomeSprite);
        loginMenuUI.add(clickToBegin);
        flashingEffect(clickToBegin, 2, 2);

        loginMenuUI.add(dividerSprite);
        loginMenuUI.add(powerBtnSprite);

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
