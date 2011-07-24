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
		var el = this
		$('<div class="question_comments"></div').load( '/questions/' + this.id + '/talking_points', 
			function(text,stat, xhr){ 
				$(el).closest('div.talking_points_list').find('div.talking_point_entry:last').after(this);
				$(el).hide();
				//console.log(this.innerHTML)
			}
		)
		return false;
	}
);