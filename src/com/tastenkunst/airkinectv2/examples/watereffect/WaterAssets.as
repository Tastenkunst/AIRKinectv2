package com.tastenkunst.airkinectv2.examples.watereffect {
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;

	/**
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class WaterAssets extends Sprite {
		
		[Embed(source="water.jpg")]
		private var WATER : Class;
		
		public var _bgWater : Bitmap;
		
		public function WaterAssets() {
			_bgWater = new Bitmap(((new WATER()) as Bitmap).bitmapData, PixelSnapping.AUTO, true);
			addChild(_bgWater);
		}
	}
}
