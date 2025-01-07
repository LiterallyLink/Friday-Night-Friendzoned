package backend.composite;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

typedef ObjectMemberData =
{
	var clazz:Class<FlxBasic>;
	var relativeX:Float;
	var relativeY:Float;
}

/**
 * A CompositeObject is assumed to operate just like a `FlxObject`. It is composed of other
 * `FlxBasic`s but no external reference to those objects should be retained. The CompositeObject
 * will act as though it owns them and will alter their properties at will.
 * 
 * Initial properties of the member objects may be set before adding them to the composite. Almost
 * all such properties, in as far as they are FlxObject properties, will be relative to the
 * composite's property of the same name. They will either be added or multiplied. See the 
 * specific property modifier for details.
 */
class CompositeObject extends FlxObject implements IComposite
{
	var _members:Array<FlxBasic>;
	var _memberData:Array<ObjectMemberData>;
	
	/**
	 * @param   x        The X-coordinate of the point in space.
	 * @param   y        The Y-coordinate of the point in space.
	 * @param   width    Desired width of the rectangle.
	 * @param   height   Desired height of the rectangle.
	 */
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		super(x, y, width, height);
		// FIXME - consider ...
		// Some questionable choice here but done so that push semantics are consistent.
		// FlxTypedGroup.add will backfill into empty slots. I could just use slice on
		// delete and that would work. Perhaps better.
		_members = new Array<FlxBasic>();
		_memberData = new Array<ObjectMemberData>();
	}
	
	override public function destroy():Void
	{
		for (m in _members)
		{
			FlxDestroyUtil.destroy(m);
		}
		super.destroy();
	}
	
	override public function update(elapsed:Float):Void
	{
		// Update Composite itself first then update the members
		// using the new values of the composite.
		super.update(elapsed);
		
		for (i => m in _members)
		{
			if (m.exists && m.active)
			{
				m.update(elapsed);
				_updateMember(m, _memberData[i]);
			}
		};
	}
	
	override public function draw():Void
	{
		super.draw();
		
		for (m in _members)
		{
			if (m.exists && m.visible)
			{
				m.draw();
			}
		}
	}
	
	function _updateMember(member:FlxBasic, data:ObjectMemberData):Void
	{
		// Simple offset update only first
		if (member is FlxObject)
		{
			var m = cast(member, FlxObject);
			m.x = x + data.relativeX;
			m.y = y + data.relativeY;
			m.angle = angle;
		}
	}
	
	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("CompositeObject", super.toString()),
			LabelValuePair.weak("memberCount", _members.length)
		]);
	}
	
	public function add(member:FlxBasic, ?name:String)
	{
		// Process the new member and store
		var md = _processNewMember(member);
		_members.push(member);
		_memberData.push(md);
	}
	
	function _processNewMember(member:FlxBasic):ObjectMemberData
	{
		if (member is FlxObject)
		{
			var m = cast(member, FlxObject);
			return {
				clazz: FlxObject,
				relativeX: m.x,
				relativeY: m.y,
			};
		}
		return {
			clazz: FlxBasic,
			relativeX: 0,
			relativeY: 0,
		};
	}
	
	public function remove(?member:FlxBasic, ?name:String) {}
	
	public function getSingleCollider():FlxObject
	{
		return null;
	}
}