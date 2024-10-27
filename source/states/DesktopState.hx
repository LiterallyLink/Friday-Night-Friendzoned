package states;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.ui.FlxButton;
import backend.ApplicationButton;
import flixel.math.FlxRect;

import shaders.CRTShader;
import openfl.filters.ShaderFilter;
import flixel.addons.transition.FlxTransitionableState;

import substates.MinecraftLauncherSubState;

class DesktopState extends MusicBeatState
{
    private static inline var BUTTON_PADDING:Int = 5;

    public var shader:CRTShader;
    public var iconList:Array<ApplicationButton> = [];

	override function create()
	{	
        var desktopTheme:String = ClientPrefs.data.desktopTheme;

        FlxTransitionableState.skipNextTransIn = true;
        persistentUpdate = true;
        persistentDraw = true;

        shader = new CRTShader(0.3, 0.55);
        FlxG.camera.setFilters([new ShaderFilter(shader)]);
        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;

        FlxG.sound.playMusic(Paths.music('desktopTheme'), 0.5, true);
        FlxG.sound.play(Paths.sound('humming'), true);

        var desktopBg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('desktop/bgs/${desktopTheme}'));
        var taskbar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('desktop/taskbar'));
        taskbar.y = FlxG.height - taskbar.height;

        add(desktopBg);
        add(taskbar);

        var startButton = new FlxButton(BUTTON_PADDING, () -> {
            // FlxG.switchState(new StartMenuState());
        });
        startButton.loadGraphic(Paths.image('desktop/icons/start'));
        startButton.y = taskbar.y + (taskbar.height / 2) - (startButton.height / 2);
        add(startButton);

        var photoAlbumButton = new FlxButton(() -> {
            // FlxG.switchState(new PhotoAlbumState());
        });
        photoAlbumButton.loadGraphic(Paths.image('desktop/icons/photo_album'));
        photoAlbumButton.y = taskbar.y + (taskbar.height / 2) - (photoAlbumButton.height / 2);
        photoAlbumButton.x = (startButton.width * 2) - (photoAlbumButton.width / 2);
        add(photoAlbumButton);

        var musicPlayerButton = new FlxButton(() -> {
            // FlxG.switchState(new MusicPlayerState());
        });
        musicPlayerButton.loadGraphic(Paths.image('desktop/icons/music_player'));
        musicPlayerButton.y = taskbar.y + (taskbar.height / 2) - (musicPlayerButton.height / 2);
        musicPlayerButton.x = (photoAlbumButton.x + photoAlbumButton.width) + 10;
        add(musicPlayerButton);

        var achievementButton = new FlxButton(() -> {
            // FlxG.switchState(new AchievementState());
        });
        achievementButton.loadGraphic(Paths.image('desktop/icons/achievements'));
        achievementButton.y = taskbar.y + (taskbar.height / 2) - (achievementButton.height / 2);
        achievementButton.x = (musicPlayerButton.x + musicPlayerButton.width) + 10;
        add(achievementButton);

        var desktopBounds = new FlxRect(0, 0, FlxG.width, FlxG.height - taskbar.height);

        var appRecyclingBin = new ApplicationButton(30, 500, "desktop/icons/recycle_bin_empty", "Recycling Bin", desktopBounds);
        var appCredits = new ApplicationButton(30, 30, "desktop/icons/sticky_note", 'Credits.txt', desktopBounds);
        var appMinecraft = new ApplicationButton(200, 200, 'desktop/icons/mc', 'Minecraft', desktopBounds, MinecraftLauncherSubState);
        
        add(appRecyclingBin);
        add(appCredits);
        add(appMinecraft);
	}

	override function destroy()
	{
		super.destroy();
	}

	override function update(elapsed:Float)
	{
        if (FlxG.sound.music != null) {
            Conductor.songPosition = FlxG.sound.music.time;
        }

        super.update(elapsed);
	}
}
