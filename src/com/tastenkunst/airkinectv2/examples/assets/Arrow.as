package com.tastenkunst.airkinectv2.examples.assets {
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.display.Sprite;

	/**
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class Arrow extends Sprite {
		
		private var _currentTimeoutID : uint;

		public function Arrow() {
			init();
			_currentTimeoutID = 0;
		}

		private function init() : void {
			color = 0xffffff;
		}
		
		override public function set visible(v : Boolean) : void {
			super.visible = v;
			
			clearTimeout(_currentTimeoutID);
			_currentTimeoutID = setTimeout(resetVisible, 3000);
		}

		private function resetVisible() : void {
			super.visible = false;
		}

		public function set color(color : uint) : void {
			graphics.clear();
			graphics.beginFill(color, 1.0);
			graphics.lineStyle(5, 0x000000);
			graphics.moveTo(  0,   0);
			graphics.lineTo( 50,  50);
			graphics.lineTo( 25,  50);
			graphics.lineTo( 25, 150);
			graphics.lineTo(-25, 150);
			graphics.lineTo(-25,  50);
			graphics.lineTo(-50,  50);
			graphics.lineTo(  0,   0);
			graphics.endFill();
		}
	}
}
