package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;

import backend.ShaderManager;
import backend.Achievements;

import substates.LoginSubState;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxSpriteContainer;

import flixel.addons.transition.FlxTransitionableState;

class LoginState extends MusicBeatState {
    private var loginTheme:String = 'xmas';
    private var iconContainer:FlxSpriteContainer;
    private var cloudContainer:FlxSpriteContainer;
    private var floatUp:Bool = true;

    override public function new() {
        super();
        iconContainer = new FlxSpriteContainer();
        cloudContainer = new FlxSpriteContainer();
    }

    override function create() {
        super.create();
        
        persistentUpdate = true;
        persistentDraw = true;
        FlxTransitionableState.skipNextTransIn = true;
        FlxG.mouse.visible = true;

        var cursor:FlxSprite = new FlxSprite();
        cursor.loadGraphic(Paths.image('cursors/default'));
        FlxG.mouse.load(cursor.pixels);

        createBackground();
        ShaderManager.i().applyShaders();
        createForegroundClouds();
        createPowerButton();
        createUsers();
        
        var divider = new FlxSprite();
        divider.loadGraphic(Paths.image('menulogin/divider'));
        divider.screenCenter(XY);
        add(divider);

        startLoginMusic();
    }

    private function createBackground() {
        var bg = new FlxSprite();
        bg.loadGraphic(Paths.image('menulogin/${loginTheme}/bg'));
        add(bg);
    
        var borders = new FlxSprite();
        borders.loadGraphic(Paths.image('menulogin/${loginTheme}/borders'));
        add(borders);
    
        var bgClouds = new FlxBackdrop(Paths.image('menulogin/${loginTheme}/bg_clouds'));
        bgClouds.velocity.set(20, 0);
        add(bgClouds);
    }

    private function createForegroundClouds() {
        var positions:Array<{x:Int, y:Int}> = [
            {x: 248, y: 170},
            {x: 548, y: 185},
            {x: 968, y: 175}
        ];
        
        for (i in 0...positions.length) {
            var pos = positions[i];
            var foregroundCloud:FlxSprite = new FlxSprite(pos.x, pos.y);
            foregroundCloud.loadGraphic(Paths.image('menulogin/${loginTheme}/foreground_cloud_${i + 1}'));
            cloudContainer.add(foregroundCloud);
        }

        add(cloudContainer);
    }

    private function createUsers() {
        final ICON_HEIGHT:Float = 60;
        final ICON_PADDING:Float = 3;
        final FONT_SIZE = 30;
        final X_POS:Float = 780;
        var Y_POS:Float = 210;

        var usernames:Map<String, String> = [
            "bf" => "Her Bf <3",
            "gf" => "His Gf <3",
            "darnell" => "Darnell",
            "father" => "Daddy D.",
            "mommy" => "MOM CHANGE YOUR PFP",
            "nene" => "Nene",
            "pico" => "pico",
            "senpai" => "Sven",
            "spooky" => "SKID N' PUMP",
            "tank" => "Steve",
            "87" => "ITS ME"
        ];

        var users:Array<String> = ["bf", "gf"];
        var randomUsers:Array<String> = ["darnell", "father", "mommy", "nene", "pico", "senpai", "spooky", "tank"];

        FlxG.random.shuffle(randomUsers);

        if (FlxG.random.int(1, 100) == 87) {
            randomUsers.push("87");
        }

        users.push(randomUsers.pop());

        for (i in 0...users.length) {
            var user = users[i];

            var icon:FlxButton = new FlxButton(X_POS, Y_POS, () -> {
                if (subState != null) return;
                openSubState(new LoginSubState(user));
            });

            icon.loadGraphic(Paths.image('menulogin/icons/${user}'));
            iconContainer.add(icon);

            var username = new FlxText(
                X_POS + ICON_HEIGHT,
                Y_POS + (ICON_HEIGHT / 2),
                usernames.get(user),
                FONT_SIZE
            );

            username.borderStyle = SHADOW;
            username.y -= (username.height / 2);
            iconContainer.add(username);
            
            Y_POS += (ICON_HEIGHT + ICON_PADDING);
        }

        var profile = ClientPrefs.data.profileData;

        var profileIcon:FlxButton = new FlxButton(X_POS, Y_POS, () -> {
            if (subState != null) return;
            openSubState(new LoginSubState(profile.username));
        });

        profileIcon.loadGraphic(Paths.image('menulogin/icons/${profile.icon}'));
        iconContainer.add(profileIcon);

        var profileText = new FlxText(
            X_POS + ICON_HEIGHT,
            Y_POS + (ICON_HEIGHT / 2),
            profile.username,
            FONT_SIZE
        );

        profileText.borderStyle = SHADOW;
        profileText.y -= (profileText.height / 2);
        iconContainer.add(profileText);

        add(iconContainer);
    }

    private function bumpIcons() {
        var floatInt:Int = floatUp ? 1 : -1;

        for (icon in iconContainer.members) {
            icon.y += floatInt;
        }
    }

    private function bumpClouds() {
        var directions:Array<Int> = [for (i in 0...cloudContainer.length) FlxG.random.int(0, 2)];
        var CLOUD_SPEED:Float = 1.0;

        for (i in 0...cloudContainer.length) {
            var cloud = cloudContainer.members[i];

            if (!cloud.isOnScreen()) {
                cloud.x = -cloud.width;
            }

            switch(directions[i]) {
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

    private function createPowerButton() {
        var xPos = 43;
        var yPos = 629;
        
        var powerButton:FlxButton = new FlxButton(xPos, yPos, () -> {
            if (subState != null) return;
            handlePowerButtonClick();
        });
        powerButton.loadGraphic(Paths.image('menulogin/${loginTheme}/off_switch'));

        add(powerButton);
    }

    private function handlePowerButtonClick():Void {
        FlxG.sound.music.stop();

        FlxG.sound.play(Paths.sound('shutdown'));

        new FlxTimer().start(3, function(timer:FlxTimer) {
            Sys.exit(1);
        });
    }

    private function startLoginMusic() {
        if (FlxG.sound.music == null) {
            FlxG.sound.playMusic(Paths.music('loginMenu'), 0, true);
            FlxG.sound.music.fadeIn(4, 0, 0.7);
            FlxG.sound.play(Paths.sound('humming'), true);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.sound.music != null) {
            Conductor.songPosition = FlxG.sound.music.time;
        }
    }

    override function beatHit() {
        super.beatHit();

        floatUp = !floatUp;

        bumpClouds();
        bumpIcons();
    }

    override function destroy() {
        if (iconContainer != null) {
            iconContainer.destroy();
            iconContainer = null;
        }
        if (cloudContainer != null) {
            cloudContainer.destroy();
            cloudContainer = null;
        }
        super.destroy();
    }
}