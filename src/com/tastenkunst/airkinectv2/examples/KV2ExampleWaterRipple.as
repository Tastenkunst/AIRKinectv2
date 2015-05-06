package com.tastenkunst.airkinectv2.examples {
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Code;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import com.tastenkunst.airkinectv2.examples.watereffect.WaterAssets;
	import com.tastenkunst.airkinectv2.examples.watereffect.WaterEffect;
	import com.tastenkunst.as3.utils.DrawingUtils;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Everyone likes to play with water, right?
	 * 
	 * This is a simple Kinect example with a
	 * water ripple effect. You can either control
	 * that effect with your mouse or infront of
	 * your kinect using your hands.
	 *  
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class KV2ExampleWaterRipple extends KV2Example {
		
		// The embedded water image
		public var _assets : WaterAssets;
		
		// Set these true to show either the silhouette or the body joints.
		public var _showSilhouette : Boolean = true;
		public var _showJoints : Boolean = true;
		
		public var _bmBodyIndexFrameMappedToColorSpace : Bitmap;
		
		public var _drawSprite : Sprite;
		public var _draw : Graphics;

		public var _rippleBgWater : WaterEffect;
		
		public var _bmdBgWater : BitmapData;
		public var _bmdBgWaterFiltered : BitmapData;
		public var _bmdBgWaterFilteredDest : Point = new Point();
		public var _bmdBgWaterFilteredRect : Rectangle;
		public var _bmBgWater : Bitmap;
		
		public var _tmpPoint : Point;
		public var _currentX : Number = 0.0;
		public var _currentY : Number = 0.0;
		public var _currentScale : Number = 1.0;
		
		public function KV2ExampleWaterRipple() {
			super();
			
			_assets = new WaterAssets();
			_tmpPoint = new Point();
		}
		
		/**
		 * Configure your Kinect usage here.
		 * All options are false by default.
		 * 
		 * As we don't need to display the HD ColorFrame
		 * or the DepthFrame, we don't need to enable them.
		 * 
		 * We just need the BodyFrame to get the skeleton/body joints.
		 * If you want to display the silhouette as well, just
		 * enable it.
		 */
		override public function init() : void {
			trace("KV2ExampleWaterRipple.init");
	
			_kv2Config.enableDepthFrame = _showSilhouette;
			_kv2Config.enableBodyFrame = true;
			
			_kv2Config.enableBodyIndexFrame = _showSilhouette;
			_kv2Config.enableBodyIndexFrameMappingToColorSpace = _showSilhouette;

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
			trace("KV2ExampleWaterRipple.onKinectStarted");
			
			addChild(_assets);
			
			_bmBodyIndexFrameMappedToColorSpace = new Bitmap(_kv2Manager.bodyIndexFrameMappedToColorSpaceBmd, PixelSnapping.AUTO, true);
			_showSilhouette && addChild(_bmBodyIndexFrameMappedToColorSpace);
			
			_drawSprite = new Sprite();
			_draw = _drawSprite.graphics;
			
			addChild(_drawSprite);
			addChild(_stats);

			// Put all things in the correct place.
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();

			// Start the Kinect updates.
			addEventListener(Event.EXIT_FRAME, onEnterFrame);
		}
		
		/**
		 * The update function for the body joints.
		 * 
		 * It includes a check, whether the hand is in front of
		 * the person. All hand movement is calculated relative
		 * to the body center so every hand can reach to the very
		 * left or very right side of the water.
		 */
		override protected function onEnterFrame(event : Event) : void {
			
			var code : int;
			
			code = _kv2Manager.updateImages();
			
			if(code == KV2Code.FAIL) {
				trace("_kv2Manager.updateImages failed");
			}
			
			code = _kv2Manager.updateBodies();
			
			if(code == KV2Code.OK) {
				
				_draw.clear();
								
				var i : int;
				var l : int;
				
				var j : int;
				var m : int;

				var bodies : Vector.<KV2Body> = _kv2Manager.bodies; 
				var body : KV2Body;
				
				var joints : Vector.<KV2Joint>;
				var joint : KV2Joint;
				
				var jointBase : KV2Joint;
				var jointTop : KV2Joint;
				var jointHandRight : KV2Joint;
				var jointHandLeft : KV2Joint;
				
				var p : Point = _tmpPoint;
				var offsetX : Number = _currentX;
				var offsetY : Number = _currentY;
				var scale : Number = _currentScale;
				var radius : Number = 5 * scale;
				
				var zDiff : Number = 0.2; //in meter!
				var baseX : Number = 0.2;
				var rangeX : Number = 0.6;
				var rangeY : Number;
				var fx : Number;
				var fy : Number;
				var diffX : Number;
				
				var bodyTracked : Boolean = false;
			
				// There will always be KV2Body.BODY_COUNT KV2Body elements in that
				// vector. The Kinect either tracked them or not.
				for(i = 0, l = bodies.length; i < l; ++i) {
					body = bodies[i];
										
					// If a body got tracked:							
					if(body.tracked) {
						bodyTracked = true;
						
						joints = body.joints;
						
						jointBase = body.joints[KV2Joint.JointType_SpineBase];
						jointTop = body.joints[KV2Joint.JointType_SpineShoulder];
						
						// Draw all body joints.
						if(_showJoints) {
							for (j = 0, m = joints.length; j < m; ++j) {
								joint = joints[j];
								
								p.x = joint.colorSpacePoint.x * scale + offsetX;
								p.y = joint.colorSpacePoint.y * scale + offsetY;
						
								if(joint == jointBase) {
									DrawingUtils.drawPoint(_draw, p, radius * 2, false, 0x00ff00, 1.0);							
								} else if(joint == jointTop) {
									DrawingUtils.drawPoint(_draw, p, radius * 2, false, 0xffff00, 1.0);							
								} else {
									DrawingUtils.drawPoint(_draw, p, radius, false, 0xff7900,1.0);							
								}
							}
						}
						
						jointHandRight = body.joints[KV2Joint.JointType_HandRight];
						jointHandLeft = body.joints[KV2Joint.JointType_HandLeft];
						
						// Right hand.
						
						// A hand can draw if it is 20 cm away from the body/neck.
						if(jointBase.cameraSpacePoint.z - jointHandRight.cameraSpacePoint.z > zDiff) {
							
							// Only do stuff above the hip.
							if(jointHandRight.cameraSpacePoint.y > jointBase.cameraSpacePoint.y) {
								
								if(jointHandRight.cameraSpacePoint.y > jointTop.cameraSpacePoint.y) {
									// Nothing to do above your shoulder.
								} else {
									// Do water stuff.
									
									rangeY = jointTop.cameraSpacePoint.y - jointBase.cameraSpacePoint.y;
									fy = (jointHandRight.cameraSpacePoint.y - jointBase.cameraSpacePoint.y) / rangeY;
									
									if(fy < 0) fy = 0;
									if(fy > 1) fy = 1;
									
									p.y =  (1 - fy) * _rippleBgWater.bmdDisplacementRect.height;
									
									//eg. base x of hand right is 0.20 ranges to -0.4 and to 0.8
									diffX = (jointHandRight.cameraSpacePoint.x - jointBase.cameraSpacePoint.x);
									diffX -= baseX;
									
									fx = diffX / rangeX;
									
									p.x = fx * _rippleBgWater.bmdDisplacementRect.width * 0.5 + 
											_rippleBgWater.bmdDisplacementRect.width * 0.5;
											
									_rippleBgWater.drawRipple(p.x, p.y, 20);
								}
							}
							
							if(body.handRightState == KV2Body.HandState_Closed && body.handRightConfidence == KV2Body.TrackingConfidence_High) {
								/*trace("***************" +
									"\n" + jointHandRight.cameraSpacePoint.y.toFixed(2) + 
									"\n" + jointBase.cameraSpacePoint.y.toFixed(2) + 
									"\n" + jointTop.cameraSpacePoint.y.toFixed(2));*/
							}
						}
						
						// Left hand.
						
						if(jointBase.cameraSpacePoint.z - jointHandLeft.cameraSpacePoint.z > zDiff) {
							
							// Only do stuff above the hip.
							if(jointHandLeft.cameraSpacePoint.y > jointBase.cameraSpacePoint.y) {
								
								if(jointHandLeft.cameraSpacePoint.y > jointTop.cameraSpacePoint.y) {
									// Nothing to do above your shoulder.																
								} else {
									// do water stuff
									
									rangeY = jointTop.cameraSpacePoint.y - jointBase.cameraSpacePoint.y;
									fy = (jointHandLeft.cameraSpacePoint.y - jointBase.cameraSpacePoint.y) / rangeY;
									
									if(fy < 0) fy = 0;
									if(fy > 1) fy = 1;
									
									p.y =  (1 - fy) * _rippleBgWater.bmdDisplacementRect.height;
									
									//eg. base x of hand left is -0.20 ranges to -0.8 and to 0.4
									diffX = (jointHandLeft.cameraSpacePoint.x - jointBase.cameraSpacePoint.x);
									diffX += baseX;
									
									fx = diffX / rangeX;
									
									p.x = fx * _rippleBgWater.bmdDisplacementRect.width * 0.5 + 
											_rippleBgWater.bmdDisplacementRect.width * 0.5;
											
									_rippleBgWater.drawRipple(p.x, p.y, 20);
								}
							}
							
							if(body.handLeftState == KV2Body.HandState_Closed && body.handLeftConfidence == KV2Body.TrackingConfidence_High) {
							/*	trace("***************" +
									"\n" + jointHandLeft.cameraSpacePoint.y.toFixed(2) + 
									"\n" + jointBase.cameraSpacePoint.y.toFixed(2) + 
									"\n" + jointTop.cameraSpacePoint.y.toFixed(2));*/
							}
						}
					}
				}
			}
		}
		
		
		protected function onResize(event : Event = null) : void {
			trace("KV2ExampleWaterRipple.onResize");
			
			var sw : int = stage.stageWidth;
			var sh : int = stage.stageHeight;
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
			
			bm = _bmBodyIndexFrameMappedToColorSpace;
			
			if(bm != null) {
				bm.scaleX = scale;
				bm.scaleY = scale;
				bm.x = x;
				bm.y = y;
				bm.alpha = 0.5;
			}
			
			_currentX = x;
			_currentY = y;
			_currentScale = scale;
			
			if(_bmdBgWater == null) {
				
				_bmdBgWater = new BitmapData(_assets._bgWater.width, _assets._bgWater.height + 30, true, 0x0);
				_bmdBgWater.draw(_assets._bgWater, new Matrix(1.0, 0.0, 0.0, 1.0, 0, 30), null, null, null, true);
				_bmdBgWaterFiltered = _bmdBgWater.clone();
				_bmdBgWaterFilteredRect = _bmdBgWaterFiltered.rect;
				_bmBgWater = new Bitmap(_bmdBgWaterFiltered, PixelSnapping.AUTO, true);
				
				var i : int = _assets.getChildIndex(_assets._bgWater);
				_assets.addChildAt(_bmBgWater, i);
				_assets.removeChild(_assets._bgWater);
								
				_rippleBgWater = new WaterEffect(_bmdBgWater.width, _bmdBgWater.height, 30, 7, 7);
				_rippleBgWater.onRipple = onRipple;
				//addChild(_rippleBgWater);
								
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			
			_bmBgWater.x = _assets._bgWater.x;
			_bmBgWater.y = _assets._bgWater.y - 30;
		}

		public function onRipple(filter : DisplacementMapFilter) : void {
			_bmdBgWaterFiltered.applyFilter(
				_bmdBgWater, 
				_bmdBgWaterFilteredRect, 
				_bmdBgWaterFilteredDest, 
				filter);
		}
		
		public function onMouseMove(event : MouseEvent) : void {
			_rippleBgWater.drawRipple(_bmBgWater.mouseX, _bmBgWater.mouseY, 20);
		}
	}
}
