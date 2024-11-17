package backend.window;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEvent;
import backend.window.composite.CompositeSprite;

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
    private var composite:CompositeSprite;

    private var baseWidth:Float;
    private var baseHeight:Float;

    private var currentResizeDirection:ResizeDirection = NONE;

    private var topLeftCorner:FlxSprite;
    private var topMiddle:FlxSprite;
    private var topRightCorner:FlxSprite;
    private var leftMiddle:FlxSprite;
    private var rightMiddle:FlxSprite;
    private var bottomLeftCorner:FlxSprite;
    private var bottomMiddle:FlxSprite;
    private var bottomRightCorner:FlxSprite;

    public function new(composite:CompositeSprite) {
        super();
        
        this.composite = composite;
        
        add(composite);

        this.baseWidth = composite.width;
        this.baseHeight = composite.height;

        createBorders();
        updateBorderPositions();
        setupResizeHandlers();
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

    private function setupResizeHandlers():Void {
        FlxMouseEvent.add(topLeftCorner, null, null, onResizeHover, onResizeExit, false, true, false);
        FlxMouseEvent.add(topMiddle, null, null, onResizeHover, onResizeExit, false, true, false);
        FlxMouseEvent.add(topRightCorner, null, null, onResizeHover, onResizeExit, false, true, false);
        
        FlxMouseEvent.add(leftMiddle, null, null, onResizeHover, onResizeExit, false, true, false);
        FlxMouseEvent.add(rightMiddle, null, null, onResizeHover, onResizeExit, false, true, false);
        
        FlxMouseEvent.add(bottomLeftCorner, null, null, onResizeHover, onResizeExit, false, true, false);
        FlxMouseEvent.add(bottomMiddle, null, null, onResizeHover, onResizeExit, false, true, false);
        FlxMouseEvent.add(bottomRightCorner, null, null, onResizeHover, onResizeExit, false, true, false);
    }

    private function onResizeHover(sprite:FlxSprite):Void {
        currentResizeDirection = if (sprite == topLeftCorner) TOP_LEFT
            else if (sprite == topMiddle) TOP
            else if (sprite == topRightCorner) TOP_RIGHT
            else if (sprite == leftMiddle) LEFT
            else if (sprite == rightMiddle) RIGHT
            else if (sprite == bottomLeftCorner) BOTTOM_LEFT
            else if (sprite == bottomMiddle) BOTTOM
            else if (sprite == bottomRightCorner) BOTTOM_RIGHT
            else NONE;
            
        updateMouseCursor(currentResizeDirection);
    }

    private function onResizeExit(sprite:FlxSprite):Void {
        trace('on resize exit');
        currentResizeDirection = NONE;
        updateMouseCursor(NONE);
    }

    private function updateMouseCursor(direction:ResizeDirection):Void {
        var cursor:FlxSprite = new FlxSprite();
        
        switch (direction) {
            case LEFT, RIGHT:
                cursor.loadGraphic(Paths.image('cursors/resize-horizontal'));
            case TOP, BOTTOM:
                cursor.loadGraphic(Paths.image('cursors/resize-vertical'));
            case TOP_LEFT, BOTTOM_RIGHT:
                cursor.loadGraphic(Paths.image('cursors/resize-nwse'));
            case TOP_RIGHT, BOTTOM_LEFT:
                cursor.loadGraphic(Paths.image('cursors/resize-nesw'));
            case NONE:
                cursor.loadGraphic(Paths.image('cursors/default'));
        }
        
        FlxG.mouse.load(cursor.pixels);
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

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        updateBorderPositions();
    }
}