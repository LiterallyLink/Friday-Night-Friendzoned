package states;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.input.keyboard.FlxKey;
import backend.Highscore;
import backend.ShaderManager;

class BootState extends MusicBeatState {
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    public static var initialized:Bool = false;

    public static var shouldCrashOnBoot:Bool;
    public static var CRASH_PROBABILITY:Float = 0.05;

    public static var canEnterBios:Bool = true;

    public static var logoVariant:Int = FlxG.random.int(1, 3);

    override public function create():Void {
        Paths.clearStoredMemory();

        FlxG.mouse.visible = false;
        FlxG.fixedTimestep = false;
        FlxG.game.focusLostFramerate = 60;
        FlxG.keys.preventDefaultKeys = [TAB];

        super.create();

        loadPreferences();
        ShaderManager.getInstance().applyShaders();
        loadBootSequence();
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

    private function loadBootSequence():Void {
        FlxG.sound.play(Paths.sound('bootup'));
    
        final currentDate:String = Date.now().toString();

        final bootPrompts:Array<{text:String, color:UInt}> = [
            {text: 'Yo, yo, yo! Bootin\' up this funky fresh system!\n${currentDate}', color: FlxColor.YELLOW},
            {text: "scanning for funky fresh beats...", color: FlxColor.WHITE},
            {text: "warming up microphones...", color: FlxColor.WHITE},
            {text: "loading audio tracks...", color: FlxColor.WHITE},
            {text: "calibrating rhythm sensors...", color: FlxColor.WHITE},
            {text: "initializing arrow inputs...", color: FlxColor.WHITE},
            {text: "positioning hitboxes...", color: FlxColor.WHITE},
            {text: "preparing funky.env...", color: FlxColor.WHITE},
            {text: "checking for groove modules...", color: FlxColor.WHITE},
            {text: "synchronizing funk levels...", color: FlxColor.WHITE},
            {text: "adjusting menus and options...", color: FlxColor.WHITE},
            {text: "applying latest patches...", color: FlxColor.WHITE},
            {text: "optimizing girlfriend's ass...", color: FlxColor.WHITE},
            {text: "searching for secret levels...", color: FlxColor.WHITE},
            {text: "compiling funky engine...", color: FlxColor.WHITE},
            {text: "WARNING: Friendzoned93 has not yet been tested on your device.\nUse latest FriendzonedOS or Groovium for a better experience !", color: 0xFFE21142},
            {text: "Friendzoned93 v2.4.7 booting up...", color: FlxColor.YELLOW},
            {text: "bios ... ready to jam", color: FlxColor.WHITE},
            {text: "settings ... set and fresh", color: FlxColor.WHITE},
            {text: "modules ... locked and loaded", color: FlxColor.WHITE},
            {text: "desktop ... lookin' fly", color: FlxColor.WHITE},
            {text: "audio ... bumpin' loud", color: FlxColor.WHITE},
            {text: "boot ... startin' strong", color: FlxColor.WHITE},
            {text: "apps ... ready to rock", color: FlxColor.WHITE},
            {text: "utils ... geared up", color: FlxColor.WHITE},
            {text: "upgrade ... primed", color: FlxColor.WHITE},
            {text: "config ... configured to the max !", color: FlxColor.WHITE},
            {text: "exe ... executable excellence", color: FlxColor.WHITE},
            {text: "explorer ... navigatin' like a boss", color: FlxColor.WHITE},
            {text: "start ... kickin' it off", color: FlxColor.WHITE},
            {text: "storage ... all packed up", color: FlxColor.WHITE}
        ];
    
        var yPos:Int = 5;
        var delay:Float = 0;

        final bootPromptGroup:FlxGroup = new FlxGroup();
        add(bootPromptGroup);
    
        if (FlxG.random.float(0, 1) < CRASH_PROBABILITY)
            shouldCrashOnBoot = true;
    
        for (i in 0...bootPrompts.length) {
            var prompt:FlxText = new FlxText(10, yPos, bootPrompts[i].text)
                .setFormat(null, 8, bootPrompts[i].color);

            yPos += (i == 0 || i == 14 || i == 15 || i == 16) ? 30 : 10;
            delay += FlxG.random.float(0.1, 0.3);

            new FlxTimer().start(delay, function(timer:FlxTimer):Void {
                bootPromptGroup.add(prompt);
            });
        }
    
        final enterBiosPrompt:FlxText = new FlxText(10, FlxG.height - 30, "Press <DEL> to enter SETUP");
        enterBiosPrompt.setFormat(null, 8, FlxColor.YELLOW);
        bootPromptGroup.add(enterBiosPrompt);
    
        new FlxTimer().start(delay + 0.5, (_) -> {
            canEnterBios = false;
            remove(bootPromptGroup);
            showLogoAndTransition();
        });
    }

    private function showLogoAndTransition():Void {
        final friendzonedLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logos/friendzonedLogo${logoVariant}'));
        friendzonedLogo.screenCenter(XY);

        final copyrightNotice:FlxText = new FlxText(10, FlxG.height - 30, '@ 1993 Friendzoned Electronics Inc. All rights reserved.', 7);

        add(friendzonedLogo);
        add(copyrightNotice);

        FlxSpriteUtil.fadeIn(friendzonedLogo, 2, true);
        FlxG.sound.play(Paths.sound('startup'));

        new FlxTimer().start(5, (_) -> {
            LoadingState.loadAndSwitchState(new LoginState());
        });
    }

    override function update(elapsed:Float) {
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        if (canEnterBios && (FlxG.keys.justPressed.DELETE || FlxG.keys.justPressed.BACKSPACE)) {
            canEnterBios = false;
            LoadingState.loadAndSwitchState(new BiosState());
        }
    }
}
