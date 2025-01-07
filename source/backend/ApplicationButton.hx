package backend;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

import flixel.input.mouse.FlxMouseEvent;
import backend.drag.AppManager;

class ApplicationButton extends FlxSpriteGroup
{
    public static inline var DEFAULT_FONT_SIZE:Int = 10;
    public static inline var DEFAULT_LABEL_PADDING:Int = 0;

    private var _button:FlxButton;
    private var _label:FlxText;
    public var _bounds:FlxRect;
    
    public var _onSingleClick:Void->Void;
    public var _onDoubleClick:Void->Void;
    public var _onRightClick:Void->Void;

    private var _startPosition:FlxPoint;
    private var _lastValidPosition:FlxPoint;

    var scaleTween:FlxTween;
    var boundsTween:FlxTween;
    
    final _scaleTweenDuration:Float = 0.2;
    final _boundsSnapDuration:Float = 0.3;

    public function new(X:Float = 0, Y:Float = 0,  ?Bounds:FlxRect, ?ImagePath:String, ?LabelText:String, ?OnSingleClick:Void->Void, ?OnDoubleClick:Void->Void, ?OnRightClick:Void->Void)
    {
        super(X, Y);

        _startPosition = new FlxPoint(X, Y);
        _lastValidPosition = new FlxPoint(X, Y);
        
        _bounds = Bounds;
        _onSingleClick = OnSingleClick;
        _onDoubleClick = OnDoubleClick;
        _onRightClick = OnRightClick;

        addButton(ImagePath);

        if (LabelText != null)
            addLabel(LabelText);

        AppManager.i().registerButton(this);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
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

    private function updateLabelPosition():Void
    {
        if (_label != null)
        {
            _label.x = _button.x + (_button.width - _label.width) / 2;
            _label.y = _button.y + _button.height + DEFAULT_LABEL_PADDING;
        }
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

    /*
    ================
     EVENT HANDLERS
    ================
    */

    public function setOnSingleClick(callback:Void->Void):Void {
        _onSingleClick = callback;
    }

    public function setOnRightClick(callback:Void->Void):Void {
        _onRightClick = callback;
    }

    public function setOnDoubleClick(callback:Void->Void):Void {
        _onDoubleClick = callback;
    }
}