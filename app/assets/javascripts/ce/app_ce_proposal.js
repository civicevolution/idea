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
			if(!member.ape_code){
				$.getScript('/sign_in/sign_in_form?act=sign_in&team_id=' + team_id);
			}
		})
	}
	
	truncate_comments();
	dispatcher.update_coms_new();
	
	activate_text_counters_grow($('textarea, input[type="text"]'), 120);
	
	init_rating_sliders( $("div.theme_slider") );
	
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
	$('h1.home_title').append( $('h1.home_title').next('a') );
	$('div.idea_summary div.inner > *:last').append( $('div.idea_summary div.inner').next('a') );
	
	$('input, textarea').placeholder();
	
	set_answer_links_target();
	set_answer_links_target( $('div.idea_summary') );
		
	if(!member.active_participant && !project_coordinator){
		$('div.proposal').hide();
	}
	setTimeout(function(){init_tooltips();},300);
}

function init_rating_sliders( sliders ){
	sliders.each(
		function(){
			var slider = $(this);
			var my_rating = Number( slider.attr('my_rating') );
			slider.slider({
				stop: function(event, ui) { 
					var par = $(ui.handle).parent();
					if(!member.ape_code){
						par.slider('value',50)
						$.getScript('/sign_in/sign_in_form?act=sign_in&team_id=' + team_id);
					}else{
						$.post('/idea/rating', {id: par.attr('id'), mode: par.attr('mode'), rating: ui.value}, function(){}, "script");
					}
				},
				value: my_rating,
				range: "min"
			});
		}
	);
}

function set_answer_links_target(section){
	section = section || $('div.answer_block div.answer')
	section.find('a').each(
		function(){
			var link = $(this);
			if(!link.attr('target') && !link.attr('class')){
				link.attr('target','_blank');
			}
		}
	);
}


$('div.home_page table.proposal_stats').die('click').live('click',
	function(){
		document.location = '/plan/' + $(this).closest('div.notebook').attr('id')
	}
)

$('a.endorse_this_proposal').live('click',function(){
	$('html,body').animate( {scrollTop: $('div.endorsements').offset().top}, 800);
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
					var form = $(this).closest('form');
					var attachments = form.find('div.attachments');
					attachments.find('p.clear_both').before( '<div class="attachment" id="' + data.result.attachment_id + '"><img src="' + icon_url + '"/><img class="delete" src="/assets/circle_x_sm.gif"/><p>' + 	data.result.attachment_file_name + '</p></div>');
					attachments.show(400);
					var ids = attachments.find('div.attachment').map( function(){return this.id;});
					form.find('input[name="attachments"]').val( $.makeArray(ids).join(','));
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
			attachments.closest('form').find('input[name="attachments"]').val( $.makeArray(ids).join(','));
			if(attachments.find('img').size() == 0){
				attachments.hide(800);
			}
		});
	}).fail(function() { alert("attachment delete error"); });
})

$('body').on('click', 'div.constituent_ideas li.idea_post_it', 
	function(){
			var post_it = $(this).find('div.post-it');
			$.getScript('/idea/' + post_it.attr('id') + '/details');
			var constituent_ideas = post_it.closest('div.constituent_ideas');
			$('div.answer_details').animate({left: -(constituent_ideas.position().left + 20) },350);
			//$('div.answer_details').animate({left:'-440'},350);
	}
);

$('body').on('click', 'div.constituent_idea_details a.return_to_answer_details', 
	function(){
			$('div.answer_details').animate({left:'0'},350);
			return false;
	}
);

$('body').on('click', 'div.my_new_ideas a.close_my_ideas', 
	function(){
			$(this).closest('div.my_new_ideas').hide(500,function(){$(this).remove();});
			return false;
	}
);


setTimeout(function(){
	if(params['clear']=='f'){
		$('a.clear').remove();
	}
});

$('body').on('focus blur','div.activity_stream form', 
	function(event){
		var form = $(this);
		var textarea = form.find('textarea');
		if(event.type=='focusin'){
			form.addClass('active');
		}else if(textarea.val()==''){
			//form.removeClass('active');
		}
	}
);

$('body').on('click','div.answer_block li.theme',
	function(event){
		if(event.target.nodeName !='A'){
			$(this).prepend('<img class="wait" src="/assets/wait5.gif"/>');
			$.getScript('/idea/' + this.id + '/details'  + ( $(event.target).hasClass('edit') ? '?mode=edit' : '') );
		}
	}
);