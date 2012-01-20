console.log("loading app_resize.js");


var accordion_elements = {
	'h3#member': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#member': {visible: false, min: 60, max: 300, pct: 0, height: 0 },
	'h3#curated_list': {visible: false, min: 0, max: 0, pct: 0, height: 0 },
	'div#curated_list': {visible: false, min: 160, max: 400, pct: 0, height: 0 },
	'h3#help': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#help': {visible: false, min: 100, max: 500, pct: 0, height: 0 },
	'h3#progress': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#progress': {visible: false, min: 100, max: 300, pct: 0, height: 0 },
	'h3#suggested_actions': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#suggested_actions': {visible: false, min: 60, max: 300, pct: 0, height: 0 },
	'h3#activity_chat': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#activity_chat': {visible: true, min: 120, max: 400, pct: 0, height: 0 }
}	

function init_accordion_elements(){
// Init element jquery refs - Just one time
		for(el in accordion_elements){
			var rec = accordion_elements[el]
			rec.$el = $(el);
		}

// init visibility & height
		for(el in accordion_elements){
			var rec = accordion_elements[el]
			if(rec.visible){
				rec.$el.show();
			}else{
				rec.$el.hide();
			}
		}
		
		accordion_elements['div#activity_chat'].offset = 
			$('div#presence').outerHeight() + $('form#chat_form').outerHeight() + 24;
			
}
init_accordion_elements();


function accordion_resize(){
	console.log("Do accordion_resize()");
	
	// get the height of visible elements
	for(el in accordion_elements){
		var rec = accordion_elements[el];
		rec.height = rec.visible ? $(el).outerHeight() : 0;
		//console.log("el " + el + " height is " + rec.height);
	}

	// calculate fixed tab height
	var tabs_height = 0 
	for(el in accordion_elements){
		if(el.match(/^h3/)) tabs_height += accordion_elements[el].height
	}

	var win_height = $(window).height() - 6 - 10;
	$('div#guideAccordion').css({ height: win_height, overflow: 'hidden'});	
	
	var panels_height = win_height - tabs_height;
	console.log("win_height: " + win_height + " tabs_height: " + tabs_height + " Remaining height for panels: " + panels_height);
	
	// Allocate the remaining height to the visible panels in the table
	// 1 Sum the max heights for the visible panels
	var required_height = 0;
	for(el in accordion_elements){
		if(el.match(/^div/)){
			var rec = accordion_elements[el];
			if(rec.visible){
				rec.height = rec.max;
				required_height += rec.height;
				console.log("el " + el + "  max height is " + rec.height);
			}
		}
	}
	console.log("required max height: " + required_height + " Remaining height for panels: " + panels_height + " ratio " + panels_height/required_height);
	
	// 2 If required_height is less than panels_height, just use maxs I already set
	if(required_height > panels_height){
		// 3 If sum is greater than avl, get ratio and set height as ratio of each max
		var ratio = panels_height/required_height;
		var required_height = 0;
		for(el in accordion_elements){
			if(el.match(/^div/)){
				var rec = accordion_elements[el];
				if(rec.visible){
					rec.height = rec.max * ratio;
					// 4 If any height is less than its min, steal from the other panels
					if(rec.height < rec.min) rec.height = rec.min;
					required_height += rec.height;
					console.log("el " + el + " height is " + rec.height);
				}
			}
		}
		console.log("required_height as assigned: " + required_height)
		// 5 If all panel heights hit their min, make full accordion scroll y
		if(required_height > panels_height){
			// determine how much reduction I need
			// apply it to the divs whose height > min
			// if every panel height = min, add scroll-y
		}
	}	
	
	// Finally, assign the values to panels expressed by the table
	var tabs_height = 0 
	for(el in accordion_elements){
		if(el.match(/^div/)){
			var rec = accordion_elements[el];
			if(rec.visible){
				rec.$el.show();
				rec.$el.height(rec.height);
			}else{
				rec.$el.hide();
			}
		} 
	}

	// confirm the accordion total height
	var act_height = accordion_heights();
	
	// if there is any height left over, give it to activity/chat
	console.log("act_height: " + act_height + " win_height: " + win_height);
	if(act_height < win_height){
		console.log("allocate remainder to chat")
		rec = accordion_elements['div#activity_chat'];
		if(rec.visible){
			rec.height += win_height - act_height;
			rec.$el.height(rec.height);
		}
	}
	// Now I need to do some internal work to make chat log div use all of its alloted space
	$('div#chat_log').height( accordion_elements['div#activity_chat'].height - accordion_elements['div#activity_chat'].offset );
	
}


function accordion_heights(){
	var calc_height = 0;
	var act_height = 0;
	for(el in accordion_elements){
		var rec = accordion_elements[el];
		if(rec.visible){
			console.log(el + " visible: " + rec.visible + " act height: " + rec.$el.outerHeight() + " height: " + rec.height + " min: " + rec.min + " max: " + rec.max + ( (rec.min == rec.height) ? " @MIN" : '') );
			calc_height += rec.height;
			act_height += rec.$el.outerHeight();
		}else{
			console.log(el + " HIDDEN"); 
		}
	}
	console.log("calc_height: " + calc_height + " act_height: " + act_height );
	return act_height;
}