package states;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.ui.FlxButton;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxSpriteGroup;

import substates.StartMenuSubState;
import substates.MinecraftLauncherSubState;
import substates.paint.PaintSubState;
import substates.lethal.LethalPauseSubState;

import backend.ShaderManager;
import backend.ApplicationButton;
import backend.DragManager;

import backend.window.WindowManager;
import backend.window.composite.CompositeSprite;
import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class DesktopState extends MusicBeatState
{
	private var dragManager:DragManager;

	private static inline var X_TASKBAR_PADDING:Int = 5;
	private static inline var Y__TASKBAR_PADDING:Int = 10;

	public var taskbar:FlxSprite;

	private var digitSprites:Array<FlxSprite>;
	private var ampmSprite:FlxSprite;
	private var currentHours:Int = -1;
	private var currentMinutes:Int = -1;
	private var currentAMPM:String = "";

	override function create()
	{
		ShaderManager.i().applyShaders();
		dragManager = DragManager.i();

		addMusic();
		setDesktopBg();
		setupTaskBar();
		testWindowManager();
	}

	private function addMusic()
	{
		FlxG.sound.playMusic(Paths.music('desktopTheme'), 0.5, true);
		FlxG.sound.play(Paths.sound('humming'), true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		DragManager.i().update();

		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	private function setDesktopBg()
	{
		var desktopTheme:String = ClientPrefs.data.pcTheme;
		var desktopBg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menudesktop/bgs/${desktopTheme}'));
		add(desktopBg);
	}

	private function setupTaskBar()
	{
		taskbar = new FlxSprite().loadGraphic(Paths.image('menudesktop/taskbar'));
		taskbar.y = FlxG.height - taskbar.height;
		add(taskbar);

		this.createTaskbarButtons(taskbar);
		this.createTaskbarClock(taskbar);
	}

	private function createTaskbarButtons(taskbar:FlxSprite):Void
	{
		var onDown = new FlxSprite(X_TASKBAR_PADDING, taskbar.y + Y__TASKBAR_PADDING, Paths.image('menudesktop/taskbar/start_down'));
		onDown.visible = false;

		var start = new FlxButton(X_TASKBAR_PADDING, taskbar.y + Y__TASKBAR_PADDING, () ->
		{
			onDown.visible = true;
			openSubState(new StartMenuSubState(onDown, taskbar));
		}).loadGraphic(Paths.image('menudesktop/taskbar/start'));

		add(start);
		add(onDown);
	}

	private function createTaskbarClock(taskbar)
	{
		var clockGroup = new FlxSpriteGroup();
		digitSprites = [];

		var date = Date.now();
		var hours = date.getHours();
		var minutes = date.getMinutes();
		var ampm = "AM";

		if (hours >= 12)
		{
			ampm = "PM";
			if (hours > 12)
			{
				hours -= 12;
			}
		}
		if (hours == 0)
			hours = 12;

		var dimmedDigit = new FlxSprite().loadGraphic(Paths.image('menudesktop/taskbar/clock/dimmed_digit'));
		var separator = new FlxSprite().loadGraphic(Paths.image('menudesktop/taskbar/clock/semi_colon'));
		var digitWidth = dimmedDigit.width;
		var separatorWidth = separator.width;

		for (i in 0...4)
		{
			var newDigit = dimmedDigit.clone();
			var xPos = i * digitWidth + (i >= 2 ? separatorWidth : 0);
			newDigit.setPosition(xPos, 0);
			clockGroup.add(newDigit);

			if (i == 1)
			{
				var newSeparator = separator.clone();
				newSeparator.setPosition((i + 1) * digitWidth, 0);
				clockGroup.add(newSeparator);
			}

			var digitSprite = new FlxSprite().loadGraphic(Paths.image('menudesktop/taskbar/clock/0'));
			digitSprite.setPosition(xPos, 0);
			clockGroup.add(digitSprite);
			digitSprites.push(digitSprite);
		}

		ampmSprite = new FlxSprite().loadGraphic(Paths.image('menudesktop/taskbar/clock/AM'));
		ampmSprite.setPosition((4 * digitWidth) + separatorWidth, 0);
		clockGroup.add(ampmSprite);

		add(clockGroup);
        clockGroup.screenCenter(XY);

		startClockTimer();
		updateClockSprites(hours, minutes, ampm);
	}

    private function startClockTimer() {
        var date = Date.now();
        var seconds = date.getSeconds();
        var milliseconds = date.getTime() % 1000;
        
        var delay = (60 - seconds - (milliseconds / 1000));
        
        new FlxTimer().start(delay, function(tmr:FlxTimer) {
            updateTime();
            tmr.start(60, function(tmr:FlxTimer) {
                updateTime();
            }, 0);
        });
     }

	private function updateTime()
	{
		var date = Date.now();
		var hours = date.getHours();
		var minutes = date.getMinutes();
		var ampm = "AM";

		if (hours >= 12)
		{
			ampm = "PM";
			if (hours > 12)
				hours -= 12;
		}
		if (hours == 0)
			hours = 12;

		if (hours != currentHours || minutes != currentMinutes || ampm != currentAMPM)
		{
			updateClockSprites(hours, minutes, ampm);
			currentHours = hours;
			currentMinutes = minutes;
			currentAMPM = ampm;
		}
	}

	private function updateClockSprites(hours:Int, minutes:Int, ampm:String)
	{
		digitSprites[0].loadGraphic(Paths.image('menudesktop/taskbar/clock/${Math.floor(hours / 10)}'));
		digitSprites[1].loadGraphic(Paths.image('menudesktop/taskbar/clock/${hours % 10}'));

		digitSprites[2].loadGraphic(Paths.image('menudesktop/taskbar/clock/${Math.floor(minutes / 10)}'));
		digitSprites[3].loadGraphic(Paths.image('menudesktop/taskbar/clock/${minutes % 10}'));

		ampmSprite.loadGraphic(Paths.image('menudesktop/taskbar/clock/$ampm'));
	}

	override function destroy()
	{
		super.destroy();
	}

	private function testWindowManager():Void {
		var composite = new CompositeSprite();
		var backdrop = new FlxSprite();
		var width = FlxG.random.int(200, 400);
		var height = FlxG.random.int(200, 400);

		backdrop.makeGraphic(width, height, FlxColor.WHITE);
		composite.add(backdrop);    
		composite.updateHitbox();
				
		var window = new WindowManager(composite);
		
		var randomX = FlxG.random.float(0, FlxG.width - width);
		var randomY = FlxG.random.float(0, FlxG.height - height);
				
		window.setPosition(randomX, randomY);
		add(window);
				
		/*
		new FlxTimer().start(2, (_) -> {
			trace('Destroying window at position: ${window.x},${window.y}');
			remove(window);
			window.destroy();
			testWindowManager();
		});
		*/
	}
}
