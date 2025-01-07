package backend.drag;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

import backend.ApplicationButton;
import backend.composite.CompositeSprite;

import backend.drag.DragState;

import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;

class AppManager
{
    private static var instance:AppManager;
    
    private static inline var DRAG_THRESHOLD:Float = 5;
    private static inline var DRAG_THRESHOLD_SQUARED:Float = DRAG_THRESHOLD * DRAG_THRESHOLD;
    
    private var state:DragState;

    private function new() {
        state = new DragState();
    }

    public static function i():AppManager {
        if (instance == null)
            instance = new AppManager();
        return instance;
    }

    public function update():Void {
        if (FlxG.mouse.justPressedRight && state.draggedObject != null) {
            state.reset();
            return;
        }
        
        if (!state.isDragEnabled) {
            return;
        }
        
        if (state.draggedObject != null && FlxG.mouse.justReleased) {
            state.reset();
            return;
        }
        
        if (state.draggedObject != null) {
            if (!state.isDragging) {
                checkDragThreshold();
            }
            
            if (state.isDragging) {
                updateDragPosition();
            }
        }
    }

    public function allowDragging():Void {
        state.isDragEnabled = true;
    }

    public function disableDragging():Void {
        state.isDragEnabled = false;
        state.reset();
    }

    public function registerButton(button:ApplicationButton):Void {
        FlxMouseEvent.add(button, onMouseDown, onMouseUp, onMouseOver, onMouseOut, false, true, false, [FlxMouseButtonID.LEFT, FlxMouseButtonID.RIGHT]);
        FlxMouseEvent.setMouseClickCallback(button, onClick);
        FlxMouseEvent.setMouseDoubleClickCallback(button, onDoubleClick);
    }

    public function onMouseDown(button:ApplicationButton):Void {
        if (FlxG.mouse.justPressedRight) {
            if (button._onRightClick != null) {
                button._onRightClick();
            }
            
            if (state.draggedObject != null) {
                state.reset();
            }

            return;
        }

        if (!state.isDragEnabled) {
            return;
        }

        state.draggedObject = button;
        state.bounds = button._bounds;

        state.dragOffset.set(
            FlxG.mouse.x - button.x,
            FlxG.mouse.y - button.y
        );
        
        state.dragStartPosition.set(FlxG.mouse.x, FlxG.mouse.y);
    }
    
    public function onMouseUp(sprite:FlxSprite):Void {
        if (state.draggedObject != null) {
            state.reset();
        }
    }

    public function onMouseOver(sprite:FlxSprite):Void {
        if (state.isDragging)
            return;
    }
    
    public function onMouseOut(sprite:FlxSprite):Void {
        if (state.isDragging)
            return;
    }
    
    private function onClick(sprite:FlxSprite):Void {
        if (!state.isDragging) {

            var button:ApplicationButton = cast sprite;

            if (button._onSingleClick != null)
                button._onSingleClick();
        }
    }

    private function onDoubleClick(sprite:FlxSprite):Void {
        if (!state.isDragging) {

            var button:ApplicationButton = cast sprite;

            if (button._onDoubleClick != null)
                button._onDoubleClick();
        }
    }
    
    private function checkDragThreshold():Void {
        var deltaX:Float = FlxG.mouse.x - state.dragStartPosition.x;
        var deltaY:Float = FlxG.mouse.y - state.dragStartPosition.y;

        var distanceSquared:Float = deltaX * deltaX + deltaY * deltaY;
                
        if (distanceSquared > DRAG_THRESHOLD_SQUARED) {
            state.isDragging = true;
        }
    }
    
    private function isWithinBounds(newX:Float, newY:Float):Bool {
        if (state.bounds == null || state.draggedObject == null)
            return true;
        
        return (newX >= state.bounds.x && 
                newY >= state.bounds.y && 
                newX + state.draggedObject.width <= state.bounds.right && 
                newY + state.draggedObject.height <= state.bounds.bottom);
    }
    
    private function updateDragPosition():Void {
        var newX:Float = FlxG.mouse.x - state.dragOffset.x;
        var newY:Float = FlxG.mouse.y - state.dragOffset.y;
        
        if (state.draggedObject != null && state.bounds != null) {
            newX = Math.max(state.bounds.x, Math.min(newX, 
                state.bounds.right - state.draggedObject.width));
                
            newY = Math.max(state.bounds.y, Math.min(newY, 
                state.bounds.bottom - state.draggedObject.height));
                
            state.draggedObject.x = newX;
            state.draggedObject.y = newY;
        } else if (state.draggedObject != null) {
            state.draggedObject.x = newX;
            state.draggedObject.y = newY;
        }
    }
}