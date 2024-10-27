package substates;

import flixel.*;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxSpriteContainer;

class MinecraftLauncherSubState extends MusicBeatSubstate
{
    private static final PADDING:Int = 4;

    public static final DIFFICULTIES:Array<String> = ["Peaceful", "Normal", "Hardcore"];
    private static var difficultyIndex = 0;
    public var difficultyButton:FlxButton;

    private var mcLauncher:FlxSpriteContainer;
    public var backdrop:FlxSprite;
    private var header:FlxButton;

    private var isDragging:Bool = false;
    private var dragOffset:FlxPoint = new FlxPoint();
    private var ismcLauncherBeingDragged:Bool = false;

	public function new()
	{
		super();
        closeCallback = () -> {};
	}
	
	override public function create():Void 
	{
        super.create();
        createmcLauncher();

        header = new FlxButton();
        header.loadGraphic(Paths.image('desktop/applications/minecraft/mc_launcher_header'));
        header.setPosition(backdrop.x + PADDING, backdrop.y + PADDING);
        mcLauncher.add(header);

        var launcherIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('desktop/applications/minecraft/mc_header_icon'));
        launcherIcon.setPosition(
            backdrop.x + (launcherIcon.width / 2),
            (backdrop.y + launcherIcon.height / 2) - 1
        );
        mcLauncher.add(launcherIcon);

        var launcherTitle:FlxText = new FlxText("Minecraft", 10);
        launcherTitle.setPosition(
            launcherIcon.x + launcherIcon.width + PADDING,
            launcherIcon.y + (launcherIcon.height / 2) - (launcherTitle.height / 2)
        );
        mcLauncher.add(launcherTitle);

        var selectWorldText:FlxText = new FlxText("Select World", 10);
        selectWorldText.setPosition(
            launcherIcon.x + (launcherIcon.width / 2),
            backdrop.y + header.height + (PADDING * 2)
        );
        mcLauncher.add(selectWorldText);

        var worlds = [
            { name:"Farlands", dateCreated: "(8/13/17, TIME TBA)", mode: "Survival Mode,", version: "1.7.3", image: "mc_level_farlands"},
            { name: "N.T.T", dateCreated: "(DATE TBA, TIME TBA)", mode: "Survival Mode,", version: "1.20.6", image: "mc_level_entities"}
        ];

        var xPos = backdrop.x + (launcherIcon.width / 2) + (PADDING * 6);
        var yPos = backdrop.y + (19 + PADDING) * 2;

        for (i in 0...worlds.length) {
            var world = worlds[i];

            var worldButton = new FlxButton(() -> {
                FlxG.sound.play(Paths.sound('minecraft/click'), false);
            });
            worldButton.loadGraphic(Paths.image('desktop/applications/minecraft/${world.image}'));
            worldButton.setPosition(xPos, yPos);
            mcLauncher.add(worldButton);

            var worldName = new FlxText(worldButton.x + worldButton.width + PADDING, worldButton.y, world.name);
            mcLauncher.add(worldName);
            
            var worldInfo = new FlxText(
                worldName.x,
                worldName.y + worldName.height - PADDING,
                '${world.name} ${world.dateCreated}\n${world.mode} Version: ${world.version}'
            );
            worldInfo.setFormat(10, FlxColor.GRAY);
                
            mcLauncher.add(worldInfo);

            yPos += (worldButton.height * 1.5) + PADDING;
            worldButton.width = 313;
        }

        var xButton:FlxButton = new FlxButton(() -> {
            close();
        });
        xButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_header_x'));
        xButton.setPosition(
            header.x + header.width - xButton.width,
            header.y + (header.height / 2) - (xButton.height / 2)
        );
        mcLauncher.add(xButton);

        var fullscreenButton:FlxButton = new FlxButton(() -> {
            // FlxG.switchState(new MinecraftLauncherSubState());
        });
        fullscreenButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_header_fullscreen'));
        fullscreenButton.setPosition(
            xButton.x - fullscreenButton.width - (PADDING / 2),
            xButton.y
        );
        mcLauncher.add(fullscreenButton);

        var minimizeButton:FlxButton;
        minimizeButton = new FlxButton(() -> {
            mcLauncher.visible = false;
        });
        minimizeButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_header_minimize'));
        minimizeButton.setPosition(
            fullscreenButton.x - minimizeButton.width - (PADDING / 2),
            xButton.y
        );
        mcLauncher.add(minimizeButton);

        var playButton = new FlxButton("Play Selected World", () -> {
            FlxG.sound.play(Paths.sound('minecraft/click'), false);
        });
        playButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_launcher_button'));
        playButton.setPosition(
            backdrop.x + playButton.width,
            backdrop.y + backdrop.height - (playButton.height * 1.5)
        );
        mcLauncher.add(playButton);

        difficultyButton = new FlxButton('Difficulty: ${DIFFICULTIES[difficultyIndex]}', cycleDifficulty);
        difficultyButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_launcher_button'));
        difficultyButton.setPosition(
            playButton.x + difficultyButton.width + (PADDING * 2),
            backdrop.y + backdrop.height - (difficultyButton.height * 1.5)
        );
        mcLauncher.add(difficultyButton);

        add(mcLauncher);
        mcLauncher.scale.set(2, 2);
	}

    private function createmcLauncher():Void {
        mcLauncher = new FlxSpriteContainer();
        backdrop = new FlxSprite().loadGraphic(Paths.image('desktop/applications/minecraft/launcher_window'));
        backdrop.screenCenter(XY);
        mcLauncher.add(backdrop);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        handleDragging();
    }

    private function handleDragging():Void {
        if (FlxG.mouse.justPressed && header.overlapsPoint(FlxG.mouse.getPosition())) {
            ismcLauncherBeingDragged = true;
            dragOffset.set(FlxG.mouse.x - mcLauncher.x, FlxG.mouse.y - mcLauncher.y);
        }

        if (FlxG.mouse.justReleased) ismcLauncherBeingDragged = false;

        if (ismcLauncherBeingDragged) {
            mcLauncher.setPosition(
                FlxG.mouse.x - dragOffset.x,
                FlxG.mouse.y - dragOffset.y
            );
        }
    }

    private function cycleDifficulty():Void {
        FlxG.sound.play(Paths.sound('minecraft/click'), false);
        difficultyIndex = (difficultyIndex + 1) % DIFFICULTIES.length;
        difficultyButton.text = "Difficulty: " + DIFFICULTIES[difficultyIndex];
    }
	
}