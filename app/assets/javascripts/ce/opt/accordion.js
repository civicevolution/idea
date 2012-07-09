console.log("loading accordion.js");

var show_acc_height = false;
var accordion_elements = {
	'h3#member_t': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#member': {visible: false, min: 180, max: 250, pct: 0, height: 0 },
	'h3#help_t': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#help': {visible: false, min: 100, max: 500, pct: 0, height: 0 },
	//'h3#progress_t': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	//'div#progress': {visible: false, min: 100, max: 300, pct: 0, height: 0 },
	'h3#suggested_actions_t': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#suggested_actions': {visible: false, min: 60, max: 100, pct: 0, height: 0 },
	'h3#curated_list_t': {visible: false, min: 0, max: 0, pct: 0, height: 0 },
	'div#curated_list': {visible: false, min: 160, max: 400, pct: 0, height: 0 },
	'h3#activity_chat_t': {visible: true, min: 0, max: 0, pct: 0, height: 0 },
	'div#activity_chat': {visible: true, min: 120, max: 400, pct: 0, height: 0 }
}	

function adjust_accordion_state(){
	// start with two states, signed in or visitor
	var state = 'visitor';
	if(member.ape_code != '') state = 'signed_in';
	console.log("adjust_accordion_state, state: " + state);

	switch(state){
		case 'signed_in':
			closePanel('#member');
			closePanel('#help');
			openPanel('#suggested_actions');
			openPanel('#activity_chat');
			break;
		case 'visitor':
			openPanel('#member');
			openPanel('#help');
			closePanel('#activity_chat');
			break;
	}
}

function closePanel(id){
	accordion_elements['div' + id].visible = false;
	$('h3' + id + '_t').addClass('ui-state-active').removeClass('ui-state-default').click();
}

function openPanel(id){
	accordion_elements['div' + id].visible = true;
	$('h3' + id + '_t').removeClass('ui-state-active').addClass('ui-state-default').click();
}

function init_accordion(){
	$('div#guideAccordion').multiOpenAccordion({
		tabShown: function(event, ui) {
		  //console.log('shown');
			try{
				//console.log("Make " + 'div#' + ui.tab.attr('id').replace(/_t$/,'') + ' visible = true')
				accordion_elements['div#' + ui.tab.attr('id').replace(/_t$/,'') ].visible = true;
				setTimeout(accordion_resize,800);
			}catch(e){}
		},
		tabHidden: function(event, ui) {
      //console.log('hidden');
			try{
				//console.log("Make " + 'div#' + ui.tab.attr('id').replace(/_t$/,'') + ' visible = false')
				accordion_elements['div#' + ui.tab.attr('id').replace(/_t$/,'') ].visible = false;
				setTimeout(accordion_resize,800);
			}catch(e){}
		}
	});
	//accordion_elements['div#member'].visible = false
	init_accordion_elements();
}
$(window).resize(function(){
		try{  
			setTimeout(accordion_resize,800);
		}catch(e){}
	}
);
$('div#guideAccordion a.sign_out').die('click').live('click', 
	function(){
		$(this).html('Signing out...')
		document.location = $(this).attr('href');
	}
);

var presence_img;
function init_accordion_elements(){
	adjust_accordion_state();
	// Init element jquery refs - Just one time
	for(el in accordion_elements){
		var rec = accordion_elements[el];
		rec.$el = $(el);
	}

	// init visibility & height
	for(el in accordion_elements){
		var rec = accordion_elements[el];
		if(rec.visible){
			rec.$el.show();
		}else{
			rec.$el.hide();
		}
	}
		
	accordion_elements['div#activity_chat'].offset = 
		$('div#presence').outerHeight() + $('form#chat_form').outerHeight() + 24;

	presence_img = $('div#presence img:first').clone();
}

function accordion_resize(){
	if(show_acc_height) console.log("Do accordion_resize()");
	
	// get the height of visible elements
	for(el in accordion_elements){
		var rec = accordion_elements[el];
		rec.height = rec.visible ? $(el).outerHeight() : 0;
		//if(show_acc_height) console.log("el " + el + " height is " + rec.height);
	}

	// calculate fixed tab height
	var tabs_height = 0 
	for(el in accordion_elements){
		if(el.match(/^h3/)) tabs_height += accordion_elements[el].height
	}

	var win_height = $(window).height() - 6 - 30;
	$('div#guideAccordion').css({ height: win_height, overflow: 'hidden'});	
	
	var panels_height = win_height - tabs_height;
	if(show_acc_height) console.log("win_height: " + win_height + " tabs_height: " + tabs_height + " Remaining height for panels: " + panels_height);
	
	// Allocate the remaining height to the visible panels in the table
	// 1 Sum the max heights for the visible panels
	var required_height = 0;
	for(el in accordion_elements){
		if(el.match(/^div/)){
			var rec = accordion_elements[el];
			if(rec.visible){
				rec.height = rec.max;
				required_height += rec.height;
				if(show_acc_height) console.log("el " + el + "  max height is " + rec.height);
			}
		}
	}
	if(show_acc_height) console.log("required max height: " + required_height + " Remaining height for panels: " + panels_height + " ratio " + panels_height/required_height);
	
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
					//if(rec.height > rec.max && rec.max > 0) rec.height = rec.max;
					required_height += rec.height;
					if(show_acc_height) console.log("el " + el + " height is " + rec.height);
				}
			}
		}
		if(show_acc_height) console.log("required_height as assigned: " + required_height)
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
				//console.log("el " + el + " height is " + rec.height + " and child tab_content height is " + (rec.height-30));
				if(el=='div#curated_list'){
					rec.$el.children('div.tab_content').height( (rec.height-50) );
				}else{
					rec.$el.children('div.tab_content').height( (rec.height-30) );
				}
			}else{
				rec.$el.hide();
			}
		} 
	}

	// confirm the accordion total height
	var act_height = accordion_heights();
	
	// if there is any height left over, give it to activity/chat
	if(show_acc_height) console.log("act_height: " + act_height + " win_height: " + win_height);
	if(act_height < win_height){
		if(show_acc_height) console.log("allocate remainder to chat")
		rec = accordion_elements['div#activity_chat'];
		if(rec.visible){
			rec.height += win_height - act_height;
			rec.$el.height(rec.height);
		}
	}
	// Now I need to do some internal work to make chat log div use all of its alloted space
	$('div#chat_log').height( accordion_elements['div#activity_chat'].height - accordion_elements['div#activity_chat'].offset );
	
	// reset the horizontal position
	var win_width = $(window).width() - 10;
	var left = $('div.page').position().left + $('div.left_side').width() + 20;
	var acc_width = $('div.right_side').width();
	if( left + acc_width > win_width){
		left = win_width - acc_width;
	}
	$('div.right_side').css('left', left );
	
	setTimeout(set_inner_tab_content_height,600);
	
}


function accordion_heights(){
	var calc_height = 0;
	var act_height = 0;
	for(el in accordion_elements){
		var rec = accordion_elements[el];
		if(rec.visible){
			if(show_acc_height) console.log(el + " visible: " + rec.visible + " act height: " + rec.$el.outerHeight() + " height: " + rec.height + " min: " + rec.min + " max: " + rec.max + ( (rec.min == rec.height) ? " @MIN" : '') );
			calc_height += rec.height;
			act_height += rec.$el.outerHeight();
		}else{
			if(show_acc_height) console.log(el + " HIDDEN"); 
		}
	}
	if(show_acc_height) console.log("calc_height: " + calc_height + " act_height: " + act_height );
	return act_height;
}

function set_inner_tab_content_height(){
	var rec = accordion_elements['div#curated_list'];
	rec.$el.height(rec.height);
	//console.log(" height is " + rec.height + " and child tab_content height is " + (rec.height-50));
	rec.$el.find('div.tab_content').height( (rec.height-50) );
}
