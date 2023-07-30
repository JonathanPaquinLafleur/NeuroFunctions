package com.jpl.graphs
{

	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.jpl.Racing;
	import com.jpl.events.GraphEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.geom.RoundedRectangle;
	import mx.graphics.shaderClasses.ColorShader;
	
	public class Graphs extends ObjectContainer3D
	{
		
		private const sizeRatio:Number = 1/3;
		
		public var bar1:Mesh = new Mesh(new CubeGeometry(100,540,50));
		private var view3d:View3D
		private var bar2:Mesh = new Mesh(new CubeGeometry(100,540,50));
		private var shadow:Mesh = new Mesh(new PlaneGeometry(280,280))
		private var light:DirectionalLight
		
		public const bar1Max:Number = 100;
		public const bar2Max:Number = 100;
		public const bar1Min:Number = 0;
		public const bar2Min:Number = 0;
		private const rotation:Boolean = false;
		
		public var bar1Value:Number = -1;
		public var bar2Value:Number = -1;
		private var barContainerAngle:Number = -1;
		[Bindable]
		public var bar1ScaleY:Number = 0;
		[Bindable]
		public var bar2ScaleY:Number = 0;
		
		[Embed(source="assets/images/shadow.png")]
		public var ShadowData:Class;
		
		public function Graphs(){
			light = new DirectionalLight(-0.3,1,1);
			light.ambient =  0.8;
			light.specular = 3;
			light.diffuse = 5;
			this.addChild(light);
			
			var shadowMat:TextureMaterial = new TextureMaterial(new BitmapTexture(Bitmap(new ShadowData()).bitmapData));
			shadowMat.alpha = 0.5
			shadowMat.alphaBlending = true;
			shadow.y = -270;
			shadow.material = shadowMat;
			
			bar1.pivotPoint = new Vector3D(0,-270,0);
			bar1.z = 55;
			var mat:ColorMaterial = new ColorMaterial(0x0000ff);
			mat.gloss = 10;
			mat.specular = 1;
			mat.ambient = 0.9
			mat.lightPicker = new StaticLightPicker([light])
			bar1.material = mat;
			bar2.pivotPoint = new Vector3D(0,-270,0);
			bar2.z = -55;
			var mat2:ColorMaterial = new ColorMaterial(0xff0000);
			mat2.gloss = 10;
			mat2.specular = 1;
			mat2.ambient = 0.9
			mat2.lightPicker = new StaticLightPicker([light])
			bar2.material = mat2;
				
			this.addChild(bar1);
			this.addChild(bar2);
			this.addChild(shadow);
			
			rotateBars(-75,false);
			setBarValues(0,0,false);
			
		}
		
		private function rotateBars(ang:int,animate:Boolean = true):void{
			if(barContainerAngle != ang){
				barContainerAngle = ang
				TweenLite.killTweensOf(this);
				var barAng:int = -ang - 20;
				var barLblAng:int = -ang;
				if(animate){
					TweenLite.to(this,1,{rotationY:ang})
					TweenLite.to(bar1,1,{rotationY:barAng})
					TweenLite.to(bar2,1,{rotationY:barAng})
				}else{
					this.rotationY = ang;
					bar1.rotationY = barAng;
					bar2.rotationY = barAng;
				}
			}
		}
		
		private function setBarValues(_bar1Value:Number,_bar2Value:Number,animate:Boolean = true):void{
			if(_bar1Value > bar1Max)
				_bar1Value = bar1Max;
			if(_bar2Value > bar1Max)
				_bar2Value = bar1Max;
			
			if(_bar1Value < bar1Min)
				_bar1Value = bar1Min;
			if(_bar2Value < bar1Min)
				_bar2Value = bar1Min;
			
			if(_bar1Value != bar1Value || _bar2Value != bar2Value){
				bar1Value = _bar1Value;
				bar2Value = _bar2Value;
				
				var bar1ValueScaleY:Number = bar1Value/bar1Max;
				var bar2ValueScaleY:Number = bar2Value/bar2Max;
				if(bar1ValueScaleY == 0)
					bar1ValueScaleY = 0.01;
				if(bar2ValueScaleY == 0)
					bar2ValueScaleY = 0.01;
				
				if(animate){
					TweenLite.to(bar1,1,{overwrite:0,scaleY:bar1ValueScaleY,onUpdate:barUpdated})
					TweenLite.to(bar2,1,{overwrite:0,scaleY:bar2ValueScaleY,onUpdate:barUpdated})
				}else{
					bar1.scaleY = bar1ValueScaleY;
					bar2.scaleY = bar2ValueScaleY;
					barUpdated();
				}
			}
		}
		
		private function barUpdated():void{
			this.dispatchEvent(new GraphEvent(GraphEvent.ValueChanged,{bar1:{value:Math.round(bar1.scaleY*100),position:Racing.view.project(new Vector3D(bar1.scenePosition.x,bar1.scenePosition.y + ((270 * bar1.scaleY)*this.scaleX),bar1.scenePosition.z))},bar2:{value:Math.round(bar2.scaleY*100),position:Racing.view.project(new Vector3D(bar2.scenePosition.x,bar2.scenePosition.y + ((270 * bar2.scaleY)*this.scaleX),bar2.scenePosition.z))}}));
			
			if(rotation){
				if(bar1.scaleY >= bar2.scaleY)
					rotateBars(-40)
				else
					rotateBars(140)
			}
		}
	
		public function update():void{
			var in1:Number = FlexGlobals.topLevelApplication.in1;
			var in2:Number = FlexGlobals.topLevelApplication.in2;
			setBarValues(in1,in2,false);
		}
		
		private function randRange(minNum:Number, maxNum:Number):Number{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
	}
}