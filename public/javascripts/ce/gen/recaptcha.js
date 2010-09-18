  function show_recaptcha(form, retry){

		if( typeof RCC_PUB_KEY == 'undefined' || RCC_PUB_KEY == ''){
			console.log("RCC_PUB_KEY is not defined! - Cannot show captcha")
			return
		}
		
    var recaptcha_dialog = $('<form class="recaptcha"><p>Please complete this test to verify you are an actual person and not a SPAM robot. Click <a href="#" class="reload_captcha">reload</a> to see a different text.</p><div id="invite_recaptcha">Text test</div><p><button>Send email</button></p></form>').
		      dialog( {title : 'Help us protect you from SPAM', modal : true, width: 400,
		        open: function(){ Recaptcha.create(RCC_PUB_KEY,"invite_recaptcha"); },
		        close: function(){ Recaptcha.destroy(); recaptcha_dialog.dialog('destroy').remove() } } );

		if(retry == true) $('button:last',recaptcha_dialog).before('<p class="warn">We\'re sorry, please try the new text above.</p>')

    $('form.recaptcha :button').unbind('click').click(
  		function(){
  			try{
  				recaptcha_submit($(this.form),form,recaptcha_dialog );
  			}catch(e){console.log("recaptcha_submit v1 error: " + e)}
  			return false;
  		}
  	);
  	$('form.recaptcha').unbind('submit').submit(
  		function(){
  			try{
  				recaptcha_submit($(this),form,recaptcha_dialog);
  			}catch(e){console.log("recaptcha_submit v2 error: " + e)}
  			return false;
  		}
  	);
  }



	function recaptcha_submit(form, par_form, dialog, callback){
	  console.log("recaptcha_submit");
	  var challenge = form.find('input[name="recaptcha_challenge_field"]').val();
	  var response = form.find('input[name="recaptcha_response_field"]').val();
	  $('input[name="recaptcha_challenge"]', par_form).val(challenge)
	  $('input[name="recaptcha_response"]', par_form).val(response)
	  //console.log("recaptcha_challenge_field: " + challenge );
	  //console.log("recaptcha_response_field: " + response );
	  Recaptcha.destroy()
	  // destroy the dialog
	  dialog.dialog('destroy').remove();
	 	$('input[type="submit"]',par_form).click()
	  return false;
	}

	$('a.reload_captcha').die('click').live('click',function(){Recaptcha.reload(); return false;})