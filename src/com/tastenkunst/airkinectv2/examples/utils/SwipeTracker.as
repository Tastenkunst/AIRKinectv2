package com.tastenkunst.airkinectv2.examples.utils {
	import com.tastenkunst.airkinectv2.KV2Body;
	import com.tastenkunst.airkinectv2.KV2Joint;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="swipe", type="flash.events.Event")]
	
	/**
	 * This utility class detects a swipe gesture:
	 * 
	 * Left to Right or
	 * Right to Left or
	 * Top to Bottom or
	 * Bottom to Top
	 * 
	 * Control the timings with the static vars.
	 * 
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class SwipeTracker extends EventDispatcher {
		
		// The dispatched event type
		public static const EVENT_SWIPE : String = "swipe";
		
		// Timing controls. I use 30 FPS most of the time.
		// So maybe you want to update this values (double it)
		// for use in a 60 FPS app?
		
		// Joint must not move for 2/3 second to start swipe.
		// (20 Frames, if 30 FPS)
		public static var numFramesToStartSwipe : int = 20;
		// Joint must not move for 1/3 second to end swipe.
		// (10 Frames, if 30 FPS)
		public static var numFramesToEndSwipe : int = 10;
		// Joint did not move far enough to trigger swipe for 2 seconds.
		// (60 Frames, if 30 FPS)
		public static var numFramesToResetSwipe : int = 60;
		// Don't start another swipe attempt for 2 seconds.
		// (60 Frames, if 30 FPS)
		public static var numFramesPauseAfterSwipe : int = 60;
		
		// Joint must not move more than that to start a swipe gesture.
		// 5 cm (CameraSpace)
		public static var maxStandStillDistance : Number = 0.05;
		// Joint must move this distance to actually trigger a swipe gesture.
		// 25 cm (CameraSpace)
		public static var minWidthOfSwipe : Number = 0.25; 
		
		// An arbitrary reset value. 
		private static const INVALID : Number = -9999;
		
		// The current joint position x.
		private var _currentX : Number;
		// The current joint position y.
		private var _currentY : Number;
		// The last joint position x.
		private var _lastX : Number;
		// The last joint position x.
		private var _lastY : Number;
		// The joint position x, where the swipe gesture started.
		private var _startX : Number;
		// The joint position y, where the swipe gesture started.
		private var _startY : Number;
		
		// Counter for numFramesToStartSwipe and numFramesToEndSwipe.
		private var _counterSwipeStart : int;
		// Counter for numFramesToResetSwipe
		private var _counterSwipeReset : int;
		
		// The event to dispatch.
		private var _eventSwipe : Event;
		
		// Resulting swipe distances (-/+ are left/right or down/up).
		private var _lastSwipeX : Number;
		private var _lastSwipeY : Number;
		
		// References of tracked body and joint.
		private var _body : KV2Body;
		private var _joint : KV2Joint;

		/**
		 * Should either get the right or left hand joint.
		 * 
		 * Of couse you could input the head or a foot joint,
		 * but who the hell will do a swipe with the head, right??
		 * 
		 * @param body the body reference to be able to retrieve the tracked body
		 * @param joint the joint to track
		 */	
		public function SwipeTracker(body : KV2Body, joint : KV2Joint) {
			_body = body;
			_joint = joint;
			
			_currentX = INVALID;
			_currentY = INVALID;
			_lastX = INVALID;
			_lastY = INVALID;
			_startX = INVALID;
			_startY = INVALID;
			
			_counterSwipeStart = 0;
			_counterSwipeReset = 0;
			
			_lastSwipeX = 0.0;
			_lastSwipeY = 0.0;
			
			_eventSwipe = new Event(EVENT_SWIPE);
		}
		
		/**
		 * You can decide outside this tracker to either
		 * give the gesture detection a try or to reset
		 * the tracker.
		 * 
		 * eg. You want to track hands only, if they are
		 * about 20cm away from the body, otherwise reset.
		 */
		public function track() : void {
			
			var joint : KV2Joint = _joint;
			var diffX : Number;
			var diffY : Number;
			
			// Get the current joint x and y.
			_currentX = joint.cameraSpacePoint.x;
			_currentY = joint.cameraSpacePoint.y;
			
			if(_lastX == INVALID) {
				// Reset check of starting position
				reset();
			} else {
				// Calculate the movement in both orientations.
				
				diffX = _currentX - _lastX;
				diffY = _currentY - _lastY;
					
				// We need to find a starting position.
				// X times consecutive small "movements" (hand stands still on a certain position).
			
				if(Math.abs(diffX) < maxStandStillDistance && Math.abs(diffY) < maxStandStillDistance) {
					
					if(_counterSwipeStart > numFramesToStartSwipe && _startX == INVALID) {
						
						// Swipe attempt now started.
						
						_startX = _currentX;
						_startY = _currentY;
					} else if(_counterSwipeStart > numFramesToStartSwipe && _startX != INVALID) {
						
						// In the swipe attempt.
						// What distance did the hand move in total?
						
						diffX = _currentX - _startX;
						diffY = _currentY - _startY;
						
						if(Math.abs(diffX) > minWidthOfSwipe || Math.abs(diffY) > minWidthOfSwipe) {
						
							_counterSwipeStart++;	
							
							if(_counterSwipeStart > numFramesToStartSwipe + numFramesToEndSwipe) {
								
								// Swipe finished.
								// Store the swiped direction and distance.
								
								_lastSwipeX = diffX;
								_lastSwipeY = diffY;
								
								// Dispatch that a swipe happened.
								
								dispatchEvent(_eventSwipe);
								
								// Reset with pause.
								
								reset(-numFramesPauseAfterSwipe);
							}	
						} else {
							
							// Swipe distance was not large. Reset after 2 seconds (30 FPS)
							
							_counterSwipeReset++;

							if(_counterSwipeReset > numFramesToResetSwipe) {
								// Nothing done.
								reset();
							}
						}
						
					} else {
						
						// Don't move the joint for a certain number of frames.
						
						_counterSwipeStart++;	
					}
				} else {
					
					// Moved a larger distance.
					
					if(_startX != INVALID) {
						// Swipe is happening.
					} else {
						// Reset, because swipe attempt not started.
						reset();
					}
				}
			}
			
			_lastX = _currentX;
			_lastY = _currentY;
		}

		/**
		 * You can decide outside this tracker to either
		 * give the gesture detection a try or to reset
		 * the tracker.
		 * 
		 * eg. You want to track hands only, if they are
		 * about 20cm away from the body, otherwise reset.
		 * 
		 * @param numFramesPause number of frames to pause the tracker.
		 */
		public function reset(numFramesPause : int = 0) : void {
			_counterSwipeStart = numFramesPause;
			_counterSwipeReset = 0;
			
			_startX = INVALID;
			_startY = INVALID;
		}
		
		/**
		 * Returns the KV2Body reference for the tracked joint.
		 */
		public function get body() : KV2Body {
			return _body;
		}
		
		/**
		 * Returns the tracked KV2Joint reference.
		 */
		public function get joint() : KV2Joint {
			return _joint;
		}
		
		/**
		 * Returns whether a swipe gesture attempt has started.
		 */
		public function get swipeStarted() : Boolean {
			return _startX != INVALID;
		}

		/**
		 * Returns the last detected swipe direction and distance (left/right). 
		 */
		public function get lastSwipeX() : Number {
			return _lastSwipeX;
		}

		/**
		 * Returns the last detected swipe direction and distance (up/down). 
		 */
		public function get lastSwipeY() : Number {
			return _lastSwipeY;
		}
	}
}
