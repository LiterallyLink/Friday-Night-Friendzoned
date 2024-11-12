package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;

class BiosUtil
{
    private static inline var DEFAULT_FONT_SIZE:Int = 20;

    public static function drawWindow(windowWidthRatio:Float, windowHeightRatio:Float):FlxSprite {
        var screenWidth:Float = FlxG.width;
        var screenHeight:Float = FlxG.height;

        var boxWidth:Float = screenWidth * windowWidthRatio;
        var boxHeight:Float = screenHeight * windowHeightRatio;
        var boxX:Float = (screenWidth - boxWidth) / 2;
        var boxY:Float = (screenHeight - boxHeight) / 2;

        var box:FlxSprite = new FlxSprite(boxX, boxY);
        box.makeGraphic(
            Std.int(boxWidth),
            Std.int(boxHeight),
            0xFF1927F1
        );

        return box;
    }

    public static function drawBorder(box:FlxSprite, strokeThickness:Int):FlxSprite {
        var borderX:Float = box.x - strokeThickness;
        var borderY:Float = box.y - strokeThickness;
        var borderWidth:Float = box.width + (strokeThickness * 2);
        var borderHeight:Float = box.height + (strokeThickness * 2);

        var border:FlxSprite = new FlxSprite(borderX, borderY);
        border.makeGraphic(
            Std.int(borderWidth),
            Std.int(borderHeight),
            FlxColor.WHITE
        );

        return border;
    }

    public static function drawDivider(box:FlxSprite, xPadding:Float, yPadding:Float, ?dividerThickness:Int = 2):FlxSprite {
        var divider:FlxSprite = new FlxSprite(box.x, box.y);
        divider.makeGraphic(
            Std.int(box.width),
            Std.int(box.height),
            FlxColor.TRANSPARENT
        );

        var startX:Float = xPadding;
        var endX:Float = box.width - xPadding;
        var yPosition:Float = yPadding;

        FlxSpriteUtil.drawLine(
            divider,
            startX,
            yPosition,
            endX,
            yPosition,
            { color: FlxColor.WHITE, thickness: dividerThickness }
        );

        return divider;
    }

    public static function drawTitle(box:FlxSprite, title:String):FlxText {
        var titleText:FlxText = new FlxText(0, 0, box.width, title);
        titleText.setFormat(null, DEFAULT_FONT_SIZE, FlxColor.WHITE, "LEFT");
        titleText.x = box.x + (titleText.height / 2);
        titleText.y = box.y + (titleText.height / 1.5);

        return titleText;
    }
}
