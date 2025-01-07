package backend;

import backend.ContextMenu;
import backend.ContextMenu.SpawnPosition;
import backend.ContextMenu.MenuItem;
import backend.ApplicationButton;
import flixel.FlxG;

/**
 * A specialized context menu for ApplicationButton instances.
 * Provides application-specific menu options while using the base ContextMenu functionality.
 */
class AppContextMenu extends ContextMenu {
    private var app:ApplicationButton;
    
    private static final APP_OPTIONS:Array<MenuItem> = [
        {
            label: "Info",
            icon: null,
            callback: null
        },
        {
            label: "Run",
            icon: null,
            callback: null
        },
        {
            label: "Run As Administrator",
            icon: null,
            callback: null
        },
        {
            label: "Copy",
            icon: null,
            callback: null
        },
        {
            label: "Rename",
            icon: null,
            callback: null
        },
        {
            label: "Delete",
            icon: null,
            callback: null
        }
    ];

    public function new(app:ApplicationButton, spawnPosition:SpawnPosition = SpawnPosition.TopLeft) {
        this.app = app;
        
        var menuOptions:Array<MenuItem> = APP_OPTIONS.map(option -> {
            return {
                label: option.label,
                icon: option.icon,
                callback: () -> {
                    handleOptionClick(option.label);
                    if (FlxG.state.subState != null) {
                        FlxG.state.closeSubState();
                    }
                }
            };
        });
        
        super(menuOptions, spawnPosition);
    }
    
    private function handleOptionClick(option:String):Void {
        switch(option) {
            case 'Info': 
                trace('Info clicked');
            
            case 'Run': 
                trace('Run clicked');
            
            case 'Run As Administrator': 
                trace('Run As Administrator clicked');
            
            case 'Copy': 
                trace('Copy clicked');
            
            case 'Rename': 
                trace('Rename clicked');
            
            case 'Delete': {
                FlxG.sound.play(Paths.sound('recycle'));
                app.kill();
            }
        }
    }
}