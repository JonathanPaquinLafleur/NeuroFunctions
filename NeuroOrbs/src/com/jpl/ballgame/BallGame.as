package com.jpl.ballgame
{
	import away3d.cameras.HoverCamera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.clip.RectangleClipping;
	import away3d.loaders.Max3DS;
	import away3d.loaders.Loader3D;
	import away3d.materials.TransformBitmapMaterial;
	import away3d.primitives.Plane;
	
	import com.jpl.ballgame.Ball;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.core.SoundAsset;
	import mx.core.UIComponent;
	import mx.effects.SoundEffect;
	
	public class BallGame extends UIComponent
	{
		[Bindable]
		public var paused:Boolean = false;
		[Bindable]
		public var playing:Boolean = false;
		[Bindable]
		public var points:int = 0;
		[Bindable]
		public var timerVal:int;
		public var background:Plane;
		private var checker:Plane;
		private var timer:Timer;
		private var checkerMat:TransformBitmapMaterial;
		private var backgroundView:View3D;
		private var foregroundView:View3D;
		private var ball1:Ball;
		private var ball2:Ball;
		private var winSound:SoundEffect;
		private var currentBall:Ball;
		
		private var hoverCamera:HoverCamera3D
		private var mouseSpeed:Number = 0.5;
		private var mouseDown:Boolean;
		private var lastX:Number;
		private var lastY:Number;
		
		[Embed (source="../assets/sound/tick.mp3")]
		private var tick_mp3:Class;
		private var tick:SoundAsset = new tick_mp3() as SoundAsset;
		[Embed (source="../assets/sound/intro.mp3")]
		private var intro_mp3:Class;
		private var intro:SoundAsset = new intro_mp3() as SoundAsset;
		[Embed (source="../assets/sound/win.mp3")]
		private var win_mp3:Class;
		private var win:SoundAsset = new win_mp3() as SoundAsset;
		[Embed (source="../assets/sound/missed.mp3")]
		private var missed_mp3:Class;
		private var missed:SoundAsset = new missed_mp3() as SoundAsset;
		
		[Embed (source="../assets/background/background.jpg")]
		public static const BackgroundImg:Class;
		[Embed (source="../assets/background/checker.jpg")]
		public static const CheckerImg:Class;
		
		public function BallGame(_width:int,_height:int)
		{
			
			//Views
			backgroundView = new View3D();
			foregroundView = new View3D({forceUpdate:true});
			this.addChild(backgroundView);
			this.addChild(foregroundView);
			
			//Camera
			hoverCamera = new HoverCamera3D({distance:1500,panAngle:30,tiltAngle:0});
			hoverCamera.hover(true);
			hoverCamera.panAngle = 180;
			hoverCamera.steps = 25;
			foregroundView.camera = hoverCamera;
			backgroundView.camera = hoverCamera;
			
			//Background
			var backgroundImg:Bitmap = new BackgroundImg();
			background = new Plane({z:-600,rotationX:90,material:backgroundImg.bitmapData,width:_width+1,height:_height+1,pushback:true})
			//backgroundView.scene.addChild(background);
			var checkerImg:Bitmap = new CheckerImg();
			checkerMat = new TransformBitmapMaterial(checkerImg.bitmapData,{repeat:true,scaleY:1,alpha:0.5});
			checker = new Plane({z:-600,rotationX:90,material:checkerMat,width:_width+1,pushfront:true});
			backgroundView.scene.addChild(checker);
			
			//Sound
			intro.play();
			
			//Init
			ball1 = new Ball(background.height,background.width);
			ball2 = new Ball(background.height,background.width);
			foregroundView.scene.addChild(ball1);
			foregroundView.scene.addChild(ball2);
			
			currentBall = ball1;
			timer = new Timer(100,40);
			timer.addEventListener(TimerEvent.TIMER,countdown);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			initBall(false);
		}

		public function start():void{
			if(!playing){
				if(!paused){
					ball1.active = false;
					ball2.active = false;
				}
				initBall();
			}else{
				timer.start();
			}
			paused = false;
			playing = true;
			dispatchEvent(new BallEvent(BallEvent.STARTEDPLAYING,null,true));
		}
		
		public function pause():void{
			paused = true;
			timer.stop();
		}
		
		public function reset():void{
			points = 0;
			timerVal = 0;
			timer.reset();
			paused = true;
			playing = false;
			dispatchEvent(new BallEvent(BallEvent.STOPEDPLAYING,null,false));
			ball1.removeEventListener(BallEvent.STARTTIMER,resetStart);
			ball1.active = false;
			ball2.removeEventListener(BallEvent.STARTTIMER,resetStart);
			ball2.active = false;
		}
		
		public function onMouseDown(event:MouseEvent):void{	
			//mouseDown = true;	
		}
		
		public function onMouseUp(event:MouseEvent):void{
			mouseDown = false;
		}
		
		public function onMouseMove(event:MouseEvent):void{
			if (mouseDown){
				hoverCamera.tiltAngle -= (event.stageY - lastY) * mouseSpeed;
				hoverCamera.panAngle -= (event.stageX - lastX) * mouseSpeed;
			}
			lastX = event.stageX;
			lastY = event.stageY;
		}
		
		public function resizeGame(width:int,height:int):void{
			foregroundView.x = width/2;
			backgroundView.x = width/2;
			foregroundView.y = height/2;
			backgroundView.y = height/2;
			
			background.width = width+1;
			background.height = height+1;
			
			checker.height = height/30;
			checker.width = width+1;
			checkerMat.scaleX = checker.height/(width+1);
			checker.y = ((height+2)/2)-(checker.height/2);
			
			foregroundView.clipping = new RectangleClipping({minX:-2002,minY:-2020,maxX:2000,maxY:2000});

			ball1.resize(background.height,background.width);
			ball2.resize(background.height,background.width);
		}
	
		public function onEnterFrame(e:Event):void{
			hoverCamera.hover();
			backgroundView.render();
			foregroundView.render();
			
			var In1:Number = FlexGlobals.topLevelApplication.In1*7;
			//var In1:Number = Math.random()*17;
			if(!paused){
				if(currentBall.move(In1)){
					win.play().stop();
					win.play();
					if(playing){
						points++;
						timer.stop();
						initBall(true);
					}else{
						initBall(false);
					}
				}
			}
		}
		
		private function initBall(startTimer:Boolean = true):void{	
			if(currentBall == ball1)
				currentBall = ball2;
			else
				currentBall = ball1;
			currentBall.init();
			if(startTimer)
				currentBall.addEventListener(BallEvent.STARTTIMER,resetStart,false,0,true);
		}
		
		private function resetStart(e:BallEvent):void{
			e.ball.removeEventListener(BallEvent.STARTTIMER,resetStart);
			if(playing){
				timer.reset();
				if(!paused)
					timer.start();
			}
		}
		
		private function countdown(e:TimerEvent):void{
			if(timerVal < 5){
				if(timer.currentCount%10 == 0 || timer.currentCount == 1){
					tick.play().stop();
					tick.play();
				}
				timerVal = (timer.currentCount/10)+1;
				if(timerVal >= 5){
					missed.play().stop();
					missed.play();
					currentBall.active = false;
					timer.stop();
					initBall();
				}
			}else{
				if(timer.currentCount%10 == 0 || timer.currentCount == 1){
					tick.play().stop();
					tick.play();
				}
				timerVal = 1;
			}
		}
	}
}