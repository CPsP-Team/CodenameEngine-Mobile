package funkin.backend.system;

import funkin.editors.SaveWarning;
import funkin.backend.assets.AssetsLibraryList;
import funkin.backend.system.framerate.SystemInfo;
import openfl.utils.AssetLibrary;
import openfl.text.TextFormat;
import flixel.system.ui.FlxSoundTray;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import funkin.backend.system.modules.*;
import lime.app.Application;

#if ALLOW_MULTITHREADING
import sys.thread.Thread;
#end
#if sys
import sys.io.File;
#end
import funkin.backend.assets.ModsFolder;

class Main extends Sprite
{
	// make this empty once you guys are done with the project.
	// good luck /gen <3 @crowplexus
	public static final releaseCycle:String = "Beta";
	// add a version number in dis shid rn 
	public static var releaseVersion(get, default):String = null;
	public static function get_releaseVersion():String {
		if (releaseVersion != null)
			return releaseVersion;
		
		return lime.app.Application.current.meta.get('version');
	}

	public static var instance:Main;

	public static var modToLoad:String = null;
	public static var forceGPUOnlyBitmapsOff:Bool = #if windows false #else true #end;
	public static var noTerminalColor:Bool = false;

	public static var scaleMode:FunkinRatioScaleMode;
	public static var framerateSprite:funkin.backend.system.framerate.Framerate;

	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels).
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var game:FunkinGame;

	/**
	 * The time since the game was focused last time in seconds.
	 */
	public static var timeSinceFocus(get, never):Float;
	public static var time:Int = 0;

	// You can pretty much ignore everything from here on - your code should go in your states.

	#if ALLOW_MULTITHREADING
	public static var gameThreads:Array<Thread> = [];
	#end

	public function new()
	{
		super();

		instance = this;

		#if mobile
		#if android
		MobileUtil.getPermissions();
		MobileUtil.initDirectory();
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("test1", "test");
		#end
		Sys.setCwd(MobileUtil.getAssetDirectory());
		#if SHOW_TEST
		NativeAPI.showMessageBox("test2", "test");
		#end
		//Sys.setCwd(haxe.io.Path.addTrailingSlash(MobileUtil.getDirectory()));
		#if android MobileUtil.copyAssets(); #end
		#if SHOW_TEST
		NativeAPI.showMessageBox("test3", "test");
		#end
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("test4", "test");
		#end
		CrashHandler.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("test5", "test");
		#end

		addChild(game = new FunkinGame(gameWidth, gameHeight, MainState, Options.framerate, Options.framerate, skipSplash, startFullscreen));
		#if SHOW_TEST
		NativeAPI.showMessageBox("test6", "test");
		#end

		#if (!web)
		addChild(framerateSprite = new funkin.backend.system.framerate.Framerate());
		SystemInfo.init();
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("test7", "test");
		#end
		#if android FlxG.android.preventDefaultKeys = [BACK]; #end

		#if DEBUG_MENU
		addChild(new DebugMenu());
		#end
	}

	@:dox(hide)
	public static var audioDisconnected:Bool = false;

	public static var changeID:Int = 0;
	public static var pathBack = #if windows
			"../../../../"
		#elseif mac
			"../../../../../../../"
		#else
			""
		#end;
	public static var startedFromSource:Bool = #if TEST_BUILD true #else false #end;


	private static var __threadCycle:Int = 0;
	public static function execAsync(func:Void->Void) {
		#if ALLOW_MULTITHREADING
		var thread = gameThreads[(__threadCycle++) % gameThreads.length];
		thread.events.run(func);
		#else
		func();
		#end
	}

	private static function getTimer():Int {
		return time = Lib.getTimer();
	}

	public static function loadGameSettings() {
		WindowUtils.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame1", "test");
		#end
		SaveWarning.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame2", "test");
		#end
		MemoryUtil.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame3", "test");
		#end
		@:privateAccess
		FlxG.game.getTimer = getTimer;
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame4", "test");
		#end
		#if ALLOW_MULTITHREADING
		for(i in 0...4)
			gameThreads.push(Thread.createWithEventLoop(function() {Thread.current().events.promise();}));
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame5", "test");
		#end
		FunkinCache.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame6", "test");
		#end
		Paths.assetsTree = new AssetsLibraryList();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame7", "test");
		#end

		#if UPDATE_CHECKING
		funkin.backend.system.updating.UpdateUtil.init();
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame8", "test");
		#end
		ShaderResizeFix.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame9", "test");
		#end
		Logs.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame10", "test");
		#end
		Paths.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame11", "test");
		#end
		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.init();
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame12", "test");
		#end

		#if (sys && TEST_BUILD)
			#if SHOW_TEST
			NativeAPI.showMessageBox("loadGame13", "test");
			#end
			trace("Used cne test / cne build. Switching into source assets.");
			#if MOD_SUPPORT
				ModsFolder.modsPath = './${pathBack}mods/';
				ModsFolder.addonsPath = './${pathBack}addons/';
			#end
			#if SHOW_TEST
			NativeAPI.showMessageBox("loadGame14", "test");
			#end
			Paths.assetsTree.__defaultLibraries.push(ModsFolder.loadLibraryFromFolder('assets', './${pathBack}assets/', true));
			#if SHOW_TEST
			NativeAPI.showMessageBox("loadGame15", "test");
			#end
		#elseif USE_ADAPTED_ASSETS
			#if SHOW_TEST
			NativeAPI.showMessageBox("loadGame16", "test");
			#end
			Paths.assetsTree.__defaultLibraries.push(ModsFolder.loadLibraryFromFolder('assets', #if mobile MobileUtil.getAssetDirectory() + #end "assets/", true));
			#if SHOW_TEST
			NativeAPI.showMessageBox("loadGame17", "test");
			#end
		#end


		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame18", "test");
		#end
		var lib = new AssetLibrary();
		@:privateAccess
		lib.__proxy = Paths.assetsTree;
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame19", "test");
		#end
		Assets.registerLibrary('default', lib);
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame20", "test");
		#end

		funkin.options.PlayerSettings.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame21", "test");
		#end
		funkin.savedata.FunkinSave.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame22", "test");
		#end
		Options.load();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame23", "test");
		#end

		FlxG.fixedTimestep = false;
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame24", "test");
		#end

		FlxG.scaleMode = scaleMode = new FunkinRatioScaleMode();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame25", "test");
		#end

		Conductor.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame26", "test");
		#end
		AudioSwitchFix.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame27", "test");
		#end
		EventManager.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame28", "test");
		#end
		FlxG.signals.focusGained.add(onFocus);
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame29", "test");
		#end
		FlxG.signals.preStateSwitch.add(onStateSwitch);
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame30", "test");
		#end
		FlxG.signals.postStateSwitch.add(onStateSwitchPost);
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame31", "test");
		#end

		FlxG.mouse.useSystemCursor = true;
		#if DARK_MODE_WINDOW
		if(funkin.backend.utils.NativeAPI.hasVersion("Windows 10")) funkin.backend.utils.NativeAPI.redrawWindowHeader();
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame32", "test");
		#end

		ModsFolder.init();
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame33", "test");
		#end
		#if MOD_SUPPORT
		ModsFolder.switchMod(modToLoad.getDefault(Options.lastLoadedMod));
		#end
		#if SHOW_TEST
		NativeAPI.showMessageBox("loadGame34", "test");
		#end

		initTransition();
	}

	public static function refreshAssets() {
		WindowUtils.resetTitle();

		FlxSoundTray.volumeChangeSFX = Paths.sound('menu/volume');
		FlxSoundTray.volumeUpChangeSFX = null;
		FlxSoundTray.volumeDownChangeSFX = null;

		if (FlxG.game.soundTray != null)
			FlxG.game.soundTray.text.setTextFormat(new TextFormat(Paths.font("vcr.ttf")));
	}

	public static function initTransition() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.7, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
	}

	public static function onFocus() {
		_tickFocused = FlxG.game.ticks;
	}

	private static function onStateSwitch() {
		scaleMode.resetSize();
	}

	private static function onStateSwitchPost() {
		// manual asset clearing since base openfl one doesnt clear lime one
		// doesnt clear bitmaps since flixel fork does it auto

		@:privateAccess {
			// clear uint8 pools
			for(length=>pool in openfl.display3D.utils.UInt8Buff._pools) {
				for(b in pool.clear())
					b.destroy();
			}
			openfl.display3D.utils.UInt8Buff._pools.clear();
		}

		MemoryUtil.clearMajor();
	}

	private static var _tickFocused:Float = 0;
	public static function get_timeSinceFocus():Float {
		return (FlxG.game.ticks - _tickFocused) / 1000;
	}
}
