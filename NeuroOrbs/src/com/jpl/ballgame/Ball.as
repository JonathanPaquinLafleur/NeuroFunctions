package com.jpl.ballgame
{
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.Cylinder;
	import away3d.primitives.Sphere;
	
	import com.greensock.TweenLite;
	
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GradientGlowFilter;
	
	import mx.effects.easing.Linear;
	
	public class Ball extends ObjectContainer3D
	{
		private var ball:Sphere;
		private var ballY:int = 25;//25-975
		private var ballX:int = 10;//20-80
		private var light:Cylinder;
		private var ballGlow:GradientGlowFilter;
		private var ballBlur:BlurFilter;
		private var width:int;
		private var height:int;
		private var _active:Boolean;
		private var backgroundHeight:int;
		private var backgroundWidth:int;
		
		//Motion Blur
		private var spring:Number = 0.1;
		private var friction:Number = 0;
		private var blurFactor:Number = 3;
		private var vx:Number = 0;
		
		public function Ball(_backgroundHeight:int,_backgroundWidth:int)
		{
			this.z = -600;
			
			//Filters
			ballGlow = new GradientGlowFilter(0,45,[0xFFFFFF,0xFFFFFF,0xFFFFFF],[0,0.5,1],[0,250,255],30,30,3,1,"full");
			ballBlur = new BlurFilter(10,10,1);
			
			//Create Ball and Light
			ball = new Sphere({radius:50,material:"white",z:-1,segmentsW:3, segmentsH:3,alpha:0,ownCanvas:true,filters:[ballGlow,ballBlur]});
			light = new Cylinder({radius:200,height:0,alpha:0,blendMode:BlendMode.ADD,filters:[new BlurFilter(200,200,1)],rotationX:90,ownCanvas:true})
			this.addChild(light);
			this.addChild(ball);
			
			resize(_backgroundHeight,_backgroundWidth);
			
		}
		
		public function init():void{
			
			ballY = 25;
			
			reposition()
			
			//Random Color
			var newColor:int = Math.round(Math.random()*0xFFFFFF);
			ballGlow.colors = [newColor,newColor,0xFFFFFF];
			light.material = new ColorMaterial(newColor);
			
			//Random Position
			ballX = Math.round(Math.random()*60)+20
			
			active = true;
		}
		
		public function move(amount:int):Boolean{
			var finished:Boolean = false;
			var blurY:Number;
			var oldY:Number = this.y;
			if(active){
				if(ballY < 975){
					ballY += amount;
				}else{
					finished = true;
					active = false;
				}
			}
			
			reposition();
			
			vx += (amount*5) * spring;
			vx *= friction;
				
			blurY = Math.abs(oldY - this.y);
				
			if((blurY*blurFactor)>10)
				ballBlur.blurY = (blurY*blurFactor);
			else
				ballBlur.blurY = 10;
			
			return finished
		}
		
		private function reposition():void{
			this.y = (backgroundHeight/2)*((ballY-500)/500);
			this.x = (backgroundWidth/2)*((ballX-50)/50);
		}
		
		public function set active(value:Boolean):void{
			TweenLite.killTweensOf(ball);
			TweenLite.killTweensOf(light);
			if(value){
				TweenLite.to(ball,1,{radius:backgroundHeight/60,ease:Linear.easeIn,overwrite:false,onComplete:resizeBall});
				TweenLite.to(ball,1,{alpha:1,ease:Linear.easeIn,overwrite:false,onComplete:activateMe});
				TweenLite.to(light,1,{alpha:0.4,ease:Linear.easeIn});
			}else{
				_active = false;
				TweenLite.to(ball,1,{radius:backgroundHeight/24,ease:Linear.easeOut,overwrite:false});
				TweenLite.to(ball,1,{alpha:0,ease:Linear.easeOut,overwrite:false,onComplete:deleteMe});
				TweenLite.to(light,1,{alpha:0,ease:Linear.easeOut});
			}
		}
		
		public function get active():Boolean{
			return _active
		}
		
		private function activateMe():void{
			_active = true;
			this.dispatchEvent(new BallEvent(BallEvent.STARTTIMER,this));
		}
		
		private function resizeBall():void{
			ball.radius = backgroundHeight/60;
		}
		
		private function deleteMe():void{
			this.dispatchEvent(new BallEvent(BallEvent.DELETEME,this));
		}
		
		public function resize(_backgroundHeight:int,_backgroundWidth:int):void{
			backgroundHeight = _backgroundHeight;
			backgroundWidth = _backgroundWidth;
			resizeBall()
			ballGlow.alphas = [0,_backgroundHeight/2400,1];
			light.radius =  _backgroundHeight/6;
			reposition();
		}
	}
}