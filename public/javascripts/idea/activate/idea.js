/*
	load_ape loads the ape client and triggers initialization
*/

function load_ape(chat_container_name){
	console.log("load ape.js")
	$.getScript('/javascripts/APE-Source/APE-init.js',
		function(data){
			console.log("loaded APE-Source/APE-init.js");		

			$.getScript('/javascripts/idea/gen/ape_client.js',
				function(data){
					console.log("loaded ape_client.js");	
					init_ape_client(chat_container_name);
				}
			);
		}
	);
	return false;
}

function init_ape_client(chat_container_name){
	_load_times.load_ape = new Date()
	if(params['ape'] == 'none'){
		console.log("XXXXXXXXXXXXXXXXXX APE WILL NOT BE LOADED")
	}else{
		if( typeof member.client == undefined || !member.client){
			member.client = new APE.Shoutbox( chat_container_name );
			member.client.load({
				'identifier':'chatdemo',
				'channel':'team' + team_id
			});
		}
	}

}


/*
	activate_ux_functions_misc activates core user functionality
*/

function activate_ux_functions_misc(){
	
	$(window).unload( function(){
		try{
			member.client.quit_immediately();
		}catch(e){}
	});

	//$( "#team_tab" ).bind( "tabsshow", function(event, ui) {
	//	if(ui.panel.id == "tab_proposal"){
	//		update_proposal();
	//	}else if(ui.panel.className.match(/discussion/)){
	//		ellipsis(ui.panel);
	//	}
	//});
	
	$( "div.question_tabs" ).bind( "tabsshow", function(event, ui) {
		//if(ui.panel.className.match(/discussion/)){
		var tab_window = $('div.tab_window',ui.panel);
		if(tab_window.hasClass('discussion')){
			//console.log("tabsshow do ellipsis")
			ellipsis(tab_window);
		}
	});	

	$( "div.team_info_tabs" ).bind( "tabsshow", function(event, ui) {
		//if(ui.panel.className.match(/discussion/)){
		var tab_window = $('div.tab_window',ui.panel);
		if (tab_window.hasClass('tab_proposal')){
			update_proposal();
			//console.log("tabsshow do update_proposal")
		}
	});	


	
	$('form').die('focus').live('focus',
	  function(){
	    setFormFocusFade(this)
	  }
	)
	
	$('form.add_comment_form').each(
		function(){
			var form = $(this);
			activate_comment_form( form );
			$('div.add_comment label',form).html('Please comment on this question');
		}
	);

	$('form.add_answer_form').each(
		function(){
			try{
				var form = $(this);
				var par_id = Number(form.closest('.Question').attr('id').match(/\d+/));
				$("input[name='par_id']",form).val(par_id)
				activate_answer_form( form );
			}catch(e){console.log("form.add_answer_form init error: " + e.message)}
		}
	);
	
	$('div.Question,div.Answer').each( function(){ $('div.coms_inner',this).prepend( $(this).children('div.Comment' )) });
		
	

	
	$('a.sign_out').die('click').live('click', 
		function(){
			//console.log("sign_out");
			try{
				member.client.quit_immediately();
			}catch(e){}
		}
	)
	
	$('a.hide_instr').die('click').live('click',
  	function(){
  		try{
				var	a = $(this);
				if(a.html().match(/Hide/)){
					var ul = a.closest('ul');
					ul.hide(500);
					var new_a = a.clone(true);
					new_a.html("Show instructions").addClass('show_instructions')
					ul.prev('p').append(new_a)
				}else{
					var ul = a.parent().next('ul');
					ul.show(500);
					a.remove();
				}
			}catch(e){console.log("close_instr error: " + e)}
			return false;
		}
	);
  
	$('table.checklist a').click( function(){var p = $(this).closest('td').find('p.details'); if(p.is(':visible')){p.hide()}else{p.show()}; return false; })
	
	$('table.team_roles p a').die('click').live('click',
	  function(){
	    var details = $(this).closest('td').find('div');
	    if(details.is(':visible')){
	      details.hide();
	      $(this).html('details');
	    }else{
	      details.show();
	      $(this).html('hide details')
	    }
	    return false;
	  }
	)

	$('form.request_help button').click(
		function(){
			try{ 
				request_help_submit($(this.form))
			}catch(e){console.log("request_help error: " + e.message)}
			return false;
		}
	)

	$('div#tab_my_profile a.upload_photo').click(function(){ $(this).closest('div').find('form.upload_member_photo').show(); return false;});
	//$("a[rel^='prettyPhoto']").prettyPhoto({theme: 'dark_rounded'});
	//$('table.team_roles td > a').die('click').live('click', team_role_volunteer);
	
	//$('div.endorse_proposal').css('opacity',.3).find('input').attr('disabled','disabled').end().find('textarea').attr('disabled','disabled');
	//$('div.public_endorsements table').css('opacity',.3);
	//$('div.member_endorsements table').css('opacity',.3);
	
	$('a.team_info').die('click').live('click',
		function(){
			var dialog = $('div#team_stats').dialog( {title : 'Team information', modal : true, width: 500 }); 
			
			
			return false;
		}
	)

	$('a.help').die('click').live('click',
		function(){
			var dialog = $('div#team_help').dialog( {title : 'Help', modal : true, width: 600 }); 
			
			
			return false;
		}
	)
	
	$('a.send_team_message').die('click').live('click',
		function(){
			$.get('/idea/email_teammates?team_id=' + team_id,
				function(data){
					temp.data = data
				  var pcs = data.split(/<script/)
					$(pcs[0]).dialog( {title : 'Send a message to your teammates', modal : true, width: 500 } )
					$('head').append('<script' + pcs[1])
				})
			return false;
		}
	);
	

} // end activate_ux_functions_misc 



/*
	activate_ux_functions_edit activates core user edit functionality
*/

function activate_ux_functions_edit(){

  $('a.edit_answer').die('click').live('click',
  	function(){
			console.log("Edit answer");
  		try{
  			var a = $(this);
				if( a.closest('div.qa').find('form.add_answer_form').size() > 0) return false;


				var ans = a.closest('div.qa').find('div.answer');
				var ctls = a.closest('p');
  			//console.log("edit this answer")
				var id = Number(ans.attr('id').match(/\d+$/))
				var mode = 'edit';
				var par_id = 0;
				//console.log("id: " + id)
				var form = $( jsonFn.add_answer_form({par_id : par_id, mode : mode, id : id }) );
				$('label',form).html("Please edit this answer");
				var char_cnt = Number(ans.closest('div.answer_section').attr('criteria').match(/\d+$/))
				//console.log("change answer form character count to " + char_cnt )
				form.find('span.char_ctr').html(char_cnt + ' characters left');
				$('a.clear',form).removeClass('clear').addClass('cancel').html('Cancel');
				var s  = ans.html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/<br\/?>/gi,'\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'');
				
				$('textarea',form).html(s);
				ans.before( form );
				orig_ans = $.merge(ans,ctls).hide(1000)
				activate_answer_form(form,orig_ans);
  		}catch(e){console.log("edit_answer error: " + e)}
  		return false;
  	}
  );


} // end activate_ux_functions_edit


function resizeUI(){
	return
	try{
		// resize only a few times.
		// only resize if the height or width has changed
	
		//Current height and width
		var curWinWidth = $(window).width();
		var curWinHeight = $(window).height();
	
		var curTopHeight = $('#top').outerHeight({margin: true}); //36; // can I calculate this?

		// compare the new height and width with old one
		if(curWinWidth == lastWinWidth && curWinHeight == lastWinHeight ) return;
		//Update the width and height
		lastWinWidth = curWinWidth;
		lastWinHeight = curWinHeight;
		//console.log("resizeUI v2")

		// adjust proposal height
		//$('div#proposal').height( $("div#nav_chat_col").height()  );//avl_height - 70);
		$('div#proposal').height( curWinHeight - curTopHeight - 20 );
	
		set_page_tabs_height(curPageId);

		// set the height of the chat windows

		var chat_height = curWinHeight - $('div#page_chat_boxes').offset().top - 100; //90;
		$('div.shoutbox_msg').css('height',chat_height);
		
		//debugger
		// adjust width of proposal
		$('body').width('auto');
		var win_width = $(window).width();
		var nav_width = $("div#nav_chat_col").width();
		if(win_width < 800){
			var prop_width = win_width < 800 ? 800 - nav_width - 20: win_width - nav_width - 20;
			$('body').width(800);
			var prop_width = 800 - nav_width - 20;
		}else{
			var prop_width = win_width - nav_width - 60;
		}
		//console.log("set width to " + prop_width)
		$('div#proposal').width( prop_width );
		$('div.comment').css('width', 'auto');

	}catch(e){console.log("resizeUI error: " + e)}
}



/*
	activate_ux_appearance updates the UI
*/

function activate_ux_appearance(){
	
	document.title = $('h3.team_title:first').text();
	
	
	$('div.coms').addClass('coms_show_one_line');
	$('div.Comment_entry').addClass('one_line_comment').removeClass('full_comment_display')
	
	
	// add link com counts
	$('div.Page').each(
		function(){
			update_embedded_discussion_links(this);
		}
	)
} // end activate_ux_appearance


/*
	activate_debug_functions_core contains important functions and links for debugging
*/


function reload_css(){
	$('head').append('<link href="/stylesheets/ce1as.css?' + Math.round(Math.random() * 10000000000) + '" media="screen" rel="stylesheet" type="text/css" />');
	$('head').append('<link href="team/get_dev_css?' + Math.round(Math.random() * 10000000000) + '" media="screen" rel="stylesheet" type="text/css" />');
}		

function request_help_submit(form){
	var msg = form[0].message.value;
	msg = msg.replace(/^\s+/,'').replace(/\s+$/,'')
	
	var sel = form.find('select')[0];
	var cat_id = sel.selectedIndex;
	if(cat_id == 0){
		$(sel).addClass('form_error_border').before('<p class="form_error_text">Please select the assistance you need</p>')
		return false;
	}
	
	var btn = $('button',form);
	btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>');
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
	if(msg!=''){
		form.ajaxSubmit({ 					
		  type: "POST", 
		  url: "/welcome/request_help", 
			data: {message : msg, category : cat_id, user_agent : navigator.userAgent, url: document.location.href, name: form[0].sender_name.value, 
					email : form[0].sender_email.value, error_log : 'no log recorded', load_time: 0  },
		  success: function(data,status){ 
				//console.log("chat submit success, call dispatchPageChatMessage");
				var dialog = $('<div>' + data + '</div>').dialog( {title : 'Thank you', modal : true, width: 500 }); 
				form[0].message.value = ''
				btn.removeAttr('disabled').next('img').remove()
		  },
			error : function(xhr,errorString,exceptionObj){
				console.log("Error, xhr: " + xhr.responseText)
				try{
					show_form_error(form, xhr.responseText);
					btn.removeAttr('disabled').next('img').remove()
				}catch(e){
					btn.removeAttr('disabled').next('img').remove()
					console.log("Chat submit error: " + e)
					$('<div><p>Sorry, we cannot process your chat message at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
				}
			}
		});
		return false;			
	}
}	

$('form.upload_member_photo input[type="submit"]').die('click').live( 'click', 
	function(){
		try{
			upload_pic($(this.form));
		}catch(e){console.log("upload_member_photo v1 error: " + e)}
		return false;
	}
);

$('form.upload_member_photo a.cancel').die('click').live( 'click', 
	function(){
		$(this).closest('form').hide();		
		return false;
	}
);

function upload_pic(form){
	console.log("upload an image v5");
	temp.form = form;
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
	var file = form.find('input[type="file"]');
	if( file.val() == '' ){
		file.after( '<p class="form_error_text">Select a photo</p>');
		return false;
	}
	
	var btn = $('input[type="submit"]',form);
	btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')
	
	form.ajaxSubmit({ 					
	  type: "POST", 
	  url: "/welcome/upload_member_photo", 
		//dataType: 'json',
		success: function(data,status){ 
		 //console.log("upload image success")
			try{
				url = data;
				$('img.signin_pic').attr('src', url.replace(/^\/+/,'/') );
				$('form.upload_member_photo').hide();
				$('span.default_pic').hide()
				btn.removeAttr('disabled').next('img').remove()
			}catch(e){
				try{
					console.log("try to extract html and convert - if this works, data is from iframe mediated post")
					data = $(data).html()
					data = eval(data)
					console.log("html eval ok, call show_error")
					show_form_error(form, data);
					btn.removeAttr('disabled').next('img').remove()
					return;								
				}catch(e){
					temp.com_submit_error = { data: temp.com_submit, status: status}
					console.log("Comment submit success has an error, see temp.com_submit_error: " + e)
					btn.removeAttr('disabled').next('img').remove()
					return;
				}
			}
	  },
		error : function(xhr,errorString,exceptionObj){
			console.log("Error, xhr: " + xhr.responseText)
		}
	});

   return false;
}

function send_load_report(){
	try{
		start = _load_times.start ? _load_times.start.getTime() : 0;
		page_loaded = _load_times.page_loaded ? _load_times.page_loaded.getTime() : 0;
		load_ape = _load_times.load_ape ? _load_times.load_ape.getTime()  : 0;
		all_init = _load_times.everything_initialized ? _load_times.everything_initialized.getTime() : 0;
		
		$.post('/client_debug/load_report', {height: $(window).height(), width: $(window).width(), start: start, 
			page_loaded: page_loaded, load_ape: load_ape, all_init: all_init, team_id: team_id })
	}catch(e){console.log("Failed to send load_report with e: " + e.message)}
}

