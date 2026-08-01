package mobile;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormatAlign;
import openfl.events.MouseEvent;
import openfl.events.Event;
import openfl.geom.Point;
import StringTools;
#if sys
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
#end

class DebugMenu extends Sprite
{
	public static var instance:DebugMenu;
	private static var messageBuffer:Array<String> = [];

	public var floatingBtn:Sprite;
	private var menuPanel:Sprite;

	private var bgShape:Shape;
	private var headerShape:Sprite;
	private var titleText:TextField;
	private var closeBtn:Sprite;
	private var resizeHandle:Sprite;
	private var logText:TextField;

	private var scrollTrack:Sprite;
	private var scrollThumb:Sprite;

	private final BASE_WIDTH:Float = 1280;
	private final BASE_HEIGHT:Float = 720;
	private var panelWidth:Float = 900;
	private var panelHeight:Float = 560;
	private final HEADER_HEIGHT:Float = 40;
	private final CORNER_RADIUS:Float = 24;

	private var isDraggingPanel:Bool = false;
	private var isDraggingIcon:Bool = false;
	private var isResizingPanel:Bool = false;
	private var isSwipingText:Bool = false;
	private var isDraggingScroll:Bool = false;

	private var dragOffsetX:Float = 0;
	private var dragOffsetY:Float = 0;
	private var iconStartDragX:Float = 0;
	private var iconStartDragY:Float = 0;
	private var iconHasDragged:Bool = false;
	private var swipeStartStageY:Float = 0;
	private var swipeStartScrollV:Int = 1;

	public function new()
	{
		super();
		instance = this;
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		setupUI();

		stage.addEventListener(Event.RESIZE, onResize);
		onResize(null);

		stage.addEventListener(MouseEvent.MOUSE_MOVE, onGeneralMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onGeneralMouseUp);

		for (htmlMsg in messageBuffer)
		{
			appendHTML(htmlMsg);
		}
		messageBuffer = [];
	}

	private function setupUI():Void
	{
		menuPanel = new Sprite();
		menuPanel.visible = false;
		addChild(menuPanel);

		bgShape = new Shape();
		menuPanel.addChild(bgShape);

		headerShape = new Sprite();
		headerShape.addEventListener(MouseEvent.MOUSE_DOWN, onPanelDragStart);
		menuPanel.addChild(headerShape);

		titleText = new TextField();
		var titleFormat:TextFormat = new TextFormat("_sans", 20, 0xFFFFFF, true);
		titleFormat.align = TextFormatAlign.CENTER;
		titleText.defaultTextFormat = titleFormat;
		titleText.text = "Console";
		titleText.selectable = false;
		titleText.mouseEnabled = false;
		titleText.autoSize = TextFieldAutoSize.CENTER;
		headerShape.addChild(titleText);

		closeBtn = new Sprite();
		closeBtn.buttonMode = true;
		closeBtn.useHandCursor = true;
		closeBtn.graphics.beginFill(0xFF4757, 1);
		closeBtn.graphics.drawCircle(0, 0, 16);
		closeBtn.graphics.endFill();
		closeBtn.graphics.lineStyle(3, 0xFFFFFF, 1, true);
		closeBtn.graphics.moveTo(-8, -8);
		closeBtn.graphics.lineTo(8, 8);
		closeBtn.graphics.moveTo(8, -8);
		closeBtn.graphics.lineTo(-8, 8);
		closeBtn.addEventListener(MouseEvent.CLICK, closeMenu);
		headerShape.addChild(closeBtn);

		logText = new TextField();
		logText.multiline = true;
		logText.wordWrap = true;
		logText.selectable = false;
		var format:TextFormat = new TextFormat("_sans", 18, 0xFFFFFF);
		format.leading = 4;
		logText.defaultTextFormat = format;
		logText.addEventListener(MouseEvent.MOUSE_DOWN, onTextSwipeStart);
		logText.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		menuPanel.addChild(logText);

		scrollTrack = new Sprite();
		menuPanel.addChild(scrollTrack);

		scrollThumb = new Sprite();
		scrollThumb.buttonMode = true;
		scrollThumb.useHandCursor = true;
		scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN, onScrollThumbDown);
		menuPanel.addChild(scrollThumb);

		resizeHandle = new Sprite();
		resizeHandle.buttonMode = true;
		resizeHandle.useHandCursor = true;
		resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, onResizeStart);
		menuPanel.addChild(resizeHandle);

		floatingBtn = new Sprite();
		floatingBtn.buttonMode = true;
		floatingBtn.useHandCursor = true;
		floatingBtn.graphics.beginFill(0x000000, 0.5);
		floatingBtn.graphics.drawCircle(40, 40, 35);
		floatingBtn.graphics.endFill();
		floatingBtn.graphics.lineStyle(4, 0xFFFFFF, 1, true);
		floatingBtn.graphics.moveTo(22, 25);
		floatingBtn.graphics.lineTo(58, 25);
		floatingBtn.graphics.moveTo(22, 40);
		floatingBtn.graphics.lineTo(58, 40);
		floatingBtn.graphics.moveTo(22, 55);
		floatingBtn.graphics.lineTo(58, 55);
		floatingBtn.addEventListener(MouseEvent.MOUSE_DOWN, onIconDown);
		addChild(floatingBtn);

		floatingBtn.x = BASE_WIDTH - 100;
		floatingBtn.y = 40;
		menuPanel.x = (BASE_WIDTH - panelWidth) / 2;
		menuPanel.y = (BASE_HEIGHT - panelHeight) / 2;

		loadLayout();

		updateUILayout();
	}

	private function updateUILayout():Void
	{
		bgShape.graphics.clear();
		bgShape.graphics.beginFill(0x1E1E24, 0.85);
		bgShape.graphics.drawRoundRect(0, 0, panelWidth, panelHeight, CORNER_RADIUS, CORNER_RADIUS);
		bgShape.graphics.endFill();

		headerShape.graphics.clear();
		headerShape.graphics.beginFill(0x2A2A33, 0.95);
		headerShape.graphics.drawRoundRectComplex(0, 0, panelWidth, HEADER_HEIGHT, CORNER_RADIUS, CORNER_RADIUS, 0, 0);
		headerShape.graphics.endFill();

		titleText.x = (panelWidth - titleText.width) / 2;
		titleText.y = (HEADER_HEIGHT - titleText.height) / 2;
		closeBtn.x = panelWidth - 25;
		closeBtn.y = HEADER_HEIGHT / 2;

		var padding:Float = 15;
		var scrollWidth:Float = 15;
		logText.x = padding;
		logText.y = HEADER_HEIGHT + 5;
		logText.width = panelWidth - (padding * 2) - scrollWidth;
		logText.height = panelHeight - HEADER_HEIGHT - padding;

		resizeHandle.graphics.clear();
		resizeHandle.graphics.beginFill(0x000000, 0);
		resizeHandle.graphics.drawRect(-30, -30, 30, 30);
		resizeHandle.graphics.endFill();
		resizeHandle.graphics.lineStyle(3, 0x555560, 1, true);
		resizeHandle.graphics.moveTo(-20, -5);
		resizeHandle.graphics.lineTo(-5, -20);
		resizeHandle.graphics.moveTo(-12, -5);
		resizeHandle.graphics.lineTo(-5, -12);
		resizeHandle.x = panelWidth;
		resizeHandle.y = panelHeight;

		scrollTrack.graphics.clear();
		scrollTrack.graphics.beginFill(0x000000, 0.3);
		scrollTrack.graphics.drawRoundRect(0, 0, 8, logText.height, 8, 8);
		scrollTrack.graphics.endFill();
		scrollTrack.x = panelWidth - padding - 8;
		scrollTrack.y = logText.y;

		updateScrollbar();
	}

	private function updateScrollbar():Void
	{
		var maxV = logText.maxScrollV;
		var totalLines = logText.numLines;
		var visibleLines = totalLines - maxV + 1;
		if (visibleLines < 1)
			visibleLines = 1;

		if (maxV <= 1)
		{
			scrollThumb.visible = false;
			scrollTrack.visible = false;
			return;
		}
		else
		{
			scrollThumb.visible = true;
			scrollTrack.visible = true;
		}

		var trackH = logText.height;
		var thumbH = trackH * (visibleLines / totalLines);
		if (thumbH < 30)
			thumbH = 30;

		scrollThumb.graphics.clear();
		scrollThumb.graphics.beginFill(0x7F8FA6, 1);
		scrollThumb.graphics.drawRoundRect(0, 0, 8, thumbH, 8, 8);
		scrollThumb.graphics.endFill();
		scrollThumb.x = scrollTrack.x;

		var scrollPercent = (logText.scrollV - 1) / (maxV - 1);
		scrollThumb.y = scrollTrack.y + (trackH - thumbH) * scrollPercent;
	}

	private function onResize(e:Event):Void
	{
		if (stage == null)
			return;
		var sX = stage.stageWidth / BASE_WIDTH;
		var sY = stage.stageHeight / BASE_HEIGHT;
		var finalScale = Math.min(sX, sY);
		this.scaleX = this.scaleY = finalScale;
		this.x = (stage.stageWidth - (BASE_WIDTH * finalScale)) / 2;
		this.y = (stage.stageHeight - (BASE_HEIGHT * finalScale)) / 2;
	}

	private function onIconDown(e:MouseEvent):Void
	{
		var localPt = this.globalToLocal(new Point(e.stageX, e.stageY));
		isDraggingIcon = true;
		iconHasDragged = false;
		iconStartDragX = e.stageX;
		iconStartDragY = e.stageY;
		dragOffsetX = floatingBtn.x - localPt.x;
		dragOffsetY = floatingBtn.y - localPt.y;
	}

	private function onPanelDragStart(e:MouseEvent):Void
	{
		if (!menuPanel.visible || e.target == closeBtn)
			return;
		var localPt = this.globalToLocal(new Point(e.stageX, e.stageY));
		isDraggingPanel = true;
		dragOffsetX = menuPanel.x - localPt.x;
		dragOffsetY = menuPanel.y - localPt.y;
	}

	private function onResizeStart(e:MouseEvent):Void
	{
		isResizingPanel = true;
	}

	private function onTextSwipeStart(e:MouseEvent):Void
	{
		isSwipingText = true;
		swipeStartStageY = e.stageY;
		swipeStartScrollV = logText.scrollV;
	}

	private function onScrollThumbDown(e:MouseEvent):Void
	{
		var localPt = this.globalToLocal(new Point(e.stageX, e.stageY));
		isDraggingScroll = true;
		dragOffsetY = scrollThumb.y - localPt.y;
	}

	private function onMouseWheel(e:MouseEvent):Void
	{
		logText.scrollV -= (e.delta > 0 ? 3 : -3);
		updateScrollbar();
	}

	private function onGeneralMouseMove(e:MouseEvent):Void
	{
		var localPt = this.globalToLocal(new Point(e.stageX, e.stageY));

		if (isDraggingIcon)
		{
			var dist = Math.abs(e.stageX - iconStartDragX) + Math.abs(e.stageY - iconStartDragY);
			if (dist > 10)
				iconHasDragged = true;

			floatingBtn.x = localPt.x + dragOffsetX;
			floatingBtn.y = localPt.y + dragOffsetY;
		}
		else if (isDraggingPanel)
		{
			menuPanel.x = localPt.x + dragOffsetX;
			menuPanel.y = localPt.y + dragOffsetY;
		}
		else if (isResizingPanel)
		{
			panelWidth = localPt.x - menuPanel.x;
			panelHeight = localPt.y - menuPanel.y;

			if (panelWidth < 400)
				panelWidth = 400;
			if (panelHeight < 300)
				panelHeight = 300;

			updateUILayout();
		}
		else if (isSwipingText)
		{
			var deltaY = e.stageY - swipeStartStageY;
			var linesToMove:Int = Math.round((deltaY / this.scaleY) / 22);
			logText.scrollV = swipeStartScrollV - linesToMove;
			updateScrollbar();
		}
		else if (isDraggingScroll)
		{
			var trackH = logText.height;
			var thumbH = scrollThumb.height;
			var targetY = localPt.y + dragOffsetY;
			if (targetY < scrollTrack.y)
				targetY = scrollTrack.y;
			if (targetY > scrollTrack.y + trackH - thumbH)
				targetY = scrollTrack.y + trackH - thumbH;

			scrollThumb.y = targetY;
			var scrollPercent = (targetY - scrollTrack.y) / (trackH - thumbH);
			logText.scrollV = Math.round(1 + scrollPercent * (logText.maxScrollV - 1));
		}
	}

	private function onGeneralMouseUp(e:MouseEvent):Void
	{
		if (isDraggingIcon && !iconHasDragged)
		{
			openMenu(null);
		}

		if (isDraggingIcon || isDraggingPanel || isResizingPanel)
		{
			saveLayout();
		}

		isDraggingIcon = false;
		isDraggingPanel = false;
		isResizingPanel = false;
		isSwipingText = false;
		isDraggingScroll = false;
	}

	private function openMenu(e:MouseEvent):Void
	{
		floatingBtn.visible = false;
		menuPanel.visible = true;
		updateScrollbar();
	}

	public function closeMenu(?e:MouseEvent):Void
	{
		floatingBtn.visible = true;
		menuPanel.visible = false;
	}

	private function getSavePath():String
	{
		#if android
		return AndroidContext.getExternalFilesDir() + "/debugMenuPrefs.json";
		#else
		return "debugMenuPrefs.json"; // Fallback for Windows/Mac/iOS
		#end
	}

	private function saveLayout():Void
	{
		#if sys
		var layoutData = {
			iconX: floatingBtn.x,
			iconY: floatingBtn.y,
			panelX: menuPanel.x,
			panelY: menuPanel.y,
			pWidth: panelWidth,
			pHeight: panelHeight
		};

		try
		{
			File.saveContent(getSavePath(), Json.stringify(layoutData));
		}
		catch (e:Dynamic)
		{
			trace("Failed to save DebugMenu layout: " + e);
		}
		#end
	}

	private function loadLayout():Void
	{
		#if sys
		try
		{
			var path = getSavePath();
			if (FileSystem.exists(path))
			{
				var content = File.getContent(path);
				var data = Json.parse(content);

				if (data.pWidth != null)
					panelWidth = data.pWidth;
				if (data.pHeight != null)
					panelHeight = data.pHeight;

				if (data.iconX != null)
					floatingBtn.x = data.iconX;
				if (data.iconY != null)
					floatingBtn.y = data.iconY;
				if (data.panelX != null)
					menuPanel.x = data.panelX;
				if (data.panelY != null)
					menuPanel.y = data.panelY;
			}
		}
		catch (e:Dynamic)
		{
			trace("Failed to load DebugMenu layout: " + e);
		}
		#end
	}

	private function appendHTML(htmlLine:String):Void
	{
		logText.htmlText += htmlLine + "<br>";
		logText.scrollV = logText.maxScrollV;
		updateScrollbar();
	}

	/** Keep for backwards compatibility if you just want to throw raw text in */
	public static function addTextToDebug(text:String, color:Int = 0xFFFFFF):Void
	{
		var colorHex:String = StringTools.hex(color, 6);
		addHTMLLineToDebug("<font color='#" + colorHex + "'>" + StringTools.htmlEscape(text) + "</font>");
	}

	/** NEW: Takes a pre-formatted HTML string and adds it as ONE line */
	public static function addHTMLLineToDebug(htmlString:String):Void
	{
		if (instance != null && instance.logText != null)
		{
			instance.appendHTML(htmlString);
		}
		else
		{
			messageBuffer.push(htmlString);
		}
	}
}
