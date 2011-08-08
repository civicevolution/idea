// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs

console.log("Loading application.js");

temp = {};

$(function(){
		//collapse_proposal_view()
		size_talking_point_entries();
		$(document).ajaxSend(function(e, xhr, options) {
		  var token = $("meta[name='csrf-token']").attr("content");
		  xhr.setRequestHeader("X-CSRF-Token", token);
		});	
	
	
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
					el.closest('div.talking_point_entry').after(data);
					el.html('Hide discussion');
				}
			)
		}
		return false;
	}
);

$('a.reply').die('click').live('click',
	function(){
		var el = $(this);
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
			$.get( '/comments/' + this.id + '/comments', {}, 
				function(data){ 
					el.closest('div.Comment').after(data);
					el.html('Hide discussion');
				}
			)
		}
		return false;
	}
);


$('a.question_show_coms').die('click').live('click',
	function(){
		var el = $(this)
		var comment_ids = $.map(el.closest('div.ques_discussion').find('div.Comment'), function(c){ if(c.id) return Number(c.id); else return null;})
		$.get('/questions/' + this.id + '/comments', {'comment_ids': comment_ids},
			function(data){ 
				var div = $(data)
				var comments_sec = el.closest('div.ques_discussion')
				el.closest('p.count_link').remove();
				div.find('div.Comment').each( function(){ comments_sec.find('div.Comment:first').before(this) })
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
