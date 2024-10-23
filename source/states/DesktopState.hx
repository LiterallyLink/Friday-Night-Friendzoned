package states;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.ui.FlxButton; 

import shaders.CRTShader;
import openfl.filters.ShaderFilter;

class DesktopState extends MusicBeatState
{
    public var shader:CRTShader;

	override function create()
	{	
        var desktopTheme:String = ClientPrefs.data.desktopTheme;

        shader = new CRTShader(0.3, 0.55);
        FlxG.camera.setFilters([new ShaderFilter(shader)]);

        FlxG.mouse.visible = true;
        FlxG.mouse.useSystemCursor = true;

        FlxG.sound.playMusic(Paths.music('desktopTheme'), 0.5, true);
        
        var desktopBg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('desktop/bgs/' + desktopTheme));
        add(desktopBg);

        var taskbar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('desktop/taskbar'));
        taskbar.y = FlxG.height - taskbar.height;
        add(taskbar);

        var startBtn = new FlxButton(5, 0, null, function() {
            // FlxG.switchState(new StartMenuState());
        });
        startBtn.loadGraphic(Paths.image('desktop/icons/start'));
        startBtn.y = taskbar.y + (taskbar.height / 2) - (startBtn.height / 2);
        add(startBtn);

        var photoAlbumBtn = new FlxButton(0, 0, null, function() {
            // FlxG.switchState(new PhotoAlbumState());
        });
        photoAlbumBtn.loadGraphic(Paths.image('desktop/icons/photo_album'));
        photoAlbumBtn.y = taskbar.y + (taskbar.height / 2) - (photoAlbumBtn.height / 2);
        photoAlbumBtn.x = (startBtn.width * 2) - (photoAlbumBtn.width / 2);
        add(photoAlbumBtn);

        var musicPlayerBtn = new FlxButton(0, 0, null, function() {
            // FlxG.switchState(new MusicPlayerState());
        });
        musicPlayerBtn.loadGraphic(Paths.image('desktop/icons/music_player'));
        musicPlayerBtn.y = taskbar.y + (taskbar.height / 2) - (musicPlayerBtn.height / 2);
        musicPlayerBtn.x = (photoAlbumBtn.x + photoAlbumBtn.width) + 10;
        add(musicPlayerBtn);

        var achievementBtn = new FlxButton(0, 0, null, function() {
            // FlxG.switchState(new AchievementState());
        });
        achievementBtn.loadGraphic(Paths.image('desktop/icons/achievements'));
        achievementBtn.y = taskbar.y + (taskbar.height / 2) - (achievementBtn.height / 2);
        achievementBtn.x = (musicPlayerBtn.x + musicPlayerBtn.width) + 10;
        add(achievementBtn);
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
