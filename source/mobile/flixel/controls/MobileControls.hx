package mobile.flixel.controls;

#if flixel
class MobileControls extends FlxSpriteGroup {
	private var controls:Array<InputHandler> = [];

	public static var instance:MobileControls;

	public var buttons:Array<Button> = [];
	public var dpads:Array<DPad> = [];
	public var joysticks:Array<Joystick> = [];
	public var hitboxes:Array<Hitbox> = [];

	public var curDPadMode:String;
	public var curActionMode:String;

	public function new() {
		super();
		instance = this;
	}

	public function getHitboxFromName(n:String) {
		for (b in hitboxes)
			if (b != null && b.jsonName == n)
				return b;
		return null;
	}

	public function getDPadFromName(n:String) {
		for (b in dpads)
			if (b != null && b.jsonName == n)
				return b;
		return null;
	}

	public function getJoyStickFromName(n:String) {
		for (b in joysticks)
			if (b != null && b.jsonName == n)
				return b;
		return null;
	}

	public function getButtonFromName(n:String) {
		for (b in buttons)
			if (b != null && b.jsonName == n)
				return b;
		return null;
	}

	public function addButtonCamera() {
		var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false);
		cam.zoom = 1;
		for (btn in buttons) {
			btn.cameras = [cam];
			btn.camera = cam;
		}
	}

	public function addDPadCamera() {
		var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false);
		cam.zoom = 1;
		for (btn in dpads) {
			btn.cameras = [cam];
			btn.camera = cam;
		}
	}

	public function addJoyStickCamera() {
		var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false);
		cam.zoom = 1;
		for (btn in joysticks) {
			btn.cameras = [cam];
			btn.camera = cam;
		}
	}

	public function addHitboxCamera() {
		var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false);
		cam.zoom = 1;
		for (btn in hitboxes) {
			btn.cameras = [cam];
			btn.camera = cam;
		}
	}

	public function addCamera() {
		var cam = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false);
		cam.zoom = 1;
		cameras = [cam];
	}

	private function loadJson(n:String, mod:String, reg:String):ControlsJsonDef {
		var p = FileSystem.exists(mod + n + ".json") ? mod + n + ".json" : reg + n + ".json";
		var r = File.getContent(p);
		return r != null ? Json.parse(r) : null;
	}

	public function addButton(name:String) {
		if (buttons.length > 0)
			removeButton();
		var p = loadJson(name, Config.MODDED_BUTTON_JSON, Config.BUTTON_JSON);
		if (p != null && p.buttons != null)
			for (d in p.buttons) {
				var b = new Button(d);
				addControl(b);
				buttons.push(b);
			}
		curActionMode = name;
	}

	public function addDPad(name:String) {
		if (dpads.length > 0)
			removeDPad();
		var p = loadJson(name, Config.MODDED_DPAD_JSON, Config.DPAD_JSON);
		if (p != null && p.dpads != null)
			for (d in p.dpads) {
				var b = new DPad(d);
				addControl(b);
				dpads.push(b);
			}
		curDPadMode = name;
	}

	public function addJoyStick(name:String) {
		if (joysticks.length > 0)
			removeJoyStick();
		var p = loadJson(name, Config.MODDED_JOYSTICK_JSON, Config.JOYSTICK_JSON);
		if (p != null && p.joysticks != null)
			for (d in p.joysticks) {
				var b = new Joystick(d);
				addControl(b);
				joysticks.push(b);
			}
	}

	public function addHitbox(name:String) {
		if (hitboxes.length > 0)
			removeHitbox();
		var p = loadJson(name, Config.MODDED_HITBOX_JSON, Config.HITBOX_JSON);
		if (p != null && p.hitboxes != null)
			for (d in p.hitboxes) {
				var b = new Hitbox(d);
				addControl(b);
				hitboxes.push(b);
			}
	}

	private function addControl(c:InputHandler) {
		controls.push(c);
		add(c);
	}

	public function removeButton() {
		for (b in buttons) {
			controls.remove(b);
			remove(b, true);
		}
		buttons = [];
	}

	public function removeDPad() {
		for (b in dpads) {
			controls.remove(b);
			remove(b, true);
		}
		dpads = [];
	}

	public function removeJoyStick() {
		for (b in joysticks) {
			controls.remove(b);
			remove(b, true);
		}
		joysticks = [];
	}

	public function removeHitbox() {
		for (b in hitboxes) {
			controls.remove(b);
			remove(b, true);
		}
		hitboxes = [];
	}

	public function clearControls() {
		removeButton();
		removeDPad();
		removeJoyStick();
		removeHitbox();
		resetAllInputs();
	}

	public function checkState(id:String, state:String = "pressed"):Bool {
		var isAny = (id == "any" || id == null);
		for (c in controls) {
			if (c == null || c.disabled)
				continue;
			if (isAny) {
				switch (state.toLowerCase()) {
					case "pressed":
						if (c.activeIDs.length > 0)
							return true;
					case "justpressed":
						for (a in c.activeIDs)
							if (!c.lastActiveIDs.contains(a))
								return true;
					case "justreleased":
						for (l in c.lastActiveIDs)
							if (!c.activeIDs.contains(l))
								return true;
					case "released":
						if (c.activeIDs.length == 0)
							return true;
				}
			} else {
				switch (state.toLowerCase()) {
					case "pressed":
						if (c.pressed(id))
							return true;
					case "justpressed":
						if (c.justPressed(id))
							return true;
					case "justreleased":
						if (c.justReleased(id))
							return true;
					case "released":
						if (c.released(id))
							return true;
				}
			}
		}
		return false;
	}

	public function resetAllInputs() {
		for (c in controls)
			if (c != null)
				c.resetInputs();
	}
}
#end
