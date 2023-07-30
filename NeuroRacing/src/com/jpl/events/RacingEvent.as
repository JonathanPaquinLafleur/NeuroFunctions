package com.jpl.events
{
	import flash.events.Event;

	public class RacingEvent extends Event
	{
		public static const Loaded:String = "Loaded";
		
		public var data:Object;
		
		public function RacingEvent(type:String,_data:Object = null){
			super(type)
			data = _data;
		}
	}
}