package 
{
	import flash.display.*;
	import flash.xml.*;
	import flash.net.*;
	import flash.events.*;
	import flash.net.SharedObject;

	public class weathers extends MovieClip
	{
		var myXML:XML;
		var myLoader:URLLoader = new URLLoader();
		var userCity:String;

		var master:MovieClip;
		var masterStage:MovieClip;
		var iconArray:Array = [];
		const totalDays:int = 7;
		
		var mySO:SharedObject = SharedObject.getLocal("weatherforecast");
		var newSO:SharedObject = SharedObject.getLocal("newforecast");

		public function weathers()
		{
			// constructor code
			getCityFromInput();
		}

		function getCityFromInput()
		{
			masterStage = new stage_mc  ;
			masterStage.x = 400;
			masterStage.y = 100;
			
			addChild(masterStage);
			
			mySO = SharedObject.getLocal("weatherforecast");
			masterStage.inputtextbox.text = mySO.data.myCity;
			
			newSO = SharedObject.getLocal("newforecast");
			masterStage.inputtextbox.text = newSO.data.myCity;
			
			masterStage.submitButton.addEventListener(MouseEvent.CLICK, buttonClickFunction);
		}

		function buttonClickFunction(e:MouseEvent):void
		{
			userCity = masterStage.inputtextbox.text;
			mySO.data.myCity = masterStage.inputtextbox.text;
			mySO.flush();
			fillArray();
		}

		function fillArray()
		{
			removeChild(masterStage);
			master = new master_mc  ;
			master.x = 0;
			master.y = 0;
			master.visible = false;
			master.newweathertextbox.text = mySO.data.myCity;
			
			addChild(master);

			iconArray[0] = master.day1;
			iconArray[1] = master.day2;
			iconArray[2] = master.day3;
			iconArray[3] = master.day4;
			iconArray[4] = master.day5;
			iconArray[5] = master.day6;
			iconArray[6] = master.day7;

			importXML();
		}

		function importXML()
		{
			myLoader.load(new URLRequest("http://api.openweathermap.org/data/2.5/forecast/daily?q=" + userCity + "&mode=xml&units=imperial&cnt=7&nocache" + new Date().getTime()));
			myLoader.addEventListener(Event.COMPLETE, processXML);
		}

		public function processXML(e:Event):void
		{
			myXML = new XML(e.target.data);
			var tempString:String;
			var tempDate:Date = new Date();
			var myDate:String;
			var dayCount:int = 1;
			//trace(myXML);

			for (var i:int = 0; i < totalDays; i++)
			{
				myDate = tempDate.toString();
				
				iconArray[i].todayDate = myDate.substr(0,11);
				iconArray[i].weatherType = myXML.forecast.time[i].symbol. @ name;
				iconArray[i].symbolNumber = myXML.forecast.time[i].symbol. @ number;
				iconArray[i].highTemp = myXML.forecast.time[i].temperature. @ max;
				iconArray[i].lowTemp = myXML.forecast.time[i].temperature. @ min;

				if (iconArray[i].symbolNumber == 800)
				{
					iconArray[i].gotoAndStop(1);
				}
				if (iconArray[i].symbolNumber >= 500 && iconArray[i].symbolNumber < 600)
				{
					iconArray[i].gotoAndStop(2);
				}
				if (iconArray[i].symbolNumber > 800 && iconArray[i].symbolNumber < 900)
				{
					iconArray[i].gotoAndStop(3);
				}
				if (iconArray[i].symbolNumber >= 700 && iconArray[i].symbolNumber < 750)
				{
					iconArray[i].gotoAndStop(4);
				}
				if (iconArray[i].symbolNumber >= 200 && iconArray[i].symbolNumber < 300)
				{
					iconArray[i].gotoAndStop(5);
				}
				if (iconArray[i].symbolNumber >= 600 && iconArray[i].symbolNumber < 700)
				{
					iconArray[i].gotoAndStop(6);
				}

				iconArray[i].conditiontextbox.text = iconArray[i].todayDate +
				"\n" + iconArray[i].weatherType + 
				"\nHigh of " + iconArray[i].highTemp + 
				"F\nLow of " + iconArray[i].lowTemp + "F";
				
				tempDate.setDate(tempDate.getDate()+dayCount);
				master.visible = true;
				master.newWeatherBtn.addEventListener(MouseEvent.CLICK, newWeatherClickFunction);
			}
			
			function newWeatherClickFunction(e:MouseEvent):void
			{
				userCity = master.newweathertextbox.text;
				
				newSO.data.myCity = master.newweathertextbox.text;
				newSO.flush();
				importXML();
			}
		}
	}
}