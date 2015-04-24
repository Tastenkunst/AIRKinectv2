/**
 * stats.as
 * http://github.com/mrdoob/stats.as
 * 
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 * 
 *	addChild( new Stats() );
 *
 **/
package net.hires.debug {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	/**
	 * Slightly different Stats class. It calculates the average value of inputs (red value)
	 */
	public class Stats extends Sprite {	

		protected const WIDTH : uint = 70;
		protected const HEIGHT : uint = 100;

		public var xml : XML;

		protected var text : TextField;
		protected var style : StyleSheet;

		protected var timer : uint;
		protected var fps : uint;
		protected var ms : uint;
		protected var ms_prev : uint;
		protected var mem : Number;
		protected var mem_max : Number;

		protected var graph : BitmapData;
		protected var rectangle : Rectangle;

		protected var fps_graph : uint;
		protected var mem_graph : uint;
		protected var mem_max_graph : uint;

		protected var colors : Colors = new Colors();
		private var _times : Array = new Array();
		private var _avgTime : Number = 0;

		/**
		 * <b>Stats</b> FPS, MS and MEM, all in one.
		 */
		public function Stats() : void {
			
			mem_max = 0;

			xml = <xml><fps>FPS:</fps><ms>MS:</ms><mem>MEM:</mem><memMax>MAX:</memMax></xml>;
		
			style = new StyleSheet();
			style.setStyle('xml', {fontSize:'9px', fontFamily:'_sans', leading:'-2px'});
			style.setStyle('fps', {color: hex2css(colors.fps)});
			style.setStyle('ms', {color: hex2css(colors.ms)});
			style.setStyle('mem', {color: hex2css(colors.mem)});
			style.setStyle('memMax', {color: hex2css(colors.memmax)});
			
			text = new TextField();
			text.width = WIDTH;
			text.height = 50;
			text.styleSheet = style;
			text.condenseWhite = true;
			text.selectable = false;
			text.mouseEnabled = false;
			
			rectangle = new Rectangle(WIDTH - 1, 0, 1, HEIGHT - 50);			
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
			
		}
		
		public function set input(time : Number) : void {
			//filter time < 6, since this means, that face estimation was skipped
			if(time > 5) {
				_times.unshift(time);
				if(_times.length > 10) {
					_times.pop();
				}
				time = 0;
				for(var i : int = 0; i < _times.length; i++) {
					time += _times[i];
				}
				_avgTime = (time / _times.length);
			}
		}
		
		private function init(e : Event) : void {
			graphics.beginFill(colors.bg);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();

			addChild(text);
			
			graph = new BitmapData(WIDTH, HEIGHT - 50, false, colors.bg);
			graphics.beginBitmapFill(graph, new Matrix(1, 0, 0, 1, 0, 50));
			graphics.drawRect(0, 50, WIDTH, HEIGHT - 50);
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, update);
			
		}

		private function destroy(e : Event) : void {
			
			graphics.clear();
			
			while(numChildren > 0)
				removeChildAt(0);			
			
			graph.dispose();
			
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(Event.ENTER_FRAME, update);
			
		}

		private function update(e : Event) : void {
			
			timer = getTimer();
//			
//			if(mem_max != _input) {
//				mem_max = input;
//				xml.memMax = "Time: " + mem_max;
//				mem_max_graph = Math.min(graph.height, Math.sqrt(Math.sqrt(mem_max * 5000))) - 2;
//				graph.scroll(-1, 0);
//				graph.fillRect(rectangle, colors.bg);
//				graph.setPixel(graph.width - 1, graph.height - mem_max_graph, colors.memmax);
//			}
//			
			if( timer - 1000 > ms_prev ) {
				ms_prev = timer;
				mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				mem_max = _avgTime;//mem_max > mem ? mem_max : mem;
				
				fps_graph = Math.min(graph.height, ( fps * 4 / stage.frameRate ) * graph.height);
				mem_graph = Math.min(graph.height, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
				mem_max_graph = Math.min(graph.height, Math.sqrt(Math.sqrt(mem_max * 5000))) - 2;
				
				graph.scroll(-1, 0);
				
				graph.fillRect(rectangle, colors.bg);
//				graph.setPixel(graph.width - 1, graph.height - fps_graph, colors.fps);
//				graph.setPixel(graph.width - 1, graph.height - ( ( timer - ms ) >> 1 ), colors.ms);
//				graph.setPixel(graph.width - 1, graph.height - mem_graph, colors.mem);
				graph.setPixel(graph.width - 1, graph.height - mem_max_graph, colors.memmax);
				
				xml.fps = "FPS: " + fps + " / " + stage.frameRate; 
				xml.mem = "MEM: " + mem;
				xml.memMax = "update: " + _avgTime.toFixed(1) + " ms";
				fps = 0;				
			}

			fps++;
			
			xml.ms = "MS: " + (timer - ms);
			ms = timer;
			
			text.htmlText = xml;
		}

		private function onClick(e : MouseEvent) : void {
			
			mouseY / height > .5 ? stage.frameRate-- : stage.frameRate++;
			xml.fps = "FPS: " + fps + " / " + stage.frameRate;  
			text.htmlText = xml;
			
		}

		// .. Utils

		private function hex2css( color : int ) : String {
			
			return "#" + color.toString(16);
			
		}
		
	}
	
}

class Colors {

	public var bg : uint = 0x171717;
	public var fps : uint = 0xfff600;
	public var ms : uint = 0x00f600;
	public var mem : uint = 0x00f6ff;
	public var memmax : uint = 0xf60000;

	public function Colors() {
	}

}