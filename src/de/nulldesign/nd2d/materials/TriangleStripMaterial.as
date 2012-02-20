package de.nulldesign.nd2d.materials
{
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.shader.ShaderCache;
	import de.nulldesign.nd2d.materials.texture.ASpriteSheetBase;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;

	public class TriangleStripMaterial extends AMaterial
	{
		protected static const VERTEX_SHADER:String = "m44 op, va0, vc0 \n" +
													"mov v0, va1";
		protected static const FRAGMENT_SHADER:String = "tex oc, v0, fs0 <2d>";
		
		public var faceList:Vector.<Face> = null;
		public var texture:Texture2D = null;
		public var spriteSheet:ASpriteSheetBase = null;
		
		public function TriangleStripMaterial(f:Vector.<Face>, t:Texture2D)
		{
			super();
			faceList = f;
			texture = t;
		}
		
		override protected function generateBufferData(context:Context3D, faceList:Vector.<Face>):void
		{
			super.generateBufferData(context, faceList);
		}
		
		override protected function prepareForRender(context:Context3D):void
		{
			clipSpaceMatrix.identity();
			clipSpaceMatrix.append(modelMatrix);
			clipSpaceMatrix.append(viewProjectionMatrix);
			
			context.setProgram(shaderData.shader);
			context.setBlendFactors(blendMode.src, blendMode.dst);
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, clipSpaceMatrix, true);
			
			context.setTextureAt(0, texture.getTexture(context));
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
			context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
		}
		
		override public function render(context:Context3D, faceList:Vector.<Face>, startTri:uint, numTris:uint):void
		{
			generateBufferData(context, faceList);
			prepareForRender(context);
			context.drawTriangles(indexBuffer, startTri * 3, numTris);
			clearAfterRender(context);
		}
		
		override protected function clearAfterRender(context:Context3D):void
		{
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
		}
		
		override protected function initProgram(context:Context3D):void
		{
			if(!shaderData)
			{
				shaderData = ShaderCache.getInstance().getShader(context, this, VERTEX_SHADER, FRAGMENT_SHADER, 4, texture.textureOptions);
			}
		}
		
		override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void
		{
			fillBuffer(buffer, v, uv, face, VERTEX_POSITION, 2);
			fillBuffer(buffer, v, uv, face, VERTEX_UV, 2);
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}
	}
}