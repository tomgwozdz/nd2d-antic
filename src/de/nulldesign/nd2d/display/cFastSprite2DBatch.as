package de.nulldesign.nd2d.display
{	
	import de.nulldesign.nd2d.materials.Sprite2DBatchMaterial;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.display3D.Context3D;
	
	public class cFastSprite2DBatch extends Sprite2DBatch
	{		
		public function cFastSprite2DBatch(textureObject:Texture2D)
		{
			super(textureObject);
		}
		
		override internal function stepNode(elapsed:Number, timeSinceStartInSeconds:Number):void
		{			
			this.timeSinceStartInSeconds = timeSinceStartInSeconds;
			
			// here's where this batch is much, much faster - we don't care about calling stepNode on any children, because we're not
			// going to nest children in these sprite batches ever...and calling stepNode on all Sprite2D objects in the batch was super-slow
			// because of all of the function calls that would occur, and setting widths, height, etc. through setter functions.
			// Not doing any of those checks increased performance by roughly 25% on one computer that I tested on.
		}	
	}
}
