package substates;

import flixel.*;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.group.FlxSpriteContainer;
import flixel.input.keyboard.FlxKey;

import backend.DragManager;

class MinecraftLauncherSubState extends MusicBeatSubstate
{
    private static final BASE_PADDING:Int = 4;
    private static final BASE_WIDTH:Float = 854;
    private static final BASE_HEIGHT:Float = 480;
    private static final BASE_FONT_SIZE:Int = 10;
    
    private static final MIN_SCALE:Float = 0.5;
    private static final MAX_SCALE:Float = 5.0;
    private static final SCALE_STEP:Float = 0.1;

    private var mcLauncher:FlxSpriteContainer;
    public var backdrop:FlxSprite;
    private var header:FlxButton;
    private var launcherIcon:FlxSprite;
    private var launcherTitle:FlxText;
    private var xButton:FlxButton;
    private var fullscreenButton:FlxButton;
    private var minimizeButton:FlxButton;
    private var selectWorldText:FlxText;
    
    private var scaleX:Float;
    private var scaleY:Float;
    private var scaledPadding:Float;
    private var currentScale:Float = 1.0;

    private static final worlds = [
        { name:"Farlands", dateCreated: "(8/13/17, 7:27 PM)", mode: "Survival Mode,", version: "1.7.3", image: "mc_level_farlands"},
        { name: "N.T.T", dateCreated: "(DATE TBA, TIME TBA)", mode: "Survival Mode,", version: "1.20.6", image: "mc_level_entities"}
    ];

    public function new()
    {
        super();
        closeCallback = () -> {};
    }
    
    override public function create():Void 
    {
        super.create();
        calculateScaling();
        createMCLauncher();
        
        header = new FlxButton();
        header.loadGraphic(Paths.image('menudesktop/applications/minecraft/mc_launcher_header'));
        
        launcherIcon = new FlxSprite();
        launcherIcon.loadGraphic(Paths.image('menudesktop/applications/minecraft/mc_launcher_icon'));
        
        launcherTitle = new FlxText(0, 0, 0, "Minecraft", Math.round(BASE_FONT_SIZE * currentScale));
        
        selectWorldText = new FlxText(0, 0, 0, "Select World", Math.round(BASE_FONT_SIZE * currentScale));
        
        xButton = new FlxButton(0, 0, "", () -> {
            close();
        });
        xButton.loadGraphic(Paths.image('menudesktop/applications/minecraft/mc_header_x'));
        
        fullscreenButton = new FlxButton(0, 0, "", () -> {
            // FlxG.switchState(new MinecraftLauncherSubState());
        });
        fullscreenButton.loadGraphic(Paths.image('menudesktop/applications/minecraft/mc_header_fullscreen'));
        
        minimizeButton = new FlxButton(0, 0, "", () -> {
            mcLauncher.visible = false;
        });
        minimizeButton.loadGraphic(Paths.image('menudesktop/applications/minecraft/mc_header_minimize'));
        
        mcLauncher.add(header);
        mcLauncher.add(launcherIcon);
        mcLauncher.add(launcherTitle);
        mcLauncher.add(selectWorldText);
        mcLauncher.add(xButton);
        mcLauncher.add(fullscreenButton);
        mcLauncher.add(minimizeButton);
        createWorldsList();

        updateScale();
        
        add(mcLauncher);

        DragManager.getInstance().registerDraggableGroup(mcLauncher, header);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        DragManager.getInstance().update();
        
        var ctrlPressed:Bool = FlxG.keys.pressed.CONTROL;
        
        if (ctrlPressed)
        {
            if (FlxG.keys.justPressed.PLUS)
            {
                currentScale = Math.min(currentScale + SCALE_STEP, MAX_SCALE);
                updateScale();
            }
            else if (FlxG.keys.justPressed.MINUS)
            {
                currentScale = Math.max(currentScale - SCALE_STEP, MIN_SCALE);
                updateScale();
            }
        }
    }

    private function scaleElement(element:FlxSprite):Void {
        element.scale.set(scaleX * currentScale, scaleY * currentScale);
        element.updateHitbox();
    }

    private function updateScale():Void
        {
            calculateScaling();
            
            scaleElement(backdrop);
            backdrop.screenCenter(XY);
            
            scaleElement(header);
            scaleElement(launcherIcon);
            
            launcherTitle.size = Math.round(BASE_FONT_SIZE * currentScale);
            selectWorldText.size = Math.round(BASE_FONT_SIZE * currentScale);
            
            scaleElement(xButton);
            scaleElement(fullscreenButton);
            scaleElement(minimizeButton);
            
            header.setPosition(
                backdrop.x + (scaledPadding * currentScale), 
                backdrop.y + (scaledPadding * currentScale)
            );
            
            var headerCenterY:Float = header.y + (header.height / 2);
            
            launcherIcon.setPosition(
                header.x + (scaledPadding * currentScale * 2),
                headerCenterY - (launcherIcon.height / 2)
            );
            
            launcherTitle.setPosition(
                launcherIcon.x + launcherIcon.width + (scaledPadding * currentScale),
                headerCenterY - (launcherTitle.height / 2)
            );
            
            selectWorldText.setPosition(
                backdrop.x + (scaledPadding * currentScale * 4),
                backdrop.y + header.height + (scaledPadding * currentScale * 4)
            );
            
            xButton.setPosition(
                header.x + header.width - xButton.width - (scaledPadding * currentScale),
                headerCenterY - (xButton.height / 2)
            );
            
            fullscreenButton.setPosition(
                xButton.x - fullscreenButton.width - ((scaledPadding * currentScale) / 2),
                xButton.y
            );
            
            minimizeButton.setPosition(
                fullscreenButton.x - minimizeButton.width - ((scaledPadding * currentScale) / 2),
                xButton.y
            );

            for (sprite in mcLauncher.members.copy()) {
                if (sprite != backdrop && sprite != header && sprite != launcherIcon && 
                    sprite != launcherTitle && sprite != selectWorldText && 
                    sprite != xButton && sprite != fullscreenButton && sprite != minimizeButton) {
                    mcLauncher.remove(sprite);
                }
            }
            
            createWorldsList();
        }

    private function calculateScaling():Void {
        var gameWidth:Float = FlxG.width;
        var gameHeight:Float = FlxG.height;
        
        scaleX = gameWidth / BASE_WIDTH;
        scaleY = gameHeight / BASE_HEIGHT;
        
        scaledPadding = BASE_PADDING * scaleX;
    }

    private function createWorldsList():Void {
        var xPos = backdrop.x + (launcherIcon.width / 2) + (BASE_PADDING * currentScale * 6);
        var yPos = selectWorldText.y + selectWorldText.height + (BASE_PADDING * currentScale * 2);
    
        for (world in worlds) {
            var worldButton = new FlxButton(0, 0, "", () -> {
                FlxG.sound.play(Paths.sound('minecraft/click'));
            });
            worldButton.loadGraphic(Paths.image('menudesktop/applications/minecraft/${world.image}'));
            scaleElement(worldButton); 
            worldButton.setPosition(xPos, yPos);
            
            var worldName = new FlxText(
                worldButton.x + worldButton.width + (BASE_PADDING * currentScale), 
                worldButton.y, 
                0,
                world.name, 
                Math.round(BASE_FONT_SIZE * currentScale)
            );
            
            var worldInfo = new FlxText(
                worldName.x,
                worldName.y + worldName.height - (BASE_PADDING * currentScale),
                0,
                '${world.name} ${world.dateCreated}\n${world.mode} Version: ${world.version}',
                Math.round(BASE_FONT_SIZE * currentScale)
            );
            worldInfo.setFormat(null, Math.round(BASE_FONT_SIZE * currentScale), FlxColor.GRAY);
            
            mcLauncher.add(worldButton);
            mcLauncher.add(worldName);
            mcLauncher.add(worldInfo);
    
            yPos += (worldButton.height * 1.5) + (BASE_PADDING * currentScale);
            worldButton.width = 313 * (scaleX * currentScale);
        }
    }

    private function createMCLauncher():Void {
        mcLauncher = new FlxSpriteContainer();
        
        backdrop = new FlxSprite().loadGraphic(Paths.image('menudesktop/applications/minecraft/launcher_window'));
        backdrop.scale.set(scaleX, scaleY);
        backdrop.updateHitbox();
        backdrop.screenCenter(XY);
        
        mcLauncher.add(backdrop);
    }
}