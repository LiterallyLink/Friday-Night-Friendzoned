package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

class ApplicationButton extends FlxGroup
{
    // Constants
    private static inline var DOUBLE_CLICK_DELAY:Float = 0.3;
    private static inline var DRAG_DELAY:Float = 0.1;
    private static inline var LABEL_OFFSET:Float = -5;
    private static inline var BOUNDS_MARGIN:Float = 20;
    private static inline var RETURN_TWEEN_DURATION:Float = 0.5;
    private static inline var DRAG_THRESHOLD:Float = 5;

    // Core components
    private var button:FlxButton;
    private var label:FlxText;
    private var bounds:FlxRect;

    // Click handling
    private var clickCount:Int = 0;
    private var doubleClickTimer:FlxTimer;
    private var onDoubleClick:Null<() -> Void>;
    private var initialClickPos:FlxPoint;

    // Drag handling
    private var isDragging:Bool = false;
    private var isDraggable:Bool = true;
    private var dragOffset:FlxPoint;
    private var startDragTime:Float = 0;
    private var lastValidPosition:FlxPoint;
    private var returnTween:FlxTween;
    private var mouseDownPos:FlxPoint;
    private var isMouseDown:Bool = false;

    public function new(X:Float = 0, Y:Float = 0, Text:String = "", fontSize:Int = 12, ?GraphicPath:String, 
                       ?Bounds:FlxRect, isDraggable:Bool = true, ?OnDoubleClick:Null<() -> Void>)
    {
        super();
        trace('Creating new ApplicationButton at ($X, $Y) with text: $Text');
        initializeComponents(X, Y, Text, fontSize, GraphicPath, Bounds, isDraggable, OnDoubleClick);
    }

    private function initializeComponents(X:Float, Y:Float, Text:String, fontSize:Int, ?GraphicPath:String, 
                                        ?Bounds:FlxRect, isDraggable:Bool = true, ?OnDoubleClick:Null<() -> Void>):Void 
    {
        trace('Initializing components');
        lastValidPosition = FlxPoint.get(X, Y);
        dragOffset = FlxPoint.get();
        mouseDownPos = FlxPoint.get();
        initialClickPos = FlxPoint.get();
        this.isDraggable = isDraggable;
        
        bounds = Bounds != null ? Bounds : new FlxRect(0, 0, FlxG.width, FlxG.height);
        trace('Setting bounds: ${bounds.toString()}');

        button = new FlxButton(X, Y, null, null);
        if (GraphicPath != null) {
            trace('Loading graphic: $GraphicPath');
            button.loadGraphic(Paths.image(GraphicPath));
        }
        
        label = new FlxText(X, Y + button.height + LABEL_OFFSET, 0, Text, fontSize);
        label.alignment = CENTER;
        label.x = X + (button.width - label.width) / 2;
        label.color = FlxColor.WHITE;
        label.setBorderStyle(SHADOW, FlxColor.BLACK, 1);
        trace('Created label with text: $Text');
        
        add(button);
        add(label);
        
        onDoubleClick = OnDoubleClick;
        doubleClickTimer = new FlxTimer();
        
        button.onDown.callback = startDragCheck;
        button.onUp.callback = stopDragCheck;
        button.onOut.callback = handleButtonOut;
        button.onOver.callback = handleButtonOver;
        trace('Button callbacks set up');
    }

    private function handleClick():Void {
        trace('Handle click called, distance from initial: ${getDistanceFromInitialClick()}');
        if (getDistanceFromInitialClick() <= DRAG_THRESHOLD) {
            clickCount++;
            trace('Click count incremented to: $clickCount');
            
            if (clickCount == 1) {
                trace('First click detected, starting double click timer');
                doubleClickTimer.start(DOUBLE_CLICK_DELAY, (_) -> {
                    trace('Double click timer expired, resetting click count');
                    clickCount = 0;
                }, 1);
            }
            else if (clickCount == 2) {
                trace('Double click detected!');
                if (onDoubleClick != null) {
                    trace('Executing double click callback');
                    onDoubleClick();
                }
                clickCount = 0;
                doubleClickTimer.cancel();
            }
        }
    }

    private function getDistanceFromInitialClick():Float {
        var dx = FlxG.mouse.x - initialClickPos.x;
        var dy = FlxG.mouse.y - initialClickPos.y;
        var distance = Math.sqrt(dx * dx + dy * dy);
        trace('Distance from initial click: $distance px');
        return distance;
    }

    private function startDragCheck():Void {
        if (!isDraggable) return;
        
        trace('Starting drag check');
        isMouseDown = true;
        startDragTime = FlxG.game.ticks;
        mouseDownPos.set(FlxG.mouse.x, FlxG.mouse.y);
        initialClickPos.set(FlxG.mouse.x, FlxG.mouse.y);
        dragOffset.set(FlxG.mouse.x - button.x, FlxG.mouse.y - button.y);
        trace('Mouse down at (${FlxG.mouse.x}, ${FlxG.mouse.y}), offset: (${dragOffset.x}, ${dragOffset.y})');

        if (returnTween != null && returnTween.active) {
            trace('Cancelling active return tween');
            returnTween.cancel();
        }
    }

    private function handleButtonOut():Void {
        trace('Button out event, isDragging: $isDragging');
        if (isDragging) {
            button.status = FlxButton.PRESSED;
            trace('Keeping button pressed for dragging');
        }
    }

    private function handleButtonOver():Void {
        trace('Button over event, isDragging: $isDragging, isMouseDown: $isMouseDown');
        if (isDragging && isMouseDown) {
            button.status = FlxButton.PRESSED;
            trace('Restoring pressed state for dragging');
        }
    }

    private function stopDragCheck():Void {
        if (!isDraggable) return;
        
        trace('Stopping drag check');
        isMouseDown = false;
        var elapsed = (FlxG.game.ticks - startDragTime) / 1000;
        trace('Elapsed time: $elapsed seconds');
        
        if (!isDragging) {
            trace('Not dragging, handling as click');
            handleClick();
        }
        
        checkOutOfBounds();
        isDragging = false;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (isDraggable && isMouseDown) {
            var holdTime = (FlxG.game.ticks - startDragTime) / 1000;
            var distance = getDistanceFromInitialClick();
            
            if (holdTime >= DRAG_DELAY || distance > DRAG_THRESHOLD) {
                trace('Drag conditions met - holdTime: $holdTime, distance: $distance');
                updateDragPosition();
            }
        }

        if (FlxG.mouse.justReleased) {
            trace('Mouse released, isDragging: $isDragging');
            if (isDragging) {
                checkOutOfBounds();
            }
            isMouseDown = false;
            isDragging = false;
        }
    }

    private function updateDragPosition():Void {
        if (!isDraggable) return;
        
        isDragging = true;
        var newX = FlxG.mouse.x - dragOffset.x;
        var newY = FlxG.mouse.y - dragOffset.y;
        
        trace('Updating drag position to ($newX, $newY)');
        button.x = newX;
        button.y = newY;
        updateLabelPosition();

        if (isWithinBounds(newX, newY)) {
            trace('Position within bounds, updating last valid position');
            lastValidPosition.set(newX, newY);
        }
    }

    private inline function isWithinBounds(X:Float, Y:Float):Bool {
        var result = X >= bounds.x && 
               X + button.width <= bounds.x + bounds.width &&
               Y >= bounds.y && 
               Y + button.height <= bounds.y + bounds.height;
        trace('Bounds check for ($X, $Y): $result');
        return result;
    }

    private function checkOutOfBounds():Void {
        if (!isDraggable) return;
        
        var isOutOfBounds:Bool = 
            button.x < bounds.x - BOUNDS_MARGIN || 
            button.x + button.width > bounds.x + bounds.width + BOUNDS_MARGIN ||
            button.y < bounds.y - BOUNDS_MARGIN || 
            button.y + button.height > bounds.y + bounds.height + BOUNDS_MARGIN;

        trace('Out of bounds check: $isOutOfBounds');
        if (isOutOfBounds) {
            trace('Button out of bounds, returning to last valid position');
            returnToLastPosition();
        }
    }

    private function returnToLastPosition():Void {
        if (returnTween != null && returnTween.active) {
            trace('Cancelling active return tween');
            returnTween.cancel();
        }

        trace('Starting return tween to position (${lastValidPosition.x}, ${lastValidPosition.y})');
        returnTween = FlxTween.tween(button, 
            {x: lastValidPosition.x, y: lastValidPosition.y}, 
            RETURN_TWEEN_DURATION, 
            {
                ease: FlxEase.elasticOut,
                onUpdate: (_) -> updateLabelPosition()
            }
        );
    }

    private inline function updateLabelPosition():Void {
        label.x = button.x + (button.width - label.width) / 2;
        label.y = button.y + button.height + LABEL_OFFSET;
    }

    // Public API
    public function setBounds(newBounds:FlxRect):Void {
        trace('Setting new bounds: ${newBounds.toString()}');
        bounds = newBounds;
    }

    public function setText(newText:String):Void {
        trace('Setting new text: $newText');
        label.text = newText;
        updateLabelPosition();
    }

    public function setIcon(GraphicPath:String):Void {
        trace('Setting new icon: $GraphicPath');
        button.loadGraphic(Paths.image(GraphicPath));
        updateLabelPosition();
    }

    public function setTextColor(color:FlxColor):Void {
        label.color = color;
    }

    override public function destroy():Void {
        trace('Destroying ApplicationButton');
        doubleClickTimer?.destroy();
        dragOffset?.put();
        lastValidPosition?.put();
        mouseDownPos?.put();
        initialClickPos?.put();
        
        if (returnTween != null && returnTween.active) {
            trace('Cancelling active return tween during destroy');
            returnTween.cancel();
        }
            
        button.destroy();
        label.destroy();
        bounds = null;
        
        super.destroy();
    }
}