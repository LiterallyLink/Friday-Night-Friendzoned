package backend;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

class ApplicationButton extends FlxSpriteGroup
{
    public static inline var DEFAULT_FONT_SIZE:Int = 10;
    public static inline var DEFAULT_LABEL_PADDING:Int = 0;

    private var _button:FlxButton;
    private var _label:FlxText;
    private var _bounds:FlxRect;
    
    public var _onSingleClick:Void->Void;
    public var _onDoubleClick:Void->Void;

    private var _startPosition:FlxPoint;
    private var _lastValidPosition:FlxPoint;

    var scaleTween:FlxTween;
    var boundsTween:FlxTween;
    
    final _scaleTweenDuration:Float = 0.2;
    final _boundsSnapDuration:Float = 0.3;

    public function new(X:Float = 0, Y:Float = 0, ?ImagePath:String, ?LabelText:String, ?Bounds:FlxRect, ?OnSingleClick:Void->Void, ?OnDoubleClick:Void->Void)
    {
        super(X, Y);

        _startPosition = new FlxPoint(X, Y);
        _lastValidPosition = new FlxPoint(X, Y);
        
        _bounds = Bounds;
        _onSingleClick = OnSingleClick;
        _onDoubleClick = OnDoubleClick;

        addButton(ImagePath);

        if (LabelText != null)
            addLabel(LabelText);

        DragManager.i().setButton(this);
    }

    private function addButton(?ImagePath:String):Void
    {
        _button = new FlxButton();

        if (ImagePath != null)
            _button.loadGraphic(Paths.image(ImagePath));
        add(_button);
    }

    private function addLabel(LabelText:String):Void
    {
        _label = new FlxText(0, 0, 0, LabelText, DEFAULT_FONT_SIZE);
        _label.setFormat(null, DEFAULT_FONT_SIZE, FlxColor.WHITE, "center", FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        _label.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 2, 2);

        add(_label);
        updateLabelPosition();
    }

    /*
    ================
       POSITIONING
    ================
    */

    public function setScale(Scale:Float):Void
    {
        _button.scale.set(Scale, Scale);
        _button.updateHitbox();
        updateLabelPosition();
    }

    public function updatePosition(newX:Float, newY:Float):Void
    {
        if (isWithinBounds())
        {
            _lastValidPosition.set(x, y);
        }

        x = newX;
        y = newY;

        if (!isWithinBounds())
        {
            resetPosition();
        }
    }

    public function resetPosition():Void
    {
        tweenToPosition(_lastValidPosition.x, _lastValidPosition.y);
    }

    private function updateLabelPosition():Void
    {
        if (_label != null)
        {
            _label.x = _button.x + (_button.width - _label.width) / 2;
            _label.y = _button.y + _button.height + DEFAULT_LABEL_PADDING;
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
    
    /*
    ================
       ANIMATIONS
    ================
    */

    public function tweenScale(targetScale:Float):Void
    {
        if (scaleTween != null && scaleTween.active)
        {
            scaleTween.cancel();
        }

        scaleTween = FlxTween.tween(_button.scale, 
            { x: targetScale, y: targetScale }, 
            _scaleTweenDuration,
            {
                ease: FlxEase.quartOut,
                onUpdate: (tween:FlxTween) -> {
                    _button.updateHitbox();
                    updateLabelPosition();
                }
            }
        );
    }

    public function tweenToPosition(targetX:Float, targetY:Float):Void
    {
        if (boundsTween != null && boundsTween.active)
        {
            boundsTween.cancel();
        }

        boundsTween = FlxTween.tween(this, 
            { x: targetX, y: targetY }, 
            _boundsSnapDuration, 
            {
                ease: FlxEase.elasticOut,
                onUpdate: (tween:FlxTween) -> {
                    updateLabelPosition();
                }
            }
        );
    }

    /*
    ================
     EVENT HANDLERS
    ================
    */

    public function setOnSingleClick(callback:Void->Void):Void {
        _onSingleClick = callback;
    }

    public function setOnDoubleClick(callback:Void->Void):Void {
        _onDoubleClick = callback;
    }
}