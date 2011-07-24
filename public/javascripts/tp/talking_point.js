temp = {}
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