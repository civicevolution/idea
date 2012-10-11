console.log("Loading rightpanel.js");

var presence_img;
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
	presence_img = $('div#presence img:first').clone();
	if(presence_img.attr('id') == 0){
		$('div#presence img:first').remove();
	}
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
	
	////console.log("win_height: " + win_height + ", fixed_height: " + fixed_height + ", margins: " + margins + ", remaining_height: " + remaining_height);
	////var context_height = remaining_height / 2;
	//var chat_height = remaining_height / 2;
	////$('div.page_context').height( context_height );
	////$('div.list_tabs').height( context_height );
	//var sug_act_height = remaining_height / 2;
	//$('div.suggested_action').height( sug_act_height );
	//$('div.new_content').height( sug_act_height - 0 );
	//
	//$('div.activity_chat').height( chat_height );
	//$('div#chat_log').height( chat_height - 100 );
	$('div.instructions').height( remaining_height );

	// reset the horizontal position
	var win_width = $(window).width() - 10;
	var left = $('div.page_content_div').position().left + $('div.left_side').width() + 20;
	var right_width = $('div.right_side').width();
	if( left + right_width > win_width){
		left = win_width - right_width;
	}
	$('div.right_side').css('left', left );
	
	set_inner_tab_content_height();
	
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
	var div = $('div.list_tabs');
	var sel_tp_list = div.find('div.selected_tp_list');
	var tp_list_margin = sel_tp_list.outerHeight() - sel_tp_list.height();
	var tabs_height = div.find('ul.list_tabs').outerHeight();
	sel_tp_list.height( div.height() - tabs_height - tp_list_margin - 10 );
}
