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
			//member.client.quit_immediately();
			console.log("quit APE immediately")
		}catch(e){}
	});

	$('a.sign_out').die('click').live('click', 
		function(){
			//console.log("sign_out");
			try{
				member.client.quit_immediately();
			}catch(e){}
		}
	)
	
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

				var ans = a.closest('div.qa').find('div.answer div.answer_body');
				var ctls = a.closest('p');
  			//console.log("edit this answer")
				var id = Number(ans.attr('id').match(/\d+$/))
				if(ans.hasClass('default')){
					var mode = 'add';
					var par_id = a.closest('div.qa').attr('item_id');
				}else{
					var mode = 'edit';
					var par_id = 0;
				} 
				
				//console.log("id: " + id)
				var form = $( jsonFn.add_answer_form({par_id : par_id, mode : mode, id : id, char_cnt: Number( a.closest('div.qa').attr('ans_criteria').match(/\d+$/)) }) );
				$('label',form).html("Please edit this answer").css('margin','4px 0 10px 0');
				//var char_cnt = Number(ans.closest('div.answer_section').attr('criteria').match(/\d+$/))
				//console.log("change answer form character count to " + char_cnt )
				//form.find('span.char_ctr').html(char_cnt + ' characters left');
				$('a.clear',form).removeClass('clear').addClass('cancel').html('Cancel');
				if(ans.hasClass('default')){
					form.find('label').html('Please write an answer for this question')
				}else{
					$('textarea',form).html(
						ans.html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/<br\/?>/gi,'\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'')
					);
				} 
				ans.before( form );
				orig_ans = $.merge(ans,ctls).hide(1000);
				activate_answer_form(form,orig_ans);
				ans.closest('div.answer_section').find('div.ans_comment_links').hide();
				$('textarea',form).focus();
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

