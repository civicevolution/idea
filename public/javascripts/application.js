// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs

//console.log("Loading application.js");

temp = {};

$(function(){
		//collapse_proposal_view()
		size_talking_point_entries();
		$(document).ajaxSend(function(e, xhr, options) {
		  var token = $("meta[name='csrf-token']").attr("content");
		  xhr.setRequestHeader("X-CSRF-Token", token);
		});	
		$('textarea').autoGrow({ minHeight  : 120, maxHeight : 500 })
	
	}
);

$('a.open_worksheet, div.proposal.inview h2.question').die('click').live('click',
	function(){
		var question_worksheet = $(this).closest('div.question_worksheet');
		show_question_worksheet(question_worksheet)
		return false;
	}
);

function show_question_worksheet(question_worksheet){
	expand_proposal_view();
	$('div.question_worksheet').hide();
	question_worksheet.show();
	$.scrollTo(question_worksheet,1000);	
}


function collapse_proposal_view(){
	$('div.question_worksheet').show();
	$('div.what_do_you_think').hide();
	$('div.ques_discussion').hide();
	//$('div.my_rating').hide();
	$('div.talking_point_preferable').hide();
	$('h3.ques_sub_hdg').hide();
	$('div.talking_point_entry.header').hide();
	$('div.talking_point_controls').hide();
	
	$('div.proposal').addClass('inview');
	$('div.question_worksheet').addClass('noview');
	$('div.summary').addClass('collapse');
	$('div.talking_point_entry').each( 
		function(){
			var el = $(this)
			var b = el.children('div.talking_point_body').height('auto');
			var cr = el.find('div.talking_point_acceptable > div.community_rating').height('auto');
			var mr = el.find('div.talking_point_acceptable > div.my_rating').height('auto');
			var max = Math.max.apply( Math, [b.height(), (cr.height() + 20), (mr.height() + 20)] );
			//console.log("max height: " + max)
			b.height(max);
			cr.height(max-20);
			mr.height(max-20);
		}
	)	
}

function size_talking_point_entries(){
	$('div.talking_point_entry').not('.header').each( 
		function(){
			var el = $(this)
			var b = el.children('div.talking_point_body').height('auto');
			var cr = el.find('div.talking_point_acceptable > div.community_rating').height('auto');
			var p = el.children('div.talking_point_preferable').height('auto');
			var max = Math.max.apply( Math, [b.height(), (cr.height() + 26), p.height()] );
			//console.log("max height: " + max)
			b.height(max);
			cr.height(max-20);
			p.height(max-20);
		}
	)	
}

function expand_proposal_view(){
	$('div.what_do_you_think').show();
	$('div.ques_discussion').show();
	//$('div.my_rating').show();
	$('div.talking_point_preferable').show();
	$('h3.ques_sub_hdg').show();
	$('div.talking_point_entry.header').show();
	$('div.talking_point_controls').show();
	
	$('div.proposal').removeClass('inview');
	$('div.question_worksheet').removeClass('noview');
	$('div.summary').removeClass('collapse');

	size_talking_point_entries();
}


$('a.tp_show_coms').die('click').live('click',
	function(){
		var el = $(this);
		if(el.html().match(/hide/i)){
			var disc = el.closest('div.talking_point_entry').next('div.talking_point_comments');
			var com_cnt = disc.find('div.Comment').size();
			switch(com_cnt){
				case 0:
					el.html('Reply');
					break;
				case 1:
					el.html('Show 1 comment');
					break;
				default:
					el.html('Show ' + com_cnt + ' comments' );
					break;
			}
			disc.remove();
		}else{
			$.get( '/talking_points/' + this.id + '/comments', {}, 
				function(data){ 
					var newNode = el.closest('div.talking_point_entry').after(data);
					el.html('Hide discussion');
					newNode.next().find('textarea').autoGrow({ minHeight  : 30, maxHeight : 500 })
				}
			)
		}
		return false;
	}
);

$('a.reply').die('click').live('click',
	function(){
		var el = $(this);
		//There are three possible cases:
		// reply to talking point comments
		// reply to a question top level comment
		// reply to a question lower level comment
		
		var par = el.closest('div.discussion');
		if(par.hasClass('talking_point_comments')){
			reply_to_talking_point_comment(el);
		}else if(par.hasClass('ques_discussion')){
			reply_to_question_comment(el);			
		}else if(par.hasClass('comment_comments')){
			reply_to_comment_comment(el);			
		}
		return false;
	}
);
	
function reply_to_comment_comment(el){
	var com = el.closest('div.Comment');
	var com_id = com.attr('id');
	var par = el.closest('div.comment_comments');
	// if there is a form open for this already just return now
	var new_form = par.find('form.comment_form[id="'  + com_id + '"]');
	if(new_form.size() == 0 ){
		var form = par.find('form.comment_form.orig');
		form.hide();
		var new_form = form.clone(true);
		new_form.attr('id',com_id);
		new_form.removeClass('orig');
		new_form.show();
		form.after(new_form);
		new_form.find('h3').html("Reply to this comment");
		new_form.find('a.clear').html("Cancel").addClass('cancel_form');
		com = com.find('div.comment_text').clone();
		var author = com.find('a.com_author').remove().html();
		var text = com.html().replace(/<p>/i,'').replace(/<\/p>/i,'\n\n').replace(/^\s*/,'').replace(/\s*$/,'');
		new_form.find('textarea').val('[quote="' + author + '"]' + text + '[/quote]\n\n');
		new_form.find('textarea').autoGrow({ minHeight  : 30, maxHeight : 500 });
		new_form.append('<input type="hidden" name="form_id" value="' + Math.round(Math.random()*1e16) + '"/>');
	}
	if(!new_form.isOnScreen()){
		$.scrollTo(new_form,700);
	}
}
		
		
function reply_to_question_comment(el){	
	if(el.html().match(/hide/i)){
		var disc = el.closest('div.Comment').next('div.comment_comments');
		var com_cnt = disc.find('div.Comment').size();
		switch(com_cnt){
			case 0:
				el.html('Reply');
				break;
			case 1:
				el.html('Show 1 comment');
				break;
			default:
				el.html('Show ' + com_cnt + ' comments' );
				break;
		}
		disc.remove();
	}else{
		$.get( '/comments/' + el.attr('id') + '/comments', {}, 
			function(data){ 
				var newNode = el.closest('div.Comment').after(data);
				el.html('Hide discussion');
				newNode.next().find('textarea').autoGrow({ minHeight  : 30, maxHeight : 500 })
			}
		)
	}
}



function reply_to_talking_point_comment(el){
	var com = el.closest('div.Comment');
	var com_id = com.attr('id');
	var par = el.closest('div.talking_point_comments');
	// if there is a form open for this already just return now
	var new_form = par.find('form.comment_form[id="'  + com_id + '"]');
	if(new_form.size() == 0 ){
		var form = par.find('form.comment_form.orig');
		form.hide();
		var new_form = form.clone(true);
		new_form.attr('id',com_id);
		new_form.removeClass('orig');
		new_form.show();
		form.after(new_form);
		new_form.find('h3').html("Reply to this comment");
		new_form.find('a.clear').html("Cancel").addClass('cancel_form');
		com = com.find('div.comment_text').clone();
		var author = com.find('a.com_author').remove().html();
		var text = com.html().replace(/<p>/i,'').replace(/<\/p>/i,'\n\n').replace(/^\s*/,'').replace(/\s*$/,'');
		new_form.find('textarea').val('[quote="' + author + '"]' + text + '[/quote]\n\n');
		new_form.find('textarea').autoGrow({ minHeight  : 30, maxHeight : 500 });
		new_form.append('<input type="hidden" name="form_id" value="' + Math.round(Math.random()*1e16) + '"/>');
	}
	if(!new_form.isOnScreen()){
		$.scrollTo(new_form,700);
	}
}


$('a.cancel_form').die('click').live('click',
	function(){
		var el = $(this);
		var par = el.closest('div.discussion');
		var orig_form = par.find('form.comment_form.orig');
		el.closest('form.comment_form').remove();
		var forms = par.find('form.comment_form:visible');
		if(forms.size() == 0){
			orig_form.show(); 
		}
		return false;
	}
);

$('a.clear').die('click').live('click',
	function(){
		$(this).closest('div.discussion').find('form.comment_form.orig textarea').val('');
		return false;
	}
);



$('a.question_show_coms').die('click').live('click',
	function(){
		var el = $(this)
		var comment_ids = $.map(el.closest('div.ques_discussion').find('div.Comment'), function(c){ if(c.id) return Number(c.id); else return null;})
		$.get('/questions/' + this.id + '/comments', {'comment_ids': comment_ids},
			function(data){ 
				var div = $(data);
				var comment_insert_point = el.closest('div.ques_discussion').find('div.Comment:first');
				el.closest('p.count_link').remove();
				//div.find('div.Comment').each( function(){ comments_sec.find('div.Comment:first').before(this) });
				div.find('div.Comment').each( function(){ comment_insert_point.before(this) });
			},
			"html"
		)
		return false;
	}
);


$('a.question_show_talking_points').die('click').live('click',
	function(){
		var el = $(this)
		var talking_point_ids = $.map(el.closest('div.talking_points_list').find('div.talking_point_entry'), function(tp){ if(tp.id) return Number(tp.id); else return null;})
		$.get('/questions/' + this.id + '/talking_points', {'talking_point_ids': talking_point_ids},
			function(data){ 
				var div = $(data)
				var talking_points_sec = el.closest('div.talking_points_list')
				el.closest('p.show_more_link').remove();
				div.find('div.talking_point_entry').each( function(){ talking_points_sec.append(this) })
				size_talking_point_entries();
			},
			"html"
		)
		return false;
	}
);

$('form#what_do_you_think_form').bind('ajax:before', 
	function(){
		if( $(this).find('input:radio:checked').size() == 0 ){
			alert("Please select Add a comment, or Add a talking point")
			return false
		}
	}
);


$('div.my_rating :radio').die('change').live('change',
	function(){
		$.post('/talking_points/' + $(this).closest('div.talking_point_entry').attr('id') + '/rate', {rating: this.value})
	}
);


$('p.my_preference :checkbox').die('change').live('change',
	function(){
		$.post('/talking_points/' + $(this).closest('div.talking_point_entry').attr('id') + '/prefer', {prefer: this.checked})
	}
);

$('a.request_help').live('click',
	function(){
		console.log("a.request_help");
		if($('div.request_help').size()==0){
			$.get('/idea/request_help',
				function(data){
				  var pcs = data.split(/<script/);
					var dialog = $(pcs[0]).dialog( {title : '2029 and Beyond Help and Feedback', modal : true, width: 600, closeOnEscape: false } );
					if(typeof activate_request_help_form == 'undefined') $('head').append('<script' + pcs[1]);
					activate_request_help_form(dialog.find('form'));
					dialog.find('select').focus();
				}
			)
		}
		return false;
	}
)
$('a.request_help').html('');

$('a.help_tag').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
		$(this).addClass('mouseover')
  } else {
		$(this).removeClass('mouseover')
  }
});

$('a.request_new').live('click',
	function(){
		//console.log("Show the new content");
		var help = $('div.new_content');
		if(help.size()==0){
			$.get('/plan/' + team_id + '/new_content/110729',
				function(data){
				  var pcs = data.split(/<script/);
					var dialog = $(pcs[0]).dialog( {title : 'New content', modal : false, width: 'auto', closeOnEscape: true } );
					//if(typeof activate_request_help_form == 'undefined') $('head').append('<script' + pcs[1]);
					//activate_request_help_form(dialog.find('form'));
					//dialog.find('select').focus();
				}
			)
		}else{
			var help_dlg = help.closest('div.ui-dialog');
			if(help_dlg.is(":visible")){
				help_dlg.hide();
			}else{
				help_dlg.show();
			}
			
			
		}
		return false;
	}
)
$('a.request_help').html('');

$('a.new_tag').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
		$(this).addClass('mouseover')
  } else {
		$(this).removeClass('mouseover')
  }
});

$('div.new_content a.display_worksheet').die('click').live('click',
	function(){
		var question_id = Number(this.href.match(/questions\/(\d+)/)[1]);
		console.log("Display the worksheet for " + question_id );
		//debugger
		console.log("this.href: " + this.href);
		// http://2029.civicevolution.dev/questions/350/worksheet
		$.get(this.href,
			function(data){
				//debugger

				$('div.new_content').closest('div.ui-dialog').hide();
				var body_div = $('div.page_content_div');
				body_div.hide();
				$(data).insertAfter(body_div.eq(0)).attr('id',question_id);
			}
		)
		
		Number('http://2029.civicevolution.dev/questions/350/worksheet'.match(/questions\/(\d+)/)[1])
		
		//$('div.talking_points_content_page').hide()
		
		//temp.ws_link = this
		//console.log("show worksheet");
		//console.log("href: " + this.href);
		return false;
	}
)
