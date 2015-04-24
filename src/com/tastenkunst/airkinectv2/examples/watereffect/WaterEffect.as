package com.tastenkunst.airkinectv2.examples.watereffect {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * The water effect class from one of our last
	 * Kinect projects. Have fun with it!
	 *  
	 * @author Marcel Klammer, Tastenkunst GmbH, 2015
	 */
	final public class WaterEffect extends Sprite {
		
		public var onRipple : Function;
		
		private var _origin : Point;
		
		private var _buffer1 : BitmapData;
		private var _buffer2 : BitmapData;
		private var _buffer3 : BitmapData;
		private var _bufferRect : Rectangle;
		
		private var _displacementMapFilter : DisplacementMapFilter;
		private var _bmdDisplacement : BitmapData;
		private var _bmdDisplacementRect : Rectangle;
		
		private var _drawRect : Rectangle;
		private var _expandFilter : ConvolutionFilter;
		private var _colourTransform : ColorTransform;
		private var _matrix : Matrix;
		private var _scaleXInv : Number;
		private var _scaleYInv : Number;
		
		public function WaterEffect(width : int, height : int, 
				displScale : Number, scaleX : Number = 5, scaleY : Number = 5) {
			
			_bmdDisplacementRect = new Rectangle(0, 0, width, height);			
			_origin = new Point();
			
			_scaleXInv = 1 / scaleX;
			_scaleYInv = 1 / scaleY;
			
			_buffer1 = new BitmapData(width * _scaleXInv, height * _scaleYInv, false, 6785367);
			_buffer2 = new BitmapData(_buffer1.width, _buffer1.height, false, 1192960);
			_buffer3 = _buffer2.clone();
			_bufferRect = _buffer1.rect;
			
			_bmdDisplacement = new BitmapData(width, height, false, 0x7f7f7f);
			
			_drawRect = new Rectangle();
			_displacementMapFilter = new DisplacementMapFilter(_bmdDisplacement, _origin, 
				BitmapDataChannel.BLUE, BitmapDataChannel.BLUE, 
				displScale, displScale, "wrap");
			
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			_expandFilter = new ConvolutionFilter(3, 3, [0.5, 1, 0.5, 1, 0, 1, 0.5, 1, 0.5], 3);
			_colourTransform = new ColorTransform(1, 1, 1, 1, 128, 128, 128);
			_matrix = new Matrix(_bmdDisplacement.width / _buffer1.width, 0, 0, _bmdDisplacement.height / _buffer1.height);
			
			var bm : Bitmap = new Bitmap(_buffer1);
			addChild(bm);
			bm = new Bitmap(_buffer2); bm.y = _buffer1.height;
			addChild(bm);
			bm = new Bitmap(_bmdDisplacement); bm.y = _buffer1.height + _buffer2.height;
			addChild(bm);
		}

		public function drawRipple(x : int, y : int, displScale : int) : void {
			var strength : int = displScale >> 1;
			
			_drawRect.x = (-strength + x) * _scaleXInv;
			_drawRect.y = (-strength + y) * _scaleYInv;
			_drawRect.width = displScale * _scaleXInv;
			_drawRect.height = displScale * _scaleYInv;
			
			_buffer1.fillRect(_drawRect, 0x56);
		}
	
		public function destroy() : void {
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			_buffer1.dispose();
			_buffer2.dispose();
			_buffer3.dispose();
			_bmdDisplacement.dispose();
		}
		
		public function applyRippleBmd(bmdSource : BitmapData, bmdDestination : BitmapData, p : Point = null) : void {
			if(p == null) p = _origin;
			
			bmdDestination.applyFilter(bmdSource, bmdDestination.rect, _origin, _displacementMapFilter);
		}
		
		private function handleEnterFrame(param1 : Event) : void {
			_buffer1.lock();
			_buffer2.lock();
			_buffer3.lock();
			_bmdDisplacement.lock();
			
			_buffer3.copyPixels(_buffer2, _bufferRect, _origin);
			_buffer2.applyFilter(_buffer1, _bufferRect, _origin, _expandFilter);
			_buffer2.draw(_buffer3, null, null, BlendMode.SUBTRACT, null, false);
			_bmdDisplacement.draw(_buffer2, _matrix, _colourTransform, null, null, true);
			
			_buffer1.unlock();
			_buffer2.unlock();
			_buffer3.unlock();
			_bmdDisplacement.unlock();
			
			var tmp : BitmapData = _buffer1;
			_buffer1 = _buffer2;
			_buffer2 = tmp;
			
			if(onRipple != null) {
				onRipple(_displacementMapFilter);
			}
		}

		public function get bmdDisplacementRect() : Rectangle {
			return _bmdDisplacementRect;
		}

		public function get bmdDisplacement() : BitmapData {
			return _bmdDisplacement;
		}
	}
}
