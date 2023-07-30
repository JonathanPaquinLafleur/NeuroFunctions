package com.jpl.graphs
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.clip.RectangleClipping;
	import away3d.core.utils.Cast;
	import away3d.lights.DirectionalLight3D;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.materials.PhongColorMaterial;
	import away3d.materials.ShadingColorMaterial;
	import away3d.materials.shaders.SpecularPhongShader;
	import away3d.primitives.Cube;
	import away3d.primitives.Plane;
	import away3d.primitives.RoundedCube;
	import away3d.primitives.Sphere;
	import away3d.primitives.TextField3D;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
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
	
	import wumedia.vector.VectorText;
	
	public class Graphs extends UIComponent
	{
		
		private const sizeRatio:Number = 1/3;
		
		private var view3d:View3D
		private var bar1:RoundedCube;
		private var bar2:RoundedCube;
		private var background:Plane;
		private var bar1Lbl:TextField3D;
		private var bar2Lbl:TextField3D;
		private var shadow:Plane;
		private var light:DirectionalLight3D;
		private var barContainer:ObjectContainer3D;
		
		public const bar1Max:Number = 100;
		public const bar2Max:Number = 100;
		public const bar1Min:Number = 0;
		public const bar2Min:Number = 0;
		
		public var bar1Value:Number = -1;
		public var bar2Value:Number = -1;
		private var barContainerAngle:Number = -1;
		[Bindable]
		public var bar1ScaleY:Number = 0;
		[Bindable]
		public var bar2ScaleY:Number = 0;
		
		private var lblOutline:GlowFilter = new GlowFilter(0x000000,1,2,2,10);
		
		[Embed(source="assets/images/shadow.png")]
		public var ShadowData:Class;
		[Embed(source="assets/images/grid.png")]
		public var GridData:Class;
		[Embed(source="assets/fonts/fonts.swf", mimeType="application/octet-stream")]
		public var FontBytes:Class;

		public var parentHeight:Number = 0;
		public var parentWidth:Number = 0;
		
		public var bar1SimulatedData:Object = {num:0};
		public var bar2SimulatedData:Object = {num:0};
		
		public function Graphs(_parentHeight:Number,_parentWidth:Number = 0){
			VectorText.extractFont(new FontBytes());
			
			parentHeight = _parentHeight;
			
			if(_parentWidth == 0)
				parentWidth = parentHeight*sizeRatio;
			else
				parentWidth = _parentWidth;
			
			view3d = new View3D({x:parentWidth/2,y:parentHeight/2});
			view3d.clipping = new RectangleClipping({minX:-parentWidth/2,maxX:parentWidth/2,minY:-(parentHeight/2),maxY:parentHeight/2})
			this.addChild(view3d);
			
			light = new DirectionalLight3D({direction:new Vector3D(-10,-10,10)});
			view3d.scene.addLight(light);
			
			barContainer = new ObjectContainer3D({y:-(parentHeight/2) + 30});
			view3d.scene.addChild(barContainer);
			
			shadow = new Plane({width:280,height:280,pushback:true,ownCanvas:true,material:new BitmapMaterial(Cast.bitmap(ShadowData),{alpha:0.5})});
			
			background = new Plane({width:280,height:700,rotationX:90,ownCanvas:true,material:new ColorMaterial(0xffffff,{alpha:0.01}),pushback:true,z:130,filters:[lblOutline]});
			view3d.scene.addChild(background);
			
			bar1 = new RoundedCube({radius:20,subdivision:0,width:100,height:540,depth:50,pivotPoint:new Vector3D(0,-270,0),z:55,material:new PhongColorMaterial(0x0000ff),ownCanvas:true})	
			bar2 = new RoundedCube({radius:20,subdivision:0,width:100,height:540,depth:50,pivotPoint:new Vector3D(0,-270,0),z:-55,material:new PhongColorMaterial(0xff0000),ownCanvas:true})
//			bar1 = new Cube({width:100,height:540,depth:50,pivotPoint:new Vector3D(0,-270,0),z:55,material:new ShadingColorMaterial(0x0000ff),ownCanvas:true})	
//			bar2 = new Cube({width:100,height:540,depth:50,pivotPoint:new Vector3D(0,-270,0),z:-55,material:new ShadingColorMaterial(0xff0000),ownCanvas:true})
				
			bar1Lbl = new TextField3D("Impact",{filters:[lblOutline],ownCanvas:true,align:"center",size:34,z:55,material:new ColorMaterial(0xffffff)});
			bar2Lbl = new TextField3D("Impact",{filters:[lblOutline],ownCanvas:true,align:"center",size:34,z:-55,material:new ColorMaterial(0xffffff)});
			barContainer.addChild(bar1);
			barContainer.addChild(bar2);
			barContainer.addChild(bar1Lbl);
			barContainer.addChild(bar2Lbl);
			barContainer.addChild(shadow);
			
			rotateBars(-40,false);
			setBarValues(0,0,false);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
//			simulateData1();
//			simulateData2();
		}
		
		private function simulateData1():void{
			TweenLite.to(bar1SimulatedData,randRange(3,6),{num:randRange(1,100),ease:Cubic.easeInOut,onComplete:simulateData1,onUpdate:simulatedDataUpdated})
		}
		
		private function simulateData2():void{
			TweenLite.to(bar2SimulatedData,randRange(3,6),{num:randRange(1,100),ease:Cubic.easeInOut,onComplete:simulateData2,onUpdate:simulatedDataUpdated})
		}
		
		private function simulatedDataUpdated():void{
			setBarValues(bar1SimulatedData.num,bar2SimulatedData.num,false);
		}
		
		private function rotateBars(ang:int,animate:Boolean = true):void{
			if(barContainerAngle != ang){
				barContainerAngle = ang
				TweenLite.killTweensOf(barContainer);
				var barAng:int = -ang - 20;
				var barLblAng:int = -ang;
				if(animate){
					TweenLite.to(barContainer,1,{rotationY:ang})
					TweenLite.to(bar1,1,{rotationY:barAng})
					TweenLite.to(bar2,1,{rotationY:barAng})
					TweenLite.to(bar1Lbl,1,{rotationY:barLblAng})
					TweenLite.to(bar2Lbl,1,{rotationY:barLblAng})
				}else{
					barContainer.rotationY = ang;
					bar1.rotationY = barAng;
					bar2.rotationY = barAng;
					bar1Lbl.rotationY = barLblAng;
					bar2Lbl.rotationY = barLblAng;
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
			bar1ScaleY = bar1.scaleY;
			bar2ScaleY = bar2.scaleY;
			
			var bar1LblY:Number = bar1.scaleY * bar1.height + (bar1Lbl.size/2);
			var bar2LblY:Number = bar2.scaleY * bar2.height + (bar2Lbl.size/2);

			bar1Lbl.y = bar1LblY;
			bar2Lbl.y = bar2LblY;
			bar1Lbl.text = (bar1.scaleY * bar1Max).toFixed(2);
			bar2Lbl.text = (bar2.scaleY * bar2Max).toFixed(2);
			
			if(bar1.scaleY >= bar2.scaleY)
				rotateBars(-40)
			else
				rotateBars(140)
		}
	
		public function onEnterFrame(e:Event):void{
			var In1:Number = FlexGlobals.topLevelApplication.In1;
			var In2:Number = FlexGlobals.topLevelApplication.In2;
			setBarValues(In1,In2);
			//var In1:Number = Math.random()*17;
			view3d.render();
		}
		
		private function randRange(minNum:Number, maxNum:Number):Number 
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
	}
}