package {
	import com.tastenkunst.airkinectv2.examples.*;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	[SWF(backgroundColor="#bbbbbb", frameRate="30", width="1280", height="720")]

	/**
	 * The document class for the examples.
	 * Choose one of the examples in the init function.
	 * 
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	public class App extends Sprite {
		
		public var _example : KV2Example;
		
		public function App() {
			if(stage == null) {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			} else {
				onAddedToStage();
			}
		}
		
		private function onAddedToStage(event : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 30;

			init();
		}

		private function init() : void {
//			_example = new KV2ExampleColorFrame();
//			_example = new KV2ExampleDepthFrame();
			_example = new KV2ExampleAll();
//			_example = new KV2ExampleWaterRipple();
//			_example = new KV2ExampleSwipeGesture();
			
			addChild(_example);
			
			_example.init();
		}
	}
}
