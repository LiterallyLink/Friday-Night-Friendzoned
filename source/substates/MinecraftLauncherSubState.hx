package substates;

import flixel.*;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxSpriteContainer;

class MinecraftLauncherSubState extends MusicBeatSubstate
{
    private static final PADDING:Int = 4;
    private static final BUTTON_SPACING:Int = 2;
    private static final DIFFICULTIES:Array<String> = ["Peaceful", "Easy", "Normal", "Hard", "Hardcore"];

    private var window:FlxSpriteContainer;
    private var header:FlxButton;

    private var difficultyButton:FlxButton;
    private var difficultyIndex:Int = 0;

    private var isDragging:Bool = false;
    private var dragOffset:FlxPoint = new FlxPoint();
    private var isWindowBeingDragged:Bool = false;

	public function new()
	{
		super();
        closeCallback = () -> {};
	}
	
	override public function create():Void 
	{
        super.create();

        window = new FlxSpriteContainer();

        var backdrop:FlxSprite = new FlxSprite().loadGraphic(Paths.image('desktop/applications/minecraft/mc_launcher_window'));
        backdrop.screenCenter(XY);
        window.add(backdrop);

        header = new FlxButton(backdrop.x + PADDING, backdrop.y + PADDING);
        header.loadGraphic(Paths.image('desktop/applications/minecraft/mc_launcher_header'));
        window.add(header);

        var icon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('desktop/applications/minecraft/mc_header_icon'));
        icon.x = header.x + PADDING;
        icon.y = header.y + (header.height - icon.height) / 2;
        window.add(icon);

        var xButton:FlxButton = new FlxButton(() -> {
            close();
        });
        xButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_header_x'));
        xButton.setPosition(
            backdrop.x + backdrop.width - xButton.width - 5,
            backdrop.y + 5
        );
        window.add(xButton);

        var fullscreenButton:FlxButton = new FlxButton(() -> {
            // FlxG.switchState(new MinecraftLauncherSubState());
        });
        fullscreenButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_header_fullscreen'));
        fullscreenButton.setPosition(
            xButton.x - fullscreenButton.width - 2,
            xButton.y
        );
        window.add(fullscreenButton);

        var minimizeButton:FlxButton = new FlxButton(() -> {
            // FlxG.switchState(new MinecraftLauncherSubState());
        });
        minimizeButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_header_minimize'));
        minimizeButton.setPosition(
            fullscreenButton.x - minimizeButton.width - 2,
            xButton.y
        );
        window.add(minimizeButton);

        var title:FlxText = new FlxText("Minecraft Launcher", 10);
        title.setPosition(
            icon.x + icon.width + PADDING,
            header.y + (header.height - title.height) / 2
        );
        window.add(title);

        var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('desktop/applications/minecraft/mc_logo'));
        logo.setPosition(
            backdrop.x + (logo.width / 4),
            backdrop.y + backdrop.height - (logo.height * 2)
        );
        window.add(logo);

        var launchButton:FlxButton = new FlxButton("Play Selected World", () -> {
            FlxG.sound.play(Paths.sound('minecraft/click'), false);
        });
        launchButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_launcher_button'));
        launchButton.setPosition(
            logo.x + logo.width + (PADDING * 2),
            logo.y + (logo.height / 2) - (launchButton.height / 2)
        );
        launchButton.label.setFormat(Paths.font("Minecraft.ttf"), 10, FlxColor.WHITE);
        window.add(launchButton);

        difficultyButton = new FlxButton("Difficulty:" + DIFFICULTIES[difficultyIndex], cycleDifficulty);
        difficultyButton.loadGraphic(Paths.image('desktop/applications/minecraft/mc_launcher_button'));
        difficultyButton.setPosition(
            launchButton.x + launchButton.width + (PADDING * 2),
            launchButton.y
        );
        difficultyButton.label.setFormat(Paths.font("Minecraft.ttf"), 10, FlxColor.WHITE);
        window.add(difficultyButton);
        
        add(window);
	}

    override function update(elapsed:Float) {
        super.update(elapsed);
        handleDragging();
    }

    private function handleDragging():Void {
        if (FlxG.mouse.justPressed && header.overlapsPoint(FlxG.mouse.getPosition())) {
            isWindowBeingDragged = true;
            dragOffset.set(FlxG.mouse.x - window.x, FlxG.mouse.y - window.y);
        }

        if (FlxG.mouse.justReleased) isWindowBeingDragged = false;

        if (isWindowBeingDragged) {
            window.setPosition(
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