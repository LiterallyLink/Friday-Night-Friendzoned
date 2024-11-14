package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import backend.ApplicationButton;

class DragManager
{
	private static inline var DRAG_SCALE:Float = 0.8;
	private static inline var NORMAL_SCALE:Float = 1.0;
	private static inline var SCALE_DURATION:Float = 0.2;

	private static var instance:DragManager;

	public static function i():DragManager
	{
		if (instance == null)
			instance = new DragManager();
		return instance;
	}

	private function new()
	{
	}

	private var isDragEnabled:Bool = true;

	private var applicationButtons:Array<ApplicationButton>;
	private var currentDragButton:ApplicationButton = null;
	private var isDragging:Bool = false;
	private var dragOffset:FlxPoint = new FlxPoint();
	private var wasDragged:Bool = false;

	public function allowDragging():Void
	{
		isDragEnabled = true;
	}

	public function disableDragging():Void
	{
		isDragEnabled = false;
		stopDragging();
	}

	public function update():Void
	{
		if (!isDragEnabled) {
			return;
		}

		if (FlxG.mouse.justReleased)
		{
			stopDragging();
			return;
		}

		if (isDragging && currentDragButton != null)
		{
			updateApplicationButtonDrag();
			return;
		}

		if (FlxG.mouse.justPressed)
		{
			startDragging();
		}
	}

	public function addApplicationButton(button:ApplicationButton):Void
	{
		if (applicationButtons == null)
			applicationButtons = new Array();
		applicationButtons.push(button);
	}

	public function isButtonBeingDragged(button:ApplicationButton):Bool
	{
		return wasDragged && currentDragButton == button;
	}

	private function startDragging():Void
	{
		if (!isDragEnabled)
		{
			return;
		}

		wasDragged = false;
		currentDragButton = getTopMostButtonAtMousePosition();

		if (currentDragButton != null)
		{
			isDragging = true;
			dragOffset.set(FlxG.mouse.x - currentDragButton.x, FlxG.mouse.y - currentDragButton.y);

			FlxTween.tween(currentDragButton.scale, {x: DRAG_SCALE, y: DRAG_SCALE}, SCALE_DURATION, {ease: FlxEase.quadOut});
		}
	}

	private function stopDragging():Void
	{
		if (currentDragButton != null)
		{
			FlxTween.tween(currentDragButton.scale, {x: NORMAL_SCALE, y: NORMAL_SCALE}, SCALE_DURATION, {ease: FlxEase.quadOut});
		}

		isDragging = false;
		currentDragButton = null;
	}

	private function updateApplicationButtonDrag():Void
	{
		var newX = FlxG.mouse.x - dragOffset.x;
		var newY = FlxG.mouse.y - dragOffset.y;

		if (newX != currentDragButton.x || newY != currentDragButton.y)
		{
			wasDragged = true;
			currentDragButton.updatePosition(newX, newY);
		}
	}

	private function getTopMostButtonAtMousePosition():ApplicationButton
	{
		if (applicationButtons == null || applicationButtons.length == 0)
			return null;

		for (i in 0...applicationButtons.length)
		{
			var button = applicationButtons[i];
			if (button.overlapsPoint(FlxG.mouse.getPosition()))
			{
				return button;
			}
		}

		return null;
	}
}
