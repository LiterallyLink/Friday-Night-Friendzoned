package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxPoint;

class DragManager
{
    private static var instance:DragManager;
    private var draggableGroups:Map<FlxSprite, FlxSpriteContainer> = new Map();
    private var isDragging:Bool = false;
    private var currentDragSprite:FlxSprite = null;
    private var dragOffset:FlxPoint = new FlxPoint();

    public static function getInstance():DragManager
    {
        if (instance == null)
            instance = new DragManager();
        return instance;
    }

    private function new() {}

    public function registerDraggableGroup(group:FlxSpriteContainer, dragSprite:FlxSprite):Void 
    {
        draggableGroups.set(dragSprite, group);
    }

    public function update():Void 
    {
        if (FlxG.mouse.justReleased) 
        {
            isDragging = false;
            currentDragSprite = null;
            return;
        }

        if (isDragging && currentDragSprite != null) 
        {
            var group = draggableGroups.get(currentDragSprite);
            if (group != null) {
                group.x = FlxG.mouse.x - dragOffset.x;
                group.y = FlxG.mouse.y - dragOffset.y;
            }
            return;
        }

        if (FlxG.mouse.justPressed) 
        {
            for (sprite in draggableGroups.keys()) 
            {
                if (sprite.overlapsPoint(FlxG.mouse.getPosition())) 
                {
                    isDragging = true;
                    currentDragSprite = sprite;
                    var group = draggableGroups.get(sprite);
                    if (group != null) {
                        dragOffset.set(
                            FlxG.mouse.x - group.x,
                            FlxG.mouse.y - group.y
                        );
                    }
                    break;
                }
            }
        }
    }
}