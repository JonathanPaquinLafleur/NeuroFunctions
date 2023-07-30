package com.jpl
{
	import away3d.containers.ObjectContainer3D;
	
	public class Car extends ObjectContainer3D
	{
		public function Car()
		{
			super();
			
		}
		
		public override function set rotationY(val:Number):void{
			super.rotationY = super.rotationY + ((val - super.rotationY)/2)
		}
		
		public override function set x(val:Number):void{
			super.x = super.x + ((val - super.x)/5)
		}
		
		public override function set z(val:Number):void{
			super.z = super.z + ((val - super.z)/5)
		}
	}
}