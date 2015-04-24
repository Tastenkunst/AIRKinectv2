package com.tastenkunst.airkinectv2.examples {
	import net.hires.debug.Stats;

	import com.tastenkunst.airkinectv2.KV2Code;
	import com.tastenkunst.airkinectv2.KV2Config;
	import com.tastenkunst.airkinectv2.KV2Manager;

	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * This is the a simple base class for all the KV2Examples.
	 * It setups the KV2Config and KV2Manager, inits the Kinect
	 * and adds the two main functions for subclasses (
	 * onKinectStarted, onEnterFrame).
	 * 
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class KV2Example extends Sprite {
		
		// We only have these two components to work with.
		public var _kv2Config : KV2Config;
		public var _kv2Manager : KV2Manager;
		
		public var _stats : Stats;

		public function KV2Example() {
			_kv2Config = new KV2Config();
			_kv2Manager = new KV2Manager();
			_stats = new Stats();
		}

		/**
		 * You will need to override this function in your subclass. 
		 * All KV2Config options are false by default.
		 */
		public function init() : void {
		}
		
		/**
		 * initKinect is the same for all subclasses. 
		 * Override onKinectStarted to be sure, that the Kinect started successfully.
		 * 
		 * It is very unlikely, that the initialization fails, because
		 * most of the data structures and sizes etc. are kept in the SDK
		 * and don't need a connected device. If you connect the Kinect
		 * while the app is already running it will just start delivering
		 * data, when it's connected (takes up to 10 seconds after connecting).
		 */
		public function initKinect() : void {
			trace("KV2Example.initKinect");

			// Start the kinect device using your config.
			var started : int = _kv2Manager.start(_kv2Config);

			// If KV2Code.OK, all is setup and started. Have fun.
			if (started == KV2Code.OK) {
				trace("KV2Example.initKinect: Kinect sensor started.");
				onKinectStarted();
			} else {
				trace("KV2Example.initKinect: Kinect sensor not started correctly.");
				onKinectFailedToStarted();
			}
		}

		/**
		 * You will need to override this function in your subclass
		 * to add you Bitmaps etc.
		 */
		protected function onKinectStarted() : void {
		}
		
		/**
		 * You will need to override this function in your subclass
		 * to know, whether the Kinect started properly.
		 */
		protected function onKinectFailedToStarted() : void {
		}
		
		/**
		 * The "main loop". The more you configure in init(), the
		 * lower the performance will get (depending on your machine). 
		 * 
		 * Setting the stage.frameRate in App to a 24 might help when using
		 * all the features at once (which I doubt will be necessary for
		 * most apps).
		 * 
		 * Anyway implement that function in your subclass to handle the
		 * updates for the image data and body data.
		 */
		protected function onEnterFrame(event : Event) : void {
		}
	}
}
