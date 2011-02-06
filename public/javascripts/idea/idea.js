var temp = {}
$(function(){

	$('div.comment_links').hide();
	
	setTimeout(init_rating_stars, 1000);
	//setTimeout(init_team_rating, 1000);
	

});

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
				//console.log("activate_comment_form(form);")
				//temp.bsd = this
				activate_comment_form( $('form.add_comment_form', this) );
				activate_idea_form( $('form.add_bs_idea_form', this) );
				$('div.list.fav div.list_inner', this).sortable( { update: idea_list_sort_update });
				$('a.edit_answer')
			}
		)
		return false;
	}
);

$('a.close_bsd').live('click',
	function(){
		console.log("close_bsd");
		$this = $(this);
		$this.closest('div.qa_bsd').hide("blind", { direction: "vertical" }, 800,
			function(){
				$this = $(this);
				$this.closest('div.qa').find('a.show_bsd').show();
				$this.remove();
			}
		)
		return false;
	}
);



function idea_list_sort_update(event,ui){
	console.log("idea_list_sort_update");
	var bs_ideas = ui.item.closest('div.list_inner').children('div.bs_idea');
	var ordered_ids = $.map(bs_ideas, function(n,i){ return Number(n.id.match(/\d+/)) })
	var question_id = Number(ui.item.closest('div.qa').attr('id').match(/\d+/));
	send_bs_idea_order_to_server(question_id, ordered_ids)
}

function send_bs_idea_order_to_server(question_id, ordered_ids){
	console.log("send_bs_idea_order_to_server question_id: " + question_id + ", ordered_ids: " + ordered_ids)
	$.ajax({ 					
	  type: "POST", 
	  url: "/idea/update_fav_bs_idea_order", 
		data: { question_id: question_id,
			ids: ordered_ids
		},
		dataType: 'json',
	  success: function(data,status){ 
			//console.log("com_rate submit success, call dispatchComRating"); with submit = true
			temp.set_favorite_success_data = data
		  dispatchBsIdeaFavorite( data[0].params, true );
	  },
		error : function(xhr,errorString,exceptionObj){
			console.log("Error on set_favorite submit, xhr: " + xhr.responseText)
		}
	});
}


$('p.idea_lists a').die('click').live('click',
	function(){
		try{
			temp.list_link = $(this);
			var list_name = $(this).attr('href').match(/list=(\w+)/)[1];
			console.log("list_name: " + list_name);
			var par = $(this).closest('div.bsd');
			var show_list = par.find('div.list.' + list_name).show();
			
			par.find('div.list').not(show_list).hide();
		}catch(e){console.log("p.idea_lists click error: " + e.message)}
		return false; 
	}
)


$('a.report').live('click',
	function(){
		var item_id = Number($(this).attr('href').match(/\d+$/))
		$('<div></div>').load("/idea/report/" + item_id, function(){activate_report_form($(this).find('form'))}).dialog({modal:true,	title: 'Report this content', width: 'auto', height: 'auto'}); 
		
		return false;
	}
)




$('form.mini_thumbs_up input[name=thumbsup_favorite]').die('click').live('click',thumbsup_favorite)

function thumbsup_favorite() {
	try{
		//console.log("thumbs_up_favorite")
		var form = $(this.form);
		// Immediately disable the submit buttons to prevent multiple clicks
		var btns = $(':submit', form).attr('disabled', 'disabled').blur();

		// Disable the form and show a spinner
		form.addClass('closed');

		// Collect the POST data to send to the server
		var postdata = {
			thumbsup_id : $("input[name='thumbsup_id']", form).val(),
			thumbsup_favorite: $(this).val() };
			form.ajaxSubmit({ 					
			  type: "POST", 
			  url: "/idea/bs_idea_favorite", 
				data: postdata,
				dataType: 'json',
			  success: function(data,status){ 
					//console.log("com_rate submit success, call dispatchComRating"); with submit = true
					temp.thumbs_up_favorite_success_data = data;

					var b = form.closest('div.bs_idea');
					if(data[0].params.data.favorite){
						b.append('<p class="fav_action_status fav">Added to your favorites</p>');
					}else{
						b.append('<p class="fav_action_status">Not a favorite</p>')
					}

					b.children('div').fadeTo(500,.1,
						function(){
							$(this).parent().hide("blind", { direction: "vertical" }, 800,
								function(){
									$this = $(this);
									//temp.$this = $this
									if($this.find('p.fav').size() > 0){
										//console.log("add to fav list")
										$this.children('p.fav_action_status').remove();
										//$this.show().children('div').fadeTo(10,1);
										$this.show().children('div').css({opacity:1});
										$this.find('div.rating').remove();
										$this.find('p.like_controls').show();
										$this.closest('div.brainstorming').find('div.list.fav div.list_inner').prepend($this.clone());
									}else{
										//console.log("remove from new list");
										$this.remove();
									}
								}
							)
						}
					)
					
				  dispatchBsIdeaFavorite( data[0].params, true );
					btns.removeAttr('disabled')
			  },
				error : function(xhr,errorString,exceptionObj){
					console.log("Error on thumbsup_favorite submit, xhr: " + xhr.responseText)
					btns.removeAttr('disabled')
				}
			});
		}catch(e){console.log("thumbs_up error: " + e)}
	// Block normal non-AJAX form submitting
	return false;
}

$('a.change_favorite').die('click').live('click',set_favorite)
function set_favorite() {
	try{
		console.log("set_favorite")
		var $this = $(this);
		temp.set_favorite_$this = $this
		var bs_idea_id = Number($this.closest('div.bs_idea').attr('id').match(/\d+/));

		// Collect the POST data to send to the server
		var postdata = {
			thumbsup_id : bs_idea_id,
			thumbsup_favorite: $this.html().match(/add/i) ? 1 : -1 };
			$.ajax({ 					
			  type: "POST", 
			  url: "/idea/bs_idea_favorite", 
				data: postdata,
				dataType: 'json',
			  success: function(data,status){ 
					//console.log("com_rate submit success, call dispatchComRating"); with submit = true
					temp.set_favorite_success_data = data
					if(data[0].params.data.favorite){
						console.log("add idea in popular to my favorites");
						// copy the idea to top of my favorites
						// change link to remove
						var b = $this.closest('div.bs_idea');
						var fav_b = b.clone(true)
						b.closest('div.brainstorming').find('div.list.fav div.list_inner').prepend(fav_b);
						fav_b.find('p.like_controls.add').remove();
						fav_b.find('p.like_controls').show();
						
						
						// remove add link from popular
						// change to "Added to your favorites"
						b.find('p.like_controls.add').html('Added to your favorites')
						
						
					}else{
						// update the list in popular to remove as my favorite	
						//console.log("data[0].params.data.bs_idea_id: " + data[0].params.data.bs_idea_id)	
						var idea_in_pop_list = $this.closest('div.brainstorming').find('div.list.pop').find('div.bs_idea#bs_idea_' + data[0].params.data.bs_idea_id );
						if(idea_in_pop_list.size()>0){
							//console.log("Un-favorited idea is in the popular ideas list");
							idea_in_pop_list.find('p.like_controls.fav').remove();
							idea_in_pop_list.find('p.like_controls').show();
						}

						//console.log("remove idea from my favorites")
						var b = $this.closest('div.bs_idea'); 
						b.append('<p class="fav_action_status fav">Removed from your favorites</p>');
						b.children('div').fadeTo(500,.1,
							function(){
								$(this).parent().hide("blind", { direction: "vertical" }, 800,
									function(){
										$this = $(this);
										$this.remove();
										}
								)
							}
						)
						
					}
				  dispatchBsIdeaFavorite( data[0].params, true );
			  },
				error : function(xhr,errorString,exceptionObj){
					console.log("Error on set_favorite submit, xhr: " + xhr.responseText)
				}
			});
		}catch(e){console.log("set_favorite error: " + e)}
	// Block normal non-AJAX form submitting
	return false;
}



$('a.bs_idea_discussion').die('click').live('click',
	function(){
		console.log("show bs_idea_discussion")
		try{
			var $this = $(this);
			var par = $this.closest('.bs_idea');
			var qna_disc = $this.closest('div.bsd').find('div.discussion.qna');
			if(qna_disc.is(':visible')){
				par.addClass('selected')
				par.closest('.brainstorming').find('div.bs_idea').not(par).hide()			
				temp.bs_idea_par = par	
				qna_disc.hide();
				qna_disc.closest('div.gen_discussion').append(par.find('div.bsd_disc').show())
				//$this.hide();
				// scroll page to the question
				var question = qna_disc.closest('div.qa').find('.question:first');
				$('html,body').animate({ scrollTop: question.offset().top }, { duration: 'slow', easing: 'swing'});
			}else{
				par.removeClass('selected');
				var idea = par.closest('.brainstorming').find('div.bs_idea:visible')
				par.closest('.brainstorming').find('div.bs_idea').show();				
				temp.idea = idea
				//debugger 
				par.find('div.discussion').append(qna_disc.closest('div.gen_discussion').find('div.bsd_disc').hide())
				qna_disc.show();
				//$this.show();
				// scroll page to the idea
				setTimeout(function(){$('html,body').animate({ scrollTop: this.offset().top }, { duration: 'slow', easing: 'swing'});}.bind(idea),500)		
			}
			
		}catch(e){console.log("show bs_idea_discussion error: " + e)}
		return false;
	}
);


$('div.bsd_disc a.bsd').live('click', 
	function(){
		$(this).closest('div.bsd').find('div.bs_idea:visible a.bs_idea_discussion').click();
		return false;
	}
);




$('div.comment').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    // do something on mouseover
		$(this).find('div.comment_links').show();
  } else {
    // do something on mouseout
		$(this).find('div.comment_links').hide();
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



function ellipsis(page){
	//console.log("$('div.comment_text:visible',page).size(): " + $('div.comment_text:visible',page).size())
	$('div.comment_text:visible',page).each(
		function(){
			//console.log("ellipsis v3")
			var $this = $(this);
			if( $this.find('div.one_liner').size() > 0 ) return;
			//if(ie7) $this.closest('div.comment').css('margin',0);
			var d = $('<div class="one_liner"><span class="txt"></span></div>')
			$(this).prepend(d)

			var w = d.width();

			var icon;
			// if the next sibling is class resource upload or resource link, add an icon
			var res = $this.next('.resource')
			if(res.size() > 0){
				if(res.attr('className').match(/hide/)){
					// if hide, don't show an icon
				}else if(res.attr('className').match(/link/)){
					icon = 'link';
					w -= 20;
				}else if(res.attr('className').match(/upload/)){
					icon = 'upload';
					w -= 20;
				}
			}			
			w -= 30; // for the ellipsis

			var s = $('span.txt',d)

			var txt = $('p:first',this).html().replace(/<br[^>]*>/gi,' ');
			var num_chars = w / 6;
			txt = txt.substring(0,num_chars);
			//console.log("num_chars: " + num_chars + " raw txt: " + txt)
			var words = txt.split(/\s+/g);
			var words_cnt = words.length
			//console.log("Start words: " + words)
			var ctr = 6, reducing = false, sizing = true;
//			
			//loopctr = 0;

			do{
				s.html( words.slice(0,ctr).join(' ') );			
				//console.log("loop: " + loopctr + ", ctr: " + ctr + " str: " + words.slice(0,ctr).join(' ') + ", width: " + s.width() + ", w: " + w)
				if(s.width() > w){
						reducing = true;
					--ctr;
					//sizing = false;
				}else if(reducing){
					sizing = false;
				}else{
					//console.log("increase ctr")
					//console.log('words: ' + words)
					++ctr;
				}
				//if( ++loopctr > 10 ) break;
			}while(sizing && ctr <= words_cnt)
			// add ellipsis and icons
			if(words_cnt > ctr){
				s.append('&hellip;')
			}

			if(icon){
				d.append('<img src="/images/icon_' + icon + '12.gif"/>');
			}

		}
	)
}




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
