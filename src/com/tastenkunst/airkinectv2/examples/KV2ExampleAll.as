package com.tastenkunst.airkinectv2.examples {
	import com.adobe.images.PNGEncoder;
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Code;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import com.tastenkunst.as3.utils.DrawingUtils;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	/**
	 * This is an example for all the image data
	 * and their mappings into other spaces. The more
	 * you enable the lower the performance depending
	 * on your machine.
	 * 
	 * It also includes the BodyFrame (25 skeleton points).
	 * 
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class KV2ExampleAll extends KV2Example {
		
		// All the possible image data.
		
		public var _bmColor : Bitmap;
		public var _bmDepth : Bitmap;
		public var _bmInfrared : Bitmap;
		public var _bmLongExposureInfrared : Bitmap;
		public var _bmBodyIndexFrame : Bitmap;
		
		public var _bmColorFrameMappedToDepthSpace : Bitmap;
		public var _bmDepthFrameMappedToColorSpace : Bitmap;
		public var _bmInfraredFrameMappedToColorSpace : Bitmap;
		public var _bmLongExposureInfraredFrameMappedToColorSpace : Bitmap;
		public var _bmBodyIndexFrameMappedToColorSpace : Bitmap;
		
		// A helper to draw the body joints.
		public var _drawSprite : Sprite;
		public var _draw : Graphics;
		
		// Other helper vars.
		public var _tmpPoint : Point;
		public var _handClosedTracked : int = 0;

		public function KV2ExampleAll() {
			super();
			
			_tmpPoint = new Point();
		}
		
		/**
		 * Configure your Kinect usage here.
		 * All options are false by default.
		 * 
		 * The more you activate, the lower the performance
		 * will be.
		 */
		override public function init() : void {
			trace("KV2ExampleAll.init");
			
			// Enable what you want to see.
			_kv2Config.enableColorFrame = true;
			_kv2Config.enableDepthFrame = true;
			_kv2Config.enableInfraredFrame = false;
			_kv2Config.enableLongExposureInfraredFrame = false;
			_kv2Config.enableBodyIndexFrame = true;
			_kv2Config.enableBodyFrame = true;
			
			_kv2Config.enableColorFrameMappingToDepthSpace = true;
			_kv2Config.enableDepthFrameMappingToColorSpace = false;
			_kv2Config.enableInfraredFrameMappingToColorSpace = false;
			_kv2Config.enableLongExposureInfraredFrameMappingToColorSpace = false;
			_kv2Config.enableBodyIndexFrameMappingToColorSpace = true;
			
			// You can set the color of the 6 body masks here:
//			var color : uint = 0xffff7900;
//			
//			_kv2Config.bodyIndexFrameColors[0] = color;
//			_kv2Config.bodyIndexFrameColors[1] = color;
//			_kv2Config.bodyIndexFrameColors[2] = color;
//			_kv2Config.bodyIndexFrameColors[3] = color;
//			_kv2Config.bodyIndexFrameColors[4] = color;
//			_kv2Config.bodyIndexFrameColors[5] = color;
			
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
			trace("KV2ExampleAll.onKinectStarted");

			_bmColor = new Bitmap(_kv2Manager.colorFrameBmd, PixelSnapping.AUTO, true);
			_bmDepth = new Bitmap(_kv2Manager.depthFrameBmd, PixelSnapping.AUTO, true);
			_bmInfrared = new Bitmap(_kv2Manager.infraredFrameBmd, PixelSnapping.AUTO, true);
			_bmLongExposureInfrared = new Bitmap(_kv2Manager.longExposureInfraredFrameBmd, PixelSnapping.AUTO, true);
			_bmBodyIndexFrame = new Bitmap(_kv2Manager.bodyIndexFrameBmd, PixelSnapping.AUTO, true);
			
			_bmColorFrameMappedToDepthSpace = new Bitmap(_kv2Manager.colorFrameMappedToDepthSpaceBmd, PixelSnapping.AUTO, true);
			_bmDepthFrameMappedToColorSpace = new Bitmap(_kv2Manager.depthFrameMappedToColorSpaceBmd, PixelSnapping.AUTO, true);
			_bmInfraredFrameMappedToColorSpace = new Bitmap(_kv2Manager.infraredFrameMappedToColorSpaceBmd, PixelSnapping.AUTO, true);
			_bmLongExposureInfraredFrameMappedToColorSpace = new Bitmap(_kv2Manager.longExposureInfraredFrameMappedToColorSpaceBmd, PixelSnapping.AUTO, true);
			_bmBodyIndexFrameMappedToColorSpace = new Bitmap(_kv2Manager.bodyIndexFrameMappedToColorSpaceBmd, PixelSnapping.AUTO, true);
			
			_bmColor.visible				= _kv2Config.enableColorFrame;
			_bmDepth.visible				= _kv2Config.enableDepthFrame;
			_bmInfrared.visible				= _kv2Config.enableInfraredFrame;
			_bmLongExposureInfrared.visible	= _kv2Config.enableLongExposureInfraredFrame;
			_bmBodyIndexFrame.visible		= _kv2Config.enableBodyIndexFrame;
			
			_bmColorFrameMappedToDepthSpace.visible		= _kv2Config.enableColorFrameMappingToDepthSpace;
			_bmDepthFrameMappedToColorSpace.visible		= _kv2Config.enableDepthFrameMappingToColorSpace;
			_bmInfraredFrameMappedToColorSpace.visible	= _kv2Config.enableInfraredFrameMappingToColorSpace;
			_bmLongExposureInfraredFrameMappedToColorSpace.visible = _kv2Config.enableLongExposureInfraredFrameMappingToColorSpace;
			_bmBodyIndexFrameMappedToColorSpace.visible = _kv2Config.enableBodyIndexFrameMappingToColorSpace;
			
			addChild(_bmColor);
			addChild(_bmBodyIndexFrameMappedToColorSpace);
			addChild(_bmDepth);
			addChild(_bmInfrared);
			addChild(_bmLongExposureInfrared);
			addChild(_bmBodyIndexFrame);
			
			addChild(_bmColorFrameMappedToDepthSpace);
			addChild(_bmDepthFrameMappedToColorSpace);
			addChild(_bmInfraredFrameMappedToColorSpace);
			addChild(_bmLongExposureInfraredFrameMappedToColorSpace);

			addChild(_stats);
				
			_drawSprite = new Sprite();
			_draw = _drawSprite.graphics;
			
			addChild(_drawSprite);
						
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
			
			var code : int;
			
			code = _kv2Manager.updateImages();
			
			if(code == KV2Code.FAIL) {
				//trace("_kv2Manager.updateImages() failed");
			}
			
			code = _kv2Manager.updateBodies();
			
			if(code == KV2Code.FAIL) {
				//trace("_kv2Manager.updateBodies() failed");
			} else {
				
				_draw.clear();
								
				var i : int;
				var l : int;
				
				var j : int;
				var m : int;

				var bodies : Vector.<KV2Body> = _kv2Manager.bodies; 
				var body : KV2Body;
				
				var joints : Vector.<KV2Joint>;
				var joint : KV2Joint;
				
				var p : Point = _tmpPoint;
				var offsetColorX : Number = _bmColor.x;
				var offsetColorY : Number = _bmColor.y;
				var offsetDepthX : Number = _bmDepth.x;
				var offsetDepthY : Number = _bmDepth.y;
				var scale : Number = _bmColor.scaleX;
				var radius : Number = 5 * scale;
				
				// There will always be KV2Body.BODY_COUNT KV2Body elements in that
				// vector. The Kinect either tracked them or not.		
				for(i = 0, l = bodies.length; i < l; ++i) {
					body = bodies[i];
					
					// If a body got tracked:
					if(body.tracked) {
						
						joints = body.joints;
						
						// Draw all 25 body joints (in DepthSpace and in ColorSpace)
						for(j = 0, m = joints.length; j < m; ++j) {
							joint = joints[j];
							
							p.x = joint.colorSpacePoint.x * scale + offsetColorX;
							p.y = joint.colorSpacePoint.y * scale + offsetColorY;
						
							DrawingUtils.drawPoint(_draw, p, radius, false, 0x000000);
							
							p.x = joint.depthSpacePoint.x * scale + offsetDepthX;
							p.y = joint.depthSpacePoint.y * scale + offsetDepthY;
						
							DrawingUtils.drawPoint(_draw, p, radius, false, 0x000000);
						}
						
						// Close your left hand to take a screenshot.
						if(body.handLeftState == KV2Body.HandState_Closed && body.handLeftConfidence == KV2Body.TrackingConfidence_High) {
							_handClosedTracked++;
							
							// About 3 seconds after closing your hand.
							if(_handClosedTracked > 90) {
								_handClosedTracked = -90; // Reset to -3 seconds
								
								var bmd : BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
								bmd.draw(stage, null, null, null, null, true);
								
								var ba : ByteArray = PNGEncoder.encode(bmd);
								ba.position = 0;
								
								var file : File = File.desktopDirectory.resolvePath("AIRKinectv2_example_app_screenshot.png");
								var fileStream : FileStream = new FileStream();
								
								fileStream.openAsync(file, FileMode.WRITE);
								fileStream.writeBytes(ba);
								fileStream.close();
								
								trace("KV2ExampleAll.onEnterFrame: saved screenshot to desktop.");						
							}
						}
					}
				}
			}
		}
		
		private function onResize(event : Event = null) : void {
			trace("KV2ExampleAll.onResize");
			var f : Number = 1.0;
			
			if(_kv2Config.enableDepthFrameMappingToColorSpace || _kv2Config.enableInfraredFrameMappingToColorSpace
					|| _kv2Config.enableLongExposureInfraredFrameMappingToColorSpace) {
				f = 0.5;			
			}
			
			var sw : int = stage.stageWidth;
			var sh : int = stage.stageHeight * f;
			var scale : Number = 1.0;
			var x : int = 0;
			var y : int = 0;
			var bm : Bitmap;
			
			// proportional inside (with unfilled borders)

			scale = sw / 1920;
			
			if(scale * 1080 > sh) {
				scale = sh / 1080;
			}

			// proportional outside (without any unfilled borders)

//			scale = sw / 1920;
//
//			if (scale * 1080 < sh) {
//				scale = sh / 1080;
//			}

			x = int((sw - 1920 * scale) * 0.5);
			y = int((sh - 1080 * scale) * 0.5);
			
			bm = _bmColor;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = x;
				bm.y = y;
			}
			
			bm = _bmBodyIndexFrameMappedToColorSpace;
			
			if(bm != null) {
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
			
			bm = _bmInfrared;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = sw - bm.width;
				bm.y = 0;
			}
						
			bm = _bmLongExposureInfrared;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = sw - bm.width;
				bm.y = bm.height;
			}
			
			bm = _bmBodyIndexFrame;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = 0;
				bm.y = 0;
			}
			
			bm = _bmColorFrameMappedToDepthSpace;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = 0;
				bm.y = bm.height;
			}
			
			bm = _bmDepthFrameMappedToColorSpace;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = -scaleX * 120;
				bm.y = sh;
			}
			
			
			bm = _bmInfraredFrameMappedToColorSpace;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = _bmInfraredFrameMappedToColorSpace.width-scaleX * 120 * 2;
				bm.y = sh;
			}
			
			bm = _bmLongExposureInfraredFrameMappedToColorSpace;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = _bmLongExposureInfraredFrameMappedToColorSpace.width*2-scaleX * 120 * 3;
				bm.y = sh;
			}
			
			
			_stats.y = sh - 100;
		}
	}
}