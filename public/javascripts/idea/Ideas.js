$('p.idea_lists a').die('click').live('click',
	function(){
		//console.log("Show the desired idea list: new, pop, fav, all")
		try{
			BsIdeas.build_list($(this));
		}catch(e){console.log("p.idea_lists a .click error: " + e.message)}
		return false; 
	}
)

$('a.bs_idea_discussion').die('click').live('click',
	function(){
		console.log("show bs_idea_discussion")
		try{
			var $this = $(this);
			var qna_disc = $this.closest('div.bsd').find('div.discussion.qna');
			if(qna_disc.is(':visible')){
				var par = $this.closest('.bs_idea');
				par.addClass('selected');
				par.closest('div.brainstorming').find('div.bs_idea').not(par).hide();		
				qna_disc.hide();
				var id = Number(par.attr('id').match(/\d+/));
				var bsd_disc = par.closest('div.bsd').find('div#idea_discussion_' + id + ' > div.bsd_disc');
				qna_disc.closest('div.gen_discussion').append(bsd_disc)
				//$this.hide();
				// scroll page to the question
				var question = qna_disc.closest('div.qa').find('.question:first');
				$('html,body').animate({ scrollTop: question.offset().top }, { duration: 'slow', easing: 'swing'});

				if(bsd_disc.find('form.add_comment_form').size() == 0 ){
					console.log("bs_idea_discussion insert com form, if not present");
					var par_id = Number(bsd_disc.attr('idea_item_id').match(/\d+/));
					var mode = 'add';
					var id = par_id;
					var resource_type = 'simple';
					//console.log("par_id: " + par_id)
					var form = $( jsonFn.add_comment_form({par_id : par_id, mode : mode, id : id, resource_type : resource_type }) );
					form.find('div.add_comment span.char_ctr:last').html(com_criteria + ' characters left');
					form.find('div.add_link span.char_ctr:last').html(res_criteria + ' characters left');
					form.find('div.attach_file span.char_ctr:last').html(res_criteria + ' characters left');

					form.css('margin-left','24px')
					bsd_disc.find('div.add_com_form').replaceWith( form );
					activate_comment_form(form);
				}
			}else{
				var idea = $this.closest('.brainstorming').find('div.bs_idea:visible');
				idea.removeClass('selected');
				$this.closest('div.brainstorming').find('div.bs_idea').show();				
				//debugger 
				var bsd_disc = qna_disc.closest('div.gen_discussion').find('div.bsd_disc');
				var id = bsd_disc.attr('id');
				$this.closest('div.bsd').find('div#idea_discussion_' + id).append(bsd_disc);
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


$('div.sort').die('click').live('click',
	function(){
		var $this = $(this);
		var bs_idea = $this.closest('div.bs_idea');
		if($this.hasClass('up')){
			var adjacent = bs_idea.prev('div.bs_idea');
			adjacent.before(bs_idea)
		}else{
			var adjacent = bs_idea.next('div.bs_idea');
				adjacent.after(bs_idea)
		}
		if(adjacent.size() > 0 ) renumber_favorites_and_send($this.closest('div.list_inner'));
	}
)


$('input.sort').die('blur').die('keyup').live('blur keyup',
	function(event){
		var $this = $(this);
		var bs_idea = $this.closest('div.bs_idea');
		if(!event.keyCode || event.keyCode == 13 ){
			var new_index_num = Number($this.val());
			// find the idea with this number
			var bs_ideas = bs_idea.parent().children('div.bs_idea').not(bs_idea)
			var before_idea = null;
			bs_ideas.each( 
				function(){
					if(!before_idea){
						// find the idea with this number or the first one greater than this number
						var idea = $(this);
						if(Number(idea.find('input.sort').val()) >= new_index_num ){
							before_idea = idea
						}
					}
				}
			)
			if(before_idea){
				bs_idea.hide(1000, 
					function(){
						before_idea.before(bs_idea);
						bs_idea.show(1000, 
							function(){
								renumber_favorites_and_send($(this).closest('div.list_inner'))
							}
						)
					}
				)
			}else{
				var favs_inner = bs_idea.closest('div.list_inner');
				bs_idea.hide(1000, 
					function(){
						favs_inner.append(bs_idea);
						bs_idea.show(1000, 
							function(){
								renumber_favorites_and_send(favs_inner)
							}
						)
					}
				)
			}
					
		}
	}
)



function renumber_favorites_and_send(favs){
	var bs_ideas = favs.children('div.bs_idea');
	var cnt = 1;
	bs_ideas.each( function(){ $(this).find('input.sort').val(cnt++);  } )
	var ordered_ids = $.map(bs_ideas, function(n,i){ return Number(n.id.match(/\d+/)) })
	var question_id = Number(favs.closest('div.qa').attr('id').match(/\d+/));
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
			console.log("com_rate submit success, call dispatchComRating");
			temp.set_favorite_success_data = data
		  dispatchBsIdeaFavorite( data[0].params, true );
	  },
		error : function(xhr,errorString,exceptionObj){
			console.log("v1 Error on set_favorite submit, xhr: " + xhr.responseText)
			try{
				var form_errors = eval(xhr.responseText)[0];	
				if(form_errors['Sign in required']){
					console.log("show the sign in form");
					show_signin_form('prioritize favorite ideas');
				}else{
					console.log("set_favorite error, not sign in required")
				}
			}catch(e){
				console.log("set_favorite submit browser error in server error handling: " + e)
				$('<div><p>Sorry, we cannot process your comment rating at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
			}
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
			console.log("set_favorite v1")
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
		console.log("send_favorite_to_server")
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
				BsIdeas.adjust_favorites(data);					
		  },
			error : function(xhr,errorString,exceptionObj){
				console.log("Error on send_favorite_to_server submit, xhr: " + xhr.responseText)
				try{
					var form_errors = eval(xhr.responseText)[0];
					if(form_errors['Sign in required']){
						console.log("show the sign in form");
						show_signin_form('add a favorite idea');
					}else{
						console.log("send_favorite_to_server error, not sign in required")
					}
				}catch(e){
					console.log("send_favorite_to_server submit browser error in server error handling: " + e)
					$('<div><p>Sorry, we cannot process your favorite rating at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
				}
			}
			
		});
		}catch(e){console.log("send_favorite_to_server error: " + e)}
}

BsIdeas = {
	bs_ideas: {},
	bs_ideas_priority: {},
	add_bs_ideas_data: function(question_id, bs_ideas,bs_ideas_priority){
		BsIdeas.bs_ideas_priority[question_id] = bs_ideas_priority;
		//console.log("add_bs_ideas_data for question_id: " + question_id )
		// create array of the bs_ideas for this question, and set the fav and pop indexes
		BsIdeas.bs_ideas[question_id] = [];
		$.each(bs_ideas, 
			function(){
				BsIdeas.bs_ideas[question_id].push(this.bs_idea);
			}
		)
		BsIdeas.process_ideas(question_id);
	},
	process_ideas: function(question_id){
		if(BsIdeas.bs_ideas[question_id].length>0){
			var bs_ideas_priority = BsIdeas.bs_ideas_priority[question_id];
			$.each(BsIdeas.bs_ideas[question_id],
				function(i,o){
					// get index of this idea in the priority array
					//var fav_index = bs_ideas_priority.indexOf(o.id);
					var fav_index = $.inArray(o.id,bs_ideas_priority);
					if(fav_index != -1){
						o.fav_index = fav_index+1;					
					}
				}
			)
			
			// sort the ideas in descending order of popularity
			BsIdeas.bs_ideas[question_id].sort( function(a,b){return b.num_favs-a.num_favs;} ) 
			//Now iterate through and set the popularity index and the num of ideas
			var num_ideas = $.map(BsIdeas.bs_ideas[question_id],function(o,i){ if(o.num_favs>0){return 1}else{return null}}).length;
			$.each(BsIdeas.bs_ideas[question_id], function(i,o){ if(Number(o.num_favs) == 0)return false;  o.pop_index = i + 1, o.pop_num = num_ideas;})
			// now each idea should have its status #s for favorite order and popularity
		}
	},
	get_idea: function(question_id, bs_idea_id){
		bs_idea_id = Number(bs_idea_id);
		var bs_idea;
		$.each(BsIdeas.bs_ideas[question_id], 
			function(i,o){
				//console.log("get_idea id: " + o.id + ", bs_idea_id: " + bs_idea_id)
				if(o.id == bs_idea_id){
						bs_idea = o;
					return false;
				}
			}
		);
		return bs_idea;
	},
	build_list: function(link){
		var list_name = String(link.attr('href').match(/list=(\w+)/)[1]);
		var question_id = Number(link.attr('href').match(/\/(\d+)\?/)[1]);
		var par = link.closest('div.brainstorming');
		
		console.log("build_list " + list_name + " for question: " + question_id );
		//select the ideas
		//sort the ideas
		//build the html
		//append to list
		//replace list
		var list = $('<div class="list_inner"></div>');

		switch(list_name){
			case 'pop':
				$.each(
					BsIdeas.bs_ideas[question_id].sort( function(a,b){return a.pop_index-b.pop_index;} ),
					function(){
						if(this.num_favs>0){
							list.append(BsIdeas.create_idea_html(this, list_name))
						}
					}
				)
				break;
			case 'fav':
				$.each(
					BsIdeas.bs_ideas[question_id].sort( function(a,b){return a.fav_index-b.fav_index;} ),
					function(){
						if(this.my_fav == 't'){
							list.append(BsIdeas.create_idea_html(this, list_name))
						}
					}
				)
				list.addClass('fav')
				break;
			case 'new':
				$.each(
					BsIdeas.bs_ideas[question_id].sort( function(a,b){return b.id-a.id;} ),
					function(){
						if(!this.my_fav){
							list.append(BsIdeas.create_idea_html(this, list_name))
						}
					}
				)
				break;
			case 'all':
				$.each(
					BsIdeas.bs_ideas[question_id].sort( function(a,b){return b.id-a.id;} ),
					function(){
						list.append(BsIdeas.create_idea_html(this, list_name))
					}
				)
				break;
		}
		par.find('div.list_inner').replaceWith(list);
		// adjust the links
		par.find('p.idea_lists').children('a').show().end().find('a[href$="' + list_name + '"]').hide();
		// adjust the title
		par.find('h3.list_title').hide();
		par.find('h3.list_title.' + list_name).show();
		// adjust the instructions
		par.find('div.instr').hide();
		par.find('div.instr.' + list_name).show();
		// adjust the status
		par.find('div.status').children('p').hide().end().find('p.' + list_name).show();
		
		// reset the order numbers for favorites
		if(list_name == 'fav'){
			var bs_ideas = list.children('div.bs_idea');
			var cnt = 1;
			bs_ideas.each( function(){ $(this).find('input.sort').val(cnt++);  } )
		}
		// show the appropriate title, instr, and status
		//$this.parent().children('a').removeClass('active_list');
		//$this.addClass('active_list');
		//show_list.closest('div.brainstorming').children('h3').html( show_list.children('h3').html() );
		
	},
	create_idea_html: function(idea, list){
		//console.log("BsIdea.create_idea_html")
		// a new idea is added - either my idea or from another user
		var bs_idea = $(jsonFn.bs_idea( { data: {bs_idea: idea}}));
		
		switch(list){
			case 'pop':
				bs_idea.find('div.sort_ctl').remove();
				bs_idea.find('p.status').remove();
				
				if(idea.my_fav == 't'){
					bs_idea.find('div.rating').remove();
					bs_idea.find('p.like_controls.add').remove();
					bs_idea.find('p.like_controls.fav').html('My #' + idea.fav_index + ' favorite idea');
				}else if(idea.my_fav == 'f'){
					bs_idea.find('div.rating').remove();
					bs_idea.find('p.like_controls.rem').remove();
					bs_idea.find('p.like_controls.fav').remove();
				}else{
					bs_idea.find('p.like_controls.rem').remove();
					bs_idea.find('p.like_controls.fav').remove();
					bs_idea.find('p.like_controls.add').remove();
				}
				break;
			case 'fav':
				bs_idea.find('div.sort_ctl input.sort').val( idea.fav_index )
				if(idea.pop_index){
					bs_idea.find('p.status').html('#' + idea.pop_index + ' of ' + idea.pop_num + ' popular ideas');
				}else{
					bs_idea.find('p.status').remove();
				}
				bs_idea.find('div.rating').remove();
				bs_idea.find('p.like_controls.fav').remove();
				bs_idea.find('p.like_controls.add').remove();
				break;
			case 'new':
				bs_idea.find('div.sort_ctl').remove();
				bs_idea.find('p.status').remove();
				bs_idea.find('p.like_controls').remove();
				break;
			case 'all':
				bs_idea.find('div.sort_ctl').remove();
				if(idea.pop_index){
					bs_idea.find('p.status').html('#' + idea.pop_index + ' of ' + idea.pop_num + ' popular ideas');
				}else{
					bs_idea.find('p.status').remove();
				}
				if(idea.my_fav == 't'){
					bs_idea.find('div.rating').remove();
					bs_idea.find('p.like_controls.add').remove();
					bs_idea.find('p.like_controls.fav').html('My #' + idea.fav_index + ' favorite idea');
				}else if(idea.my_fav == 'f'){
					bs_idea.find('div.rating').remove();
					bs_idea.find('p.like_controls.rem').remove();
					bs_idea.find('p.like_controls.fav').remove();
				}else{
					bs_idea.find('p.like_controls.rem').remove();
					bs_idea.find('p.like_controls.fav').remove();
					bs_idea.find('p.like_controls.add').remove();
				}
				break;
		}
		return bs_idea;
	},
	add_idea: function(idea, submit_response){
		console.log("BsIdea.add_idea submit_response: " + submit_response)
		
		// save the idea to the stored bs ideas
		var bs_idea = idea.data.bs_idea
		var question_id = bs_idea.question_id;
		//if(typeof bs_idea.my_fav == "undefined") bs_idea.my_fav = null;
		if(submit_response){
			bs_idea.my_fav = 't';
			BsIdeas.bs_ideas_priority[question_id].unshift(bs_idea.id);
		}else{
			bs_idea.my_fav = null;
		}
		BsIdeas.bs_ideas[question_id].push(bs_idea);
		
		// save the new priority
		send_bs_idea_order_to_server(question_id, BsIdeas.bs_ideas_priority[question_id])
		
		// process the ideas
		BsIdeas.process_ideas(question_id);
		
		// determine the current list
		var par = $('#q' + question_id).find('div.brainstorming');
		var cur_list_name = String(par.find('p.idea_lists a:hidden').attr('href').match(/\w+$/));
		
		// determine which list to add it to
		
		var list_name = 'all';
		
		// create idea html
		var idea_div = BsIdeas.create_idea_html(bs_idea, 'all');
		
		// add it to div.insert_new_ideas
		par.find('div.insert_new_ideas').append(idea_div);
		
		// if fav is current list, add this idea to the top of fav
		if(cur_list_name == 'fav'){
			idea_div = BsIdeas.create_idea_html(bs_idea, 'fav');
			par.find('div.list_inner').prepend(idea_div);
		}
		// update status
		par.find('div.status').html('')
		//var msg = $('<p class="confirmation">Your idea has been saved successfully & inserted into your favorites list</p>')
		//par.find('div.status').append(msg)
		//msg.effect('highlight',{},3000);
		
	},
	adjust_favorites:	function(data){
		console.log("BsIdeas.adjust_favorites");
		var idea_data = data[0].params.data
		temp.BsIdeas_adjust_favorites_data = idea_data; 
		var bs_idea_div = $('div#bs_idea_' + idea_data.bs_idea_id);
		var par = bs_idea_div.closest('div.brainstorming');
		var question_id = Number(par.closest('div.qa').attr('id').match(/\d+/));
		var cur_list_name = String(par.find('p.idea_lists a:hidden').attr('href').match(/\w+$/));

		if(idea_data.favorite){
			console.log("adjust to a favorite")
			// show the acknowldgement message	
			
			var bs_idea = BsIdeas.get_idea(question_id, idea_data.bs_idea_id);
			bs_idea.my_fav = 't';
			BsIdeas.bs_ideas_priority[question_id].unshift(bs_idea.id);
			BsIdeas.process_ideas(question_id);
			
			if(cur_list_name == 'new'){ // remove if list is new
				bs_idea_div.append('<p class="fav_action_status fav">Added to your favorites</p>');
				bs_idea_div.children('div').css('opacity',.1)
				bs_idea_div.fadeTo(600,1,
					function(){
						$(this).hide("blind", { direction: "vertical" }, 800,
							function(){
								$(this).remove();
							}
						);
					}
				);
				
			}else{ // otherwise update the idea
				var idea_div = BsIdeas.create_idea_html(bs_idea, cur_list_name);
				bs_idea_div.replaceWith(idea_div);
			}

		}else{
			console.log("adjust to NOT a favorite - remove it from favorites list, update in other lists");
			
			var bs_idea = BsIdeas.get_idea(question_id, idea_data.bs_idea_id);
			bs_idea.my_fav = 'f';
			//var index = BsIdeas.bs_ideas_priority[question_id].indexOf(idea_data.bs_idea_id);
			var index = $.inArray(idea_data.bs_idea_id,BsIdeas.bs_ideas_priority[question_id]);
			if(index != -1 )BsIdeas.bs_ideas_priority[question_id].splice(index,1);
			BsIdeas.process_ideas(question_id);
			
			if(cur_list_name == 'fav'){ // if the current list is 'fav', remove the idea from the list
				// show the acknowldgement message
				bs_idea_div.append('<p class="fav_action_status">Not a favorite</p>')
				bs_idea_div.children('div').css('opacity',.1)
				bs_idea_div.fadeTo(600,1,
					function(){
						$(this).hide("blind", { direction: "vertical" }, 800,
							function(){
								$(this).remove();
								// reset the order numbers for favorites
								var bs_ideas = par.find('div.list_inner').children('div.bs_idea')
								var cnt = 1;
								bs_ideas.each( function(){ $(this).find('input.sort').val(cnt++);  } )
							}
						);
					}
				);
				
			}else{
				// otherwise change my_fav status in BsIdeas.bs_ideas, rebuild item and replace it
				var idea_div = BsIdeas.create_idea_html(bs_idea, cur_list_name);
				bs_idea_div.replaceWith(idea_div);
				//bs_idea_div.fadeTo(1500,.1,
				//	function(){
				//		$(this).replaceWith(idea_div);
				//		idea_div.fadeTo(1500,1);
				//	}
				//);
				
				
			}


		}
		
		
		
	}
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
					msg.effect('highlight',{},5000, function(){$(this).remove()});					
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



function get_tooltips(el){
	try{
		$('div#clue-tip-source').remove();
		temp.tooltip = el
		//console.log("get_tooltips NOT cached");
		//$('div#tooltip_source').remove();
		if( $('div#tooltip_source').size() == 0 ){
			//console.log("get tooltips from server");
			$.ajax({dataType: 'html', url: '/idea/tooltips', async: false, 
				success: function(data){
					//console.log("request tooltips callback");
					var div = $(data);
					div.attr('id','tooltip_source');
					$('body').append(div);
				}
			});
		}
		//console.log("get_tooltips source is loaded");
		var tipcopy = $('div#tooltip_source').clone().attr('id','clue-tip-source')
		// remove all pieces except the one I want to display based on el
		var target = String(el.attr('href').match(/\w+$/));
		//console.log("tooltip target: " + target)
		if(target=='checklist'){
			// get the right checklist
			var extended_checklist = el.closest('div.checklist').find('div.extended_checklist').clone();
			if(extended_checklist.size() > 0 ){
				tipcopy.prepend(extended_checklist)
			}
		}
		// remove unused show me help
		tipcopy.children('div.show_me').not('div#show_me_' + target).remove();
		
		tipcopy.appendTo('body');
	}catch(e){console.log("tooltip error: " + e.message)}
	return true;
}


$(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});