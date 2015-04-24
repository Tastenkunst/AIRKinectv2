package com.tastenkunst.airkinectv2.examples {
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.events.Event;

	/**
	 * This example will show the different sizes of
	 * the ColorFrame space and the DepthFrame space.
	 * 
	 * You will see, that the depth image data is much
	 * smaller, than the color image data. Luckily there
	 * is a mapping in the SDK (enable it in init()). 
	 * 
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class KV2ExampleDepthFrame extends KV2Example {
		
		public var _bmColor : Bitmap;
		public var _bmDepth : Bitmap;

		public var _bmDepthFrameMappedToColorSpace : Bitmap;
		
		public function KV2ExampleDepthFrame() {
			super();
		}
		
		/**
		 * Configure your Kinect usage here.
		 * All options are false by default.
		 */
		override public function init() : void {
			trace("KV2ExampleDepthFrame.init");

			// We will need to enable ColorFrame and DepthFrame
			_kv2Config.enableColorFrame = true;
			_kv2Config.enableDepthFrame = true;
			
			// Enable this to see a mapping of the depth image to
			// the ColorFrame coordinates.
			_kv2Config.enableDepthFrameMappingToColorSpace = false;

			// This will start the Kinect.
			initKinect();
		}
		
		/**
		 * This function is your entry point. The Kinect is up
		 * and runnung. From now on you can call 
		 * 
		 * _kv2Manager.stop() and
		 * _kv2Manager.start(_kv2Config)
		 * 
		 * to pause and resume the device.
		 * 
		 * And you will also have access to the functions and
		 * data structures of the _kv2Manager.
		 */
		override protected function onKinectStarted() : void {
			trace("KV2ExampleDepthFrame.onKinectStarted");

			// Retrieve the BitmapData of the ColorFrame.
			_bmColor = new Bitmap(_kv2Manager.colorFrameBmd, PixelSnapping.AUTO, true);
			_bmDepth = new Bitmap(_kv2Manager.depthFrameBmd, PixelSnapping.AUTO, true);
			
			_bmDepthFrameMappedToColorSpace = new Bitmap(_kv2Manager.depthFrameMappedToColorSpaceBmd, PixelSnapping.AUTO, true);

			// Add DisplayObjects to the stage.
			addChild(_bmColor);
			addChild(_bmDepth);

			addChild(_bmDepthFrameMappedToColorSpace);

//			addChild(_stats);

			// Put all things in the correct place.
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();

			// Start the Kinect updates.
			addEventListener(Event.EXIT_FRAME, onEnterFrame);
		}
		
		/**
		 * This examples will only show the ColorFrame (the HD camera image).
		 */
		override protected function onEnterFrame(event : Event) : void {
			// We already wrapped the resulting BitmapData
			// into the _bmColor. This will get updated
			// automatically in updateImages().
			
			// That's why we don't need to do anything more
			// than calling updateImages.
			
			_kv2Manager.updateImages();
		}
		
		/**
		 * onResize will help us to layout the Bitmaps
		 * according to the size of this app.
		 */
		protected function onResize(event : Event = null) : void {
			trace("KV2ExampleDepthFrame.onResize");
			
			var sw : int = stage.stageWidth;
			var sh : int = stage.stageHeight;
			var scale : Number = 1.0;
			var x : int = 0;
			var y : int = 0;
			var bm : Bitmap;

			// proportional inside (with unfilled borders)

//			scale = sw / 1920;
//			
//			if(scale * 1080 > sh) {
//				scale = sh / 1080;
//			}

			// proportional outside (without any unfilled borders)

			scale = sw / 1920;

			if (scale * 1080 < sh) {
				scale = sh / 1080;
			}

			x = int((sw - 1920 * scale) * 0.5);
			y = int((sh - 1080 * scale) * 0.5);

			bm = _bmColor;

			if (bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = x;
				bm.y = y;
			}
			
			bm = _bmDepth;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = 0;
				bm.y = 0;
			}

			bm = _bmDepthFrameMappedToColorSpace;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = x;
				bm.y = y;
			}
			
			_stats.y = sh - 100;
		}
	}
}
