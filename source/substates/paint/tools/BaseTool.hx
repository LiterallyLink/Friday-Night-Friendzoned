package substates.paint.tools;

import openfl.display.BitmapData;

class BaseTool {
    private var canvas:BitmapData;
    
    public function new(canvas:BitmapData) {
        this.canvas = canvas;
    }
    
    public function onMouseDown(x:Float, y:Float, color:Int):Void {}
    public function onMouseMove(x:Float, y:Float, color:Int):Void {}
    public function onMouseUp(x:Float, y:Float, color:Int):Void {}
    public function cleanup():Void {}

    private function hasMouseMoved(oldX:Float, oldY:Float, newX:Float, newY:Float):Bool {
        return Math.floor(oldX) != Math.floor(newX) || Math.floor(oldY) != Math.floor(newY);
    }
}
