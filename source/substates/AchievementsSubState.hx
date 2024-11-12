package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;

import backend.Achievements;
import backend.BiosUtil;

class AchievementsSubState extends FlxSubState {
    private static inline var UPPER_DIVIDER_Y:Int = 70;
    private static inline var LOWER_DIVIDER_Y:Float = UPPER_DIVIDER_Y * 4.5;
    private static inline var TEXT_PADDING:Int = 10;
    private static inline var STROKE_THICKNESS:Int = 2;
    private static inline var ACHIEVEMENT_HEIGHT:Float = 40;

    private var achievementGroup:FlxSpriteGroup;
    private var achievements:Array<{data: FlxText, name: String}>;

    private var window:FlxSprite;
    private var windowStroke:FlxSprite;
    private var titleText:FlxText;
    private var titleDivider:FlxSprite;
    private var instructionsDivider:FlxSprite;

    private var visibleItems:Int = Math.floor((LOWER_DIVIDER_Y - UPPER_DIVIDER_Y) / ACHIEVEMENT_HEIGHT);
    private var selectedIndex:Int = 0;
    private var scrollOffset:Int = 0;
    private var clipRect:FlxRect;

    public function new() {
        super();
        achievementGroup = new FlxSpriteGroup();
        achievements = [];
        clipRect = new FlxRect(0, UPPER_DIVIDER_Y, 0, LOWER_DIVIDER_Y - UPPER_DIVIDER_Y);
    }

    override public function create():Void {
        super.create();

        window = BiosUtil.drawWindow(0.6, 0.6);
        windowStroke = BiosUtil.drawBorder(window, STROKE_THICKNESS);
        titleDivider = BiosUtil.drawDivider(window, 4, UPPER_DIVIDER_Y, STROKE_THICKNESS);
        instructionsDivider = BiosUtil.drawDivider(window, 4, LOWER_DIVIDER_Y, STROKE_THICKNESS);
        titleText = BiosUtil.drawTitle(window, "Achievements Flag Configuration");

        clipRect.width = window.width;

        add(windowStroke);
        add(window);
        add(titleDivider);
        add(titleText);
        add(instructionsDivider);

        loadAchievements();
        updateSelectorPosition();
    }

    private function loadAchievements():Void {
        var yPosition:Float = UPPER_DIVIDER_Y + TEXT_PADDING;
        var yPositionIncrement:Float = ACHIEVEMENT_HEIGHT;
        var FONT_SIZE:Int = 20;

        achievementGroup.setPosition(window.x, window.y);

        for (key in Achievements.achievements.keys()) {
            var achievement = Achievements.achievements.get(key);
            var isUnlocked = Achievements.isUnlocked(key);

            var achievementText = new FlxText(
                TEXT_PADDING,
                yPosition,
                window.width - (TEXT_PADDING * 2),
                '${achievement.name}. . . . . [ ${isUnlocked ? '*' : ' '} ]'
            );

            achievementText.setFormat(null, FONT_SIZE, FlxColor.WHITE, "LEFT");
            achievementGroup.add(achievementText);

            var achievementObj = {
                data: achievementText,
                name: key
            };
            achievements.push(achievementObj);

            yPosition += yPositionIncrement;
        }

        achievementGroup.clipRect = clipRect;
        add(achievementGroup);
    }


    private function updateSelectorPosition():Void {
        if (achievements.length > 0) {            
            for (i in 0...achievements.length) {
                var achievementObj = achievements[i];
                var isSelected = (i == selectedIndex);
                var isUnlocked = Achievements.isUnlocked(achievementObj.name);
                var achievement = Achievements.achievements.get(achievementObj.name);
                
                achievementObj.data.color = isSelected ? FlxColor.YELLOW : FlxColor.WHITE;
                achievementObj.data.text = '${achievement.name}. . . . . [ ${isUnlocked ? '*' : ' '} ]';
            }
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        var maxIndex:Int = achievements.length - 1;
        if (maxIndex < 0) return;

        if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP) {
            if (FlxG.keys.justPressed.DOWN && selectedIndex < maxIndex) {
                selectedIndex += 1;
            } else if (FlxG.keys.justPressed.UP && selectedIndex > 0) {
                selectedIndex -= 1;
            }
            updateSelectorPosition();
            adjustClippingRect();
        }

        if (FlxG.keys.justPressed.ENTER) {
            toggleSelectedAchievement();
        }

        if (FlxG.keys.justPressed.ESCAPE) {
            close();
        }
    }

    private function adjustClippingRect():Void {
        if (selectedIndex >= scrollOffset + visibleItems) {
            scrollOffset++;
            achievementGroup.y -= ACHIEVEMENT_HEIGHT;
            clipRect.y += ACHIEVEMENT_HEIGHT;
        }
        
        if (selectedIndex < scrollOffset) {
            scrollOffset--;
            achievementGroup.y += ACHIEVEMENT_HEIGHT;
            clipRect.y -= ACHIEVEMENT_HEIGHT;
        }
        
        achievementGroup.clipRect = clipRect;
    }

    private function toggleSelectedAchievement():Void {
        if (achievements.length > 0 && selectedIndex < achievements.length) { 
            var achievementObj = achievements[selectedIndex];
            var achievementKey:String = achievementObj.name;
            
            if (Achievements.isUnlocked(achievementKey)) {
                Achievements.remove(achievementKey);
            } else {
                Achievements.unlock(achievementKey, true);
            }
            
            Achievements.save();
            updateSelectorPosition();
        }
    }
}
