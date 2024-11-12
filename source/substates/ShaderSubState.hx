package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSubState;

import backend.ShaderManager;
import backend.BiosUtil;

class ShaderSubState extends FlxSubState {

    private static inline var WINDOW_SCALE:Float = 0.6;
    private static inline var STROKE_THICKNESS:Int = 2;
    private static inline var X_PADDING:Int = 4;
    private static inline var UPPER_DIVIDER_Y:Int = 70;
    private static inline var LOWER_DIVIDER_Y:Float = UPPER_DIVIDER_Y * 4.5;
    private static inline var TEXT_PADDING:Int = 10;
    private static inline var LINE_HEIGHT:Float = 20;
    private static inline var FONT_SIZE:Int = 16;

    private var selectionIndex:Int = 0;
    private var shaderTexts:Array<FlxText> = [];

    public function new() {
        super();
    }

    override public function create():Void {
        super.create();
        var shaders = ShaderManager.getInstance().settings;

        var window = BiosUtil.drawWindow(WINDOW_SCALE, WINDOW_SCALE);
        var windowStroke = BiosUtil.drawBorder(window, STROKE_THICKNESS);
        var upperDivider = BiosUtil.drawDivider(window, X_PADDING, UPPER_DIVIDER_Y, STROKE_THICKNESS);
        var lowerDivider = BiosUtil.drawDivider(window, X_PADDING, LOWER_DIVIDER_Y, STROKE_THICKNESS);
        var titleText = BiosUtil.drawTitle(window, "Shader Configuration");


        add(windowStroke);
        add(window);
        add(upperDivider);
        add(lowerDivider);
        add(titleText);

        createShaderNames(shaders, window);
        updateShaderText();
    }

    private function createShaderNames(shaders, window:FlxSprite):Void {
        for (i in 0...shaders.length) {
            var shaderName:FlxText = new FlxText(
                0,
                0,
                window.width - (2 * TEXT_PADDING),
                '${shaders[i].name}. . . . . [ ${shaders[i].enabled ? '*' : ' '} ]'
            );
            shaderName.setFormat(null, FONT_SIZE, FlxColor.WHITE, "LEFT");
            shaderName.x = window.x + TEXT_PADDING;
            shaderName.y = window.y + UPPER_DIVIDER_Y + TEXT_PADDING + (LINE_HEIGHT * i);

            add(shaderName);
            shaderTexts.push(shaderName);
        }
    }

    private function updateShaderText():Void {
        var shaders = ShaderManager.getInstance().settings;
        for (i in 0...shaders.length) {
            shaderTexts[i].text = '${shaders[i].name}. . . . . [ ${shaders[i].enabled ? '*' : ' '} ]';
            shaderTexts[i].color = (i == selectionIndex) ? FlxColor.YELLOW : FlxColor.WHITE;
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP && selectionIndex > 0) {
            selectionIndex--;
            updateShaderText();
        }
        if (FlxG.keys.justPressed.DOWN && selectionIndex < shaderTexts.length - 1) {
            selectionIndex++;
            updateShaderText();
        }

        if (FlxG.keys.justPressed.ENTER) {
            var shader = ShaderManager.getInstance().settings[selectionIndex];
            ShaderManager.getInstance().toggleShader(shader.name, !shader.enabled);
            updateShaderText();
        }

        if (FlxG.keys.justPressed.ESCAPE) {
            close();
        }
    }
}
