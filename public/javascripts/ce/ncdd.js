console.log("loading ncdd.js v1")

$(function(){
	console.log("process jquery load in ncdd.js")
	$('form.suggest_workshop_proposal_form').each(
		function(){
			activate_workshop_form( $(this) )
		})

	$('button.submit_workshop_proposal').click(submit_workshop_proposal)


}); // end of jquery onload

function activate_workshop_form(form,orig_idea){
	console.log("process activate_workshop_form")
	activate_text_counters_grow( $('textarea, input[type="text"]',form) )

	
	$('div.control_line a.clear',form).click(
		function(){
		 //console.log("Clear the idea form");
			$(this).closest('form').find('textarea, input[type="input"]').val('');
			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			return false;
		}
	);

	$('button', form).unbind('click').click(
		function(){
		 console.log("Submit the workshop form");

			var form = $(this).closest('form');
			var btn = $(this);
			btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')

			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			
			form.ajaxSubmit({ 					
			  type: "POST", 
			  url: "/workshop/submit_workshop_idea", 
				dataType: 'json',
			  success: function(data,status){ 
				 //console.log("idea submit success, call dispatchBsIdeas");
					form_id = data[0].form_id;
					console.log("form_id: " + form_id)
					$('form input[name="workshop_proposal[form_id]"]').val(form_id)
					var href = $('a.preview_workshop').attr('href');
					if(!href.match(/\d$/)){
						// append the form_id to href
						$('a.preview_workshop').attr('href', href + '?id=' + form_id);
					}
					var msg = $('<p class="confirmation">This section has been saved successfully - Remember to submit when all sections are complete.</p>')
					temp.btn =btn
					btn.closest('div.control_line').after(msg)
					msg.effect('highlight',{},5000, function(){$(this).remove()});					
					btn.removeAttr('disabled').next('img').remove();
			  },
				error : function(xhr,errorString,exceptionObj){
					//console.log("Error, xhr: " + xhr.responseText)
					try{
						show_form_error(form, xhr.responseText);
						btn.removeAttr('disabled').next('img').remove();
					}catch(e){
						btn.removeAttr('disabled').next('img').remove();
						console.log("Submit workshop proposal error: " + e)
						$('<div><p>Sorry, we cannot process your workshop proposa at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					}
				}
			});
			return false;
		}
	);
}

function submit_workshop_proposal(){
	console.log("submit_workshop_proposal")
	
}