/*!
 * Autogrow Textarea Plugin Version v2.0
 * http://www.technoreply.com/autogrow-textarea-plugin-version-2-0
 *
 * Copyright 2011, Jevin O. Sewaruth
 *
 * Date: March 13, 2011
 */
jQuery.fn.autoGrow = function(o){
	
	return this.each(function(){
		//console.log("autoGrom this.cols: " + this.cols)
		//debugger
		var fixed_width = false;
		// if cols is not set, or < 5, determine the # cols based on the width
		if(this.cols < 5 ){
			//console.log("autogrow - determine the # cols based on the width");
			
			//var w = this.offsetWidth
			this.style.width = 'auto';
			this.cols = 1;
			var w1 = this.offsetWidth;
			this.cols = 2;
			var w2 = this.offsetWidth;
			this.style.width = '';
			this.cols = Math.floor(this.offsetWidth / (w2-w1));
			fixed_width = true;
		}

		if(o && o.minHeight){
			//console.log("set the # of rows")
			this.rows = 1;
			var h1 = this.offsetHeight;
			this.rows = 2;
			var h2 = this.offsetHeight;
			var rows = Math.floor(o.minHeight/(h2-h1));
			this.rows = rows > 2 ? rows : 2;
			//console.log("rows: " + this.rows)
		} 
		// Variables
		var colsDefault = this.cols;
		var rowsDefault = this.rows;
		

		//Functions
		var grow = function() {
			growByRef(this);
		}
		
		var growByRef = function(obj) {
			var linesCount = 0;
			var lines = obj.value.split('\n');
			
			for (var i=lines.length-1; i>=0; --i)
			{
				linesCount += Math.floor((lines[i].length / colsDefault) + 1);
			}

			if (linesCount >= rowsDefault)
				obj.rows = linesCount + 1;
			else
				obj.rows = rowsDefault;
		}
		
		var characterWidth = function (obj){
			var characterWidth = 0;
			var temp1 = 0;
			var temp2 = 0;
			var tempCols = obj.cols;
			
			obj.cols = 1;
			temp1 = obj.offsetWidth;
			obj.cols = 2;
			temp2 = obj.offsetWidth;
			characterWidth = temp2 - temp1;
			obj.cols = tempCols;
			
			return characterWidth;
		}
		//debugger
		// Manipulations
		this.style.height = "auto";
		this.style.overflow = "hidden";
		//this.style.width = "auto";
		if(!fixed_width){
			//console.log("autoGrow fixed_width is false")
			this.style.width = "auto";
			this.style.width = ((characterWidth(this) * this.cols) + 6) + "px";
		}
		//debugger
		this.onkeyup = grow;
		this.onfocus = grow;
		this.onblur = grow;
		growByRef(this);
	});
};
