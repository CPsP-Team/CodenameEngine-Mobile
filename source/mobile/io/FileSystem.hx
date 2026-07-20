package mobile.io;

import openfl.Assets;
import openfl.display.BitmapData;
#if sys
import sys.FileSystem as SysFileSystem;
import sys.FileStat;
#end

using StringTools;

class FileSystem
{
	private static var _assetMap:Map<String, Bool> = null;
	private static var _dirMap:Map<String, Array<String>> = null;

	inline static function cwd(path:String):String
		return path;

	static function openflcwd(path:String):String
	{
		@:privateAccess
		for (library in lime.utils.Assets.libraries.keys())
			if (Assets.exists('$library:$path') && !path.startsWith('$library:'))
				return '$library:$path';
		return path;
	}

	static function initAssetCache()
	{
		if (_assetMap != null)
			return;
		_assetMap = new Map();
		_dirMap = new Map();

		var assetList = Assets.list();
		if (assetList == null) return;

		for (asset in assetList)
		{
			_assetMap.set(asset, true);
			var parts = asset.split("/");
			var current = "";
			
			for (i in 0...parts.length - 1)
			{
				var folder = current == "" ? parts[i] + "/" : current + parts[i] + "/";
				
				try {
					if (SysFileSystem.exists(folder) && SysFileSystem.isDirectory(folder)) {
						var nextFile = parts[i + 1];
						if (!_dirMap.exists(folder))
							_dirMap.set(folder, []);
						var arr = _dirMap.get(folder);
						if (!arr.contains(nextFile))
							arr.push(nextFile);
						current = folder;
					}
				} catch (e:Dynamic) {
					continue;
				}
			}
		}
	}

	public static function exists(path:String):Bool
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		if (SysFileSystem.exists(actualPath))
			return true;
		#end
		initAssetCache();
		return _assetMap.exists(openflcwd(path)) || _assetMap.exists(path);
	}

	public static function rename(path:String, newPath:String):Void
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		if (SysFileSystem.exists(actualPath))
			SysFileSystem.rename(actualPath, cwd(newPath));
		#end
	}

	public static function stat(path:String):Null< #if sys FileStat #else Dynamic #end>
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		return SysFileSystem.stat(actualPath);
		#else
		return null;
		#end
	}

	public static function fullPath(path:String):String
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		return SysFileSystem.fullPath(actualPath);
		#else
		return path;
		#end
	}

	public static function getBitmapData(path:String):BitmapData
	{
		#if sys
		var actualPath:String = cwd(path);
		#if linux
		var casePath = getCaseInsensitivePath(path);
		if (casePath != null)
			actualPath = casePath;
		#end
		if (SysFileSystem.exists(actualPath) && !SysFileSystem.isDirectory(actualPath))
			return BitmapData.fromFile(actualPath);
		#end
		var assetPath = openflcwd(path);
		if (exists(assetPath))
			return Assets.getBitmapData(assetPath);
		return null;
	}

	public static function absolutePath(path:String):String
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		return SysFileSystem.absolutePath(actualPath);
		#else
		return path;
		#end
	}

	public static function isDirectory(path:String):Bool
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		if (SysFileSystem.isDirectory(actualPath))
			return true;
		#end
		initAssetCache();
		return _dirMap.exists(path.endsWith("/") ? path : path + "/");
	}

	public static function createDirectory(path:String):Void
	{
		#if sys
		if (!SysFileSystem.exists(cwd(path)))
			SysFileSystem.createDirectory(cwd(path));
		#end
	}

	public static function deleteFile(path:String):Void
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		if (SysFileSystem.exists(actualPath))
			SysFileSystem.deleteFile(actualPath);
		#end
	}

	public static function deleteDirectory(path:String):Void
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		if (SysFileSystem.exists(actualPath))
			SysFileSystem.deleteDirectory(actualPath);
		#end
	}

	public static function readDirectory(path:String):Array<String>
	{
		var results:Array<String> = [];
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		if (SysFileSystem.exists(actualPath) && SysFileSystem.isDirectory(actualPath))
		{
			results = SysFileSystem.readDirectory(actualPath);
		}
		#end

		initAssetCache();
		var normalizedPath = path.endsWith("/") ? path : path + "/";
		if (_dirMap.exists(normalizedPath))
		{
			for (item in _dirMap.get(normalizedPath))
			{
				if (!results.contains(item))
					results.push(item);
			}
		}
		return results;
	}

	#if (linux && sys)
	public static function getCaseInsensitivePath(path:String):String
	{
		if (SysFileSystem.exists(path))
			return path;
		var parts = path.split("/");
		var current = path.charAt(0) == "/" ? "/" : Sys.getCwd();
		for (part in parts)
		{
			if (part == "")
				continue;
			if (!SysFileSystem.exists(current) || !SysFileSystem.isDirectory(current))
				return null;
			var files = SysFileSystem.readDirectory(current);
			var found = false;
			for (f in files)
			{
				if (f.toLowerCase() == part.toLowerCase())
				{
					current += (current == "/" ? "" : "/") + f;
					found = true;
					break;
				}
			}
			if (!found)
				return null;
		}
		return current;
	}
	#end
}
