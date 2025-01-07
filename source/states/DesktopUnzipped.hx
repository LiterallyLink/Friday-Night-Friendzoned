package states;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.ui.FlxButton;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxSpriteGroup;

import substates.StartMenuSubState;
import substates.ContextMenuSubState;
import substates.minecraft.MinecraftLauncherSubState;
import substates.paint.PaintSubState;
import substates.lethal.LethalPauseSubState;

import backend.ShaderManager;
import backend.ApplicationButton;
import backend.drag.DragManager;

import backend.window.WindowManager;
import backend.composite.CompositeSprite;
import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class DesktopUnzipped extends MusicBeatState
{
	private var dragManager:DragManager;

	private static inline var X_TASKBAR_PADDING:Int = 5;
	private static inline var Y__TASKBAR_PADDING:Int = 10;

	public var taskbar:FlxSprite;

	private var appCredits:ApplicationButton;
	private var appMinecraft:ApplicationButton;

	private var digitSprites:Array<FlxSprite>;
	private var ampmSprite:FlxSprite;
	private var currentHours:Int = -1;
	private var currentMinutes:Int = -1;
	private var currentAMPM:String = "";

	override function create()
	{
		ShaderManager.i().applyShaders();
		dragManager = DragManager.i();

		playDesktopMusic();
		setDesktopBg();
		setupTaskBar();
		
		var bounds = new FlxRect(0, 0, FlxG.width, FlxG.height - taskbar.height);

		appMinecraft = new ApplicationButton(0, 100, bounds, 'menudesktop/applications/mc', 'Minecraft',
		() -> {
			trace('single click');
		},
		() -> {
			openSubState(new MinecraftLauncherSubState());
		},
		() -> {
			openSubState(new ContextMenuSubState(appMinecraft));
		});

		appCredits = new ApplicationButton(0, 0, bounds, 'menudesktop/applications/sticky_note', 'Credits.txt',
		() -> {
			trace('single click');
		},
		() -> {
			trace('double click');
		},
		() -> {
			openSubState(new ContextMenuSubState(appCredits));
		});
		
		add(appMinecraft);
		add(appCredits);
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

	private function playDesktopMusic()
	{
		FlxG.sound.playMusic(Paths.music('desktopTheme'), 0.5, true);
		FlxG.sound.play(Paths.sound('humming'), true);
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
}
