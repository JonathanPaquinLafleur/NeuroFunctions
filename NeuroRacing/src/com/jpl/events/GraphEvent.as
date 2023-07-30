package com.jpl.events
{
	import flash.events.Event;

	public class GraphEvent extends Event
	{
		public static const ValueChanged:String = "Value_Changed";
		
		public var data:Object;
		
		public function GraphEvent(type:String,_data:Object){
			super(type)
			data = _data;
		}
	}
}