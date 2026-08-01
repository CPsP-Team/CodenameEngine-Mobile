package funkin.options.categories;

import flixel.input.keyboard.FlxKey;
import lime.system.System as LimeSystem;
import funkin.backend.assets.ModsFolder;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class MobileOptions extends OptionsScreen
{
	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');
		trace(daList);

		return daList;
	}
	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		if(Assets.exists(path)) daList = Assets.getText(path);
		trace(daList);
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function mergeAllTextsNamed(file:String)
	{
		var mergedList:Array<String> = [];
		var list:Array<String> = coolTextFile(file);
		for (value in list)
			if(!mergedList.contains(value) && value.length > 0)
				mergedList.push(value);
		return mergedList;
	}

	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL_MEDIA", "EXTERNAL"];
	var customPaths:Array<String> = MobileUtil.getCustomStorageDirectories(false);
	final lastExternal:String = Options.storageType;
	var externalOption:ArrayOption;
	#end
	final lastDebug = Options.debugConsole;

	var HitboxModes:Array<String>;
	public function new()
	{
		super('Mobile Options', 'Mobile Options', ['FULL', 'A_B']);
		#if android
		storageTypes = storageTypes.concat(customPaths); //Get Custom Paths From File
		#end

		HitboxModes = mergeAllTextsNamed("assets/mobile/Hitbox/hitboxModeList.txt");
		if ((HitboxModes == null))
			HitboxModes = ["Normal"];

		add(new NumOption('Extra Buttons', 'Select how many extra buttons you prefer to have on hitbox.', 0, 2, 1, 'extraButtons'));
		/* Tahtalı Köy, can be added back later.
		add(new ArrayOption(getNameID('hitboxType'), getDescID('hitboxType'), ["No Gradient", "No Gradient (Old)", "Gradient"],
			["No Gradient", "No Gradient (Old)", "Gradient"], 'hitboxType'));
		*/
		add(new ArrayOption('Hitbox Mode', 'Choose your Hitbox Style! (Cannot be added custom ones for now)', HitboxModes, HitboxModes, 'hitboxMode'));
		add(new Checkbox('Hitbox Position', 'If checked, the Hitbox will be put at the top of the screen, otherwise will stay at the bottom.', "hitboxPos"));
		add(new NumOption('Control Opacity', 'Change how opaque the Mobile Controls should be', 0.0, 1.0, 0.1, "controlsAlpha", (alpha:Float) ->
		{
			//MusicBeatState.instance.mobileManager.alpha = alpha;
			if (funkin.backend.system.Controls.instance.mobileC)
			{
				FlxG.sound.volumeUpKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.muteKeys = [];
			}
			else
			{
				FlxG.sound.volumeUpKeys = [FlxKey.PLUS, FlxKey.NUMPADPLUS];
				FlxG.sound.volumeDownKeys = [FlxKey.MINUS, FlxKey.NUMPADMINUS];
				FlxG.sound.muteKeys = [FlxKey.ZERO, FlxKey.NUMPADZERO];
			}
		}));
		#if DEBUG_MENU
		add(new Checkbox('Debug Console', 'If checked, A Debug Console Icon will show up.', "debugConsole"));
		#end
		#if android
		add(externalOption = new ArrayOption('Folder', 'Which folder Codename Engine Mods should stored?\nCan be added custom folders, check android/data for that', storageTypes,
			storageTypes, 'storageType'));
		#end
	}

	override function close()
	{
		super.close();
		Options.save();
		#if DEBUG_MENU
		if (lastDebug != Options.debugConsole) {
			DebugMenu.instance.closeMenu();
			DebugMenu.instance.floatingBtn.visible = Options.debugConsole;
		}
		#end

		#if android
		if (lastExternal != externalOption.displayOptions[externalOption.currentSelection])
		{
			Options.save();
			File.saveContent(MobileUtil.getStorageTypePath(), Options.storageType);
			MobileUtil.initDirectory();
			funkin.backend.utils.NativeAPI.showMessageBox("Warning: Storage Type Has Been Changed!", "The Storage Type has been changed.\nA restart is required for this change to take effect.\nAny previously installed mods will have to be moved manually to the new Storage Types's directory after this restart.\n\nPress OK to reset the game and apply the changes.");
			LimeSystem.exit(1);
		}
		#end
	}
}