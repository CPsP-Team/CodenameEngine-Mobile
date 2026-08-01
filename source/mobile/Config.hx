package mobile;

import mobile.io.FileSystem;
import mobile.io.File;
import mobile.ControlsData;
import haxe.Json;

class Config
{
	public static var DPAD_PATH:String = "assets/mobile/DPad/images/";
	public static var BUTTON_PATH:String = "assets/mobile/Button/images/";
	public static var JOYSTICK_PATH:String = "assets/mobile/JoyStick/images/";

	public static var DPAD_JSON:String = "assets/mobile/DPad/";
	public static var BUTTON_JSON:String = "assets/mobile/Button/";
	public static var JOYSTICK_JSON:String = "assets/mobile/JoyStick/";
	public static var HITBOX_JSON:String = "assets/mobile/Hitbox/";

	/* RECOMMEND TO CHANGING THESE FOR THE GAMES USING MODDING SYSTEM */
	public static var MODDED_DPAD_PATH(get, default):String = "";
	public static var MODDED_BUTTON_PATH(get, default):String = "";
	public static var MODDED_JOYSTICK_PATH(get, default):String = "";

	public static var MODDED_DPAD_JSON(get, default):String = "";
	public static var MODDED_BUTTON_JSON(get, default):String = "";
	public static var MODDED_JOYSTICK_JSON(get, default):String = "";
	public static var MODDED_HITBOX_JSON(get, default):String = "";

	public static var Buttons:Map<String, ControlsJsonDef> = new Map();
	public static var DPads:Map<String, ControlsJsonDef> = new Map();
	public static var JoySticks:Map<String, ControlsJsonDef> = new Map();
	public static var Hitboxes:Map<String, ControlsJsonDef> = new Map();

	private static function get_MODDED_DPAD_PATH()
	{
		return modPath + "mobile/DPad/images/";
	}
	private static function get_MODDED_BUTTON_PATH()
	{
		return modPath + "mobile/Button/images/";
	}
	private static function get_MODDED_JOYSTICK_PATH()
	{
		return modPath + "mobile/JoyStick/images/";
	}
	private static function get_MODDED_DPAD_JSON()
	{
		return modPath + "mobile/DPad/";
	}
	private static function get_MODDED_BUTTON_JSON()
	{
		return modPath + "mobile/Button/";
	}
	private static function get_MODDED_JOYSTICK_JSON()
	{
		return modPath + "mobile/JoyStick/";
	}
	private static function get_MODDED_HITBOX_JSON()
	{
		return modPath + "mobile/Hitbox/";
	}
	private inline static function getModFolder()
	{
		#if MOD_SUPPORT
		final moddyFolder:String = (ModsFolder.currentModFolder != null
			&& ModsFolder.currentModFolder != "default") ? '${ModsFolder.modsPath}${ModsFolder.currentModFolder}/' : "null/";
		return moddyFolder;
		#else
		return "null/";
		#end
	}

	private static var modPath:String = "";
	public static function init() {
		Buttons.clear();
		DPads.clear();
		JoySticks.clear();
		Hitboxes.clear();

		#if MOD_SUPPORT
		modPath = getModFolder();
		#end

		loadIntoMap(BUTTON_JSON, Buttons);
		loadIntoMap(MODDED_BUTTON_JSON, Buttons);

		loadIntoMap(DPAD_JSON, DPads);
		loadIntoMap(MODDED_DPAD_JSON, DPads);

		loadIntoMap(JOYSTICK_JSON, JoySticks);
		loadIntoMap(MODDED_JOYSTICK_JSON, JoySticks);

		loadIntoMap(HITBOX_JSON, Hitboxes);
		loadIntoMap(MODDED_HITBOX_JSON, Hitboxes);
	}

	private static function loadIntoMap(path:String, map:Map<String, ControlsJsonDef>) {
		if (path != null && path != "" && FileSystem.exists(path) && FileSystem.isDirectory(path)) {
			var files = FileSystem.readDirectory(path);
			for (i in 0...files.length) {
				var file = files[i];
				if (file.length > 5 && file.substr(-5) == ".json") {
					var name = file.substr(0, file.length - 5);
					var content = File.getContent(path + file);
					if (content != null) {
						try {
							var parsed:ControlsJsonDef = Json.parse(content);
							map.set(name, parsed);
						} catch (e:Dynamic) {}
					}
				}
			}
		}
	}
}
