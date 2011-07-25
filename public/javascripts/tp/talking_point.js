temp = {}

$(function(){
		//expand_proposal_view()
	
	
	
	}
);

$('a.expand_proposal_view').die('click').live('click',
	function(){
		expand_proposal_view();
		return false;
	}
);

$('a.collapse_proposal_view').die('click').live('click',
	function(){
		collapse_proposal_view();
		return false;
	}
);

function collapse_proposal_view(){
	$('div.what_do_you_think').hide();
	$('div.ques_discussion').hide();
	//$('div.my_rating').hide();
	$('div.talking_point_preferable').hide();
	$('h3.ques_sub_hdg').hide();
	$('div.talking_point_entry.header').hide();
	$('div.talking_point_controls').hide();
	
	$('div.proposal').addClass('inview');
	$('div.question_page').addClass('noview');

	$('div.talking_point_entry').each( 
		function(){
			var el = $(this)
			var b = el.children('div.talking_point_body').height('auto');
			var cr = el.find('div.talking_point_acceptable > div.community_rating').height('auto');
			var mr = el.find('div.talking_point_acceptable > div.my_rating').height('auto');
			var max = Math.max.apply( Math, [b.height(), (cr.height() + 20), (mr.height() + 20)] );
			console.log("max height: " + max)
			b.height(max);
			cr.height(max-20);
			mr.height(max-20);
		}
	)	
}

function expand_proposal_view(){
	$('div.what_do_you_think').show();
	$('div.ques_discussion').show();
	$('div.my_rating').show();
	$('div.talking_point_preferable').show();
	$('h3.ques_sub_hdg').show();
	$('div.talking_point_entry.header').show();
	$('div.talking_point_controls').show();
	
	$('div.proposal').removeClass('inview');
	$('div.question_page').removeClass('noview');

	$('div.talking_point_entry').each( 
		function(){
			var el = $(this)
			var b = el.children('div.talking_point_body').height('auto');
			var cr = el.find('div.talking_point_acceptable > div.community_rating').height('auto');
			var p = el.children('div.talking_point_preferable').height('auto');
			var max = Math.max.apply( Math, [b.height(), (cr.height() + 20), p.height()] );
			console.log("max height: " + max)
			b.height(max);
			cr.height(max-20);
			p.height(max-20);
		}
	)	
}


$('a.tp_show_coms').die('click').live('click',
	function(){
		var el = this
		$('<div class="talking_point_comments"></div').load( '/talking_points/' + this.id + '/comments', 
			function(text,stat, xhr){ 
				$(el).closest('div.talking_point_entry').after(this);
				//console.log(this.innerHTML)
			}
		)
		return false;
	}
);

$('a.question_show_coms').die('click').live('click',
	function(){
		var el = this
		$('<div class="question_comments"></div').load( '/questions/' + this.id + '/comments', 
			function(text,stat, xhr){ 
				$(el).closest('div.ques_discussion').find('div.Comment:last').after(this);
				$(el).hide();
				//console.log(this.innerHTML)
			}
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