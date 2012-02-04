console.log("Loading rightpanel.js");

function right_panel_init(){
	// move the Select taling points label into the tab header
	var lt = $('div.list_tabs')
	lt.find('ul.list_tabs').append( lt.find('p.label'));
	
	$(window).resize(function(){
			try{  
				setTimeout(right_panel_resize,800);
			}catch(e){}
		}
	);
	setTimeout(	right_panel_resize, 200);
	
	
}

function right_panel_resize(){
	// get overall avl height
	var win_height = $(window).height();
	$('div.right_side').height(win_height); //.css({ height: win_height, overflow: 'hidden'});	
	
	// why is this different
	//$('div.right_master').height()
	
	// get fixed_height
	var fixed_height = 0;
	$('div.right_master div.fix_ht').each(
		function(){
			fixed_height += $(this).outerHeight()
		}
	);
	
	var margins = 124;
	var remaining_height = win_height - fixed_height - margins;
	
	//console.log("win_height: " + win_height + ", fixed_height: " + fixed_height + ", margins: " + margins + ", remaining_height: " + remaining_height);
	var context_height = remaining_height / 2;
	var chat_height = remaining_height / 2;
	$('div.page_context').height( context_height );
	$('div.list_tabs').height( context_height );
	
	$('div.activity_chat').height( chat_height );
	$('div#chat_log').height( chat_height - 112 );

	// reset the horizontal position
	var win_width = $(window).width() - 10;
	var left = $('div.page').position().left + $('div.left_side').width() + 20;
	var right_width = $('div.right_side').width();
	if( left + right_width > win_width){
		left = win_width - right_width;
	}
	$('div.right_side').css('left', left );
	
}

function update_suggested_action(){
	var cta = 'Hey, do this'
	$('div.suggested_action p.action').html(cta);
	
}

function update_right_panel_context(page_state){
	var page_context = $('div.right_master div.page_context');
	var list_tabs = $('div.right_master div.list_tabs');
	switch(page_state){
		case 'proposal':
				page_context.show();
				list_tabs.hide();
			break;
		
		case 'worksheet':
			page_context.hide();
			list_tabs.show();
			break;
		
	}
	
}

function set_inner_tab_content_height(){
	return 
	var rec = accordion_elements['div#curated_list'];
	rec.$el.height(rec.height);
	//console.log(" height is " + rec.height + " and child tab_content height is " + (rec.height-50));
	rec.$el.find('div.tab_content').height( (rec.height-50) );
}
