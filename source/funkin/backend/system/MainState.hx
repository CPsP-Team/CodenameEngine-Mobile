package funkin.backend.system;

#if MOD_SUPPORT
import sys.FileSystem;
#end
import funkin.backend.assets.ModsFolder;
import funkin.menus.TitleState;
import funkin.menus.BetaWarningState;
import funkin.backend.chart.EventsData;
import flixel.FlxState;
import haxe.io.Path;

@dox(hide)
typedef AddonInfo = {
	var name:String;
	var path:String;
}

/**
 * Simple state used for loading the game
 */
class MainState extends FlxState {
	public static var initiated:Bool = false;
	public static var betaWarningShown:Bool = false;
	public override function create() {
		super.create();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test8", "test");
		#end
		if (!initiated)
			Main.loadGameSettings();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test9", "test");
		#end
		initiated = true;

		#if sys
		CoolUtil.deleteFolder('./.temp/'); // delete temp folder
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("test10", "test");
		#end
		Options.save();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test11", "test");
		#end

		FlxG.bitmap.reset();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test12", "test");
		#end
		FlxG.sound.destroy(true);
		#if SHOW_TEST
		NativeAPI.showMessageBox("test13", "test");
		#end

		Paths.assetsTree.reset();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test14", "test");
		#end

		#if MOD_SUPPORT
		inline function isDirectory(path:String):Bool
			return FileSystem.exists(path) && FileSystem.isDirectory(path);

		inline function ltrim(str:String, prefix:String):String
			return str.substr(prefix.length).ltrim();

		inline function loadLib(path:String, name:String)
			Paths.assetsTree.addLibrary(ModsFolder.loadModLib(path, name));

		var _lowPriorityAddons:Array<AddonInfo> = [];
		var _highPriorityAddons:Array<AddonInfo> = [];
		var _noPriorityAddons:Array<AddonInfo> = [];

		#if SHOW_TEST
		NativeAPI.showMessageBox("test15", "test");
		#end

		var addonPaths = [
			ModsFolder.addonsPath,
			(
				ModsFolder.currentModFolder != null ?
					ModsFolder.modsPath + ModsFolder.currentModFolder + "/addons/" :
					null
			)
		];

		#if SHOW_TEST
		NativeAPI.showMessageBox("test16", "test");
		#end

		for(path in addonPaths) {
			if (path == null) continue;
			if (!isDirectory(path)) continue;

			for(addon in FileSystem.readDirectory(path)) {
				if(!FileSystem.isDirectory(path + addon)) {
					switch(Path.extension(addon).toLowerCase()) {
						case 'zip':
							addon = Path.withoutExtension(addon);
						default:
							continue;
					}
				}

				var data:AddonInfo = {
					name: addon,
					path: path + addon
				};

				if (addon.startsWith("[LOW]")) _lowPriorityAddons.insert(0, data);
				else if (addon.startsWith("[HIGH]")) _highPriorityAddons.insert(0, data);
				else _noPriorityAddons.insert(0, data);
			}
		}

		#if SHOW_TEST
		NativeAPI.showMessageBox("test17", "test");
		#end

		for (addon in _lowPriorityAddons)
			loadLib(addon.path, ltrim(addon.name, "[LOW]"));

		#if SHOW_TEST
		NativeAPI.showMessageBox("test18", "test");
		#end

		if (ModsFolder.currentModFolder != null)
			loadLib(ModsFolder.modsPath + ModsFolder.currentModFolder, ModsFolder.currentModFolder);

		#if SHOW_TEST
		NativeAPI.showMessageBox("test19", "test");
		#end

		for (addon in _noPriorityAddons)
			loadLib(addon.path, addon.name);

		#if SHOW_TEST
		NativeAPI.showMessageBox("test20", "test");
		#end

		for (addon in _highPriorityAddons)
			loadLib(addon.path, ltrim(addon.name, "[HIGH]"));

		#if SHOW_TEST
		NativeAPI.showMessageBox("test21", "test");
		#end

		#end

		MusicBeatTransition.script = "";
		Main.refreshAssets();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test22", "test");
		#end
		ModsFolder.onModSwitch.dispatch(ModsFolder.currentModFolder);
		#if SHOW_TEST
		NativeAPI.showMessageBox("test23", "test");
		#end
		DiscordUtil.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test24", "test");
		#end
		EventsData.reloadEvents();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test25", "test");
		#end
		TitleState.initialized = false;

		if (betaWarningShown)
			FlxG.switchState(new TitleState());
		else {
			FlxG.switchState(new BetaWarningState());
			betaWarningShown = true;
		}
		#if SHOW_TEST
		NativeAPI.showMessageBox("test26", "test");
		#end

		mobile.Config.init();

		#if SHOW_TEST
		NativeAPI.showMessageBox("test27", "test");
		#end

		CoolUtil.safeAddAttributes('./.temp/', NativeAPI.FileAttribute.HIDDEN);

		#if SHOW_TEST
		NativeAPI.showMessageBox("test28", "test");
		#end
	}
}