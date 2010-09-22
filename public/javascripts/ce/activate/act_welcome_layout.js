var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};

$(function(){
	$('a.register').die('click').live('click',
		function(){
			try{
				var cur_form = $('form.signin_form:visible').size() > 0 ? $('form.signin_form') : $('form.reset_password_form');
				$(':input',cur_form).removeClass('form_error_border');
				$('p.form_error_text',cur_form).remove();
				
				cur_form.hide(1000, 
					function(){
						$('form.register_form').show(500, register_expand_col	);
					}
				);
			}catch(e){console.log("register click e: " + e )}
			return false
		}
	);

	$('a.reset_password').die('click').live('click',
		function(){
			try{
				$('form.reset_password_form input[name="email"]').val( $('form.signin_form input[name="email"]').val() )
				$('form.signin_form').hide(1000, 
					function(){
						$('form.reset_password_form').show(1000);
					}
				);
			}catch(e){console.log("register click e: " + e )}
			return false
		}
	);

	$('a.sign_in').die('click').live('click',
		function(){
			try{
				restore_right_col()
				var cur_form = $('form.register_form:visible').size() > 0 ? $('form.register_form') : $('form.reset_password_form');
				$(':input',cur_form).removeClass('form_error_border');
				$('p.form_error_text',cur_form).remove();
				cur_form.hide(1000, 
					function(){
						$('form.signin_form').show(1000);
					}
				);
			}catch(e){console.log("signin click e: " + e)}
			return false			
		}
	);

	$('form.signin_form :button').unbind('click').click( 
		function(){
			try{
				signin_submit($(this.form));
			}catch(e){console.log("signin_form v1 error: " + e)}
			return false;
		}
	);
	$('form.signin_form').unbind('submit').submit(
		function(){
			try{
				signin_submit($(this));
			}catch(e){console.log("signin_form v2 error: " + e)}
			return false;
		}
	);

	$('form.reset_password_form :button').unbind('click').click( 
		function(){
			try{
				reset_password_submit($(this.form));
			}catch(e){console.log("reset_password_submit v1 error: " + e)}
			return false;
		}
	);
	$('form.reset_password_form').unbind('submit').submit(
		function(){
			try{
				reset_password_submit($(this));
			}catch(e){console.log("reset_password_submit v2 error: " + e)}
			return false;
		}
	);

	$('form.register_form input[type="submit"]').unbind('click').click( 
		function(){
			try{
				register_submit($(this.form));
			}catch(e){console.log("register_form v1 error: " + e)}
			return false;
		}
	);

	if($('ul.teams_list li').size() > 0 ) $('div.sign_in').effect("pulsate", 'fast');
	
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

	if( !(typeof member_id != 'undefined' && member_id != 0) ) $('form.mini_thumbs_up :submit').attr('disabled','disabled');

	activate_text_counters_grow( $('div.left_col textarea, div.left_col input:text') )
	
}); // end of jquery onload


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
				form.closest('div').replaceWith(data)
				$('div.sign_in').effect("pulsate", 'fast')
				// update the suggest proposal idea message
				
				$('div.left_col .suggest_sign_in:first').replaceWith( $('div.right_col .suggest_sign_in').removeClass('hide') )	
				my_team_ids = [];
				$('ul.teams_list li').each(function(){ my_team_ids.push(this.getAttribute('id')) })
				$('.join_sign_in').remove();
				btn.removeAttr('disabled').next('img').remove();
				$('form.mini_thumbs_up :submit').removeAttr('disabled')				
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
				console.log("reset_password submit success, call dispatchPageChatMessage");
				//console.log("show the teams in data: " + data)
				$('<div><p>Please check your email for instructions to reset your pasword.</p></div>').dialog( {title : 'Reset email sent', modal : true } )
				//$('a.sign_in').click();	
				btn.removeAttr('disabled').next('img').remove();			
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
}

function register_expand_col(){
	//$('form.register_form').unbind('click')
	//var mask = $('<div class="mask"></div>');
	//mask.click( restore_right_col )
	//$('body').append(mask)
	//mask.css({width: $(document).width(), height: $(document).height()  }).fadeTo(500,.8)								
	//Recaptcha.create("6Le027wSAAAAABJKdXtEfpJb7-T3ybjUC3tpuCnn","recaptcha_register");
	//var pos = $('div.right_col').position();
	//$('div.right_col').addClass('reg_only').css({top: pos.top, left: pos.left - 125});
}
	
function restore_right_col(){
	//$('div.right_col').removeClass('reg_only');
	//$('div.mask').remove();
	//$('div#recaptcha_register').html('');
	//$('form.register_form').click( register_expand_col )
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
				//console.log("register success");
				setTimeout(restore_right_col, 1000);
				
				console.log("show dialog")
				$('<div>' + data + '</div>').dialog( {title : 'Thank you', modal : true } )

		  	$('a.sign_in').click();
		  	$('form.register_form input[name="member[first_name]"]').val('')
		  	$('form.register_form input[name="member[last_name]"]').val('')
		  	
		  	$('form.signin_form input[name="email"]').val( $('form.register_form input[name="member[email]"]').val() )
		  	$('form.register_form input[name="member[email]"]').val('') 
		  	$('form.register_form input[name="member[password]"]').val('')
		  	$('form.register_form input[name="member[password_confirmation]"]').val('')
				btn.removeAttr('disabled').next('img').remove();
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
		while(el = el.parent()){
		var div = el.find('div.how:first')
			if(div.size() > 0){
				if(div.is(':visible')){
					div.hide()
					$(this).html('How')
				}else{
					div.show()
					$(this).html('Close')
				}
				return false;
			}
		}
		false;
	}
)

$('div.teams_list img.signin_pic').die('click').live( 'click',
	function(){
		$('div.teams_list form.upload_member_photo').show();
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

$('form.upload_member_photo a.cancel').die('click').live( 'click', 
	function(){
		$('div.teams_list form.upload_member_photo').hide();		
		return false;
	}
);


function upload_pic(form){
	//console.log("upload an image v4");
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
	var file = $('input[type="file"]');
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
				$('div.teams_list img.signin_pic').attr('src', url.replace(/^\/+/,'/') );
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
