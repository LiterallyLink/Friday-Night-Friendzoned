package backend.window.composite;

import flixel.FlxBasic;
import flixel.FlxObject;
/**
 * The composite interface definition 
 */
interface IComposite
{
	/**
	 * Add a member to this composite.
	 * 
	 * @param member the member to add
	 * @param name an optional name for the member
	 */
	public function add(member:FlxBasic, name:Null<String> = null):Void;
	
	/**
	 * Remove the member specified by reference to the original member object or by name.
	 * If both member and name are specified and they do not refer to the same member
	 * an exception will be thrown.
	 * 
	 * @param member the member to remove
	 * @param name the name of the member
	 */
	public function remove(member:Null<FlxBasic> = null, name:Null<String> = null):Void;
	
	/**
	 * Get this composite's collider hitbox object. This may be used in
	 * any standard collision group or function. This will collide as though
	 * the entire composite was just one entity.
	 * 
	 * @return FlxObject the collider object
	 */
	public function getSingleCollider():FlxObject;
}