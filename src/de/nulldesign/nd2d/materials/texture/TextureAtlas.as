/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package de.nulldesign.nd2d.materials.texture {

	import de.nulldesign.nd2d.materials.texture.parser.ATextureAtlasParser;
	import de.nulldesign.nd2d.materials.texture.parser.TexturePackerParser;
	import de.nulldesign.nd2d.materials.texture.parser.ZwopTexParser;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class TextureAtlas extends ASpriteSheetBase {

		public static const XML_FORMAT_COCOS2D:String = "xmlFormatCocos2D";
		public static const XML_FORMAT_ZWOPTEX:String = "xmlFormatZwoptex";

		protected var animNames:Array = new Array();
		
		/**
		 *
		 * @param sheetWidth
		 * @param sheetHeight
		 * @param xmlData
		 * @param fps
		 * @param spritesPackedWithoutSpace set to true to get rid of pixel bleeding for packed atlases without spaces: http://www.nulldesign.de/2011/08/30/nd2d-pixel-bleeding/
		 */
		public function TextureAtlas(sheetWidth:Number, sheetHeight:Number, xmlData:XML, xmlFormat:String, fps:uint, spritesPackedWithoutSpace:Boolean = false) {
			this.fps = fps;
			this.spritesPackedWithoutSpace = spritesPackedWithoutSpace;
			this._sheetWidth = sheetWidth;
			this._sheetHeight = sheetHeight;

			if(xmlData) {
				parse(xmlData, xmlFormat);
				BuildAnimations();
			}
		}

		override public function addAnimation(name:String, keyFrames:Array, loop:Boolean):void {

			if(keyFrames[i] is String) {

				// make indices out of names
				var keyFramesIndices:Array = [];

				for(var i:int = 0; i < keyFrames.length; i++) {
					keyFramesIndices.push(frameNameToIndex[keyFrames[i]]);
				}

				animationMap[name] = new SpriteSheetAnimation(keyFramesIndices, loop);

			} else {
				animationMap[name] = new SpriteSheetAnimation(keyFrames, loop);
			}
		}

		/**
		 * paeser switch
		 * @param value
		 */
		protected function parse(value:XML, xmlFormat:String):void {

			var parser:ATextureAtlasParser;

			switch(xmlFormat) {
				case XML_FORMAT_COCOS2D:
					parser = new TexturePackerParser();
					break;
				case XML_FORMAT_ZWOPTEX:
					parser = new ZwopTexParser();
					break;
			}

			parser.parse(value);

			frameNameToIndex = parser.frameNameToIndex;
			frames = parser.frames;
			offsets = parser.offsets;
			sourceSizes = parser.originalSizes;

			uvRects = new Vector.<Rectangle>(frames.length, true);
			frame = 0;
		}

		override public function clone():ASpriteSheetBase {

			var t:TextureAtlas = new TextureAtlas(_sheetWidth, _sheetHeight, null, null, fps, spritesPackedWithoutSpace);

			t.animationMap = animationMap;
			t.activeAnimation = activeAnimation;
			t.frames = frames;
			t.offsets = offsets;
			t.sourceSizes = sourceSizes;
			t.frameNameToIndex = frameNameToIndex;
			t.uvRects = uvRects;
			t.frame = frame;

			return t;
		}
		
		public function GetSourceSizeForFrame(frame:int):Point
		{
			if(sourceSizes.hasOwnProperty(frame))
			{
				return sourceSizes[frame];	
			}
			return new Point(frames[frame].width, frames[frame].height);
		}
		
		public function get AnimNames():Array
		{
			return animNames;
		}
		
		public function GetFrameIndexFromFrameName(frameName:String):int
		{
			return frameNameToIndex[frameName];
		}
		
		public function GetFrameNameToIndexDictionary():Dictionary
		{
			return frameNameToIndex;
		}
		
		public function GetOffsetForFrame(frameIndex:int):Point {
			return offsets[frameIndex];
		}
		
		// build up all animations based on frame names
		public function BuildAnimations():void
		{
			var frameNames:Array = frameNames
			var prevAnimName:String = "";
			var animFrames:Array;
			
			animNames = new Array();
			for each (var frameName:String in frameNames)
			{				
				// the animation name is everything except the last underscore, the frame number, and the file extension
				var position:int = frameName.lastIndexOf("_");
				var animName:String = frameName.substr(0, position);
				
				// get the frame number (right before the "." in the file extension
				var dotPosition:int = frameName.lastIndexOf(".");
				var frameNumber:int = parseInt(frameName.substr(position + 1, dotPosition - position - 1));
				
				if (animName != prevAnimName)
				{
					if (animFrames && animFrames.length > 0)
					{
						trace("==> Creating animation " + prevAnimName + " with " + animFrames.length + " frames");
						addAnimation(prevAnimName, animFrames, true);
						animNames.push(prevAnimName);
					}
					
					animFrames = new Array();
					prevAnimName = animName;
				}
				
				animFrames.push(frameName);	// stores all of the frames for one animation
				
				//trace("Frame name: " + frameName + " Animation Name: " + animName + " Frame Number: " + frameNumber);
				
				//var pieces:Array = frameName.split(/[^0-9-]+/);	// split into pieces based on 
				//frames.push(new Rectangle(array[1], array[2], array[3], array[4]));
			}
			
			// add the last animation :)
			if (animFrames && animFrames.length > 0)
			{
				trace("==> Creating animation " + prevAnimName + " with " + animFrames.length + " frames");
				addAnimation(prevAnimName, animFrames, true);
				animNames.push(prevAnimName);
			}
		}		
	}
}
