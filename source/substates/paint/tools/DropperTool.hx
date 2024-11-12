package substates.paint.tools;

import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.FlxG;

import substates.paint.PaintSubState;

class DropperTool extends BaseTool {    
    public function new(canvas:BitmapData) {
        super(canvas);
    }

    override public function onMouseDown(x:Float, y:Float, color:Int):Void {
        var newColor:Int;     
        newColor = getColorAt(x, y);
        PaintSubState.selectedColor = newColor;

        SoundManager.playSound('paint/Dropper');
    }

    override public function onMouseMove(x:Float, y:Float, color:Int):Void {}

    private function getColorAt(x:Float, y:Float):Int {
        return canvas.getPixel32(Math.floor(x), Math.floor(y));
    }
}