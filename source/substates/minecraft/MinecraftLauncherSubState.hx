package substates.minecraft;

import flixel.FlxSubState;

import backend.window.WindowManager;
import backend.composite.CompositeSprite;

class MinecraftLauncherSubState extends MusicBeatSubstate
{
    public var composite:CompositeSprite;
    private var window:WindowManager;


    public function new()
    {
        super();
    }
    
    override public function create():Void 
    {
        super.create();

        composite = new CompositeSprite();

        var backdrop = new FlxSprite();
        backdrop.loadGraphic(Paths.image('menudesktop/applications/minecraft/launcher_window'));
        
        composite.add(backdrop);
        composite.updateHitbox();
        // createDragHandle(width:Float, height:Float, xPos:Float, yPos:Float, ?debug:Bool = false)
        window = new WindowManager(composite);
        window.createDragHandle(756, 28, 8, 8, true);
        window.screenCenter();

        add(window);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}