package backend;

import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxSubState;

class ApplicationButton extends FlxSpriteGroup
{
    private var _button:FlxButton;
    private var _label:FlxText;
    private var _bounds:FlxRect;
    private var _substateCallback:Class<FlxSubState>;
    private var _currentSubState:FlxSubState;

    private var _isDragging:Bool = false;
    private var _dragOffset:FlxPoint;
    private var _startPosition:FlxPoint;
    private var _wasDragged:Bool = false;

    private var boundsTween:FlxTween;
    private var scaleTween:FlxTween;

    public static inline var DEFAULT_FONT_SIZE:Int = 10;
    public static inline var DEFAULT_LABEL_PADDING:Int = 0;
    public static inline var BOUNDS_SNAP_DURATION:Float = 0.3;
    public static inline var SCALE_TWEEN_DURATION:Float = 0.2;

    public function new(X:Float = 0, Y:Float = 0, ?ImagePath:String, ?LabelText:String, ?Bounds:FlxRect, ?SubstateClass:Class<FlxSubState>)
    {
        super(X, Y);

        _dragOffset = new FlxPoint();
        _startPosition = new FlxPoint(X, Y);
        _bounds = Bounds;
        _substateCallback = SubstateClass;
        _currentSubState = null;

        initializeButton(ImagePath);
        if (LabelText != null)
            initializeLabel(LabelText);
        setupMouseEvents();
    }

    private function setupMouseEvents():Void
    {
        FlxMouseEvent.add(_button, onMouseDown, null, onMouseOver, onMouseOut);
        FlxMouseEvent.setMouseDoubleClickCallback(_button, onDoubleClick);
    }

    private function startDragging():Void
    {
        FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_MOVE, onMouseMove);
        FlxG.stage.addEventListener(openfl.events.MouseEvent.MOUSE_UP, onGlobalMouseUp);
    }

    private function stopDragging():Void
    {
        FlxG.stage.removeEventListener(openfl.events.MouseEvent.MOUSE_MOVE, onMouseMove);
        FlxG.stage.removeEventListener(openfl.events.MouseEvent.MOUSE_UP, onGlobalMouseUp);
        tweenScale(1.0);
    }

    private function onMouseDown(sprite:FlxSprite):Void
    {
        _isDragging = true;
        _wasDragged = false;
        _startPosition.set(x, y);
        _dragOffset.set(FlxG.mouse.x - x, FlxG.mouse.y - y);
        startDragging();
    }
    
    private function onGlobalMouseUp(event:openfl.events.MouseEvent):Void
    {
        if (_isDragging)
        {
            _isDragging = false;
            stopDragging();

            if (_wasDragged && _bounds != null && !isWithinBounds())
            {
                tweenToPosition(_startPosition.x, _startPosition.y);
            }
        }
    }

    private function tweenScale(targetScale:Float):Void
        {
            if (scaleTween != null && scaleTween.active)
            {
                scaleTween.cancel();
            }
    
            scaleTween = FlxTween.tween(_button.scale, 
                { x: targetScale, y: targetScale }, 
                SCALE_TWEEN_DURATION,
                {
                    ease: FlxEase.quartOut,
                    onUpdate: function(tween:FlxTween) {
                        _button.updateHitbox();
                        updateLabelPosition();
                    }
                }
            );
        }

    private function tweenToPosition(targetX:Float, targetY:Float):Void
    {
        if (boundsTween != null && boundsTween.active)
        {
            boundsTween.cancel();
        }

        boundsTween = FlxTween.tween(this, 
            { x: targetX, y: targetY }, 
            BOUNDS_SNAP_DURATION, 
            {
                ease: FlxEase.elasticOut,
                onUpdate: function(tween:FlxTween) {
                    updateLabelPosition();
                }
            }
        );
    }

    private function onMouseMove(event:openfl.events.MouseEvent):Void
    {
        tweenScale(0.8);

        if (FlxG.mouse.x < 0 || FlxG.mouse.x > FlxG.width ||
            FlxG.mouse.y < 0 || FlxG.mouse.y > FlxG.height)
        {
            _isDragging = false;
            stopDragging();
            tweenToPosition(_startPosition.x, _startPosition.y);
            return;
        }

        var newX = FlxG.mouse.x - _dragOffset.x;
        var newY = FlxG.mouse.y - _dragOffset.y;

        if (newX != x || newY != y)
        {
            _wasDragged = true;
            x = newX;
            y = newY;
            updateLabelPosition();
        }
    }

    private function onMouseOver(sprite:FlxSprite):Void
    {
        // Add hover effects
    }

    private function onMouseOut(sprite:FlxSprite):Void
    {
        // Remove hover effects
    }

    private function onDoubleClick(sprite:FlxSprite):Void
    {
        if (!_wasDragged && _substateCallback != null && _currentSubState == null)
        {
            var currentState = FlxG.state;
            if (currentState != null)
            {
                _currentSubState = Type.createInstance(_substateCallback, []);
                _currentSubState.closeCallback = () -> {
                    _currentSubState = null;
                };
                currentState.openSubState(_currentSubState);
            }
        }
    }

    private function isWithinBounds():Bool
    {
        if (_bounds == null) 
            return true;
            
        return (x >= _bounds.x && 
                y >= _bounds.y && 
                x + width <= _bounds.right && 
                y + height <= _bounds.bottom);
    }

    private function initializeButton(?ImagePath:String):Void
    {
        _button = new FlxButton(0, 0);
        if (ImagePath != null)
            _button.loadGraphic(Paths.image(ImagePath));
        add(_button);
    }

    public function setScale(Scale:Float):Void
    {
        _button.scale.set(Scale, Scale);
        _button.updateHitbox();
        updateLabelPosition();
    }

    private function initializeLabel(LabelText:String):Void
    {
        _label = new FlxText(0, 0, 0, LabelText, DEFAULT_FONT_SIZE);
        _label.setFormat(null, DEFAULT_FONT_SIZE, FlxColor.WHITE, "center");
        add(_label);
        updateLabelPosition();
    }

    private function updateLabelPosition():Void
    {
        if (_label != null)
        {
            _label.x = _button.x + (_button.width - _label.width) / 2;
            _label.y = _button.y + _button.height + DEFAULT_LABEL_PADDING;
        }
    }

    override public function destroy():Void
    {
        if (boundsTween != null && boundsTween.active)
        {
            boundsTween.cancel();
            boundsTween = null;
        }

        FlxMouseEvent.remove(_button);
        stopDragging(); // Ensure we clean up any active listeners
        
        _dragOffset = FlxDestroyUtil.put(_dragOffset);
        _startPosition = FlxDestroyUtil.put(_startPosition);
        _button = FlxDestroyUtil.destroy(_button);
        _label = FlxDestroyUtil.destroy(_label);
        _currentSubState = null;
        
        super.destroy();
    }
}