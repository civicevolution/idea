// CivicEvolution application specific code is copyright 2000-2012 Practical Evolution, LLC 
//
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs


//console.log("Loading application.js");

$(function(){
	init_page();
});



function init_page(){
	//console.log("init_page")
	if(typeof right_panel_init != "undefined"){
		right_panel_init();
	}
	
	if(!member.ape_code){
		$('body').on('keydown.check_signed_in', 'form.suggest_idea textarea, form.add_comment textarea, form.endorsement textarea',function(){
			$('body').off('keydown.check_signed_in');
			$.getScript('/sign_in/sign_in_form?act=sign_in');
		})
	}
	
	activate_text_counters_grow($('textarea, input[type="text"]'), 120);
	
	if(!$.support.borderRadius){ 
		console.log("load corner support script and activate");
		$.getScript('/assets/opt/jquery.corner.js', 
			function(){
				$('div.right_side div.corner').css('background-color','#eee').corner();
			}
		);
	}else{
		// define dummy corner function
		$.fn.corner = function(){ return this; }
	}
	try{
		init_add_this();
	}catch(e){}
	try{
		$("a[rel^='prettyPhoto']").prettyPhoto({theme: 'dark_rounded'});
		//console.log("pretty photo is okay")
	}catch(e){}
}

$('div.home_page table.proposal_stats').die('click').live('click',
	function(){
		document.location = '/plan/' + $(this).closest('div.notebook').attr('id')
	}
)

$('a.endorse_this_proposal').live('click',function(){
	$.scrollTo("div.endorsements",2000);
	return false;
});

$('table#new_content tr').die('click').live('click',
	function(){
		var tr = $(this);
		var tp_id = tr.attr('tp_id');
		var com_id;
		var url;
		if(tr.hasClass('talking_point')){
			var url = '/talking_points/' + tp_id + '/comments';
			//console.log("show talking point with id: " + tp_id + " with url: " + url);
		}else if(tr.hasClass('comment')){
			var com_id = tr.attr('com_id');
			var url = '/talking_points/' + tp_id + '/comments?com_id=' + com_id;
			//console.log("show comment with id: " + com_id + " in talking_point with id: " + tp_id + " with url: " + url);
		}else if(tr.hasClass('question')){
			var ques_id = tr.attr('id');
			var url = '/questions/' + ques_id + '/worksheet'
			//console.log("show question with id: " + ques_id + " with url: " + url);
		}
		if(url){
		  // check if the page is already loaded before I request it
		  if( $('div.talking_point_comments[id="' + tp_id + '"]').size() > 0 ){
        if(com_id){
  				var com = $('div.Comment[id="' + com_id + '"]');
  				$('div.discussion[id="' + tp_id + '"]').scrollTo(com,600);
  				com.effect('highlight', {color: '#EAF8D0'},3000);				
  				tr.fadeTo(0,.4);
  			}
		  }else{
		    // load the page now
  		  tr.find('td').append('<img src="/assets/wait3.gif"/>');
  			$.ajax({
  			  url: url, 
  			  complete: function(){
  			    //console.log("display new content complete callback");
  			    tr.find('img').remove();
  			    tr.find('td').fadeTo(0,.4);
          }, 
  			  dataType: 'script'
  			});
        
  			$('div.talking_point_comments').each(
  			  function(){
  			    var popup = $(this);
  			    if(popup.find('textarea').val()==''){
  			      popup.slideUp(800,function(){ $(this).remove()});
  			    }
  			  }
  			);  
  		}
		}
	}
);
$('table#new_content tr:odd').addClass('striped');


$('div.proposal').on('click', 'div.form_help_slide a.close', function(){
	close_idea_help_popup(this);
	return false;
});
$('div.proposal').on('click', 'div.add_idea a.show_idea_help_popup', function(){
	open_idea_help_popup(this);
	return false;
});
$('div.proposal').on('focus', 'div.add_idea textarea', function(){
	open_idea_help_popup(this);
	return false;
});

function open_idea_help_popup(el){
	var help_slide = $(el).closest('div.question_summary').find('div.form_help_slide');
	if(el.nodeName == 'TEXTAREA' && help_slide.hasClass('auto-opened')){
		//console.log("help was already opened once on this question");
		return;
	}
	help_slide.removeClass('collapsed');
	help_slide.addClass('auto-opened');
	var body = help_slide.find('div.help_body');
	var new_scroll_pos = $(document).scrollTop() + body.height();
	if(new_scroll_pos>40) new_scroll_pos -= 40;
	body.slideDown(800);	
	$('html, body').animate({scrollTop: new_scroll_pos }, 800);
}
function close_idea_help_popup(el){
	var help_slide = $(el).closest('div.question_summary').find('div.form_help_slide');
	var body = help_slide.find('div.help_body');
	body.slideUp(800, function(){
		$(this).closest('div.form_help_slide').addClass('collapsed');
	});
}
$('div.proposal').on('click', 'div.form_help_slide a.ideas_vs_comments', function(){
	var ideas_vs_comments = $(this).closest('div.form_help_slide').find('ul.ideas_vs_comments');
	if( ideas_vs_comments.is(':visible') ){
		ideas_vs_comments.hide(400);
	}else{
		ideas_vs_comments.show(400);
	}
	return false;
});
$('div.proposal').on('click', 'div.form_help_slide a.theming_page_notes', function(){
	var theming_page_notes = $(this).closest('div.form_help_slide').find('ul.theming_page_notes');
	if( theming_page_notes.is(':visible') ){
		theming_page_notes.hide(400);
	}else{
		theming_page_notes.show(400);
	}
	return false;
});


$(function () {
	init_file_uploads( $('input.attachment-upload') );
});

	function init_file_uploads(file_inputs){
		//console.log("init fileupload");
    file_inputs.fileupload({
        dataType: 'json',
				forceIframeTransport: false,
				formData: {authenticity_token: AUTH_TOKEN },
				progressall: function (e, data) {
					var progress = parseInt(data.loaded / data.total * 100, 10);
					//console.log("progress: " + progress);
					$(this).closest('div.attachment_btn').next('div.attachment_upload_progress').find('div.bar').css(
					'width',
					progress + '%'
					);
				},
				start: function(e){
					var attachment_div = $(this).closest('div.attachment_btn').addClass('waiting');
					attachment_div.next('div.attachment_upload_progress').find('div.bar').css('width','0%');
					return true;
				},
				always: function(e){
					var attachment_div = $(this).closest('div.attachment_btn').removeClass('waiting');
					attachment_div.next('div.attachment_upload_progress').find('div.bar').css('width','0%');
				},
				fail: function (e,data){
					var error_message = data.jqXHR.responseText.match(/attachment_file_size[^\w]*([\w ]+)/);
					if( error_message.length>1 ){
						error_message = error_message[1];
					}else{
						error_message = data.jqXHR.responseText;
					}
					$('<p class="warn">' + error_message + '</p>').dialog( {title : 'Sorry', modal : true, width : '200px', closeOnEscape: true, close: function(){$(this).remove()} });
				},
				done: function (e, data) {
					temp.attachment_data = data;
					//console.log("attachment_url: " + data.result.attachment_url);
					
					var icon_url = data.result.attachment_content_type.match(/image/i) ? 
						data.result.attachment_icon_url : '/assets/doc_icon.gif';
					var add_idea = $(this).closest('div.add_idea');
					var attachments = add_idea.find('div.attachments');
					attachments.find('p.clear_both').before( '<div class="attachment" id="' + data.result.attachment_id + '"><img src="' + icon_url + '"/><img class="delete" src="/assets/circle_x_sm.gif"/><p>' + 	data.result.attachment_file_name + '</p></div>');
					attachments.show(400);
					var ids = attachments.find('div.attachment').map( function(){return this.id;});
					add_idea.find('input[name="attachments"]').val( $.makeArray(ids).join(','));
				}
    });
	}


$('body').on('click', 'div.attachments img.delete', function(){
	var attachment_div = $(this).closest('div');
	var id = attachment_div.attr('id');
	console.log("delete " + id);
	$.ajax({
	  type: 'POST',
	  url: '/uploads/' + id + '/destroy',
	  dataType: 'json'
	}).done(function(data) { 
		attachment_div.hide(800,function(){
			var attachments = attachment_div.closest('div.attachments');
			attachment_div.remove();
			var ids = attachments.find('div.attachment').map( function(){return this.id;});
			attachments.closest('div.add_idea').find('input[name="attachments"]').val( $.makeArray(ids).join(','));
			if(attachments.find('img').size() == 0){
				attachments.hide(800);
			}
		});
	}).fail(function() { alert("attachment delete error"); });
})
