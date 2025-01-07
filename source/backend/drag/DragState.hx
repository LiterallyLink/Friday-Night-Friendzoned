package backend.drag;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import backend.ApplicationButton;
import backend.composite.CompositeSprite;

class DragState {
    public var draggedObject:ApplicationButton;
    public var isDragging:Bool;
    public var isDragEnabled:Bool;
    public var dragOffset:FlxPoint;
    public var dragStartPosition:FlxPoint;
    public var bounds:FlxRect;
        
    public function new() {
        isDragging = false;
        isDragEnabled = true;
        dragOffset = new FlxPoint();
        dragStartPosition = new FlxPoint();
    }
    
    public function reset():Void {
        isDragging = false;
        draggedObject = null;
        bounds = null;
    }
}