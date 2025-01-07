package substates;

import backend.ApplicationButton;
import backend.ContextMenu.SpawnPosition;
import backend.AppContextMenu;
import flixel.FlxG;

/**
 * A context menu substate that appears when right-clicking an application button.
 * Uses the AppContextMenu implementation for handling application-specific operations.
 */
class ContextMenuSubState extends MusicBeatSubstate {
    private var menu:AppContextMenu;

    public function new(app:ApplicationButton, spawnPosition:SpawnPosition = SpawnPosition.TopLeft) {
        super();
        
        menu = new AppContextMenu(app, spawnPosition);
        add(menu);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (FlxG.mouse.justPressed && !menu.overlapsPoint(FlxG.mouse.getPosition())) {
            close();
        }
    }
}