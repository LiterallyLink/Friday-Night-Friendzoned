package backend.composite;

import backend.composite.CompositeObject;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;

typedef SpriteMemberData = {
    var clazz:Class<FlxBasic>;
    var memberScale:FlxPoint;
}

@:access(backend.composite.CompositeObject)
class CompositeSprite extends FlxSprite implements IComposite {
    var _compositeObject:CompositeObject;
    var _memberData:Array<SpriteMemberData>;
    
    var _previousScaleX:Float = 1.0;
    var _previousScaleY:Float = 1.0;
    
    var _hitbox:SingleCollider;
    
    public final HITBOX = '__hitbox__';
    
    public function new(?x:Float = 0, ?y:Float = 0) {
        super(x, y);
        _compositeObject = new CompositeObject(x, y);
        _memberData = new Array<SpriteMemberData>();
        _hitbox = new SingleCollider(this, 0.0, 0.0);
        _hitbox.elasticity = 1.0;
        add(_hitbox, HITBOX);
    }
    
    override public function update(elapsed:Float):Void {
        if (_hitbox.touching != FlxDirectionFlags.NONE)
            processCollision();
            
        super.update(elapsed);
        _compositeObject.update(elapsed);
        
        for (i => m in _compositeObject._members) {
            if (m.exists && m.active && m is FlxSprite) {
                m.update(elapsed);
                _updateMember(m, _memberData[i]);
            }
        };
        
        _hitbox.x += (x - last.x);
        _hitbox.y += (y - last.y);
    }
    
    override public function draw():Void {
        #if FLX_DEBUG
        if (FlxG.debugger.drawDebug) {
            drawDebug();
            _hitbox.drawDebug();
        }
        #end
        _compositeObject.draw();
    }
    
    override public function destroy():Void {
        super.destroy();
    }
    
    @:noCompletion
    override function set_x(value:Float):Float {
        if (_compositeObject == null) {
            return x = value;
        }
        return x = _compositeObject.x = value;
    }
    
    @:noCompletion
    override function set_y(value:Float):Float {
        if (_compositeObject == null) {
            return y = value;
        }
        return y = _compositeObject.y = value;
    }
    
    @:noCompletion
    override function set_angle(Value:Float):Float {
        var ret = super.angle = Value;
        
        if (_compositeObject != null) {
            _compositeObject.angle = Value;
        }
        return ret;
    }
    
    override public function updateHitbox():Void {
        var minX = 999999.0;
        var minY = 999999.0;
        var maxX = 0.0;
        var maxY = 0.0;
        
        var maxX_unscaled = 0.0;
        var maxY_unscaled = 0.0;
        
        for (i => m in _compositeObject._members) {
            if (i == 0)
                continue;
            if (m is FlxObject) {
                var o = cast(m, FlxObject);
                
                var dx = _compositeObject._memberData[i].relativeX;
                var dy = _compositeObject._memberData[i].relativeY;
                
                dx = dx * scale.x;
                dy = dy * scale.y;
                
                if (x + dx < minX) {
                    minX = x + dx;
                }
                if (x + dx + o.width * scale.x > maxX) {
                    maxX = x + dx + o.width * scale.x;
                    maxX_unscaled = x + dx + o.width;
                }
                if (y + dy < minY) {
                    minY = y + dy;
                }
                if (y + dy + o.height * scale.y > maxY) {
                    maxY = y + dy + o.height * scale.y;
                    maxY_unscaled = y + dy + o.height;
                }
            }
        }
        
        width = maxX - minX;
        height = maxY - minY;
        
        // Adjust position of the hitbox
        var o2 = new FlxPoint().copyFrom(origin);
        o2.subtract(minX - x, minY - y);
        var bnds = FlxRect.get().set(minX, minY, width, height).getRotatedBounds(angle, o2);
        
        _compositeObject._memberData[0].relativeX = (bnds.x - x);
        _compositeObject._memberData[0].relativeY = (bnds.y - y);
        
        _hitbox.setSize(bnds.width, bnds.height);
    }
    
    function _updateMember(member:FlxBasic, data:SpriteMemberData):Void {
        if (member is FlxSprite) {
            var m = cast(member, FlxSprite);
            
            // Update origin relative to composite
            m.origin = new FlxPoint(x + origin.x - m.x, y + origin.y - m.y);
            
            // Apply composite scale multiplied by member's own scale
            m.scale.x = data.memberScale.x * scale.x;
            m.scale.y = data.memberScale.y * scale.y;
            
            m.offset.set(offset.x, offset.y);
        }
    }
    
    function processCollision():Void {
        x -= Math.round((x + _compositeObject._memberData[0].relativeX - _hitbox.x));
        y -= Math.round((y + _compositeObject._memberData[0].relativeY - _hitbox.y));
        velocity.add(_hitbox.velocity.x, _hitbox.velocity.y);
        _hitbox.velocity.set();
    }
    
    public function add(member:FlxBasic, ?name:String) {
        var md = _processNewMember(member);
        _memberData.push(md);
        _compositeObject.add(member, name);
    }
    
    function _processNewMember(member:FlxBasic):SpriteMemberData {
        if (member is FlxSprite) {
            var m = cast(member, FlxSprite);
            return {
                clazz: FlxSprite,
                memberScale: new FlxPoint(m.scale.x, m.scale.y)
            };
        }
        else if (member is FlxObject) {
            return {
                clazz: FlxObject,
                memberScale: new FlxPoint(1.0, 1.0)
            };
        }
        return {
            clazz: FlxBasic,
            memberScale: new FlxPoint(1.0, 1.0)
        };
    }
    
    public function remove(?member:FlxBasic, ?name:String) {}
    
    public function getSingleCollider():FlxObject {
        return _hitbox;
    }
}