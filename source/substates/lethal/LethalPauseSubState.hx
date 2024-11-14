package substates.lethal;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import states.apps.lethalcompany.LethalTitleState;

private typedef MenuItem = {
    label:String,
    callback:() -> Void,
    text:FlxText
}

class LethalPauseSubState extends FlxSubState {
    private final font:String = Paths.font("LethalCompanyFont.ttf");

    private static inline final SELECTED_TEXT_SIZE:Int = 256;
    private static inline final DEFAULT_TEXT_SIZE:Int = 240;
    private static inline final TEXT_SCALE:Float = 0.25;
    private static inline final MENU_START_X:Float = 200;
    private static inline final MENU_START_Y:Float = 400;
    private static inline final MENU_SPACING:Float = 60;
    
    private final menuItems:Array<MenuItem>;
    private var currentIndex:Int = 0;
    
    private var bg:FlxSprite;
    private var pauseBorder:FlxSprite;
    private var selector:FlxSprite;
    
    private var isInQuitConfirm:Bool = false;
    private var quitText:FlxText;
    private var quitOptions:Array<FlxText> = [];
    private var quitSelector:FlxSprite;
    private var quitCurrentIndex:Int = 1;
    
    public function new() {
        super();

        menuItems = [
            { label: 'Resume', callback: () -> close(), text: null },
            { label: 'Restart Song', callback: () -> restartSong(), text: null },
            { label: 'Settings', callback: () -> openSettings(), text: null },
            { label: 'Quit', callback: () -> openQuitConfirm(), text: null }
        ];
    }
    
    override public function create():Void {
        super.create();

        createBackdrop();
        createPauseMenu();
        createQuitMenu();
    }
    
    private function createBackdrop():Void {
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF542413);
        bg.alpha = 0.6;
        add(bg);

        pauseBorder = new FlxSprite().loadGraphic(Paths.image('menudesktop/applications/lethal/pause'));
        pauseBorder.alpha = 0.6;
        add(pauseBorder);
    }
    
    private function createPauseMenu():Void {
        selector = new FlxSprite(195, 0).makeGraphic(400, 30, 0xFFFF7F3F);
        add(selector);
        
        for (i in 0...menuItems.length) {
            final text = new FlxText(MENU_START_X, MENU_START_Y + (i * MENU_SPACING), 0, "> " + menuItems[i].label);
            text.setFormat(font, DEFAULT_TEXT_SIZE, 0xFFFF7F3F, LEFT);
            text.antialiasing = true;
            text.scale.set(TEXT_SCALE, TEXT_SCALE);
            menuItems[i].text = text;
            add(text);
        }
    }
    
    private function createQuitMenu():Void {        
        quitText = new FlxText(150, 300, FlxG.width, "Would you like to leave the game?");
        quitText.setFormat(font, DEFAULT_TEXT_SIZE, 0xFF01F0FF, LEFT);
        quitText.antialiasing = true;
        quitText.scale.set(TEXT_SCALE, TEXT_SCALE);
        quitText.visible = false;
        add(quitText);
        
        quitSelector = new FlxSprite(195, 0).makeGraphic(400, 30, 0xFF52FF91);
        quitSelector.visible = false;
        add(quitSelector);
        
        final quitLabels = ['Confirm', 'Cancel'];
        for (i in 0...quitLabels.length) {
            final text = new FlxText(MENU_START_X, 500 + (i * MENU_SPACING), 0, "> " + quitLabels[i]);
            text.setFormat(font, DEFAULT_TEXT_SIZE, 0xFFFF7F3F, LEFT);
            text.antialiasing = true;
            text.scale.set(TEXT_SCALE, TEXT_SCALE);
            text.visible = false;
            quitOptions.push(text);
            add(text);
        }
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        isInQuitConfirm ? handleQuitInput() : handleInput();
    }
    
    private function handleInput():Void {
        if (FlxG.keys.justPressed.UP) 
            changeSelection(-1);
        else if (FlxG.keys.justPressed.DOWN) 
            changeSelection(1);
        else if (FlxG.keys.justPressed.ESCAPE) 
            close();
        else if (FlxG.keys.justPressed.ENTER)
            menuItems[currentIndex].callback();
    }
    
    private function handleQuitInput():Void {
        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN) 
            changeQuitSelection();
        else if (FlxG.keys.justPressed.ESCAPE) 
            closeQuitConfirm();
        else if (FlxG.keys.justPressed.ENTER)
            processQuitSelection();
    }
    
    private function processQuitSelection():Void {
        if (quitCurrentIndex == 0)
            FlxG.switchState(new LethalTitleState());
        else
            closeQuitConfirm();
    }
    
    private function updateMenuState(texts:Array<FlxText>, selector:FlxSprite, selectedIndex:Int, ?textColor:Int):Void {
        final selectedText = texts[selectedIndex];
        selector.y = selectedText.y + (selectedText.height / 2) - (selector.height / 2);
        
        final color = textColor != null ? textColor : 0xFFFF7F3F;
        
        for (i in 0...texts.length) {
            final isSelected = i == selectedIndex;
            texts[i].setFormat(
                font,
                isSelected ? SELECTED_TEXT_SIZE : DEFAULT_TEXT_SIZE,
                isSelected ? FlxColor.BLACK : color,
                LEFT
            );
            texts[i].antialiasing = true;
            texts[i].scale.set(TEXT_SCALE, TEXT_SCALE);
            texts[i].updateHitbox();
        }
    }
    
    private function changeSelection(change:Int = 0):Void {
        currentIndex = (currentIndex + change + menuItems.length) % menuItems.length;
        updateMenuState(menuItems.map(item -> item.text), selector, currentIndex);
    }
    
    private function changeQuitSelection():Void {
        quitCurrentIndex = quitCurrentIndex == 0 ? 1 : 0;
        updateMenuState(quitOptions, quitSelector, quitCurrentIndex);
    }
    
    private function openQuitConfirm():Void {
        isInQuitConfirm = true;
        toggleMenuVisibility(false);
        toggleQuitVisibility(true);
        updateMenuState(quitOptions, quitSelector, quitCurrentIndex);
    }
    
    private function closeQuitConfirm():Void {
        isInQuitConfirm = false;
        toggleMenuVisibility(true);
        toggleQuitVisibility(false);
        quitCurrentIndex = 1;
    }
    
    private function toggleMenuVisibility(visible:Bool):Void {
        selector.visible = visible;
        for (item in menuItems) item.text.visible = visible;
    }
    
    private function toggleQuitVisibility(visible:Bool):Void {
        quitText.visible = visible;
        quitSelector.visible = visible;
        for (option in quitOptions) option.visible = visible;
    }
    
    private function restartSong():Void { trace("Restarting song..."); }
    private function openSettings():Void { trace("Opening settings..."); }
}