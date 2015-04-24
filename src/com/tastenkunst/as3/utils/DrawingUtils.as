package com.tastenkunst.as3.utils {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Utility class used to draw points, rectangles or shapes (vertices + triangles).
	 */
	public class DrawingUtils {
		
		public static function drawTriangles(g : Graphics, vertices : Vector.<Number>, triangles : Vector.<int>, 
				clear : Boolean = false, lineThickness : Number = 0.50, 
				lineColor : uint = 0x00f6ff, lineAlpha : Number = 0.85,
				fillColor : uint = 0x00f6ff, fillAlpha : Number = 0.10) : void {
			clear && g.clear();
			
			if(lineAlpha > 0.0) g.lineStyle(lineThickness, lineColor, lineAlpha);
			if(fillAlpha > 0.0) g.beginFill(fillColor, fillAlpha);
			
			g.drawTriangles(vertices, triangles);
			
			if(fillAlpha > 0.0) g.endFill();
			if(lineAlpha > 0.0) g.lineStyle();
		}
		
		public static function drawTrianglesAsPoints(g : Graphics, vertices : Vector.<Number>, radius : Number = 2.0, 
				clear : Boolean = false,
				fillColor : uint = 0x00f6ff, fillAlpha : Number = 1.0) : void {
			clear && g.clear();
			
			g.beginFill(fillColor, fillAlpha);
			
			var i : int = 0;
			var l : int = vertices.length;
			
			for(; i < l;) {
				var x : Number = vertices[i++];
				var y : Number = vertices[i++];
				g.drawCircle(x, y, radius);
			}

			g.endFill();
		}

		public static function drawTrianglesWithTexture(g : Graphics, vertices : Vector.<Number>, triangles : Vector.<int>, 
				texture : BitmapData, uvData : Vector.<Number>, clear : Boolean = false) : void {
			clear && g.clear();
			
			g.lineStyle();
			g.beginBitmapFill(texture);
			g.drawTriangles(vertices, triangles, uvData);
			g.endFill();
		}

		public static function drawRect(g : Graphics, rect : Rectangle, 
				clear : Boolean = false, lineThickness : Number = 1.0, 
				lineColor : uint = 0x00f6ff, lineAlpha : Number = 1.0) : void {
			clear && g.clear();
			
			g.lineStyle(lineThickness, lineColor, lineAlpha);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
			g.lineStyle();
		}

		public static function drawRects(g : Graphics, rects : Vector.<Rectangle>, 
				clear : Boolean = false, lineThickness : Number = 1.0, 
				lineColor : uint = 0x00f6ff, lineAlpha : Number = 1.0) : void {
			clear && g.clear();
			
			g.lineStyle(lineThickness, lineColor, lineAlpha);
			
			var i : int = 0;
			var l : int = rects.length;
			var rect : Rectangle;
			
			for(; i < l; i++) {
				rect = rects[i];
				g.drawRect(rect.x, rect.y, rect.width, rect.height);
			}
			
			g.lineStyle();
		}

		public static function drawPoint(g : Graphics, p : Point, radius : Number, 
				clear : Boolean = false, 
				fillColor : uint = 0x00f6ff, fillAlpha : Number = 1.0) : void {
			clear && g.clear();
			
			g.beginFill(fillColor, fillAlpha);
			g.drawCircle(p.x, p.y, radius);
			g.endFill();
		}

		public static function drawPoints(g : Graphics, points : Vector.<Point>, radius : Number, 
				clear : Boolean = false, 
				fillColor : uint = 0x00f6ff, fillAlpha : Number = 1.0) : void {
			clear && g.clear();
			
			g.beginFill(fillColor, fillAlpha);
			
			var i : int = 0;
			var l : int = points.length;
			var p : Point;
			
			for(; i < l; i++) {
				p = points[i];
				g.drawCircle(p.x, p.y, radius);
			}
			
			g.endFill();
		}
	}
}
