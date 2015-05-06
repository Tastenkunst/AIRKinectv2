package com.tastenkunst.airkinectv2.examples {
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Code;
	import com.tastenkunst.airkinectv2.KV2Joint;
	import com.tastenkunst.airkinectv2.examples.assets.Arrow;
	import com.tastenkunst.airkinectv2.examples.utils.SwipeTracker;
	import com.tastenkunst.as3.utils.DrawingUtils;

	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * I was asked to implement a swipe gesture 
	 * (left/right, up/down).
	 * 
	 * This example uses a SwipeTracker utility class
	 * to detect swipe gestures for wanted joints (here: hands).
	 * 
	 * If you try this example you will see a small
	 * outlined circle in your left and right hand.
	 * If that small circle gets larger, you can do your
	 * swipe gesture either to the right, left, up or down.
	 *
	 * A large arrow will be displayed, if the swipe gesture
	 * was detected.
	 * 
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class KV2ExampleSwipeGesture extends KV2Example {
		
		// Set these true to show either the silhouette or the body joints.
		public var _showSilhouette : Boolean = true;
		public var _showJoints : Boolean = true;
		
		public var _bmBodyIndexFrameMappedToColorSpace : Bitmap;
		
		public var _drawSprite : Sprite;
		public var _draw : Graphics;

		public var _tmpPoint : Point;
		public var _offsetX : Number = 0.0;
		public var _offsetY : Number = 0.0;
		public var _offsetScale : Number = 1.0;
		
		// Hashmap for the swipe trackers, key: the tracked joints.
		public var _swipeTrackerMap : Dictionary;
		// Hashmap for the displayed arrows, key: the tracked joints.
		public var _arrowMap : Dictionary;
		
		private var _meterInFrontOfBody : Number = 0.2;
		
		public function KV2ExampleSwipeGesture() {
			super();
			
			_tmpPoint = new Point();
			_swipeTrackerMap = new Dictionary();
			_arrowMap = new Dictionary();
		}
		
		/**
		 * Configure your Kinect usage here.
		 * All options are false by default.
		 * 
		 * As we don't need to display the HD ColorFrame
		 * or the DepthFrame, we don't need to enable them.
		 * (Actually DepthFrame is needed for the BodyIndexFrame
		 * mapping to ColorSpace.)
		 * 
		 * We just need the BodyFrame to get the skeleton/body joints.
		 * If you want to display the silhouette as well, just
		 * enable it.
		 */
		override public function init() : void {
			trace("KV2ExampleSwipeGesture.init");
	
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
			trace("KV2ExampleSwipeGesture.onKinectStarted");
			
			var i : int;
			var l : int;
			var body : KV2Body;
			var joint : KV2Joint;
			var arrow : Arrow;
			var tracker : SwipeTracker;
			
			// Prepare the swipe trackers and arrows.
			
			for(i = 0, l = _kv2Manager.bodies.length; i < l; ++i) {
				body = _kv2Manager.bodies[i];
				
				joint = body.joints[KV2Joint.JointType_HandLeft];
				tracker = new SwipeTracker(body, joint);
				tracker.addEventListener(SwipeTracker.EVENT_SWIPE, onSwipe);
				
				arrow = new Arrow();
				arrow.visible = false;
				addChild(arrow);
				
				_swipeTrackerMap[joint] = tracker;
				_arrowMap[joint] = arrow;
				
				joint = body.joints[KV2Joint.JointType_HandRight];
				tracker = new SwipeTracker(body, joint);
				tracker.addEventListener(SwipeTracker.EVENT_SWIPE, onSwipe);
				
				arrow = new Arrow();
				arrow.visible = false;
				addChild(arrow);
					
				_swipeTrackerMap[joint] = tracker;
				_arrowMap[joint] = arrow;
			}
			
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
		 * the person. If that's true, the swipe tracker can do
		 * its work.
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
				var jointHandRight : KV2Joint;
				var jointHandLeft : KV2Joint;
				
				var p : Point = _tmpPoint;
				var offsetX : Number = _offsetX;
				var offsetY : Number = _offsetY;
				var scale : Number = _offsetScale;
				var radius : Number = 5 * scale;
				
				// There will always be KV2Body.BODY_COUNT KV2Body elements in that
				// vector. The Kinect either tracked them or not.
				for(i = 0, l = bodies.length; i < l; ++i) {
					body = bodies[i];
										
					// If a body was tracked:
					if(body.tracked) {
						
						joints = body.joints;
						
						jointBase = body.joints[KV2Joint.JointType_SpineBase];
						jointHandRight = body.joints[KV2Joint.JointType_HandRight];
						jointHandLeft = body.joints[KV2Joint.JointType_HandLeft];
						
						// Draw all body joints.
						if(_showJoints) {
							for (j = 0, m = joints.length; j < m; ++j) {
								joint = joints[j];
								
								p.x = joint.colorSpacePoint.x * scale + offsetX;
								p.y = joint.colorSpacePoint.y * scale + offsetY;
								
								switch(joint) {
									case jointBase:
										DrawingUtils.drawPoint(_draw, p, radius * 2, false, 0x00ff00, 1.0); 
										break;
									default:
										DrawingUtils.drawPoint(_draw, p, radius, false, 0xff7900,1.0);
								}
							}
						}

						// Right hand.
						handleSwipeGestureForJoint(jointHandRight, jointBase, radius);
						
						// Left hand.
						handleSwipeGestureForJoint(jointHandLeft, jointBase, radius);
					}
				}
			}
		}
		
		/**
		 * Handles the actual swipe tracker stuff. Checks, whether the hand is
		 * in front of the body. If that's true, give the tracking a try, if not,
		 * reset the tracker.
		 */
		private function handleSwipeGestureForJoint(joint : KV2Joint, 
				jointBase : KV2Joint, radius : Number) : void {
			
			var swipeTracker : SwipeTracker = _swipeTrackerMap[joint] as SwipeTracker;
			var p : Point = _tmpPoint;
			
			// The hand should be a bit in front on the body to trigger actions.
			// CameraSpace is in meter. So _meterInFrontOfBody = 0.2 mean 0.2m or 20cm.
			if(jointBase.cameraSpacePoint.z - joint.cameraSpacePoint.z > _meterInFrontOfBody) {
				
				swipeTracker.track();
				
				p.x = joint.colorSpacePoint.x * _offsetScale + _offsetX;
				p.y = joint.colorSpacePoint.y * _offsetScale + _offsetY;
					
				if(swipeTracker.swipeStarted) {
					DrawingUtils.drawPointWithOutline(_draw, p, radius * 10, false, swipeTracker.body.color, 0.5, 5.0);
				} else {
					DrawingUtils.drawPointWithOutline(_draw, p, radius *  2, false, swipeTracker.body.color, 0.5, 3.0);
				}
				
			} else {
				// Reset, if hand is to close to the body.
				swipeTracker.reset();
			}
		}
		
		/**
		 * Displays an arrow where where joint ended the swipe.
		 */
		protected function onSwipe(event : Event) : void {
			trace("KV2ExampleSwipeGesture.onSwipe");
			
			var swipeTracker : SwipeTracker = event.currentTarget as SwipeTracker;
			var arrow : Arrow = _arrowMap[swipeTracker.joint];
			var rot : Number = 0;
			
			// Set the direction of the arrow.
			if(Math.abs(swipeTracker.lastSwipeX) > Math.abs(swipeTracker.lastSwipeY)) {
				if(swipeTracker.lastSwipeX < 0) {
					rot = -90; // Right > Left
				} else {
					rot =  90; // Left > Right
				}
			} else {
				if(swipeTracker.lastSwipeY < 0) {
					rot = -180; // Top > Bottom
				} else {
					rot =    0; // Bottom > Top
				}
			}
			
			arrow.x = swipeTracker.joint.colorSpacePoint.x * _offsetScale + _offsetX;
			arrow.y = swipeTracker.joint.colorSpacePoint.y * _offsetScale + _offsetY;
			arrow.rotation = rot;
			arrow.color = swipeTracker.body.color;
			arrow.visible = true;
		}
		
		/**
		 * Put all things in the correct place.
		 */
		protected function onResize(event : Event = null) : void {
			trace("KV2ExampleSwipeGesture.onResize");
			
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
				bm.alpha = 0.25;
			}
			
			_offsetX = x;
			_offsetY = y;
			_offsetScale = scale;
		}
	}
}
