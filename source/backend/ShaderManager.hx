package backend;

import flixel.FlxG;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter; // Added for type compatibility
import shaders.CRTShader;

typedef ShaderSettings = {
    var name:String;
    var enabled:Bool;
    var params:Map<String, Float>;
}

class ShaderManager
{
    private static var instance:ShaderManager;

    private var shaders:Map<String, Dynamic> = new Map();
    private var shaderFilters:Map<String, ShaderFilter> = new Map();
    
    public var settings:Array<ShaderSettings> = [];

    private function new() 
    {
        setupShaders();
        loadShaderSettings();
    }

    private function setupShaders():Void
    {
        var crtShader = new CRTShader(0.35, 0.75);
        shaders.set("CRT", crtShader); 
        shaderFilters.set("CRT", new ShaderFilter(crtShader));

        var defaultParams = ["warp" => 0.35, "scan" => 0.75];
        var params = new Map<String, Float>();
        for (key => value in defaultParams) {
            params.set(key, value);
        }

        settings.push({
            name: "CRT",
            enabled: true,
            params: params
        });
    }
    
    public static function i():ShaderManager 
    {
        if (instance == null) {
            instance = new ShaderManager();
        }
        return instance;
    }

    public function toggleShader(shaderName:String, enabled:Bool):Void
    {
        for (shader in settings) {
            if (shader.name == shaderName) {
                shader.enabled = enabled;
                break;
            }
        }

        applyShaders();
        saveShaderSettings();
    }
    
    public function applyShaders():Void 
    {
        if (FlxG.camera != null) {
            var activeShaders:Array<BitmapFilter> = [];

            for (shader in settings) {
                if (shader.enabled && shaderFilters.exists(shader.name)) {
                    activeShaders.push(shaderFilters.get(shader.name));
                }
            }

            FlxG.camera.setFilters(activeShaders);
        }
    }
    
    public function updateShaderValue(shaderName:String, paramName:String, value:Float):Void 
    {
        // Update settings
        for (shader in settings) {
            if (shader.name == shaderName && shader.params.exists(paramName)) {
                shader.params.set(paramName, value);
            }
        }

        // Update actual shader
        switch (shaderName) {
            case "CRT":
                var crtShader:CRTShader = cast shaders.get("CRT");
                switch(paramName) {
                    case "warp":
                        crtShader.warp.value = [value];
                    case "scan":
                        crtShader.scan.value = [value];
                }
            default:
        }

        saveShaderSettings();
    }

    public function getShaderSetting(shaderName:String):Null<ShaderSettings>
    {
        for (shader in settings) {
            if (shader.name == shaderName) {
                return shader;
            }
        }
        return null;
    }

    private function saveShaderSettings():Void
    {
        if (FlxG.save.data.shaderSettings == null) {
            FlxG.save.data.shaderSettings = [];
        }

        FlxG.save.data.shaderSettings = settings;
        FlxG.save.flush();
    }

    private function loadShaderSettings():Void
    {
        if (FlxG.save.data.shaderSettings != null) {
            var savedSettings:Array<ShaderSettings> = cast FlxG.save.data.shaderSettings;

            for (saved in savedSettings) {
                for (shader in settings) {
                    if (saved.name == shader.name) {
                        shader.enabled = saved.enabled;
                        
                        for (param => value in saved.params) {
                            if (shader.params.exists(param)) { 
                                shader.params.set(param, value); 
                                updateShaderValue(shader.name, param, value);
                            }
                        }
                    }
                }
            }
        }
    }
}