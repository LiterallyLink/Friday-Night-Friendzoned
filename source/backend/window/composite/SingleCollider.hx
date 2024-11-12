package backend.window.composite;

import flixel.FlxObject;

class SingleCollider extends FlxObject
{
	var _object:CompositeSprite;
	
	public function new(object:CompositeSprite, x:Float = 0.0, y:Float = 0.0, width:Float = 0.0, height:Float = 0.0)
	{
		super(x, y, width, height);
		_object = object;
	}
}