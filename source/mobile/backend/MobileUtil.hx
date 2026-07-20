package mobile.backend;

import lime.system.System as LimeSystem;
import haxe.io.Path;
import haxe.Exception;

import lime.system.System;
import lime.app.Application;
import openfl.Assets;
import haxe.io.Bytes;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

using StringTools;

/** 
* @Authors MaysLastPlay, ArkoseLabs, MarioMaster (MasterX-39), Dechis (dx7405)
* @version: 0.4.0
**/
typedef CustomStorageModeData = { modes:Array<ModeData> }
typedef ModeData = { Name:String, Folder:String }
class MobileUtil
{
	#if sys
	public static inline function getAssetDirectory():String
		return #if android haxe.io.Path.addTrailingSlash("/sdcard/Android/data/com.yoshman29.codenameengine/files") #elseif ios lime.system.System.documentsDirectory #else Sys.getCwd() #end;

	#if android
	public static inline function getCustomStoragePath():String
		return AndroidContext.getExternalFilesDir() + '/storageModes.json';
	public static inline function getStorageTypePath():String
		return AndroidContext.getExternalFilesDir() + '/storagetype.txt';

	public static function getCustomStorageDirectories(?doNotSeperate:Bool):Array<String>
	{
		var curJsonFile:String = getCustomStoragePath();
		var ArrayReturn:Array<String> = [];

		if (FileSystem.exists(curJsonFile))
		{
			try {
				var rawJson:String = File.getContent(curJsonFile);
				var parsedData:CustomStorageModeData = haxe.Json.parse(rawJson);

				if (parsedData.modes != null) {
					for (mode in parsedData.modes) {
						if (mode.Name == null || mode.Folder == null) continue;

						if (doNotSeperate)
							// Keeping the "Name|Folder" format, so initDirectory() doesn't break
							ArrayReturn.push(mode.Name + "|" + mode.Folder);
						else
							ArrayReturn.push(mode.Name);
					}
				}
			} catch (e:haxe.Exception) {
				trace("Error parsing storage JSON: " + e.message);
			}
		}
		return ArrayReturn;
	}

	// always force path due to haxe
	public static var currentDirectory:String;
	public static function initDirectory():String {
		var daPath:String = '';
		if (!FileSystem.exists(getStorageTypePath()))
			File.saveContent(getStorageTypePath(), Options.storageType);

		var curStorageType:String = File.getContent(getStorageTypePath());

		/* Put this there because I don't want to override original paths, also brokes the normal storage system */
		for (line in getCustomStorageDirectories(true))
		{
			if (line.startsWith(curStorageType) && (line != '' || line != null)) {
				var dat = line.split("|");
				daPath = dat[1];
			}
		}

		/* Hardcoded Storage Types, these types cannot be changed by Custom Type
		 * paths using "/sdcard/" location because otherwise engine crashes. -ArkoseLabs
		 **/
		switch(curStorageType) {
			case 'EXTERNAL':
				daPath = "/sdcard/.CodenameEngine";
			/* obb doesnt work and I dont wanna fix it -ArkoseLabs
			case 'EXTERNAL_OBB':
				daPath = "/sdcard/Android/obb/com.yoshman29.codenameengine";
			*/
			case 'EXTERNAL_MEDIA':
				daPath = "/sdcard/Android/media/com.yoshman29.codenameengine";
			case 'EXTERNAL_DATA':
				daPath = "/sdcard/Android/data/com.yoshman29.codenameengine/files";
			default: //technically not needed but here for safety -ArkoseLabs
				if (daPath == null || daPath == '') daPath = "/sdcard/Android/data/com.yoshman29.codenameengine/files";
		}
		daPath = Path.addTrailingSlash(daPath);
		currentDirectory = daPath;

		try
		{
			if (!FileSystem.exists(MobileUtil.getAssetDirectory()))
				FileSystem.createDirectory(MobileUtil.getAssetDirectory());
		}
		catch (e:Dynamic)
		{
			Application.current.window.alert("Looks like you doesn't have directory named\n" + MobileUtil.getAssetDirectory() +
			"\nBut maybe this couldn't be right, android loves to give errors like this\nPress OK & let's see what happens\nCurrent Error You Got:\n" + e, "Warning!");
			//lime.system.System.exit(1);
		}

		try
		{
			if (!FileSystem.exists(MobileUtil.getDirectory() + "mods/"))
				FileSystem.createDirectory(MobileUtil.getDirectory() + "mods/");
		}
		catch (e:Dynamic)
		{
			Application.current.window.alert("Looks like you doesn't have directory named\n" + MobileUtil.getDirectory() + "mods/" + 
			"\nBut maybe this couldn't be right, android loves to give errors like this\nPress OK & let's see what happens\nCurrent Error You Got:\n" + e, "Warning!");
			//lime.system.System.exit(1);
		}

		return daPath;
	}

	/**
	 * Requests Storage Permissions on Android Platform.
	 */
	public static function getPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			AndroidPermissions.requestPermissions([
				'READ_MEDIA_IMAGES',
				'READ_MEDIA_VIDEO',
				'READ_MEDIA_AUDIO',
				'READ_MEDIA_VISUAL_USER_SELECTED'
			]);
		else
			AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

		if (!AndroidEnvironment.isExternalStorageManager())
			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
	}

	public static var lastGettedPermission:Int;
	public static function chmodPermission(fullPath:String) {
		var process = new Process('stat -c %a ${fullPath}');
		var stringOutput:String = process.stdout.readAll().toString();
		process.close();
		lastGettedPermission = Std.parseInt(stringOutput);
	}

	public static function chmod(permissions:Int, fullPath:String) {
		var process = new Process('chmod -R ${permissions} ${fullPath}');

		var exitCode = process.exitCode();
		if (exitCode == 0) 
			trace('Success: Permissions for the ${fullPath} file have been set to (${permissions})');
		else
		{
			var errorOutput = process.stderr.readAll().toString();
			trace('ERROR: Request to change permissions for the (${fullPath}) file failed. Exit Code: ${exitCode}, Error: ${errorOutput}');
		}
		process.close();
	}
	#end

	public static function getDirectory():String
	{
		#if android	
		var _currentDirectory = currentDirectory;
		if (_currentDirectory == null || _currentDirectory == "") {
    	    trace("currentDirectory is null, initializing again...");
    	    _currentDirectory = initDirectory(); 
    	}
		return _currentDirectory;
		#elseif ios
		return LimeSystem.documentsDirectory;
		#else
		return Sys.getCwd();
		#end
	}

	/**
	 * Saves a file to the external storage.
	 */
	public static function save(fileName:String = 'Ye', fileExt:String = '.txt', fileData:String = 'Nice try, but you failed, try again!', ?alert:Bool = true):Void
	{
		final folder:String = #if android MobileUtil.getDirectory() + #else Sys.getCwd() + #end 'saves/';
		try
		{
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			File.saveContent('$folder/$fileName', fileData);
			if (alert)
				Application.current.window.alert('${fileName} has been saved.', "Success!");
		}
		catch (e:Dynamic)
			if (alert)
				Application.current.window.alert('${fileName} couldn\'t be saved.\n${e.message}', "Error!");
			else
				trace('$fileName couldn\'t be saved. (${e.message})');
	}
	#end

	/**
	 * @param folders Optional list of specific folders (e.g. ["assets/data/"]). If null, copies all assets.
	 */
	public static function copyAssets(folders:Array<String> = null, onProgress:String->Int->Int->Void = null, onComplete:Void->Void = null):Void {
		#if mobile
		var rootTarget = getAssetDirectory();
		try {
			var assetList:Array<String> = Assets.list();

			var toCopy = assetList.filter(function(assetKey) {
				var cleanPath = assetKey;
				var colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) {
					cleanPath = cleanPath.substring(colonIndex + 1);
				}

				if (!StringTools.startsWith(cleanPath, "assets/")) return false;
				if (folders == null) return true;

				for (f in folders) {
					if (StringTools.startsWith(cleanPath, f)) return true;
				}
				return false;
			});

			var total = toCopy.length;
			if (total == 0) {
				if (onComplete != null) onComplete();
				return;
			}

			for (i in 0...total) {
				var assetKey = toCopy[i];

				var cleanPath = assetKey;
				var colonIndex = cleanPath.indexOf(":");
				if (colonIndex != -1) {
					cleanPath = cleanPath.substring(colonIndex + 1);
				}

				var fullPath = Path.join([rootTarget, cleanPath]);

				var directory = Path.directory(fullPath);
				if (!FileSystem.exists(directory)) FileSystem.createDirectory(directory);
				var shouldCopy = !FileSystem.exists(fullPath);

				if (!shouldCopy) {
					try {
						var assetBytes = Assets.getBytes(assetKey);
						var localBytes = File.getBytes(fullPath);
						
						if (localBytes != null && assetBytes != null) {
							if (localBytes.length != assetBytes.length) {
								shouldCopy = true;
							} else {
								for (j in 0...localBytes.length) {
									if (localBytes.get(j) != assetBytes[j]) {
										shouldCopy = true;
										break;
									}
								}
							}
						}
					} catch (e:Dynamic) {
						shouldCopy = true;
					}
				}

				if (shouldCopy) {
					var bytes:Bytes = null;
					try {
						bytes = Assets.getBytes(assetKey);
					} catch (e:Dynamic) {
						try {
							var text:String = Assets.getText(assetKey);
							if (text != null) {
								bytes = Bytes.ofString(text);
							}
						} catch (e2:Dynamic) {
							trace('Failed to read text fallback for $assetKey: $e2');
						}
					}

					if (bytes != null) {
						File.saveBytes(fullPath, bytes);
					} else {
						trace('Could not extract data for asset: $assetKey');
					}
				}

				if (onProgress != null) onProgress(cleanPath, i + 1, total);
			}

			if (onComplete != null) onComplete();
		} catch (e:Dynamic) {
			trace('Asset Copy Error: $e');
		}
		#end
	}
}