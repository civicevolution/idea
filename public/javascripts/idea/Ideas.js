$('p.idea_lists a').die('click').live('click',
	function(){
		console.log("Show the desired idea list: new, pop, fav, all")
		try{
			var $this = $(this);
			temp.list_link = $this;
			var list_name = $this.attr('href').match(/list=(\w+)/)[1];
			console.log("list_name: " + list_name);
			var par = $this.closest('div.bsd');
			var show_list = par.find('div.list.' + list_name).show();
			
			par.find('div.list').not(show_list).hide();
			
			$this.parent().children('a').removeClass('active_list');
			$this.addClass('active_list')
			
		}catch(e){console.log("p.idea_lists click error: " + e.message)}
		return false; 
	}
)


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
		console.log("close the idea discussion and return to the idea list")
		$(this).closest('div.bsd').find('div.bs_idea:visible a.bs_idea_discussion').click();
		return false;
	}
);



$('a.edit_bs_idea').die('click').live('click',
	function(){
		try{
			var a = $(this);
			var idea = a.closest('td').find('div.bs_idea');
			var ctls = a.closest('p');
			//console.log("edit this idea, size: " + idea.size())
			var id = Number(a.attr('href').match(/\d+$/));
			var ideas = idea.closest('div.bs_ideas');
			var q_id = Number(ideas.attr('id').match(/\d+/))
			var mode = 'edit';
			//console.log("id: " + id)
			var form = $( jsonFn.add_bs_idea_form({id : id, q_id: q_id, mode : mode }) );
			$('label',form).html("Please edit this idea");
			var char_cnt = Number(idea.closest('div.bs_ideas').attr('criteria').match(/\d+$/))
			//console.log("change answer form character count to " + char_cnt )
			form.find('span.char_ctr').html(char_cnt + ' characters left');
			
			$('div.control_line',form).css('margin-bottom','40px');
			$('a.clear',form).removeClass('clear').addClass('cancel').html('Cancel');
			var s  = idea.html().replace(/p>\s*<p/g,'p><p').replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/\s*$/,'').replace(/^[ ]*/mg,'');
	 		
			$('textarea',form).html(s);
			//console.log("ready to show form before idea: size: " + idea.size())
			form.hide();
			ctls.hide(1000);
			idea.hide(1000, 
				function(){
					//console.log("now add the idea form idea.size: " + idea.size())
					idea.before( form );
					form.show(1000)
				}
			);
			orig_idea = $.merge(ctls,idea);
			activate_idea_form(form,orig_idea);
		}catch(e){console.log("edit_idea error: " + e)}
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



$('form.mini_thumbs_up input[name=thumbsup_favorite]').live('click',
	function() {
		try{
			//console.log("thumbs_up_favorite")
			var form = $(this.form);
			// Immediately disable the submit buttons to prevent multiple clicks
			var btns = $(':submit', form).attr('disabled', 'disabled').blur();

			// Disable the form and show a spinner
			form.addClass('closed');
			send_favorite_to_server( $("input[name='thumbsup_id']", form).val(), $(this).val() );
			}catch(e){console.log("thumbs_up error: " + e)}
		// Block normal non-AJAX form submitting
		return false;
	}
);

$('a.change_favorite').live('click',
	function() {
		try{
			console.log("set_favorite")
			var $this = $(this);
			temp.set_favorite_$this = $this
			var bs_idea_id = Number($this.closest('div.bs_idea').attr('id').match(/\d+/));
			var fav = $this.html().match(/add/i) ? 1 : -1;
			send_favorite_to_server(bs_idea_id, fav);
			return false;
		}catch(e){console.log("change_favorite error: " + e.message)}
	}
);

function send_favorite_to_server(bs_idea_id,fav){
	try{
		$.ajax({ 					
		  type: "POST", 
		  url: "/idea/bs_idea_favorite", 
			data: {
				thumbsup_id : bs_idea_id,
				thumbsup_favorite: fav },
			dataType: 'json',
		  success: function(data,status){ 
				console.log("send_favorite_to_server submit success, call BsIdeas.favorite"); 
				temp.send_favorite_to_server = data
				BsIdeas.adjust_favorites(data)
					
		  },
			error : function(xhr,errorString,exceptionObj){
				console.log("Error on send_favorite_to_server submit, xhr: " + xhr.responseText)
			}
		});
		}catch(e){console.log("send_favorite_to_server error: " + e)}
}

BsIdeas = {
  adjust_favorites: function(data){
		// this must adjust the existing idea since it may have embedded comments
		console.log("BsIdeas.adjust_favorites");
		var idea_data = data[0].params.data
		temp.BsIdeas_adjust_favorites_data = idea_data; // .bs_idea_Id, .favorite true|false
		
		if(idea_data.favorite){
			console.log("adjust to a favorite")
			// show the acknowldgement message	

			var bs = $('div#bs_idea_' + idea_data.bs_idea_id);
			var bs_clone = bs.clone().eq(0);
			bs.append('<p class="fav_action_status fav">Added to your favorites</p>');
			bs.children('div').css('opacity',.1)
			var par = bs.closest('div.brainstorming');

			// add to top of favorite list

			var fav_list = par.find('div.list.fav div.list_inner');
			fav_list.find('p.empty').remove(); // if the list is empty
			bs_clone.hide();
			bs_clone.find('p.like_controls.add a').html("Remove from my favorites");
			bs_clone.find('div.rating').remove();
			bs_clone.find('p.like_controls').removeClass('hide');
			fav_list.prepend(bs_clone);
			bs_clone.show("blind", { direction: "vertical" }, 800);
			
			// remove from new list (if present)
			var bs_in_new = par.find('div.list.new div#bs_idea_' + idea_data.bs_idea_id);
			bs_in_new.fadeTo(600,1,
				function(){
					$(this).hide("blind", { direction: "vertical" }, 800,
						function(){
							$(this).remove();
						}
					);
				}
			);
			
			// update fav status if in pop list, remove add as fav link and mark as my fav
			var bs_in_pop = par.find('div.list.pop div#bs_idea_' + idea_data.bs_idea_id);
			if(bs_in_pop.size() > 0){
				bs_in_pop.children('p.fav_action_status').remove();
				bs_in_pop.children('div').fadeTo(500,1);
				bs_in_pop.find('p.like_controls').html("Added as your favorite");
			}

			// update fav status if in all list, remove add as fav link and mark as my fav
			var bs_in_all = par.find('div.list.all div#bs_idea_' + idea_data.bs_idea_id);
			if(bs_in_all.size() > 0){
				bs_in_all.fadeTo(600,1, 
					function(){
						var $this = $(this);
						$this.children('p.fav_action_status').remove();
						// replace "Add to my favorites" with your favorite
						$this.find('p.like_controls.add').html("Added as your favorite");
						$this.children('div').fadeTo(500,1);
					}
				)
			}
			
		}else{
			console.log("adjust to NOT a favorite")
			var par = $('div#bs_idea_' + idea_data.bs_idea_id).closest('div.brainstorming');
			
			// remove from fav list
			var bs_in_fav = par.find('div.list.fav div#bs_idea_' + idea_data.bs_idea_id);
			// show the acknowldgement message
			bs_in_fav.append('<p class="fav_action_status">Not a favorite</p>')
			bs_in_fav.children('div').css('opacity',.1)
			bs_in_fav.fadeTo(600,1,
				function(){
					$(this).hide("blind", { direction: "vertical" }, 800,
						function(){
							$(this).remove();
						}
					);
				}
			);
			// update fav status if in pop list, remove my fav and add "add as fav link"
			var bs_in_pop = par.find('div.list.pop div#bs_idea_' + idea_data.bs_idea_id);
			if(bs_in_pop.size() > 0){
				bs_in_pop.find('p.like_controls.fav').remove();
				bs_in_pop.find('p.like_controls').removeClass('hide');
			}
			
			// update fav status if in all list, remove my fav and add "add as fav link"
			var bs_in_all = par.find('div.list.all div#bs_idea_' + idea_data.bs_idea_id);
			if(bs_in_all.size() > 0){
				bs_in_all.find('p.like_controls.fav').remove();
				bs_in_all.find('p.like_controls').removeClass('hide');
			}
			
			
		}
		
	},
	add_idea: function(idea, submit_response){
		console.log("BsIdea.add_idea")
		// a new idea is added - either my idea or from another user
		temp.add_idea = idea
		var html = jsonFn.bs_idea(idea);
		var par = $('div#q' + idea.data.bs_idea.question_id + ' div.brainstorming')
		var bs_idea = $(html).prependTo( par.find('div.list.new') );
		bs_idea.find('p.status').hide();
		bs_idea.find('div.rating').remove();
		bs_idea.find('p.like_controls.rem').hide();
		bs_idea.find('p.like_controls.fav').html('Added to your favorites');
		
		bs_idea.clone().prependTo( par.find('div.list.all') );
		
		
		bs_idea = bs_idea.clone().prependTo( par.find('div.list.fav > div') );
		//bs_idea.find('p.status').hide();
		//bs_idea.find('div.rating').remove();
		bs_idea.find('p.like_controls.rem').show();
		bs_idea.find('p.like_controls.fav').hide();
		
		// popularity # a of b
		
		
		// Fav state 1, 0, -1
		
		
		
	},
	adjust_idea_layout: function(idea, list){
		// adjust the layout of the idea depending on the idea's fav status and the destination list
		// convert data into html
		var div = $( jsonFn['bs_idea']( idea ) );
	},
	adjust_idea_list: function(list){
		
		
	},
	select_idea_list: function(name){
		
		
	},
	data: { ver: 'BsIdeas data ver 0.1'}
}

/*

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
*/


function dispatchBsIdeas(item,submit_response){
	BsIdeas.add_idea(item,submit_response)
	return;
	
	console.log("v5 dispatchBsIdeas" + " submit_response: " + submit_response);
	var idea = item.data.bs_idea
	var par = $('div#q' + item.data.bs_idea.question_id).find('div.brainstorming')

	debugger
	console.log("uid: " + item.uid)
	var node = $("div[uid='" + item.uid + "']", par )	
	
	if(submit_response){
		//console.log("submit_response is true, force it to write the data");
		temp.idea_submit_response = item
		// this is dispatched from the submit response - I submitted this
		console.log("Provide edit link - I own this")
		item.edit_link = 'on'
	}else{
		//console.log("submit_response is NOT true, this is APE ");
		NOTIFIER.inform( { type: 'bs_idea', page_id: 
		 	Number( $('div#bs_ideas_' + item.data.bs_idea.question_id).closest('.Page').attr('id').match(/\d+/)) })
		temp.idea_ape = item
		item.edit_link = 'off'
		// this is dispatched from APE broadcast
		// if this uid has already been used in this parent, return because it was created for submit response
		if(node.size() > 0){
			console.log("submit response already inserted idea, ignore this ape broadcast")
			return;
		}
	}

	// convert data into html
	var div = $( jsonFn['bs_idea']( item ) )

	var icon_elm = $(new_icon_data['bs_idea'], div);
	//if(item.mode == 'add'){
	//	icon_elm.prepend('<span class="new _bs_idea">New</span>');
	//}else if(item.mode == 'edit'){
	//		icon_elm.prepend('<span class="new _updated _bs_idea">Updated</span>');
	//}
		
	// insert into the question
	if(node.size() > 0){
		// this item was already added by ape before submit_response 
		console.log("replace ape version with submit response version")
		// give div the sibling class of the node
		node.replaceWith(div);
		//node.after(div)  // for testing
	}else if(item.mode == 'add'){
		console.log("no duplicate, prepend this idea to the div.ideas table")
		//var par = $('div#bs_ideas_' + item.data.bs_idea.question_id + ' tr:first')
		
		if(par.size() == 0){
			console.log("dispatchBsIdeas didn't find par for qid: " + item.data.bs_idea.question_id)
			//// empty table doesn't any tr, so append to the table
			//par = $('div#bs_ideas_' + item.data.bs_idea.question_id + ' table')
			//var tb = $('<tbody></tbody>');
			//tb.append(div);
			//par.append( tb );
		}else{
			//par.before( div );		
			par.find('form:last').before(div)
		}
		div.hide().show(2000, function(){
			div.effect("highlight", {}, 4000)
		})
		//par.closest('table').find('tr.empty_table').remove()
	}else{
		console.log("item.mode = " + item.mode + ", should be edit")
		var par = $('div#bs_' + item.data.bs_idea.id).closest('tr')
		temp.idea_par = par
		console.log("replace new with updated")
		temp.idea_div = div
		par.replaceWith(div);
		div.effect("highlight", {}, 2000);
	}
	//$('abbr.timeago',div).timeago();
	//if(item.my_vote > 0){
	//	// should show Please rate
	//	$(':radio',div).eq( item.my_vote - 1 ).attr('checked','checked');
	//}else{
	//	$(':radio:checked',div).removeAttr('checked');
	//	$('span.team_rating',div).replaceWith( $('<span class="please_rate">Please rate</span>') );		
	//}
	//init_team_rating(div)
	//init_rating_stars( $(':radio.star',div) );
}


function activate_idea_form(form,orig_idea){
	console.log("activate_idea_form")
	activate_text_counters_grow( $('textarea',form) )

	$('div.control_line a.cancel',form).click(
		function(){
			try{
				//console.log("Cancel the idea form");
				var form = $(this).closest('form');
				form.remove();
				// restore a form that may have been faded
				//form.closest('.tab_window').find('form.add_answer_form:last').fadeTo(1000,1)
				if(orig_idea)orig_idea.show(1000)
			}catch(e){
				console.log("answer cancel error: "+ e)
			}
			return false;
		}
	);
	
	$('div.control_line a.clear',form).click(
		function(){
		 //console.log("Clear the idea form");
			$(this).closest('form').find('textarea').val('');
			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			return false;
		}
	);

	$('button', form).unbind('click').click(
		function(){
		 console.log("Submit the idea form");

			var form = $(this).closest('form');
			var btn = $(this);
			btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')

			$(':input',form).removeClass('form_error_border');
			$('p.form_error_text',form).remove();
			
			form.ajaxSubmit({ 					
			  type: "POST", 
			  url: "/idea/create_brainstorm_idea", 
				dataType: 'json',
			  success: function(data,status){ 
				 //console.log("idea submit success, call dispatchBsIdeas");
				  //dispatchBsIdeas( data[0].params.data, true );
					BsIdeas.add_idea( data[0].params.data, true );
					var msg = $('<p class="confirmation">Your idea has been saved successfully & inserted into your favorites list</p>')
					form.prepend(msg)
					msg.effect('highlight',{},3000, function(){$(this).remove()});					
					$('textarea',form).val('');
					btn.removeAttr('disabled').next('img').remove();
			  },
				error : function(xhr,errorString,exceptionObj){
					//console.log("Error, xhr: " + xhr.responseText)
					try{
						show_form_error(form, xhr.responseText);
						btn.removeAttr('disabled').next('img').remove();
					}catch(e){
						btn.removeAttr('disabled').next('img').remove();
						console.log("Brainstorm idea submit error: " + e)
						$('<div><p>Sorry, we cannot process your brainstorm idea at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
					}
				}
			});
			return false;
		}
	);
}