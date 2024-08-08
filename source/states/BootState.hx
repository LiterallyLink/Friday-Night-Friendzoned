package states;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.input.keyboard.FlxKey;

import backend.WeekData;
import backend.Highscore;

class BootState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	override public function create():Void
	{
		Paths.clearStoredMemory();

        FlxG.mouse.visible = false;

        FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Highscore.load();


		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

        var dateNow:String = Date.now().toString();

        var bootMessages:Array<String> = [
            'Yo, yo, yo! Bootin\' up this funky fresh system!\n${dateNow}',
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
            "WARNING: Funkin93 has not yet been tested on your device.\nUse latest FunkinOS or Groovium for a better experience !",
            "Funkin93 v2.4.7 booting up...",
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

        var colors:Array<UInt> = [
            FlxColor.YELLOW,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFF9F0C2E,
            FlxColor.YELLOW,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872,
            0xFFC9D872
        ];

        var bootingTextArray:Array<FlxText> = [];
        var yPos:Int = 5;

        for (i in 0...bootMessages.length) {
            var text:FlxText = new FlxText(10, yPos, bootMessages[i], 8);
            text.setFormat(null, 8, colors[i]);
            bootingTextArray.push(text);

            if (i == 0 || i == 14 || i == 15 || i == 16) {
                yPos += 30;
            } else {
                yPos += 10;
            }
        }

        var delay:Float = 0;

        for (i in 0...bootingTextArray.length) {
            delay += FlxG.random.float(0.1, 0.3);
            new FlxTimer().start(delay, function(timer:FlxTimer):Void {
                add(bootingTextArray[i]);
            });
        }

        var enterBIOSText:FlxText = new FlxText(10, FlxG.height - 30, "Press DEL to enter SETUP", 8);
        enterBIOSText = enterBIOSText.setFormat(null, 8, FlxColor.YELLOW);
        add(enterBIOSText);
    }

    override function update(elapsed:Float)
	{
		super.update(elapsed);

        if (FlxG.keys.justPressed.DELETE || FlxG.keys.justPressed.BACKSPACE) {
            LoadingState.loadAndSwitchState(new BiosState());
        }
	}
}
