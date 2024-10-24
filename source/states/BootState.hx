package states;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.input.keyboard.FlxKey;
import backend.Highscore;
import shaders.CRTShader;
import openfl.filters.ShaderFilter;

class BootState extends MusicBeatState {
    public var vcr:CRTShader;

    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    public static var initialized:Bool = false;
    public static var initCrash:Bool;
    public static var initBios:Bool = true;

    public static var logoInt:Int = FlxG.random.int(1, 3);

    override public function create():Void {
        initializeSettings();
        super.create();
        loadPreferences();
        setupBootText();
    }

    private function initializeSettings():Void {
        Paths.clearStoredMemory();
        FlxG.mouse.visible = false;
        FlxG.fixedTimestep = false;
        FlxG.game.focusLostFramerate = 60;
        FlxG.keys.preventDefaultKeys = [TAB];
    }

    private function loadPreferences():Void {
        FlxG.save.bind('funkin', CoolUtil.getSavePath());
        ClientPrefs.loadPrefs();
        Highscore.load();

        if (!initialized) {
            if (FlxG.save.data != null && FlxG.save.data.fullscreen) {
                FlxG.fullscreen = FlxG.save.data.fullscreen;
            }
            persistentUpdate = true;
            persistentDraw = true;
        }

        if (FlxG.save.data.weekCompleted != null) {
            StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
        }
    }

    private function setupBootText():Void {
        vcr = new CRTShader(0.35, 0.75);
        FlxG.camera.setFilters([new ShaderFilter(vcr)]);
        FlxG.sound.play(Paths.sound('bootup'));

        var bootTextGroup:FlxGroup = new FlxGroup();
        add(bootTextGroup);

        var currentDate:String = Date.now().toString();
        var bootText:Array<String> = getBootText(currentDate);
        var colors:Array<UInt> = getBootTextColors();

        var yPos:Int = 5;
        var delay:Float = 0;

        if (FlxG.random.float(0, 1) < 0.05) initCrash = true;

        for (i in 0...bootText.length) {
            var text:FlxText = new FlxText(10, yPos, bootText[i]).setFormat(null, 8, colors[i]);
            yPos += (i == 0 || i == 14 || i == 15 || i == 16) ? 30 : 10;
            delay += FlxG.random.float(0.1, 0.3);
            new FlxTimer().start(delay, function(timer:FlxTimer):Void {
                bootTextGroup.add(text);
            });
        }

        var enterBIOSText:FlxText = new FlxText(10, FlxG.height - 30, "Press <DEL> to enter SETUP").setFormat(null, 8, FlxColor.YELLOW);
        bootTextGroup.add(enterBIOSText);

        new FlxTimer().start(delay + 0.5, function(timer:FlxTimer):Void {
            initBios = false;
            remove(bootTextGroup);
            showLogoAndTransition();
        });
    }

    private function getBootText(currentDate:String):Array<String> {
        return [
            'Yo, yo, yo! Bootin\' up this funky fresh system!\n${currentDate}',
            "scanning for funky fresh beats...",
            "warming up microphones...",
            "loading audio tracks...",
            "calibrating rhythm sensors...",
            "initializing arrow inputs...",
            "positioning hitboxes...",
            "preparing funky.env...",
            "checking for groove modules...",
            "synchronizing funk levels...",
            "adjusting menus and options...",
            "applying latest patches...",
            "optimizing girlfriend's ass...",
            "searching for secret levels...",
            "compiling funky engine...",
            "WARNING: Friendzoned93 has not yet been tested on your device.\nUse latest FriendzonedOS or Groovium for a better experience !",
            "Friendzoned93 v2.4.7 booting up...",
            "bios ... ready to jam",
            "settings ... set and fresh",
            "modules ... locked and loaded",
            "desktop ... lookin' fly",
            "audio ... bumpin' loud",
            "boot ... startin' strong",
            "apps ... ready to rock",
            "utils ... geared up",
            "upgrade ... primed",
            "config ... configured to the max !",
            "exe ... executable excellence",
            "explorer ... navigatin' like a boss",
            "start ... kickin' it off",
            "storage ... all packed up",
        ];
    }

    private function getBootTextColors():Array<UInt> {
        return [
            FlxColor.YELLOW,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            0xFFE21142,
            FlxColor.YELLOW,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE,
            FlxColor.WHITE
        ];
    }

    private function showLogoAndTransition():Void {
        var friendzonedLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('friendzonedLogo${logoInt}'));
        friendzonedLogo.screenCenter(XY);
        add(friendzonedLogo);

        FlxSpriteUtil.fadeIn(friendzonedLogo, 2, true);
        FlxG.sound.play(Paths.sound('startup'));

        var copyrightText:FlxText = new FlxText(10, FlxG.height - 30, '@ 1993 Friendzoned Electronics Inc. All rights reserved.', 7);
        add(copyrightText);

        new FlxTimer().start(5, function(timer:FlxTimer) {
            LoadingState.loadAndSwitchState(new LoginMenuState());
        });
    }

    override function update(elapsed:Float) {
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        if (initBios && (FlxG.keys.justPressed.DELETE || FlxG.keys.justPressed.BACKSPACE)) {
            LoadingState.loadAndSwitchState(new BiosState());
        }
    }
}
