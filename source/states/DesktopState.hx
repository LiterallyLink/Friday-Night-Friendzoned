package states;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.ui.FlxButton;
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxSpriteGroup;

import flixel.addons.transition.FlxTransitionableState;

import substates.MinecraftLauncherSubState;
import substates.paint.PaintSubState;

import backend.ShaderManager;
import backend.ApplicationButton;

class DesktopState extends MusicBeatState
{
    private static inline var X_PADDING:Int = 6;
    private static inline var Y_PADDING:Int = 10;

    private var clockGroup:FlxSpriteGroup;

    public var hasBrowserTransformed:Bool = ClientPrefs.data.hasBrowserTransformed;
    public var applicationArray:Array<ApplicationButton> = [];

	override function create()
	{	
        //ShaderManager.getInstance().applyShaders();

        var desktopTheme:String = ClientPrefs.data.desktopTheme;

        FlxG.sound.playMusic(Paths.music('desktopTheme'), 0.5, true);
        FlxG.sound.play(Paths.sound('humming'), true);

        var desktopBg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menudesktop/bgs/${desktopTheme}'));
        var taskbar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menudesktop/taskbar'));
        taskbar.y = FlxG.height - taskbar.height;

        add(desktopBg);
        add(taskbar);

        createTaskbarButtons(taskbar);

        var desktopBounds:FlxRect = new FlxRect(0, 0, FlxG.width, FlxG.height - taskbar.height);
        createDesktopApplications(desktopBounds);
        // createClock();
	}

    private function createTaskbarButtons(taskbar:FlxSprite):Void
    {
        var startButton = new FlxButton(X_PADDING, taskbar.y + Y_PADDING, () -> {
            //
        });
        startButton.loadGraphic(Paths.image('menudesktop/taskbar/start'));
        add(startButton);
    
        var BUTTON_PADDING:Int = X_PADDING + Y_PADDING;
        var currentX:Float = startButton.x + startButton.width + BUTTON_PADDING;
    
        // Array of button configurations
        var buttons:Array<{image:String, callback:()->Void}> = [
            {
                image: 'menudesktop/taskbar/photo_album',
                callback: () -> {
                    // FlxG.switchState(new PhotoAlbumState());
                }
            },
            {
                image: 'menudesktop/taskbar/music_player',
                callback: () -> {
                    // FlxG.switchState(new MusicPlayerState());
                }
            },
            {
                image: 'menudesktop/taskbar/achievements',
                callback: () -> {
                    // FlxG.switchState(new AchievementState());
                }
            }
        ];
    
        // Create buttons from configuration
        for (buttonConfig in buttons)
        {
            var button = new FlxButton(currentX, 0, buttonConfig.callback);
            button.loadGraphic(Paths.image(buttonConfig.image));
            button.y = taskbar.y + (taskbar.height / 2) - (button.height / 2);
            
            currentX += button.width + BUTTON_PADDING;
            add(button);
        }
    }

    private function createDesktopApplications(desktopBounds):Void {
        var appLethalCompany:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/lethal_company',
            "Lethal Company",
            desktopBounds,
        );
        
        var appMinecraftLauncher:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/mc',
            "Minecraft",
            desktopBounds,
            () -> {}
            //openSubState(new MinecraftLauncherSubState())
        );

        var appMoviePlayer:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/media_file',
            "FNa2023...\n.mov",
            desktopBounds,
        );

        var appRecycleBin:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/recycling_bin_empty',
            "Recycling Bin",
            desktopBounds,
        );

        var appCredits:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/sticky_note',
            "Credits.txt",
            desktopBounds,
        );

        var appBrowser:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/web_browser',
            "Web Browser",
            desktopBounds,
        );

        var appGavel:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/gavel',
            "Gavel",
            desktopBounds,
        );

        var appKirby:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/kirby',
            "Abby Returns\nTo Dreamland",
            desktopBounds,
        );

        var appUndertale:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/undertale',
            "Undertale",
            desktopBounds,
        );

        var appDOOM:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/DOOM',
            "DOOM",
            desktopBounds,
            () -> {}
        );

        var appPaint:ApplicationButton = new ApplicationButton(
            0,
            0,
            'menudesktop/applications/fzpaint',
            "FZPaint",
            desktopBounds,
            () -> {
                openSubState(new PaintSubState());
            }
        );

        //add(appLethalCompany);
        //add(appMinecraftLauncher);
        //add(appMoviePlayer);
        //add(appRecycleBin);
        //add(appCredits);
        //add(appBrowser);
        //add(appGavel);
        //add(appKirby);
        //add(appUndertale);
        //add(appDOOM);
        add(appPaint);
    }

    private function createClock():Void {
        clockGroup = new FlxSpriteGroup();
    
        var innerWidth:Int = 162;
        var innerHeight:Int = 51;
        var borderWidth:Int = innerWidth + 6;
        var borderHeight:Int = innerHeight + 6;
    
        var clockBorder:FlxSprite = new FlxSprite(0, 0);
        clockBorder.makeGraphic(borderWidth, borderHeight, FlxColor.BLACK);
    
        FlxSpriteUtil.drawRect(clockBorder, 0, 0, borderWidth, 3, 0xFF333333);
        FlxSpriteUtil.drawRect(clockBorder, 0, 0, 3, borderHeight, 0xFF333333);
        FlxSpriteUtil.drawRect(clockBorder, 0, borderHeight - 3, borderWidth, 3, FlxColor.WHITE);
        FlxSpriteUtil.drawRect(clockBorder, borderWidth - 3, 0, 3, borderHeight, FlxColor.WHITE);

        clockBorder.x = FlxG.width - clockBorder.width + (X_PADDING + Y_PADDING);
        clockBorder.y = FlxG.height - clockBorder.height - X_PADDING;
    
        clockGroup.add(clockBorder);
    
        add(clockGroup);
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