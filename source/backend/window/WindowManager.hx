package backend.window;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

import backend.composite.CompositeSprite;

enum ResizeDirection {
    NONE;
    LEFT;
    RIGHT;
    TOP;
    BOTTOM;
    TOP_LEFT;
    TOP_RIGHT;
    BOTTOM_LEFT;
    BOTTOM_RIGHT;
}

class WindowManager extends FlxSpriteGroup {
    private static inline var DRAG_THRESHOLD:Float = 5;
    private static inline var DRAG_THRESHOLD_SQUARED:Float = DRAG_THRESHOLD * DRAG_THRESHOLD;

    private var composite:CompositeSprite;
    private var dragHandle:FlxSprite;
    public var draggable:Bool = true;
    public var resizable:Bool = true;

    private var baseWidth:Float;
    private var baseHeight:Float;

    private var topLeftCorner:FlxSprite;
    private var topMiddle:FlxSprite;
    private var topRightCorner:FlxSprite;
    private var leftMiddle:FlxSprite;
    private var rightMiddle:FlxSprite;
    private var bottomLeftCorner:FlxSprite;
    private var bottomMiddle:FlxSprite;
    private var bottomRightCorner:FlxSprite;

    private var lastCompositeX:Float;
    private var lastCompositeY:Float;

    private var isDragging:Bool = false;
    private var isMouseDown:Bool = false;
    private var dragStartPosition:FlxPoint;
    private var dragOffset:FlxPoint;
    private var bounds:FlxRect;

    public function new(composite:CompositeSprite, ?bounds:FlxRect = null) {
        super();
        
        this.composite = composite;
        this.bounds = bounds;
        
        add(composite);

        this.baseWidth = composite.width;
        this.baseHeight = composite.height;
        
        this.lastCompositeX = composite.x;
        this.lastCompositeY = composite.y;

        dragStartPosition = FlxPoint.get();
        dragOffset = FlxPoint.get();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        if (isMouseDown && dragHandle != null && !isDragging) {
            checkDragThreshold();
        }
        
        if (!FlxG.mouse.pressed) {
            isDragging = false;
            isMouseDown = false;
        }
        
        if (isDragging && FlxG.mouse.pressed) {
            updateDragPosition();
        }
        
        if (composite.x != lastCompositeX || composite.y != lastCompositeY) {
            lastCompositeX = composite.x;
            lastCompositeY = composite.y;
        }
    }

    private function createBorders():Void {
        topLeftCorner = new FlxSprite();
        topLeftCorner.loadGraphic(Paths.image('menudesktop/applications/window/top-left'));
        add(topLeftCorner);
        
        topRightCorner = new FlxSprite();
        topRightCorner.loadGraphic(Paths.image('menudesktop/applications/window/top-right'));
        add(topRightCorner);
        
        bottomLeftCorner = new FlxSprite();
        bottomLeftCorner.loadGraphic(Paths.image('menudesktop/applications/window/bottom-left'));
        add(bottomLeftCorner);
        
        bottomRightCorner = new FlxSprite();
        bottomRightCorner.loadGraphic(Paths.image('menudesktop/applications/window/bottom-right'));
        add(bottomRightCorner);

        topMiddle = new FlxSprite();
        topMiddle.loadGraphic(Paths.image('menudesktop/applications/window/top-middle'));
        add(topMiddle);

        bottomMiddle = new FlxSprite();
        bottomMiddle.loadGraphic(Paths.image('menudesktop/applications/window/bottom-middle'));
        add(bottomMiddle);

        leftMiddle = new FlxSprite();
        leftMiddle.loadGraphic(Paths.image('menudesktop/applications/window/middle-left'));
        add(leftMiddle);

        rightMiddle = new FlxSprite();
        rightMiddle.loadGraphic(Paths.image('menudesktop/applications/window/middle-right'));
        add(rightMiddle);
    }

    public function createDragHandle(width:Float, height:Float, xPos:Float, yPos:Float, ?debug:Bool = false):Void {
        dragHandle = new FlxSprite();
        
        var color:Int = debug ? 0x33FF0000 : 0x01000000;
        dragHandle.makeGraphic(Std.int(width), Std.int(height), color);
        
        dragHandle.x = xPos;
        dragHandle.y = yPos;
        
        composite.add(dragHandle);
        
        FlxMouseEvent.add(dragHandle, onMouseDown, onMouseUp, null, null, false, true, false, [FlxMouseButtonID.LEFT, FlxMouseButtonID.RIGHT]);
    }

    private function onMouseDown(sprite:FlxSprite):Void {
        if (!draggable || FlxG.mouse.justPressedRight) {
            return;
        }

        isMouseDown = true;
        isDragging = false;
        
        dragStartPosition.set(FlxG.mouse.x, FlxG.mouse.y);
        dragOffset.set(FlxG.mouse.x - composite.x, FlxG.mouse.y - composite.y);
    }
    
    private function onMouseUp(sprite:FlxSprite):Void {
        isDragging = false;
        isMouseDown = false;
    }

    private function checkDragThreshold():Void {
        var deltaX:Float = FlxG.mouse.x - dragStartPosition.x;
        var deltaY:Float = FlxG.mouse.y - dragStartPosition.y;
        var distanceSquared:Float = deltaX * deltaX + deltaY * deltaY;
                
        if (distanceSquared > DRAG_THRESHOLD_SQUARED) {
            isDragging = true;
        }
    }
    
    private function updateDragPosition():Void {
        var newX:Float = FlxG.mouse.x - dragOffset.x;
        var newY:Float = FlxG.mouse.y - dragOffset.y;
        
        if (bounds != null) {
            newX = Math.max(bounds.x, Math.min(newX, 
                bounds.right - composite.width));
                
            newY = Math.max(bounds.y, Math.min(newY, 
                bounds.bottom - composite.height));
        }
        
        composite.setPosition(newX, newY);
    }

    private function updateBorderPositions():Void {
        var bounds = {
            x: composite.x,
            y: composite.y,
            width: composite.width,
            height: composite.height
        };
                
        topLeftCorner.setPosition(bounds.x, bounds.y);
        
        topRightCorner.setPosition(
            bounds.x + bounds.width - topRightCorner.width,
            bounds.y
        );
        
        bottomLeftCorner.setPosition(
            bounds.x,
            bounds.y + bounds.height - bottomLeftCorner.height
        );
        
        bottomRightCorner.setPosition(
            bounds.x + bounds.width - bottomRightCorner.width,
            bounds.y + bounds.height - bottomRightCorner.height
        );

        var horizontalMiddleWidth = bounds.width - topLeftCorner.width - topRightCorner.width;
        var verticalMiddleHeight = bounds.height - topLeftCorner.height - bottomLeftCorner.height;
        
        topMiddle.setGraphicSize(Std.int(horizontalMiddleWidth), Std.int(topMiddle.height));
        topMiddle.updateHitbox();
        topMiddle.setPosition(bounds.x + topLeftCorner.width, bounds.y);

        bottomMiddle.setGraphicSize(Std.int(horizontalMiddleWidth), Std.int(bottomMiddle.height));
        bottomMiddle.updateHitbox();
        bottomMiddle.setPosition(bounds.x + bottomLeftCorner.width, bounds.y + bounds.height - bottomMiddle.height);

        leftMiddle.setGraphicSize(Std.int(leftMiddle.width), Std.int(verticalMiddleHeight));
        leftMiddle.updateHitbox();
        leftMiddle.setPosition(bounds.x, bounds.y + topLeftCorner.height);

        rightMiddle.setGraphicSize(Std.int(rightMiddle.width), Std.int(verticalMiddleHeight));
        rightMiddle.updateHitbox();
        rightMiddle.setPosition(bounds.x + bounds.width - rightMiddle.width, bounds.y + topRightCorner.height);
    }

    override public function destroy():Void {
        if (dragStartPosition != null) {
            dragStartPosition.put();
        }
        if (dragOffset != null) {
            dragOffset.put();
        }
        if (bounds != null) {
            bounds.put();
        }

        if (dragHandle != null) {
            FlxMouseEvent.remove(dragHandle);
        }

        super.destroy();
    }
}