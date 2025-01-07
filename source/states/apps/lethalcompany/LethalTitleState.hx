package states.apps.lethalcompany;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.ui.FlxButton;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import states.DesktopState;
import substates.lethal.LethalSettingsSubState;

private typedef MenuItem = {
    label:String,
    callback:() -> Void,
    button:FlxButton,
    text:FlxText
}
 
class LethalTitleState extends MusicBeatState {
    private static inline final SELECTED_TEXT_SIZE:Int = 55;
    private static inline final DEFAULT_TEXT_SIZE:Int = 50;
    private static inline final TEXT_SCALE:Float = 0.5;
    private static inline final MENU_START_X:Float = 100;
    private static inline final MENU_START_Y:Float = 400;
    private static inline final MENU_SPACING:Float = 60;
    
    private final font:String = Paths.font("LethalCompanyFont.ttf");

    public static var SPLASH_TEXTS:Array<String> = [
        "OSHA violations? That's the least of our concerns",
        "Out of office reply: Currently being chased.",
        "We're understaffed... and there's a reason for that.",
        "401(k)illed in action.",
        "Sick days require proof of dismemberment.",
        "Lost and Found: Several limbs, a stop sign, and Dave's lunch box.",
        "We value our employees... at exactly 11 credits each.",
        "Spread the word",
        "Barber took a little too much off the top... of my body.",
        "Now on Only Company:\nIndustrial-chic meets eldritch horror.",
        "Sorry to hear about your coworker... but hey!\nWe have some extra hours for you now!",
        "Masked and afraid",
        "The facilities return policy is in a body bag",
        "Company Motto: What doesn't kill you... probably will next time.",
        "Our insurance doesn't cover that... or that... or anything really.",
        "Coilhead doesn't know what the definition of 'personal space' is",
        "Mind the mines, friend of mine!",
        "No overtime until you find us more clocks!",
        "Our 8 figured boss has ate figures, but at least he makes 8 figures!",
        "We love the Company! The Company!",
        "I heard the developer is a FURRY cool person!",
        "This would be a lot easier if we got paid by the hour...",
        "The Biggy busy 'Itsy Bitsy' bit me!",
        "Waste funds for guns. Waste scrap on crap!",
        "Pop! Goes the Lethal!",
        "Buttin' butts with Butlers",
        "Spoiler Alert! The Coil-Head hurts!",
        "Why do I hear a baby crying...?",
        "What's wrong? It's just your lesser Jester with a headful gesture",
        "We're not responsible if you run out of ship fuel",
        "Wattup dawg! gets absolutely mauled",
        "Batteries not included!",
        "You're in deep.",
        "Lost your badge? Don't worry, you'll be unrecognizable anyway.",
        "Thumper?\nI hardly know er!",
        "Every shift is a graveyard shift.",
        "The company handbook forgot to mention the monsters.",
        "Clock in, freak out, clock out, repeat.",
        "Remember, the break room isn't safe either.",
        "Employee of the month? Not likely.",
        "Employee benefits include adrenaline and regret.",
        "Your PTO request has been denied— again.",
        "The only promotion here is to the afterlife.",
        "First rule: don't look back\nSecond rule: too late.",
        "HR can't help you outrun that.",
        "Congratulations, you're expendable!",
        "Thumper never skips leg day.",
        "Nutcracker is more into cracking spines than nuts.",
        "The Eyeless Dog sees everything you don't.",
        "A Rubber Ducky?\nSqueak your way to safety.",
        "Found a Stop Sign?\nToo bad monsters can't read.",
        "Magic 7 Ball says: 'Signs point to danger.'",
        "Buying a Walkie Talkie?\nShare your last words in real-time!",
        "Our gratitude is as empty as your wallet!",
        "Home is where the haul is!",
        "My overtime does overtime!",
        "Don't miss the quota!",
        "Tips will not be given!",
        "Have you had an accident at work that wasn't your fault? No you haven't! It absolutely was your fault!",
        "Ghost Girl? Hear me out."
    ];

    private final titleItems:Array<MenuItem>;
    private var currentIndex:Int = 0;
    private var isShowingPopup:Bool = false;
    private var isLoading:Bool = false;

    private var bg:FlxSprite;
    private var logo:FlxSprite;
    private var border:FlxSprite;    
    private var selector:FlxSprite;
    private var popupBox:FlxSprite;

    private var version:FlxText;
    private var loadingText:FlxText;
    private var splashText:FlxText;
    private var popupText:FlxText;

    private var continueButton:FlxButton;
    private var continueBg:FlxSprite;

    public function new() {
        super();

        titleItems = [
            { label: 'Host', callback: hostGame, button: null, text: null },
            { label: 'Join a crew', callback: joinGame, button: null, text: null },
            { label: 'Settings', callback: () -> openSubState(new LethalSettingsSubState()), button: null, text: null },
            { label: 'Quit', callback: () -> FlxG.switchState(new DesktopState()), button: null, text: null }
        ];
    }
    
    override public function create():Void {
        super.create();
        createBackground();
        createSelector();
        createTitleMenu();
        createLoadingText();
        createHostGamePopup();
        togglePopup();
        updateSelection();
        playlethalSong();
    }
    
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (!isLoading) {
            handleInput();
        }
    }
    
    private function createBackground():Void {
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        add(bg);

        border = new FlxSprite();
        border.loadGraphic(Paths.image('menudesktop/applications/lethalcompany/lethal_title_border'));
        border.screenCenter(XY);
        border.alpha = 0.5;
        add(border);

        logo = new FlxSprite(0, 20);
        var logoDestination = FlxG.random.float() < 0.7 ? 'lethal_cumpanties_logo' : 'lethal_company_logo';
        logo.loadGraphic(Paths.image('menudesktop/applications/lethalcompany/${logoDestination}'));
        logo.screenCenter(X);
        add(logo);

        version = new FlxText(0, FlxG.height - 50, 'v68');
        version.setFormat(font, 65, 0xFFFD9C45, LEFT);
        version.scale.set(TEXT_SCALE, TEXT_SCALE);
        version.antialiasing = true;
        add(version);
        
        splashText = new FlxText(0, 0, 500, SPLASH_TEXTS[Std.random(SPLASH_TEXTS.length)]);
        splashText.setFormat(font, 35, 0xFFFD9C45, CENTER);
        splashText.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF000000, 2);
        splashText.antialiasing = true;
        
        splashText.angle = -15;
        splashText.x = logo.x + logo.width - (splashText.width / 2);
        splashText.y = logo.y + logo.height - splashText.height;
        
        FlxTween.tween(splashText.scale, { x: 1.1, y: 1.1 }, 0.3, {
            ease: FlxEase.sineInOut,
            type: PINGPONG,
        });
        
        add(splashText);
    }
    
    private function createSelector():Void {
        selector = new FlxSprite(95, 0);
        selector.makeGraphic(400, 30, 0xFFFD9C45);
        add(selector);
    }
    
    private function createTitleMenu():Void {
        for (i in 0...titleItems.length) {
            final text = new FlxText(
                MENU_START_X, 
                MENU_START_Y + (i * MENU_SPACING),
                790,
                '> ${titleItems[i].label}'
            );
            text.setFormat(font, DEFAULT_TEXT_SIZE, 0xFFFD9C45, LEFT);
            text.antialiasing = true;
            text.scale.set(TEXT_SCALE, TEXT_SCALE);
            
            final button = new FlxButton(
                MENU_START_X,
                MENU_START_Y + (i * MENU_SPACING),
                "",
                () -> {
                    if (!isShowingPopup && !isLoading) {
                        currentIndex = i;
                        updateSelection();
                        FlxG.sound.play(Paths.sound('lethal_confirm'));
                        titleItems[i].callback();
                    }
                }
            );
            
            final index = i;
            button.onOver.callback = () -> {
                if (!isShowingPopup && !isLoading) {
                    currentIndex = index;
                    updateSelection();
                }
            };
            
            button.makeGraphic(400, 30, 0x00000000);
            
            titleItems[i].text = text;
            titleItems[i].button = button;
            
            add(text);
            add(button);
        }
    }
    
    private function createLoadingText():Void {
        loadingText = new FlxText(0, 0, "Loading...");
        loadingText.setFormat(font, 60, 0xFFFD9C45, CENTER);
        loadingText.scale.set(TEXT_SCALE, TEXT_SCALE);
        loadingText.screenCenter(XY);
        loadingText.y += 100;
        loadingText.visible = false;
        add(loadingText);
    }
    
    private function createHostGamePopup():Void {
        popupBox = new FlxSprite();
        popupBox.makeGraphic(400, 250, 0xFF7B1A1B);
        popupBox.screenCenter(XY);
        popupBox.alpha = 0.8;
        add(popupBox);
    
        drawPopupBorders(popupBox);
    
        popupText = new FlxText(0, 0, "Could not connect to Steam\nservers! (If you just want to\nplay on your local network,\nchoose LAN on launch.)");
        popupText.setFormat(font, 100, 0xFFFD9C45, "center");
        popupText.scale.set(0.25, 0.25);
        popupText.screenCenter(XY);
        popupText.y -= 30;
        add(popupText);
    
        continueBg = new FlxSprite();
        continueBg.makeGraphic(250, 30, 0xFFFD9C45);
        continueBg.screenCenter(XY);
        continueBg.y += 70;
        add(continueBg);
    
        continueButton = new FlxButton(continueBg.x, continueBg.y, "", () -> {
            if (isShowingPopup) {
                FlxG.sound.play(Paths.sound('lethal_cancel'));
                togglePopup();
                toggleMenu();
                isShowingPopup = false;
            }
        });
        continueButton.loadGraphic(continueBg.graphic);
        add(continueButton);
    
        final continueText = new FlxText(0, 0, "Continue");
        continueText.setFormat(font, 100, 0xFF000000, "center");
        continueText.scale.set(0.25, 0.25);
        continueText.screenCenter(XY);
        continueText.y += 70;
        add(continueText);
    }
    
    private function handleInput():Void {
        if (!isShowingPopup) {
            if (FlxG.keys.justPressed.UP) {
                changeSelection(-1);
            } else if (FlxG.keys.justPressed.DOWN) {
                changeSelection(1);
            } else if (FlxG.keys.justPressed.ENTER) {
                FlxG.sound.play(Paths.sound('lethal_confirm'));
                titleItems[currentIndex].callback();
            }
        } else if (FlxG.keys.justPressed.ENTER) {
            FlxG.sound.play(Paths.sound('lethal_cancel'));
            togglePopup();
            toggleMenu();
            isShowingPopup = false;
        }
    }
    
    private function changeSelection(change:Int = 0):Void {
        currentIndex = (currentIndex + change + titleItems.length) % titleItems.length;
        updateSelection();
    }
    
    private function updateSelection():Void {
        for (i in 0...titleItems.length) {
            final isSelected = i == currentIndex;
            final text = titleItems[i].text;
            
            text.setFormat(
                font, 
                isSelected ? SELECTED_TEXT_SIZE : DEFAULT_TEXT_SIZE,
                isSelected ? FlxColor.BLACK : 0xFFFD9C45,
                LEFT
            );
            
            text.antialiasing = true;
            text.scale.set(TEXT_SCALE, TEXT_SCALE);
            text.updateHitbox();
        }
        
        updateSelectorPosition();
    }
    
    private function updateSelectorPosition():Void {
        final selectedText = titleItems[currentIndex].text;
        selector.y = selectedText.y + (selectedText.height / 2) - (selector.height / 2);
    }
    
    private function toggleMenu():Void {
        for (item in titleItems) {
            item.text.visible = !item.text.visible;
            item.text.active = !item.text.active;
            item.button.visible = !item.button.visible;
            item.button.active = !item.button.active;
        }

        selector.visible = !selector.visible;
        selector.active = !selector.active;
    }
    
    private function togglePopup():Void {
        popupBox.visible = !popupBox.visible;
        popupText.visible = !popupText.visible;
        continueButton.visible = !continueButton.visible;
        continueButton.active = !continueButton.active;
        continueBg.visible = !continueBg.visible;
    }
    
    private function drawPopupBorders(box:FlxSprite):Void {
        FlxSpriteUtil.drawLine(box, 0, 0, box.width, 0, { color: 0xFFE21C31, thickness: 2 });
        FlxSpriteUtil.drawLine(box, 0, 0, 0, box.height, { color: 0xFFE21C31, thickness: 2 });
        FlxSpriteUtil.drawLine(box, box.width, 0, box.width, box.height, { color: 0xFFE21C31, thickness: 2 });
        FlxSpriteUtil.drawLine(box, 0, box.height, box.width, box.height, { color: 0xFFE21C31, thickness: 2 });
        FlxSpriteUtil.drawLine(box, 8, 8, box.width - 8, 8, { color: 0xFFE21C31, thickness: 2 });
        FlxSpriteUtil.drawLine(box, 8, 8, 8, box.height - 8, { color: 0xFFE21C31, thickness: 2 });
        FlxSpriteUtil.drawLine(box, box.width - 8, 8, box.width - 8, box.height - 8, { color: 0xFFE21C31, thickness: 2 });
        FlxSpriteUtil.drawLine(box, 8, box.height - 8, box.width - 8, box.height - 8, { color: 0xFFE21C31, thickness: 2 });
    }
    
    private function playlethalSong():Void {
        FlxG.sound.playMusic(Paths.music('lethal_company_main_menu'), true);
    }
    
    private function hostGame():Void {
        isLoading = true;
        toggleMenu();
        loadingText.visible = true;
        
        new FlxTimer().start(10.0, function(_) {
            FlxG.sound.play(Paths.sound('lethal_error'));

            loadingText.visible = false;
            isLoading = false;
            isShowingPopup = true;
            togglePopup();
        });
    }
    
    private function joinGame():Void { 
        trace("Opening join game menu..."); 
    }
}