package com.jpl.ballgame
{
	import com.jpl.ballgame.Ball;
	
	import flash.events.Event;

	public class BallEvent extends Event
	{
		public static const DELETEME:String = "DELETEME";
		public static const STARTTIMER:String = "STARTTIMER";
		public static const STARTEDPLAYING:String = "STARTEDPLAYING";
		public static const STOPEDPLAYING:String = "STOPEDPLAYING";
			
		public var ball:Ball;
		public var playing:Boolean;	
		
		public function BallEvent(type:String,_ball:Ball=null,_playing:Boolean = true)
		{
			playing = _playing;
			ball = _ball;
			super(type)
		}
	}
}