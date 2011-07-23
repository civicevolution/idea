temp = {}
$('a.tp_show_coms').die('click').live('click',
	function(){
		temp.a_this = this;
		var el = this
		$('<div class="talking_point_comments"></div').load( '/talking_points/' + this.id + '/comments', 
			function(text,stat, xhr){ 
				temp.el = el
				temp.cb_this = this
				$(el).closest('div.talking_point_entry').after(this);
				//console.log(this.innerHTML)
			}
		)
		return false;
	}
);

$('a.question_show_coms').die('click').live('click',
	function(){
		temp.a_this = this;
		var el = this
		$('<div class="question_comments"></div').load( '/questions/' + this.id + '/comments', 
			function(text,stat, xhr){ 
				temp.el = el
				temp.cb_this = this
				$(el).closest('div.ques_discussion').find('div.Comment:last').after(this);
				$(el).hide();
				//console.log(this.innerHTML)
			}
		)
		return false;
	}
);