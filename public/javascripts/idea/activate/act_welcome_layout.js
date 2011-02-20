var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};

$(function(){
	if($('ul.teams_list li').size() > 0 && $('div.sign_in').size() > 0) $('div.sign_in').effect("pulsate", 'fast');
}); // end of jquery onload

	
$('a.sign_in').die('click').live('click',
	function(){
		try{
			//var link = $('a#sign_in_link')
			var link = $(this);
			if(link.size()==0 || link.attr('pos') == 'center'){
				var pos = 'center';				
			}else if(link.size()>0){
				var pos = link.position();
				var top = pos.top + 20;
				var left = pos.left - 600 + link.width();
				pos = [left,top]
			}
			
			var dialog = $('<div id="sign_in_dialog"></div>').dialog( {title : 'Please sign in', modal : true, width: '600px', position : pos } ).append(  $('div#hidden_forms div#sign_in_form').clone(true) )
			if(pos == 'center')	$('a',dialog).attr('pos','center');
			$('input[name="email"]', dialog).focus()
			//var cur_form = $('form.signin_form:visible').size() > 0 ? $('form.signin_form') : $('form.reset_password_form');
			var form = dialog.find('form')
			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			
			// if this was called by a link in a dialog, remove the dialog
			if(link.size()>0) link.closest('div.ui-dialog').dialog('destroy').remove()
		}catch(e){console.log("sign in link click e: " + e )}
		return false
	}
);

$('a.reset_password').die('click').live('click',
	function(){
		try{
			//var link = $('a#sign_in_link')
			var link = $(this)
			if(link.size()==0 || link.attr('pos') == 'center'){
				var pos = 'center';				
			}else if(link.size()>0){
				var pos = link.position();
				var top = pos.top + 20;
				var left = pos.left - 285 + link.width();
				pos = [left,top]
			}

			var dialog = $('<div id="sign_in_dialog"></div>').dialog( {title : 'Reset my password', modal : true, width : '285px', position : pos } ).append(  $('div#hidden_forms div#reset_password_form').clone(true) )
			if(pos == 'center')	$('a',dialog).attr('pos','center');
			$('form.reset_password_form input[name="email"]').val( $('input[name="email"]', $(this).closest('form')).val() )
			$('input[name="email"]', dialog).focus();
			if(link.size()>0) link.closest('div.ui-dialog').dialog('destroy').remove()
		}catch(e){console.log("register click e: " + e )}
		return false
	}
);

	
$('a.join_our_community').die('click').live('click',
	function(){
		try{
			//var link = $('a#sign_in_link')
			var link = $(this)
			if(link.size()==0 || link.attr('pos') == 'center'){
				var pos = 'center';				
			}else if(link.size()>0){
				var pos = link.position();
				var top = pos.top + 20;
				var left = pos.left - 480 + link.width();
				pos = [left,top]
			}
			
			$('<div></div>').load("/welcome/join_our_community", 
				function(){
					var $this = $(this);
					$this.dialog( {title : 'Please register', modal : true, width : '480px', position : pos, closeOnEscape : false } )
					if(pos == 'center')	$('a',dialog).attr('pos','center');
				}
			)
			if(link.size()>0) link.closest('div.ui-dialog').dialog('destroy').remove()
			
			//var dialog = $('<div>Loading...</div>').dialog( {title : 'Please register', modal : true, width : '480px', position : pos, closeOnEscape : false } )
			//	.load( '/welcome/join_our_community', function(){ $('input[type="text"]:first', this).focus()} )
			//if(pos == 'center')	$('a',dialog).attr('pos','center');
			//if(link.size()>0) link.closest('div.ui-dialog').dialog('destroy').remove()
		}catch(e){console.log("register click e: " + e )}
		return false
	}
);

$('a#cta_register').die('click').live('click',
	function(){
		$('a.join_our_community').click();		
		return false;
	}
);

$('form.signin_form :button').live('click', 
	function(){
		try{
			signin_submit($(this.form));
		}catch(e){console.log("signin_form v1 error: " + e)}
		return false;
	}
);

	//$('form.signin_form').unbind('submit').submit(
	$('form.signin_form').live('submit',
		function(){
			try{
				signin_submit($(this));
			}catch(e){console.log("signin_form v2 error: " + e)}
			return false;
		}
	);
	
$('form.signin_form .cancel').die('click').live('click',
	function(){
		try{
			$(this).closest('div.ui-dialog').dialog('destroy').remove();
		}catch(e){console.log("signin_form cancel v1 error: " + e)}
		return false;
	}
);
	

$('form.reset_password_form :button').live('click',
	function(){
		try{
			reset_password_submit($(this.form));
		}catch(e){console.log("reset_password_submit v1 error: " + e)}
		return false;
	}
);
	//$('form.reset_password_form').unbind('submit').submit(
	$('form.reset_password_form').live('submit',
		function(){
			try{
				reset_password_submit($(this));
			}catch(e){console.log("reset_password_submit v2 error: " + e)}
			return false;
		}
	);
	
$('div#reset_password_form .cancel').die('click').live('click',
	function(){
		try{
			$(this).closest('div.ui-dialog').dialog('destroy').remove();
		}catch(e){console.log("reset_password_submit v1 error: " + e)}
		return false;
	}
);

$('form.register_form input[type="submit"]').die('click').live('click',
	function(){
		try{
			register_submit($(this.form));
		}catch(e){console.log("register_form v1 error: " + e)}
		return false;
	}
);

$('form.register_form .cancel').die('click').live('click',
	function(){
		try{
			$(this).closest('div.ui-dialog').dialog('destroy').remove();
		}catch(e){console.log("register_form cancel v1 error: " + e)}
		return false;
	}
);
	

	//// for reg testing, preload the fields
	//$('a.register').click();
	//$('form.register_form input[name="member[first_name]"]').val('Test')
	//$('form.register_form input[name="member[last_name]"]').val('Regis')
	//$('form.register_form input[name="member[email]"]').val('test-1@civicevolution.org')
	//$('form.register_form input[name="member[password]"]').val('abc')
	//$('form.register_form input[name="member[password_confirmation]"]').val('ab')
	
$('a.2029_guidelines').live('click',
	function(){
		data = $('<div></div>')
		data.append( $('div.ground_rules').clone() );
		data.append( $('div.guidelines').clone() );
		data.dialog( {title : '2029 and beyond Online Groundrules and Guidelines', modal : true, width: 500, maxHeight: 500 } );
		return false;
	}
)

$('form.upload_member_photo input[type="submit"]').die('click').live( 'click', 
	function(){
		try{
			upload_pic($(this.form));
		}catch(e){console.log("upload_member_photo v1 error: " + e)}
		return false;
	}
);
	
// defined functions 

function signin_submit(form){
	console.log("signin_form submit")
	
	var btn = $('input[type="submit"]',form);
	btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')
	
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
		form.ajaxSubmit({ 					
		  type: "POST", 
			url: 'http://' + document.location.host + '/welcome/signin',
		  success: function(data,status){ 
				//console.log("chat submit success, call dispatchPageChatMessage");
				//console.log("show the teams in data: " + data + " status: " + status)
				if(data.match(/^__REDIRECT__=/)){
					document.location = data.match(/^__REDIRECT__=(.*)/)[1]			
					return;		
				}
				my_team_ids = [];
				$('ul.teams_list li').each(function(){ my_team_ids.push(this.getAttribute('id')) })
				$('.join_sign_in').remove();
				$('form.mini_thumbs_up :submit').removeAttr('disabled')
				form.closest('div.ui-dialog').dialog('destroy').remove();		
				$('div.join_com').replaceWith(data)
				$('div.right_col').prepend($('div#my_teams').children())
				//if ( $('div#my_teams ul.teams_list li').size() > 0 ){
				//	$('a.my_teams').click()
				//}
		  },
			error : function(xhr,errorString,exceptionObj){
				console.log("Error, xhr: " + xhr.responseText )
				try{
					$("input[name='email']",form).before('<p class="form_error_text">' + xhr.responseText + "</p>")
					// show case sensitive warning
					$("span.case",form).show()
					
					btn.removeAttr('disabled').next('img').remove();
				}catch(e){
					btn.removeAttr('disabled').next('img').remove();
					console.log("Sign in submit error: " + e)
					$('<div><p>Sorry, we cannot process your sign in request at this time. Please check your email and password.</p></div>').dialog( {title : 'Warning', modal : true } )
				}
			}
		});
		return false;			
}	

$('li.team').die('click').live('click',
	function(){
		if(this.getAttribute('launched') == 't'){
			document.location = '/team?id=' + this.getAttribute('id')
		}else{
			document.location = '/team/proposal?id=' + this.getAttribute('id')
		}
	}
);

$('a.team_entry_title').die('click').live('click',
	function(){
		try{
			var id = Number(this.getAttribute('href').match(/\d+$/))
			//console.log("id: " + id + ", my_team_ids: " + my_team_ids)
			if($.inArray(id,my_team_ids) != -1 && this.getAttribute('launched') == 't'){
				// console.log("show workspace")
				document.location = '/team?id=' + id
			}else{
				//console.log("show proposal")
				document.location = '/team/proposal?id=' + id
			}
		}catch(e){console.log("team_entry_title error: e: " + e.message)}
		return false;
	}
);

function reset_password_submit(form){
	console.log("reset_password_submit submit")
	
	var btn = $('input[type="submit"]',form);
	btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')
	
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
		form.ajaxSubmit({ 					
		  type: "POST", 
			url: 'http://' + document.location.host + '/welcome/reset_password',
		  success: function(data,status){ 
				//console.log("reset_password submit success	");
				form.closest('div.ui-dialog').find('div#reset_password_form').html('<p>Please check your email for instructions to reset your pasword.</p>' + 
					'<p><a href="#" class="cancel">Close</a></p>')
		  },
			error : function(xhr,errorString,exceptionObj){
				console.log("Error, xhr: " + xhr.responseText)
				try{
					if(xhr.responseText.match(/<body>/i)){
						$("input[name='email']",form).before('<p class="form_error_text">' + 'send email failed' + "</p>")
					}else{
						$("input[name='email']",form).before('<p class="form_error_text">' + xhr.responseText + "</p>")
					}
					btn.removeAttr('disabled').next('img').remove();
				}catch(e){
					console.log("reset_password_submit submit error: " + e)
					$('<div><p>Sorry, we could not process your reset request. Please check your email address and try again.</p></div>').dialog( {title : 'Warning', modal : true } )
					btn.removeAttr('disabled').next('img').remove();
				}
			}
		});
		return false;			
}

$('a.reload_captcha').die('click').live('click',function(){Recaptcha.reload(); return false;})

function register_submit(form){
	//console.log("register_submit submit")
	
	////make sure recaptcha is present
	//if($('div.#recaptcha_register').html() == '') {
	//	register_expand_col()
	//	return false;
	//}
	
	var btn = $('input[type="submit"]',form);
	btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')
	
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
		form.ajaxSubmit({ 					
		  type: "POST", 
			url: 'http://' + document.location.host + '/welcome/register',
		  success: function(data,status){ 
				var dialog = $('<div>' + data + '</div>').dialog( {title : 'Thank you', modal : true } );
				$('div.join_com').replaceWith( dialog.find('div.member_info').remove() );
				form.closest('div.ui-dialog').dialog('destroy').remove();
		  },
			error : function(xhr,errorString,exceptionObj){
				console.log("Error, xhr: " + xhr.responseText)
				try{
					show_form_error(form,xhr.responseText)
					//$("input[name='first_name']",form).before('<p class="form_error_text">' + xhr.responseText + "</p>")
					btn.removeAttr('disabled').next('img').remove();
				}catch(e){
					console.log("register_submit submit error: " + e)
					$('<div><p>Sorry, we cannot process your registration at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					btn.removeAttr('disabled').next('img').remove();
				}
			}
		});
		return false;			
}

$('a.terms_of_use').die('click').live('click',
	function(){
		$.get('/welcome/terms_of_service',
			function(data){
				$(data).dialog( {title : 'CivicEvolution Terms of Service', modal : true, width: 500, maxHeight: 500 } )
			})
		
		return false;
	}
);

$('a.request_confirmation_email').die('click').live('click', 
	function(){
		$.get('/welcome/request_confirmation_email',
			function(data){
				$(data).dialog( {title : 'Confirmation email has been sent', modal : true, width: 500, maxHeight: 500 } )
			})
		
		return false;
	}
);

$('a.how').die('click').live('click',
	function(){
		var el = $(this)
		// find the first div.how below this
		console.log("open how")
		while(el = el.parent()){
			var div = el.find('div.how:first');
			console.log("div.size(): " + div.size())
			if(div.size() > 0){
				if(div.is(':visible')){
					console.log("hide")
					div.hide()
					$(this).html('How')
				}else{
					console.log("show")
					div.show()
					$(this).html('Close')
				}
				return false;
			}
		}
		return false;
	}
)

$('div.member_info img.signin_pic').die('click').live( 'click',
	function(){
		var mi = $(this).closest('div.member_info');
		var pos = mi.position();
		var top = pos.top + mi.height() + 20;
		var left = pos.left - 300 + mi.width();
		//debugger	
		
		var dialog = $('<div id="upload_pic_dialog"></div>')
			.dialog( {title : 'Upload your profile picture', modal : true, width: '300px', position : [left,top] } )
			.append(  $('form.upload_member_photo:first').clone(true) )
	}
)

//$('form.upload_member_photo input[type="submit"]').die('click').live( 'click', 
//$('form.upload_member_photo button').die('click').live( 'click', 

$('form.upload_member_photo a.cancel').die('click').live( 'click', 
	function(){
		$(this).closest('div.ui-dialog').dialog('destroy').remove();
		return false;
	}
);


function upload_pic(form){
	console.log("upload an image v5i");
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	var file = $('input[type="file"]',form);
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
				$('div.member_info img.signin_pic').attr('src', url.replace(/^\/+/,'/') );
				var dialog = form.closest('div.ui-dialog');
				if (dialog.size() > 0) dialog.dialog('destroy').remove();
				$('div.teams_list form.upload_member_photo').hide();
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

function warn_sign_in(el){
	//console.log("warn_sign_in")
  if(el.checked){
    $(el).next('p').show()
  }else{
    $(el).next('p').hide()
  }
}

function link_disabled(){
	$('<div><p>Sorry, this feature is not currently active, we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
	return false;
}
