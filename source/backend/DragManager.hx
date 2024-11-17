package backend;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.input.mouse.FlxMouseEvent;

import backend.ApplicationButton;

enum DragType {
    NONE;
    WINDOW_DRAG;
    WINDOW_RESIZE;
    APP_DRAG;
}

class DragManager
{
    private static var instance:DragManager;

    public var isDragging:Bool = false;
    private var isDragEnabled:Bool = true;

    private var draggedApp:ApplicationButton = null;
    private var draggedType:DragType = NONE;
    private var dragOffset:FlxPoint = new FlxPoint();
    private var dragStartPosition:FlxPoint = new FlxPoint();
    private var dragThreshold:Float = 5;

    private var buttons:Array<ApplicationButton> = [];

    private function new() {}

    public static function i():DragManager {
        if (instance == null)
            instance = new DragManager();
        return instance;
    }

    public function allowDragging():Void {
        isDragEnabled = true;
    }

    public function disableDragging():Void {
        isDragEnabled = false;
        resetDrag();
    }

    private function resetDrag():Void {
        isDragging = false;
        draggedType = NONE;
        draggedApp = null;
    }

    public function setButton(button:ApplicationButton):Void {
        if (!buttons.contains(button))
            buttons.push(button);

        FlxMouseEvent.add(button, onMouseDown);
        FlxMouseEvent.setMouseClickCallback(button, onClick);
        FlxMouseEvent.setMouseDoubleClickCallback(button, onDoubleClick);
    }

    private function onClick(sprite:FlxSprite):Void {
        if (!isDragging) {
            var button:ApplicationButton = cast sprite;
            if (button._onSingleClick != null)
                button._onSingleClick();
        }
    }

    private function onDoubleClick(sprite:FlxSprite):Void {
        if (!isDragging) {
            var button:ApplicationButton = cast sprite;
            if (button._onDoubleClick != null)
                button._onDoubleClick();
        }
    }

    private function onMouseDown(sprite:FlxSprite):Void {
        if (!isDragEnabled) {
            return;
        }
        
        var button:ApplicationButton = cast sprite;
        draggedApp = button;
        draggedType = APP_DRAG;
        
        dragOffset.set(
            FlxG.mouse.x - button.x,
            FlxG.mouse.y - button.y
        );
        
        dragStartPosition.set(FlxG.mouse.x, FlxG.mouse.y);
    }

	private function checkMouseReleased():Bool {
		if (!FlxG.mouse.pressed) {
			resetDrag();
			return true;
		}

		return false;
	}
	
	private function checkDragThreshold():Void {
		var deltaX:Float = FlxG.mouse.x - dragStartPosition.x;
		var deltaY:Float = FlxG.mouse.y - dragStartPosition.y;
		var distanceMoved:Float = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
		
		if (distanceMoved > dragThreshold) {
			isDragging = true;
		}
	}
	
	private function updateDragPosition():Void {
		var newX:Float = FlxG.mouse.x - dragOffset.x;
		var newY:Float = FlxG.mouse.y - dragOffset.y;
		
		draggedApp.updatePosition(newX, newY);
	}
	
	public function update():Void {
		if (!isDragEnabled) return;
		
		if (draggedApp != null) {
			if (checkMouseReleased()) return;
			
			if (!isDragging) {
				checkDragThreshold();
			}
			
			if (isDragging) {
				updateDragPosition();
			}
		}
	}
}