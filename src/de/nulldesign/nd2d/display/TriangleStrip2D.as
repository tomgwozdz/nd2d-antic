package de.nulldesign.nd2d.display
{
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.materials.TriangleStripMaterial;
	import de.nulldesign.nd2d.materials.texture.ASpriteSheetBase;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.StatsObject;
	
	import flash.display3D.Context3D;
	import flash.geom.Vector3D;

	public class TriangleStrip2D extends Node2D
	{
		public var faceList:Vector.<Face> = null;
		public var texture:Texture2D = null;
		public var spriteSheet:ASpriteSheetBase = null;
		public var material:TriangleStripMaterial = null;
		
		public function TriangleStrip2D(f:Vector.<Face>, t:Texture2D)
		{
			super();
			faceList = f;
			texture = t;
			material = new TriangleStripMaterial(f, t);
		}
		
		override internal function drawNode(context:Context3D, camera:Camera2D, parentMatrixChanged:Boolean, statsObject:StatsObject):void
		{
			super.drawNode(context, camera, parentMatrixChanged, statsObject);
		}
		
		override protected function draw(context:Context3D, camera:Camera2D):void
		{
			material.blendMode = blendMode;
			material.modelMatrix = localModelMatrix;
			material.viewProjectionMatrix = camera.getViewProjectionMatrix(false);
			material.spriteSheet = spriteSheet;
			material.texture = texture;
			material.render(context, faceList, 0, faceList.length);
		}
		
		override public function set width(value:Number):void
		{
			_width = value;
		}
		override public function set height(value:Number):void
		{
			_height = value;
		}
		
		override public function get numTris():uint
		{
			return faceList.length * 2;
		}
		
		override public function get drawCalls():uint
		{
			return (material) ? material.drawCalls : 0;
		}
		
		override public function handleDeviceLoss():void
		{
			super.handleDeviceLoss();
			
			if(material)
			{
				material.handleDeviceLoss();
			}
			
			if (texture)
			{
				texture.texture = null;
			}
		}
	}
}