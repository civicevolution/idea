var ie7 = false;
$(function(){

	if($.browser.msie){
		//alert("MSIE version is " + $.browser.version)
		if($.browser.version.match(/7\./)){
			ie7 = true;
		}
	} 

	$('form.join_proposal_team').unbind('submit').submit(
		function(){
			try{
				join_proposal_team(this);
			}catch(e){console.log("join_proposal_team v1 error: " + e)}
			return false;
		}
	);

	$('form.join_proposal_team input[type="submit"]').unbind('click').click( 
		function(){
			try{
				join_proposal_team($(this.form));
			}catch(e){console.log("join_proposal_team v2 error: " + e)}
			return false;
		}
	);

	$('form.add_comment_form').each(
		function(){
			var form = $(this);
			activate_comment_form( form );
		}
	);

	$('form.invite_friends').unbind('submit').submit(
		function(){
			try{
								console.log("invite_friends")
				invite_friends(this);
			}catch(e){console.log("invite_friends v1 error: " + e)}
			return false;
		}
	);

	$('form.invite_friends input[type="submit"]').unbind('click').click( 
		function(){
			try{
				console.log("invite_friends")
				invite_friends($(this.form));
			}catch(e){console.log("invite_friends v2 error: " + e)}
			return false;
		}
	);

	$('form.invite_friends a.clear').unbind('click').click(
		function(){
			try{
				$('textarea', this.form).val('')
				return false;
			}catch(e){console.log("invite_friends clear error: " + e)}
			return false;
		}
	);

	$('a.pub_com').die('click').live('click', show_pub_coms);
	$('a.open_all').html('Open all comments');
	$('div.close_1com').hide()

	update_discussion_links();

	$('div.Comment').addClass('one_line_comment').removeClass('full_comment_display')
	
	
	$('img.share_this').click( 
		function(){
			$('<div><p>Sorry, one click sharing is not currently active.</p><p>You can still go to your favorite sites and share this page\'s address:</p><p> ' + document.location.href + '</p></div>').dialog( {title : 'Warning', modal : true, width : 400 } )		
		}
	);


}); // end of jquery onload

function join_proposal_team(form){
	console.log("join_proposal_team submit")
	
	var btn = $('input[type="submit"]',form);
	btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')
	
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
	form.ajaxSubmit({ 					
	  type: "POST", 
		url: 'http://' + document.location.host + '/team/join_proposal_team',
	  success: function(data,status){ 
			$('<div>' + data + '</div>').dialog( {title : 'Thank you', modal : true, width: 500, 
				close: 
					function(){
						//console.log("join_proposal_team close dialog")
						var team_id = $('input[name="team_id"]',form).val();
						//console.log("team_id: " + team_id)
						if(data.match(/\/team\?/)) document.location = '/team?id=' + team_id;
					}				
				}	
			);
			$('div.join').hide(500) 
			btn.removeAttr('disabled').next('img').remove();
		//	$(form).parent('div.join').replaceWith('<h3>You are a member of this team</h3>')
	  },
		error : function(xhr,errorString,exceptionObj){
			console.log("Error, xhr: " + xhr.responseText)
			try{
				show_form_error(form,xhr.responseText)
				//$("input[name='first_name']",form).before('<p class="form_error_text">' + xhr.responseText + "</p>")
				btn.removeAttr('disabled').next('img').remove();
			}catch(e){
				console.log("join_proposal_team submit error: " + e)
				$('<div><p>Sorry, we cannot process your proposal join request at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
				btn.removeAttr('disabled').next('img').remove();
			}
		}
	});			
}

var preview_dialog;
function invite_friends(form){
	var btn = $('input[type="submit"]',form);
	btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')
	
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
	form.ajaxSubmit({ 					
	  type: "POST", 
		url: 'http://' + document.location.host + '/team/invite_friends',
	  success: function(data,status){ 
			if($('input[name="send_now"]', form).val() == 'true'){
				// clear preview and acknowledge email was sent
				$('input[name="send_now"]', form).val('')
				var dialog = $('<div>' + data + '</div>').dialog( {title : 'Thank you', modal : true, width: 500 }); 
				// find and remove the preview dialog
				preview_dialog.dialog('destroy').remove()
			}else{
				preview_dialog = $('<div>' + data + '</div>').dialog( {title : 'Please preview your email', modal : true, width: 500,
						close: function(){ 	$('input[name="send_now"]', form).val('') } }); 
				preview_dialog.find('a.make_changes').click(
					function(){
						preview_dialog.remove();
						$('input[name="send_now"]', form).val('')
						return false;
					}
				)
				preview_dialog.find('button').click(
					function(){
						console.log("send this email now")
						//dialog.remove();
						$('input[name="send_now"]', form).val('true')
						btn.removeAttr('disabled').next('img').remove();
						show_recaptcha( form, false )
						//invite_friends(form);
						return false;
					}
				)
			}
			btn.removeAttr('disabled').next('img').remove();
	  },
		error : function(xhr,errorString,exceptionObj){
			console.log("Error, xhr: " + xhr.responseText)
			try{
				if(xhr.responseText.match(/Captcha failed/) ){
					//console.log("try recaptcha again")
					show_recaptcha( form, true )
					btn.removeAttr('disabled').next('img').remove();
					return false;
				}
				show_form_error(form,xhr.responseText)
				//$("input[name='first_name']",form).before('<p class="form_error_text">' + xhr.responseText + "</p>")
				btn.removeAttr('disabled').next('img').remove();
			}catch(e){
				console.log("invite_friends submit error: " + e)
				$('<div><p>Sorry, we cannot process your invitation request at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
				btn.removeAttr('disabled').next('img').remove();
			}
		}
	});			
}


function show_pub_coms(){
	try{
		var link = $(this)
		if(link.html().match(/close/i)){
		 //console.log("show_embedded_com_form close the form/discussion")
			//discussion_div.closest('tr').remove();
			link.html(link.attr('title_count'))
			link.next('div.item').addClass('hide');
			return false;			
		}
		link.attr('title_count',link.html())
		link.html('Close discussion');	
		link.next('div.item').removeClass('hide');
		// do ellipsis
		console.log("call ellipsis")
		ellipsis(link.next('div.discussion'))
	
	}catch(e){console.log("error show_pub_coms e: " + e)}
	return false
}

function update_discussion_links(){
	//console.log("update_discussion_links");
	$('a.pub_com' ).each(
	  function(){
			//if(single_mode)debugger
	    var link = $(this);
			var disc = link.next('div.pub_coms')
			var new_count = disc.find('span.new._comment').size()
			var com_count = disc.find('div.comment').size()
			if (new_count > 0){
				// show new coms
				link.html(('View ' + new_count + ' new comment') + ((new_count.length==1) ? '' : 's'));
				link.css('color','red');
			}else if(com_count>0){
				// 
				link.html(('View ' + com_count + ' comment') + ((com_count.length==1) ? '' : 's'));
			}else{
				link.html('Discuss')
	  	}
		}
	)
}
