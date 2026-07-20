package mobile.io;

import openfl.Assets;
#if sys
import sys.FileSystem as SysFileSystem;
import sys.FileStat;
import sys.io.File as SysFile;
import sys.io.FileInput;
import sys.io.FileOutput;
#end
import mobile.io.FileSystem;

using StringTools;

class File
{
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

	public static function getContent(path:String):Null<String>
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = FileSystem.getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		if (SysFileSystem.exists(actualPath))
			return SysFile.getContent(actualPath);
		#end

		if (FileSystem.exists(openflcwd(path)))
			return Assets.getText(openflcwd(path));
		return null;
	}

	public static function getBytes(path:String):Null<haxe.io.Bytes>
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = FileSystem.getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		if (SysFileSystem.exists(actualPath))
			return SysFile.getBytes(actualPath);
		#end

		var flPath = openflcwd(path);
		if (FileSystem.exists(flPath))
		{
			switch (haxe.io.Path.extension(flPath).toLowerCase())
			{
				case 'otf' | 'ttf':
					return openfl.utils.ByteArray.fromFile(flPath);
				default:
					return Assets.getBytes(flPath);
			}
		}
		return null;
	}

	public static function saveContent(path:String, content:String):Void
	{
		#if sys SysFile.saveContent(cwd(path), content); #end
	}

	public static function saveBytes(path:String, bytes:haxe.io.Bytes):Void
	{
		#if sys SysFile.saveBytes(cwd(path), bytes); #end
	}

	public static function read(path:String, binary:Bool = true):Null< #if sys FileInput #else Dynamic #end>
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = FileSystem.getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		return SysFile.read(actualPath, binary);
		#else
		return null;
		#end
	}

	public static function write(path:String, binary:Bool = true):Null< #if sys FileOutput #else Dynamic #end>
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = FileSystem.getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		return SysFile.write(actualPath, binary);
		#else
		return null;
		#end
	}

	public static function append(path:String, binary:Bool = true):Null< #if sys FileOutput #else Dynamic #end>
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = FileSystem.getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		return SysFile.append(actualPath, binary);
		#else
		return null;
		#end
	}

	public static function update(path:String, binary:Bool = true):Null< #if sys FileOutput #else Dynamic #end>
	{
		#if sys
		var actualPath = cwd(path);
		#if linux
		var cp = FileSystem.getCaseInsensitivePath(path);
		if (cp != null)
			actualPath = cp;
		#end
		return SysFile.update(actualPath, binary);
		#else
		return null;
		#end
	}

	public static function copy(srcPath:String, dstPath:String):Void
	{
		#if sys
		var actualSrc = cwd(srcPath);
		#if linux
		var cp = FileSystem.getCaseInsensitivePath(actualSrc);
		if (cp != null)
			actualSrc = cp;
		#end
		SysFile.copy(actualSrc, cwd(dstPath));
		#end
	}
}
