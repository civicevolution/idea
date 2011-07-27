temp = {}

$(function(){
		collapse_proposal_view()
	
	
	
	}
);

$('a.expand_proposal_view').die('click').live('click',
	function(){
		expand_proposal_view();
		return false;
	}
);

$('a.collapse_proposal_view, div.navigation a.summary').die('click').live('click',
	function(){
		collapse_proposal_view();
		return false;
	}
);

$('a.open_worksheet, div.proposal.inview h2.question').die('click').live('click',
	function(){
		var question_worksheet = $(this).closest('div.question_worksheet');
		show_question_worksheet(question_worksheet)
		return false;
	}
);

$('div.navigation a.goto').die('click').live('click',
	function(){
		var question_worksheet = $('div.question_worksheet[id=' + this.id + ']');
		$('div.question_worksheet').hide();
		question_worksheet.show();
		$.scrollTo(question_worksheet,1000);	
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

	$('div.talking_point_entry').each( 
		function(){
			var el = $(this)
			var b = el.children('div.talking_point_body').height('auto');
			var cr = el.find('div.talking_point_acceptable > div.community_rating').height('auto');
			var p = el.children('div.talking_point_preferable').height('auto');
			var max = Math.max.apply( Math, [b.height(), (cr.height() + 20), p.height()] );
			//console.log("max height: " + max)
			b.height(max);
			cr.height(max-20);
			p.height(max-20);
		}
	)	
}


$('a.tp_show_coms').die('click').live('click',
	function(){
		var el = $(this);
		$.get( '/talking_points/' + this.id + '/comments', {}, 
			function(data){ 
				el.closest('div.talking_point_entry').after(data);
			}
		)
		
		//$('<div class="talking_point_comments"></div').load( '/talking_points/' + this.id + '/comments', 
		//	function(text,stat, xhr){ 
		//		$(el).closest('div.talking_point_entry').after(this);
		//		//console.log(this.innerHTML)
		//	}
		//)
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
			},
			"html"
		)
		return false;
	}
);