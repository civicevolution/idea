
$(function(){
	console.log("Start initializing the page, tabs first")
		$('div.tabs').tabs();
		$("a[rel^='prettyPhoto']").prettyPhoto({theme: 'dark_rounded'});

	$('form.suggest_proposal_idea_form').unbind('submit').submit(
		function(){
			try{
				submit_proposal_idea(this);
			}catch(e){console.log("suggest_proposal_idea_form v1 error: " + e)}
			return false;
		}
	);

	$('form.suggest_proposal_idea_form input[type="submit"]').unbind('click').click( 
		function(){
			try{
				submit_proposal_idea($(this.form));
			}catch(e){console.log("suggest_proposal_idea_form v2 error: " + e)}
			return false;
		}
	);

}); // end of jquery onload


function submit_proposal_idea(form){
	console.log("submit_proposal_idea submit")
	
	var btn = $('input[type="submit"]',form);
	btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>');
	
	// for now, override the initiative_id with the parameter init_id
	//var init_id = document.location.search.match(/\binit_id=/) ? Number(document.location.search.match(/\binit_id=(\d+)/)[1]) : 1;
	var init_id =  document.location.host.match(/^t/) ? 3 : 1;
	$('input[name="proposal_idea[initiative_id]"]',form).val(init_id)
	console.log("use in")
	
	$(':input',form).removeClass('form_error_border');
	$('p.form_error_text',form).remove();
	
		form.ajaxSubmit({ 					
		  type: "POST", 
			url: 'http://' + document.location.host + '/team/submit_proposal_idea',
		  success: function(data,status){ 
				//console.log("chat submit success, call dispatchPageChatMessage");
				$('<div>' + data + '</div>').dialog( {title : 'Thank you', modal : true } )
				$('form.suggest_proposal_idea_form :text').val('')
				$('form.suggest_proposal_idea_form textarea').val('')
				$('form.suggest_proposal_idea_form :checkbox').removeAttr('checked')
				btn.removeAttr('disabled').next('img').remove();
		  },
			error : function(xhr,errorString,exceptionObj){
				console.log("Error, xhr: " + xhr.responseText)
				try{
					show_form_error(form,xhr.responseText)
					//$("input[name='first_name']",form).before('<p class="form_error_text">' + xhr.responseText + "</p>")
					btn.removeAttr('disabled').next('img').remove();
				}catch(e){
					console.log("submit_proposal_idea submit error: " + e)
					$('<div><p>Sorry, we cannot process your proposal ideas at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					btn.removeAttr('disabled').next('img').remove();
				}
			}
		});			
}

