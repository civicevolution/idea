var temp = {}
$(function(){

	$('div.comment_links').hide();
	$('div.ans_comment_links a').hide();
	
	setTimeout(init_rating_stars, 1000);
	//setTimeout(init_team_rating, 1000);
	activate_endorsement_form();
	
	$('div#endorsements table abbr.timeago').timeago();

});

$('a.delete_endorsement').live('click', 
	function(){
		console.log("delete_endorsement");
		try{
			
			$.ajax({ 					
			  type: "POST", 
			  url: "/idea/endorse_proposal", 
				data: { team_id: team_id,
					act: 'delete'
				},
				dataType: 'json',
			  success: function(data,status){ 
					//console.log("com_rate submit success, call dispatchComRating"); with submit = true
					temp.delete_endorsement = data
				  dispatchEndorsement( data[0].params.data, true );
			  },
				error : function(xhr,errorString,exceptionObj){
					console.log("Error on set_favorite submit, xhr: " + xhr.responseText)
				}
			});
			
			
		}catch(e){console.log("delete_endorsement e: " + e.message)}
		return false;
	}
);

$('a.2029_guidelines').live('click',
	function(){
		$('<div>Loading...</div>').load("/idea/guidelines", function(){
			$(this).dialog( {title : '2029 and beyond Online Groundrules and Guidelines', modal : true, width: 600, maxHeight: 500 } );
		})
		return false;
	}
)


$('a.update_endorsement').live('click', 
	function(){
		console.log("update_endorsement");
		try{
			var form = $('div#endorsements form');
			form.show();
			var t = $(this).closest('tr').find('td.text').html();
			form.find('textarea').val( strip_white_space(t) )
		}catch(e){console.log("update_endorsement e: " + e.message)}
		return false;
	}
);



$('div.rate').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    // do something on mouseover
		$this = $(this)
		$this.find('div.results').hide();
		$this.find('form').show();
  } else {
    // do something on mouseout
		$this = $(this)
		$this.find('div.results').show();
		$this.find('form').hide();
  }
});

$('a.show_bsd').live('click',
	function(){
		$this = $(this);
		$this.hide();
		$this.next('div.show_bsd').html('Loading...')
		$this.next('div.show_bsd').load('/idea/bsd',{id: $this.attr('href').match(/\d+/)[0]}, 
			function(){
				var $this = $(this);
				$this.hide();
				$this.show("blind", { direction: "vertical" }, 2000);
				
				//console.log("activate_comment_form(form);")
				//temp.bsd = this
				$this.find('div.comment_links').hide();
				activate_comment_form( $('form.add_comment_form', this) );
				activate_idea_form( $('form.add_bs_idea_form', this) );
				$('div.list.fav div.list_inner', this).sortable( { update: idea_list_sort_update });
				$this.find('p.idea_lists a').eq(0).click();
				//$('a.edit_answer')
			}
		)
		return false;
	}
);

$('a.close_bsd').live('click',
	function(){
		console.log("close_bsd");
		$this = $(this);
		$this.closest('div.qa_bsd').hide("blind", { direction: "vertical" }, 1200,
			function(){
				$this = $(this);
				$this.closest('div.qa').find('a.show_bsd').show();
				$this.remove();
			}
		)
		return false;
	}
);




$('a.report').live('click',
	function(){
		var item_id = Number($(this).attr('href').match(/\d+$/))
		$('<div></div>').load("/idea/report/" + item_id, 
			function(){
				var $this = $(this);
				$this.dialog({modal:true,	title: 'Report this content', width: 'auto', height: 'auto'}); 
				activate_report_form($this.find('form'))
			}
		)
		return false;
	}
)

$('a.pre_review_proposal:first').live('click',
	function(){
		var item_id = Number($(this).attr('href').match(/\d+$/))
		$('<div></div>').load("/idea/submit_proposal/" + team_id + '?act=pre_review', 
			function(){
				var $this = $(this);
				$this.dialog({modal:true,	title: 'Request pre-submission review', width: 'auto', height: 'auto'}); 
				activate_submit_form($this.find('form'))
			}
		)
		return false;
	}
)

$('a.submit_proposal:first').live('click',
	function(){
		var item_id = Number($(this).attr('href').match(/\d+$/))
		$('<div></div>').load("/idea/submit_proposal/" + team_id + '?act=submit', 
			function(){
				var $this = $(this);
				$this.dialog({modal:true,	title: 'Submit for official review', width: 'auto', height: 'auto'}); 
				activate_submit_form($this.find('form'))
			}
		)
		return false;
	}
)



$('div.comment').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    // do something on mouseover
		$(this).find('div.comment_links').show();
  } else {
    // do something on mouseout
		$(this).find('div.comment_links').hide();
  }
});

$('div.answer_section').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    // do something on mouseover
		$(this).find('div.ans_comment_links a').show();
  } else {
    // do something on mouseout
		$(this).find('div.ans_comment_links a').hide();
  }
});



$('div.discussion').delegate( 'div.close_1com, div.one_line', 'click', 
	function(){
		var $this = $(this);
		if( $this.closest('div.Comment_entry').hasClass('full_comment_display') ){
			$this.closest('div.comment').slideUp(500, function(){
				$(this).closest('div.Comment_entry').addClass('one_line_comment').removeClass('full_comment_display');
				$(this).slideDown(200,
					function(){
						ellipsis(this);
					}
				)
			},'easeOutQuart');
			
		}else{
			$this.closest('div.comment').slideUp(500, function(){
				$(this).closest('div.Comment_entry').removeClass('one_line_comment').addClass('full_comment_display');
				$(this).slideDown(200)
			},'easeOutQuart');
		}
	}
);


Function.prototype.bind = function(bind, args){
	return this.create({bind: bind, arguments: args});
}

// I made need to work with the arguments.slice part
Function.prototype.create = function(options){
	var self = this;
	options = options || {};
	return function(event){
		var args = options.arguments;
		if(args != undefined){
			args = $.makeArray(args);
		}else{
			// options.event would be the first item, so drop it if it exists
			//args = Array.prototype.splice.call(arguments, (options.event) ? 1 : 0);
			args = $.makeArray(arguments);
		}
		var returns = function(){
			return self.apply(options.bind || null, args);
		};
		return returns();
	};
}
