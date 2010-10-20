/*
	load_ape loads the ape client and triggers initialization
*/

function load_ape(chat_container_name){
	
	if(params['ape'] == 'none'){
		console.log("XXXXXXXXXXXXXXXXXX APE WILL NOT BE LOADED")
	}else{
		//console.log("index.html javascript to create the client, client: " + client)
		if( typeof member.client == undefined || !member.client){
			//console.log("create client")
			member.client = new APE.Shoutbox( chat_container_name );
			member.client.load({
				'identifier':'chatdemo',
				'channel':'team' + team_id
			});
		}
	}

}

var apeResetWatchDog = setTimeout(reinitializeApe,90000);

function reinitializeApe(){
	console.log("reinitializeApe - resetting APE comm now")
	delete member.client
	$('iframe.ape').remove()
	chat_container_name = 'page_chat_boxes';
	member.client = new APE.Shoutbox( chat_container_name );
	member.client.load({
		'identifier':'chatdemo',
		'channel':'team' + team_id
	});		
	console.log("reinitializeApe - APE comm has been reset")
}


/*
	activate_ux_function_calls activates core user functionality
*/

function activate_ux_function_calls(){
	
	$('a.view_history').die('click').live('click',view_history);
	$('a.view_transcript').die('click').live('click',view_chat_transcript);
	
	
	//$('a.my_teams').die('click').live('click', link_disabled);
	//$('a.settings').die('click').live('click', link_disabled);
	//$('a.feedback').die('click').live('click', link_disabled);
	//$('a.help').die('click').live('click', link_disabled);
	
	// defined functions 
	
	function link_disabled(){
		$('<div><p>Sorry, this function is not currently active, we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
		return false;
	}	

} // end activate_ux_function_calls

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
			ellipsis(tab_window);
		}else if (tab_window.hasClass('tab_proposal')){
			update_proposal();
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
		
	
	
	
	$('div#proposal_view .question').die('click').live('click',
	  function(){
	    //console.log("this.id: " + this.id)
	    //console.log("Number(this.id.match(/\d+/)): " + Number(this.id.match(/\d+/)))
			// target id is for question, find question's page
			temp.prop_ques = this;
			id = Number(this.id.match(/\d+/))
			change_page(Number( $('#i' + id).closest('.Page').attr('id').match(/\d+/)))
	    $("div#proposal > div.Team > div.Page[id='i" + curPageId + "']").find('ul.qa_tabs li').eq(2).click()
			return false;
	  }
	);
	
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
	$("a[rel^='prettyPhoto']").prettyPhoto({theme: 'dark_rounded'});
	$('table.team_roles td > a').die('click').live('click', link_disabled);
	
	$('div.endorse_proposal').css('opacity',.3).find('input').attr('disabled','disabled').end().find('textarea').attr('disabled','disabled');
	$('div.public_endorsements table').css('opacity',.3);
	$('div.member_endorsements table').css('opacity',.3);
	

} // end activate_ux_functions_misc 

/*
	activate_ux_pages activates the pages
*/

function activate_ux_pages(){
	
	var page_links = $('#nav_chat_col div.nav a');
	curPageId = page_links[0].getAttribute('href').match(/\d+$/)[0];
	//console.log("curPageId: " + curPageId)
	//console.log("set links to change_page for page_links.size(): " + page_links.size() )
	page_links.die('click').live('click', change_page);
	$('div#nav_chat_col > .nav a:first').click();
	
	$('div.member_indicator').attr({href:'#page_presence_cluetip', rel: '#page_presence_cluetip', title: 'Team members viewing this page'}).cluetip(
	  {local: true, 
	  hideLocal: true, 
	  cursor: 'pointer',
	  onActivate: NOTIFIER.report_page_presence}
	);

	
	$('a.view_history').cluetip({
	  cluetipClass: 'jtip', 
	  arrows: true, 
	  dropShadow: false, 
	  height: '300px', 
	  width: '400px',
 	  sticky: true,
		showTitle: false,
	  positionBy: 'bottomTop'
	});	
	
	
} // end activate_ux_pages





/*
	activate_ux_functions_edit activates core user edit functionality
*/

function activate_ux_functions_edit(){

  $('a.edit_answer').die('click').live('click',
  	function(){
  		try{
  			var a = $(this);
				var ans = a.closest('td').find('div.answer');
				var ctls = a.closest('p');
  			//console.log("edit this answer")
				var id = Number(a.attr('href').match(/\d+$/))
				var mode = 'edit';
				var par_id = 0;
				//console.log("id: " + id)
				var form = $( jsonFn.add_answer_form({par_id : par_id, mode : mode, id : id }) );
				$('label',form).html("Please edit this answer");
				var char_cnt = Number(ans.closest('div.answers').attr('criteria').match(/\d+$/))
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

  $('a.edit_bs_idea').die('click').live('click',
  	function(){
  		try{
  			var a = $(this);
				var idea = a.closest('td').find('div.bs_idea');
				var ctls = a.closest('p');
  			//console.log("edit this idea, size: " + idea.size())
				var id = Number(a.attr('href').match(/\d+$/));
				var ideas = idea.closest('div.bs_ideas');
				var q_id = Number(ideas.attr('id').match(/\d+/))
				var mode = 'edit';
				//console.log("id: " + id)
				var form = $( jsonFn.add_bs_idea_form({id : id, q_id: q_id, mode : mode }) );
				$('label',form).html("Please edit this idea");
				var char_cnt = Number(idea.closest('div.bs_ideas').attr('criteria').match(/\d+$/))
				//console.log("change answer form character count to " + char_cnt )
				form.find('span.char_ctr').html(char_cnt + ' characters left');
				
				$('div.control_line',form).css('margin-bottom','40px');
				$('a.clear',form).removeClass('clear').addClass('cancel').html('Cancel');
				var s  = idea.html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'');
		 		
				$('textarea',form).html(s);
				//console.log("ready to show form before idea: size: " + idea.size())
				form.hide();
				ctls.hide(1000);
				idea.hide(1000, 
					function(){
						//console.log("now add the idea form idea.size: " + idea.size())
						idea.before( form );
						form.show(1000)
					}
				);
				orig_idea = $.merge(ctls,idea);
				activate_idea_form(form,orig_idea);
  		}catch(e){console.log("edit_idea error: " + e)}
  		return false;
  	}
  );

	activate_idea_forms();


} // end activate_ux_functions_edit


/*
	activate_ux_functions_discussion activates core user discussion functionality
*/

function activate_ux_functions_discussion(){
	
	$('div.bs_ideas a.com_on_tgt, div.answers a.com_on_tgt').die('click').live('click', show_embedded_com_form);

	//console.log("open_all.click")

	//console.log("open_all_idea_com.click")
	$('a.open_all_idea_coms').die('click').live('click',
		function(){
			try{
				var a = $(this);
				var par = a.closest('.embedded_discussion');
				if( a.html().match(/Open/)){
					$('div.Comment',par).addClass('full_comment_display').removeClass('one_line_comment');
					a.html('Close all comments');
				}else{
					$('div.Comment',par).addClass('one_line_comment').removeClass('full_comment_display');
					a.html('Open all comments');
				}			
			}catch(e){console.log("open_all error: " + e)}
			return false;
		}
	);

	$('a.view_target').die('click').live('click',
		function(){
			try{
				var a = $(this);
				var par = a.closest('.Comment_entry');
				var title = a.html();
				if( title.match(/View/)){
					var type = par.attr('target_type');
					var id = par.attr('target_id');
				  //console.log("Show the target type: " + type + ", id: " + id);
				
					if(type == 11){
						//console.log("get tgt idea with id: " + id)
						var label = "idea";
						var tgt = $('#bs_' + id).parent().children().clone(true);
						$('.edit_bs_idea',tgt).hide();
						//$('.edit_bs_idea',tgt).attr('class','view_target_source').html('View full idea');
						$('.com_on_tgt',tgt).html('Close').click(
							function(){
								//console.log("close this target");
								$(this).closest('.target').hide(1000, 
									function(){ 
										$(this).remove();
										a.html( title.replace(/Hide/,'View') );
									} 
								);
								return false;
							}
						);
					}else if(type==2){
						//console.log("get tgt answer with id: " + id)
						var label = 'answer';
						var tgt = $('#ans_' + id).parent().children().clone(true);
						$('.edit_answer',tgt).hide();
						$('.com_on_tgt',tgt).html('Close').click(
							function(){
								//console.log("close this target");
								$(this).closest('.target').hide(1000, 
									function(){ 
										$(this).remove();
										a.html( title.replace(/Hide/,'View') );
									} 
								);
								return false;
							}
						);
						
					}
					if(tgt){
						var display_div = $('<div class="target"></div>');
						par.closest('.item').prepend(display_div);
						display_div.append('<p class="targeted_object">The ' + label + ' this comment discusses<\p>');
						display_div.append(tgt);
						a.html( title.replace(/View/,'Hide') );
					}

				}else{
				  //console.log("Hide the target")
					a.html( title.replace(/Hide/,'View') );
					par.closest('.item').find('.target').hide(2000, function(){ $(this).remove()});
				}			
			}catch(e){console.log("view_target error: " + e)}
			return false;
		}
	);

} // end activate_ux_functions_discussion



function resizeUI(){
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
	$('div.Comment').addClass('one_line_comment').removeClass('full_comment_display')
	
	
	// add link com counts
	$('div.Page').each(
		function(){
			update_embedded_discussion_links(this);
		}
	)
} // end activate_ux_appearance

function update_embedded_discussion_links(page){
	//console.log("update_embedded_discussion_links");
	var page_disc = $(page).find('.inner_question_discussion');
	// I can also call this to update the link for a single item, in which case page is an element in the page
	var single_mode = false;
	if(page_disc.size() == 0 ){
		page_disc = $(page).closest('.Page').find('.inner_question_discussion');
		single_mode = true;
		temp.update_embedded_discussion_links_single_mode_page = page
	} 
	//console.log("single_mode: " + single_mode)
	$('a.com_on_tgt',page).each(
	  function(){
			//if(single_mode)debugger
	    var link = $(this);
	    var id = Number(link.attr('href').match(/\d+$/))
			if(link.hasClass('idea')){
		    var idea_coms = $('div[target_id=' + id + '][target_type=11]',page_disc).parent().find('div.comment');
				var new_coms = idea_coms.find('span.new._comment')
		    //console.log("find coms with target_id: " + id + " coms: " + idea_coms.size() )
				if(new_coms.size()>0){
					var str = ('View ' + new_coms.length + ' new comment') + ((new_coms.length==1) ? '' : 's')
					link.css('color','red');
					if(single_mode){
						//console.log("single mode idea , str: " + str)
			      link.attr('title_count', str );
						if(!link.html().match(/Close/)){
							link.html( str );
						}
					}else{
			      link.html( str );
					}
				}else if(idea_coms.size()>0){
		      link.html('View ' + idea_coms.size() + ' comments')
		    }else{
		      link.html('Discuss')
		    }
			}else{
		    var ans_coms = $('div[target_id=' + id + '][target_type=2]',page_disc).parent().find('div.comment');
				var new_coms = ans_coms.find('span.new._comment')
		    //console.log("find coms with target_id: " + id + " coms: " + idea_coms.size() )
				if(new_coms.size()>0){
					var str = ('View ' + new_coms.length + ' new comment') + ((new_coms.length==1) ? '' : 's')
					link.css('color','red');
					if(single_mode){
						//console.log("single mode ans , str: " + str)
			      link.attr('title_count', str );
						if(!link.html().match(/Close/)){
							link.html( str );
						}
					}else{
			      link.html( str );
					}					
				}else if(ans_coms.size()>0){
		      link.html('View ' + ans_coms.size() + ' comments')
		    }else{
		      link.html('Discuss')
		    }
			}
	  }
	)
}

/*
	activate_debug_functions_core contains important functions and links for debugging
*/

//function activate_update_css_functions(){
//	var h = $('div#logo')
//	h.wrap('<a href="#"></a>');
//	h.closest('a').click( function(){
//		$('head').append('<link href="/stylesheets/ce1a.css?' + Math.round(Math.random() * 10000000000) + '" media="screen" rel="stylesheet" type="text/css" />');
//		$('head').append('<link href="team/get_dev_css?' + Math.round(Math.random() * 10000000000) + '" media="screen" rel="stylesheet" type="text/css" />');
//	});		
//} // end activate_update_css_functions

function reload_css(){
	$('head').append('<link href="/stylesheets/ce1as.css?' + Math.round(Math.random() * 10000000000) + '" media="screen" rel="stylesheet" type="text/css" />');
	$('head').append('<link href="team/get_dev_css?' + Math.round(Math.random() * 10000000000) + '" media="screen" rel="stylesheet" type="text/css" />');
}		


/*
	activate_debug_functions contains non-essential functions and links for debugging
*/

function activate_debug_functions_extras(){

		$('#get_ape_item').die('click').live('click', request_ape_send);
	
		$('a.test_template').unbind('click').click( load_templates );
	
		$('a.update_com_func').click(
			function(){
				//console.log(".update_com_func'.click")
				$.getScript('/javascripts/app_dev.js')
				return false;
			}
		).click();

		$('a.test_pure').click(
			function(){
				$.getScript('/javascripts/test_pure.js')
				return false;
			}
		);
	
		$('a.update_insert_func').click(
			function(){
				//console.log(".update_com_func'.click")
				$.getScript('/javascripts/item_update.js')
				return false;
			}
		);	
	
		$('.clear_ape_updates').unbind('click').click(
			function(){
				//console.log("clear_ape_updates")
				return false;
			}
		);

		$('.clear_shoutbox_func').unbind('click').click(
			function(){
				//console.log("clear_shoutbox_func")
				$('#shoutbox_msg').html("");
				return false;
			}
		);

		$('a.clear_ape_updates').unbind('click').click(
			function(){
				//console.log('clear the divs I inserted')
				$('div.test_insert').remove()
				return false;
			}
		);
		
		$('a.load_js').click(
			function(){
				//console.log(".update_com_func'.click")
				$.getScript('/javascripts/temp.js')
				$.getScript('/javascripts/item_update.js')
				return false;
			}
		).click();
} // end activate_debug_functions_extras


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