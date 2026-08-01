package mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.input.touch.FlxTouch;
import flixel.system.scaleModes.BaseScaleMode;
#if android
import lime.system.JNI;
#end

class ScreenUtil
{
	public static var swipe(default, never):SwipeUtil = new SwipeUtil();
	public static var touch(default, never):TouchUtil = new TouchUtil();
	public static var wideScreen(default, never):WideScreenMode = new WideScreenMode();
	#if android
	public static var jni(default, never):AndroidJNI = new AndroidJNI();

	public static inline function setOrientation(width:Int, height:Int, resizeable:Bool, hint:String):Dynamic
		return jni.setOrientation_jni(width, height, resizeable, hint);

	public static inline function getCurrentOrientationAsString():String
	{
		return switch (jni.getCurrentOrientation_jni())
		{
			case 1: "LandscapeRight"; //SDL_ORIENTATION_LANDSCAPE
			case 2: "LandscapeLeft"; //SDL_ORIENTATION_LANDSCAPE_FLIPPED
			case 3: "Portrait"; //SDL_ORIENTATION_PORTRAIT
			case 4: "PortraitUpsideDown"; //SDL_ORIENTATION_PORTRAIT_FLIPPED
			default: "Unknown";
		}
	}

	public static inline function isScreenKeyboardShown():Dynamic
		return jni.isScreenKeyboardShown_jni();

	public static inline function clipboardHasText():Dynamic
		return jni.clipboardHasText_jni();

	public static inline function clipboardGetText():Dynamic
		return jni.clipboardGetText_jni();

	public static inline function clipboardSetText(string:String):Dynamic
		return jni.clipboardSetText_jni(string);

	public static inline function manualBackButton():Dynamic
		return jni.manualBackButton_jni();

	public static inline function setActivityTitle(title:String):Dynamic
		return jni.setActivityTitle_jni(title);
	#end
}

class WideScreenMode extends BaseScaleMode
{
	public var enabled(default, set):Bool = false;
	public static var _enabled:Bool = false;

	override function updateGameSize(Width:Int, Height:Int):Void
	{
		if(_enabled)
		{
			super.updateGameSize(Width, Height);
		}
		else
		{
			var ratio:Float = FlxG.width / FlxG.height;
			var realRatio:Float = Width / Height;
	
			var scaleY:Bool = realRatio < ratio;
	
			if (scaleY)
			{
				gameSize.x = Width;
				gameSize.y = Math.floor(gameSize.x / ratio);
			}
			else
			{
				gameSize.y = Height;
				gameSize.x = Math.floor(gameSize.y * ratio);
			}
		}
	}

	override function updateGamePosition():Void
	{
		if(_enabled)
			FlxG.game.x = FlxG.game.y = 0;
		else
			super.updateGamePosition();
	}

	@:noCompletion
	private function set_enabled(value:Bool):Bool
	{
		enabled = value;
		_enabled = value;
		FlxG.scaleMode = new WideScreenMode();
		return value;
	}
}


#if android
class AndroidJNI #if (lime >= "8.0.0") implements JNISafety #end
{
	public function new() {}

	@:noCompletion public var setOrientation_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'setOrientation',
		'(IIZLjava/lang/String;)V');
	@:noCompletion public var getCurrentOrientation_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'getCurrentOrientation', '()I');
	@:noCompletion public var isScreenKeyboardShown_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'isScreenKeyboardShown', '()Z');
	@:noCompletion public var clipboardHasText_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'clipboardHasText', '()Z');
	@:noCompletion public var clipboardGetText_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'clipboardGetText',
		'()Ljava/lang/String;');
	@:noCompletion public var clipboardSetText_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'clipboardSetText',
		'(Ljava/lang/String;)V');
	@:noCompletion public var manualBackButton_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'manualBackButton', '()V');
	@:noCompletion public var setActivityTitle_jni:Dynamic = JNI.createStaticMethod('org/libsdl/app/SDLActivity', 'setActivityTitle',
		'(Ljava/lang/String;)Z');
}
#end

class TouchUtil {
    public function new() {}

    public var pressed(get, never):Bool;
    public var justPressed(get, never):Bool;
    public var justReleased(get, never):Bool;
    public var released(get, never):Bool;
    public var instance(get, never):FlxTouch;

    public var deltaScreenX(get, never):Float;
    public var deltaScreenY(get, never):Float;
    public var pinchDelta(get, never):Float;
    public var wheel(get, never):Int;
    public var activeTouchesCount(get, never):Int;

    private var _lastScreenX:Map<Int, Float> = new Map();
    private var _lastScreenY:Map<Int, Float> = new Map();
    private var _lastPinchDistance:Float = -1;
    private var _lastTwoFingerCenterY:Float = -1;
    private var _signalsHooked:Bool = false;

    private function checkSignals():Void {
        if (!_signalsHooked && FlxG.signals != null) {
            FlxG.signals.postUpdate.add(onPostUpdate);
            _signalsHooked = true;
        }
    }

    private function onPostUpdate():Void {
        _lastScreenX.clear();
        _lastScreenY.clear();
        
        var activeTouches = [];
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                activeTouches.push(touch);
                #if (flixel < "5.9.0")
                _lastScreenX.set(touch.touchPointID, touch.screenX);
                _lastScreenY.set(touch.touchPointID, touch.screenY);
                #else
                _lastScreenX.set(touch.touchPointID, touch.viewX);
                _lastScreenY.set(touch.touchPointID, touch.viewY);
                #end
            }
        }

        if (activeTouches.length >= 2) {
            #if (flixel < "5.9.0")
            var dx = activeTouches[0].screenX - activeTouches[1].screenX;
            var dy = activeTouches[0].screenY - activeTouches[1].screenY;
            _lastTwoFingerCenterY = (activeTouches[0].screenY + activeTouches[1].screenY) / 2;
            #else
            var dx = activeTouches[0].viewX - activeTouches[1].viewX;
            var dy = activeTouches[0].viewY - activeTouches[1].viewY;
            _lastTwoFingerCenterY = (activeTouches[0].viewY + activeTouches[1].viewY) / 2;
            #end
            _lastPinchDistance = Math.sqrt(dx * dx + dy * dy);
        } else {
            _lastPinchDistance = -1;
            _lastTwoFingerCenterY = -1;
        }
    }

    @:noCompletion
    private function get_activeTouchesCount():Int {
        var count = 0;
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) count++;
        }
        return count;
    }

    @:noCompletion
    private function get_pinchDelta():Float {
        checkSignals();
        var activeTouches = [];
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) activeTouches.push(touch);
        }

        if (activeTouches.length >= 2 && _lastPinchDistance != -1) {
            #if (flixel < "5.9.0")
            var dx = activeTouches[0].screenX - activeTouches[1].screenX;
            var dy = activeTouches[0].screenY - activeTouches[1].screenY;
            #else
            var dx = activeTouches[0].viewX - activeTouches[1].viewX;
            var dy = activeTouches[0].viewY - activeTouches[1].viewY;
            #end
            var currentDistance = Math.sqrt(dx * dx + dy * dy);
            return currentDistance - _lastPinchDistance;
        }
        return 0;
    }

    @:noCompletion
    private function get_wheel():Int {
        checkSignals();
        var activeTouches = [];
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) activeTouches.push(touch);
        }

        if (activeTouches.length >= 2 && _lastTwoFingerCenterY != -1) {
            #if (flixel < "5.9.0")
            var currentCenterY = (activeTouches[0].screenY + activeTouches[1].screenY) / 2;
            #else
            var currentCenterY = (activeTouches[0].viewY + activeTouches[1].viewY) / 2;
            #end
            return Std.int(_lastTwoFingerCenterY - currentCenterY);
        }
        return 0;
    }

    @:noCompletion
    private function get_deltaScreenX():Float {
        checkSignals();
        var touch = instance;
        if (touch != null && touch.pressed && !touch.justPressed) {
            if (_lastScreenX.exists(touch.touchPointID)) {
                #if (flixel < "5.9.0")
                return touch.screenX - _lastScreenX.get(touch.touchPointID);
                #else
                return touch.viewX - _lastScreenX.get(touch.touchPointID);
                #end
            }
        }
        return 0;
    }

    @:noCompletion
    private function get_deltaScreenY():Float {
        checkSignals();
        var touch = instance;
        if (touch != null && touch.pressed && !touch.justPressed) {
            if (_lastScreenY.exists(touch.touchPointID)) {
                #if (flixel < "5.9.0")
                return touch.screenY - _lastScreenY.get(touch.touchPointID);
                #else
                return touch.viewY - _lastScreenY.get(touch.touchPointID);
                #end
            }
        }
        return 0;
    }

    public function overlaps(object:FlxObject, ?camera:FlxCamera):Bool {
        for (touch in FlxG.touches.list)
            if (touch.overlaps(object, camera ?? object.camera))
                return true;

        return false;
    }

    public function overlapsComplex(object:FlxObject, ?camera:FlxCamera):Bool {
        if (camera == null)
            for (camera in object.cameras)
                for (touch in FlxG.touches.list)
                    @:privateAccess
                    if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
                        return true;
                    else
                        @:privateAccess
                        if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
                            return true;

        return false;
    }

    public function overlapsUltraComplex(spr:FlxSprite, onTouch:Void -> Void) {
        if (instance != null) {
            var sprPos = spr.getScreenPosition(spr.camera);
            #if (flixel < "5.9.0")
            var touchX = instance.screenX;
            var touchY = instance.screenY;
            #else
            var touchX = instance.viewX;
            var touchY = instance.viewY;
            #end
            var overlap:Bool = (touchX >= sprPos.x && touchX <= sprPos.x + spr.frameWidth
            && touchY >= sprPos.y && touchY <= sprPos.y + spr.frameHeight);
            if (overlap && instance.justPressed)
                onTouch();
        }
    }

    @:noCompletion
    private function get_pressed():Bool {
        for (touch in FlxG.touches.list)
            if (touch.pressed) return true;
        return false;
    }

    @:noCompletion
    private function get_justPressed():Bool {
        for (touch in FlxG.touches.list)
            if (touch.justPressed) return true;
        return false;
    }

    @:noCompletion
    private function get_justReleased():Bool {
        for (touch in FlxG.touches.list)
            if (touch.justReleased) return true;
        return false;
    }

    @:noCompletion
    private function get_released():Bool {
        for (touch in FlxG.touches.list)
            if (touch.released) return true;
        return false;
    }

    @:noCompletion
    private function get_instance():FlxTouch {
        checkSignals();
        for (touch in FlxG.touches.list) {
            if (touch != null && (touch.pressed || touch.justReleased)) {
                return touch;
            }
        }
        return null;
    }
}

class SwipeUtil {
	public function new() {}

	@:noCompletion
	public function checkSwipe(minDegree:Float, maxDegree:Float):Bool {
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes) {
			if (swipe != null) {
				var degrees = swipe.degrees;
				if (degrees >= minDegree && degrees <= maxDegree && swipe.distance > 20) {
					return true;
				}
			}
		}
		#end
		return false;
	}

	public var UP(get, never):Bool;

	@:noCompletion
	private function get_UP():Bool {
		return checkSwipe(45, 135);
	}

	public var DOWN(get, never):Bool;

	@:noCompletion
	private function get_DOWN():Bool {
		return checkSwipe(-135, -45);
	}

	public var LEFT(get, never):Bool;

	@:noCompletion
	private function get_LEFT():Bool {
		return checkSwipe(135, 180) || checkSwipe(-180, -135);
	}

	public var RIGHT(get, never):Bool;

	@:noCompletion
	private function get_RIGHT():Bool {
		return checkSwipe(-45, 45);
	}
}