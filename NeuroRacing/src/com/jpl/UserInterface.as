package com.jpl
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.PlaneGeometry;
	
	import com.jpl.graphs.Graphs;
	
	import flash.geom.Vector3D;
	
	public class UserInterface extends ObjectContainer3D
	{
		[Bindable]
		public var graphs:Graphs;
		public var offsetX:Number = 0;
		private var distance:Number;
		
		public function UserInterface(_distance:Number)
		{
			super();
			
			distance = _distance;
			
			var mat:ColorMaterial = new ColorMaterial(0x000000);
			mat.alpha = 0.2;
			var graphBck:Mesh = new Mesh(new PlaneGeometry(3.4,40),mat);
			graphBck.rotationX = 90;
			graphBck.x = 0.45
			graphBck.z = -1.2;
			this.addChild(graphBck)
	
			graphs = new Graphs();
			graphs.rotationY = 105;
			graphs.scaleX = 0.008;
			graphs.scaleY = 0.008;
			graphs.scaleZ = 0.008;
			this.addChild(graphs);
		}
		
		public function updatePositioning():void{
			offsetX = ((Racing.view.width/960) * 4) * (640/Racing.view.height)
		}
		
		public function update(cameraDef:Object):void{
			this.position = getVector3DBetweenVector3Ds(cameraDef.targetPosition,cameraDef.position,distance)
			this.lookAt(cameraDef.position);
			this.transform.prependTranslation(offsetX,0,0);
			graphs.update();
		}
		
		public static function getVector3DBetweenVector3Ds(vec1:Vector3D,vec2:Vector3D,distance:Number):Vector3D{
			var t:Number = distance/Math.abs(Vector3D.distance(vec2,vec1))
			return new Vector3D(vec2.x + ((vec1.x - vec2.x)*t),vec2.y + ((vec1.y - vec2.y)*t),vec2.z + ((vec1.z - vec2.z)*t))
		}
	}
}