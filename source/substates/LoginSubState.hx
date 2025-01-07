package substates;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxTimer;

import states.LoginState;
import states.DesktopState;

import backend.window.WindowManager;
import backend.composite.CompositeSprite;

class LoginSubState extends FlxSubState {
    private var window:WindowManager;
    private var composite:CompositeSprite;
    private var user:String;
    
    private var usernameField:FlxInputText;
    private var passwordField:FlxInputText;
    private var confirmButton:FlxButton;

    public static final credentials:Map<String, {password:Null<String>}> = [
        'bf' => { password: "Bopeebo" },
        'gf' => { password: null },
        'darnell' => { password: null },
        'father' => { password: null },
        'mommy' => { password: null },
        'nene' => { password: null },
        'pico' => { password: null },
        'senpai' => { password: null },
        'tank' => { password: null },
        '87' => { password: null },
        'spooky' => { password: null }
    ];

    public function new(user:String) {
        super();

        this.user = user;
    }

    override function create() {
        super.create();

        if (user == "87") {
            triggerGoldenFreddyJumpscare();
            return;
        }

        createWindow();
        window = new WindowManager(composite);
        window.createDragHandle(515, 20, 10, 10, true);
        window.screenCenter(XY);

        if (ClientPrefs.data.profileData.isRegistered) {
            logIntoProfile();
        } else {
            createNewProfile();
        }

        add(window);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    private function createWindow() {
        composite = new CompositeSprite();

        var backdrop = new FlxSprite();
        backdrop.loadGraphic(Paths.image('menulogin/window/new_user_backdrop'));

        composite.add(backdrop);
        composite.updateHitbox();
    }

    private function createNewProfile() {
        var icon = new FlxSprite(20, 40).loadGraphic(Paths.image('menulogin/icons/newUser'));
        icon.scale.set(1.5, 1.5);
        icon.updateHitbox();
        composite.add(icon);

        var instructions = new FlxSprite(150, 60).loadGraphic(Paths.image('menulogin/window/instructions'));
        composite.add(instructions);

        var EREG_PATTERN = new EReg("[^a-zA-Z0-9]", "g");

        usernameField = new FlxInputText(140, 163, 350, "", 20, 0xFF000000, 0xFFFFFFFF);
        usernameField.hasFocus = true;
        usernameField.backgroundColor = 0xFFFFFFFF;
        usernameField.textField.background = true;
        usernameField.customFilterPattern = EREG_PATTERN;
        usernameField.maxLength = 14;
        composite.add(usernameField);

        passwordField = new FlxInputText(140, 225, 350, "", 20, 0xFF000000, 0xFFFFFFFF);
        passwordField.backgroundColor = 0xFFFFFFFF;
        passwordField.textField.background = true;
        passwordField.customFilterPattern = EREG_PATTERN;
        passwordField.maxLength = 14;
        composite.add(passwordField);

        usernameField.callback = keyPressCallback;
        passwordField.callback = keyPressCallback;

        addLoginButtons();
    }

    private function logIntoProfile() {
        var icon = new FlxSprite().loadGraphic(Paths.image('menulogin/icons/${user}'));
        icon.scale.set(1.5, 1.5);
        icon.updateHitbox();
        composite.add(icon);

        var EREG_PATTERN = new EReg("[^a-zA-Z0-9]", "g");

        passwordField = new FlxInputText(140, 225, 350, "", 20, 0xFF000000, 0xFFFFFFFF);
        passwordField.backgroundColor = 0xFFFFFFFF;
        passwordField.textField.background = true;
        passwordField.customFilterPattern = EREG_PATTERN;
        passwordField.maxLength = 14;
        composite.add(passwordField);

        passwordField.callback = keyPressCallback;

        addLoginButtons();
    }

    private function addLoginButtons() {
        var cancel = new FlxButton(() -> {
            close();
        });

        cancel.loadGraphic(Paths.image('menulogin/window/cancel'));
        cancel.setPosition(
            composite.width - (cancel.width + 30),
            composite.height - (cancel.height + 30)
        );

        confirmButton = new FlxButton(() -> {});
        confirmButton.loadGraphic(Paths.image('menulogin/window/dimmed_ok'));
        confirmButton.setPosition(
            cancel.x - (confirmButton.width + 15),
            cancel.y
        );

        composite.add(cancel);
        composite.add(confirmButton);
    }

    private function keyPressCallback(text:String, action:String):Void {
        var randomInt:Int = FlxG.random.int(1, 5);
        FlxG.sound.play(Paths.sound('keyboard/keypress' + randomInt));
        updateConfirmButtonState();
    }
    
    private function updateConfirmButtonState():Void {
        var isActive:Bool = passwordField.text.length > 0;
        if (usernameField != null) {
            isActive = isActive && usernameField.text.length > 0;
        }
    
        if (isActive) {
            confirmButton.loadGraphic(Paths.image('menulogin/window/ok'));
        } else {
            confirmButton.loadGraphic(Paths.image('menulogin/window/dimmed_ok'));
            confirmButton.onUp.callback = function() {};
        }
    }
   
    /*
    private function createNewProfile():Void {
        ClientPrefs.data.profileData.username = usernameField.text;
        ClientPrefs.data.profileData.password = passwordField.text;
        ClientPrefs.data.profileData.icon = 'default';
        ClientPrefs.data.profileData.isRegistered = true;
        ClientPrefs.saveSettings();
    }
    */
    
    private function handleExistingUserLogin():Void {
        var expectedPassword = credentials.get(user).password;
        
        if (passwordField.text == expectedPassword) {
            trace("Logging On...");
        } else {
            trace('wrong password');
        }
    }

    private function triggerGoldenFreddyJumpscare() {
        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound('GoldenFreddyScream'));

        var goldenFreddy = new FlxSprite();
        goldenFreddy.loadGraphic(Paths.image('menulogin/fnaf/Golden_Freddy'));
        add(goldenFreddy);

        new FlxTimer().start(3, function(timer:FlxTimer) {
            return Sys.exit(1);
        });
    }
}