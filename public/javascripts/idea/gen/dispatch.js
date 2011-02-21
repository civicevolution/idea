function init_sortable() {
	$("ul.sortable").sortable({
		stop: function(event,ui){
			//console.log("sort is stopped");
			var result = ui.item.closest('ul').sortable('toArray');
			//console.log("result: " + result)
			var h = {}
			var ord = 10;
			$.each(result, function(){
				h[ 'list_item_' + this.match(/\d+/) ] = ord;
				ord += 10;
			})
			h['id'] = ui.item.closest('ul').attr('id').match(/\d+/)[0];
			
			$.post('/idea/save_reordered_list_items', h, function(data) {
				// Show error message, if any
				if (data.error) {
					alert(data.error);
				}
			}, 'json');
			
		}
	});
	$("ul.sortable").disableSelection();
};


var new_icon_data = {
	question : 'div.question',
	answer : 'p.controls',
	comment : 'div.comment',
	bs_idea : 'p.controls'
}

function dispatchEndorsement(item,submit_response){
	console.log("dispatchEndorsement");
	temp.dispatchEndorsement_item = item;
	if(item.data.endorsement.created_at == null){
		// the endorsement was deleted
		console.log("delete endorsement")
		var tr = $('div#endorsements').find('tr#' + item.ape_code)
		tr.remove();
		if(tr.find('a.delete_endorsement').size()>0){
			// this is my endorsement, show the form again
			$('div#endorsements form').removeClass('hide');
		}
	}else{
		console.log("insert the new endorsement")
		item.show_delete = submit_response ? 't' : 'f';
		var html = jsonFn.endorsement(item);
		var table = $('div#endorsements table');
		table.prev('p.desc').html('Here are the people that have endorsed this proposal.');
		var form = $('div#endorsements form');
		form.find('a.clear').click();
		form.addClass('hide');
		// is this new or update
		var tr = table.find('tr[id="' + item.ape_code + '"]');
		if(tr.size() > 0){
			tr = tr.replaceWith(html)
			table.find('tr[id="' + item.ape_code + '"] abbr').timeago();
		}else{
			table.append(html);
			table.find('tr:last abbr.timeago').timeago();
		}
	}
	
	
}

function dispatchAnswer(item,submit_response){
	console.log("v1 dispatchAnswer, item_id(item.item_id): " + item.item_id + " submit_response: " + submit_response)
	//console.log("dispatchItem, comment_text(item.data.comment.text): " + item.data.comment.text)
	//	// get the parent to which this belongs
	//	var question_id = idea.question_id
	//	var par = $('#bs_ideas_' + question_id);
	//
	//console.log("uid: " + item.uid)
	try{
		var node = $("div.answer[uid='" + item.uid + "']" )	
		//	
		if(submit_response){
			//console.log("submit_response is true, force it to write the data");
			temp.answer_submit_response = item
			// this is dispatched from the submit response - I submitted this
			//console.log("Provide edit link - I own this")
			item.edit_link = 'on'
		}else{
			//console.log("submit_response is NOT true, this is APE ");
			NOTIFIER.inform( { type: 'answer', page_id: 
			 	Number( $('div#i' + item.par_id).closest('.Page').attr('id').match(/\d+/)) })
			temp.answer_ape = item
			item.edit_link = 'on'
			// this is dispatched from APE broadcast
			// if this uid has already been used in this parent, return because it was created for submit response
			if(node.size() > 0){
				console.log("submit response already inserted answer, ignore this ape broadcast")
				return;
			}
		}

		console.log("mode: " + item.mode + ", find par_id: " + item.par_id + ", sib_id: " + item.sib_id)

		json_test_data = item;
	
		for (x in json_test_data.data) var item_type = x;
		console.log("item_type: " + item_type)

		var html = jsonFn[item_type](item);

		var div = $(html).addClass('test_insert');
	
		var icon_elm = $(new_icon_data[item_type], div);
		if(item.mode == 'add'){
			icon_elm.prepend('<span class="new _answer">New</span>');
		}else if(item.mode == 'edit'){
			icon_elm.prepend('<span class="new _updated _answer">Updated</span>');
		}
		
		var prop_answer = div.clone();

		if(node.size() > 0){
			// this item was already added by ape before submit_response 
			console.log("replace ape version with submit response version")
			// give div the sibling class of the node
			node.replaceWith(div);
			//node.after(div)  // for testing
		}else if(item.mode == 'add'){
			console.log("no duplicate, append this answer to the div.answers for par " + item.par_ids)
			var par = $('div#i' + item.par_id + ' div.answers tr:last');
			if(par.size() == 0){
				// empty table doesn't any tr, so append to the table
				par = $('div#i' + item.par_id + ' div.answers table')
				var tb = $('<tbody></tbody>');
				tb.append(div);
				par.append( tb );
			}else{
				par.after( div );		
			}
			div.hide().show(2000, function(){
				div.effect("highlight", {}, 4000)
			})
		}else{
			console.log("mode is " + item.mode);
			temp.ans_new_div = div
			var par = $('div#ans_' + item.data.answer.id);
			temp.ans_par = par
			//div = div.find('div.entry');
			$('span.new._answer',div).replaceWith('<span class="new _updated _answer">Updated</span>');
	//		$('span.mark_new_answer',div).hide();
	//		icon_elm.prepend('<span class="mark_new_' + item_type + '">Updated</span>');
			par.replaceWith(div);
			div.effect("highlight", {}, 2000);
			par.prev('form.add_answer_form').hide(1000,
				function(){
					$(this).remove();
					par.show(1000)
				}
			);
			
			$('a.view_history',div).cluetip({
			  cluetipClass: 'jtip', 
			  arrows: true, 
			  dropShadow: false, 
			  height: '300px', 
			  width: '400px',
			  sticky: true,
			  positionBy: 'bottomTop'
			});	
			
			
		}
	}catch(e){
		console.log("Error in dispatchItem,  item.par_id: " + item.par_id + ", e: " + e)
	}
	$('abbr.timeago',div).timeago();
	if(item.my_vote > 0){
		// should show Please rate
		$(':radio',div).eq( item.my_vote - 1 ).attr('checked','checked');
	}else{
		$(':radio:checked',div).removeAttr('checked');
		$('span.team_rating',div).replaceWith( $('<span class="please_rate">Please rate</span>') );		
	}
	//init_team_rating(div)
	//init_rating_stars( $(':radio.star',div) );
}

function dispatchComment(item,submit_response){
	console.log("dispatchComment, item_id(item.item_id): " + item.item_id + " submit_response: " + submit_response)
	//console.log("dispatchItem, comment_text(item.data.comment.text): " + item.data.comment.text)

	//	// get the parent to which this belongs
	//	var question_id = idea.question_id
	//	var par = $('#bs_ideas_' + question_id);
	//
	console.log("uid: " + item.uid)
	var node = $("div[uid='" + item.uid + "']" )	
	//	
	
	if(submit_response){
		//console.log("submit_response is true, force it to write the data");
		temp.comment_submit_response = item
		// this is dispatched from the submit response - I submitted this
		//console.log("Provide edit link - I own this")
		item.edit_link = 'on'
	}else{
		//console.log("submit_response is NOT true, this is APE ");
		
		var page_id = $('div#i' + item.par_id).closest('.Page').attr('id');
		if(page_id){
			NOTIFIER.inform( { type: $('div#i' + item.par_id).closest('div.discussion').hasClass('public') ? 'pub_com' : 'comment',
			 	page_id: Number( page_id.match(/\d+/)),
				target_type: item.item.item.target_type == 2 ? 'answer' : item.item.item.target_type == 11 ? 'bs_idea' : '',
				target_id: item.item.item.target_id
			})
		}
		temp.comment_ape = item
		// this is dispatched from APE broadcast
		// if this uid has already been used in this parent, return because it was created for submit response
		if(node.size() > 0){
			console.log("submit response already inserted comment, ignore this ape broadcast")
			return;		
		} 
	}

	console.log("mode: " + item.mode + ", find par_id: " + item.par_id + ", sib_id: " + item.sib_id + ", target_id: " + item.item.item.target_id)
	//console.log("com text: " + item.data.comment.text)
	//debugger
	json_test_data = item;
	temp.dispatchCommentItem = item
	
	for (x in json_test_data.data) var item_type = x;
	console.log("item_type: " + item_type)

	var html = jsonFn[item_type](item);

	//var div = $(html).hide().addClass('test_insert');
	//var div = $(html).addClass('test_insert').addClass('full_comment_display');
	var div = $(html).addClass('test_insert');
	div.find('.Comment_entry').addClass('full_comment_display');

	// manually add the image source - when compiled it triggered extra page load
	div.find('img.i36').attr('src',item.pic_url)
	
	$('div.Comment_entry:first', div).addClass('new_com');
	// since the ellipsis aren't working yet, hide the close icon
	//div.find('.close_1com').hide()
	
	var icon_elm = $(new_icon_data[item_type], div);
	//if(item.mode == 'add'){
	//	icon_elm.prepend('<span class="new _comment">New</span>');
	//}else if(item.mode == 'edit'){
	//	icon_elm.prepend('<span class="new _updated _comment">Updated</span>');
	//}

	var new_coms = [];

	if(node.size() > 0){
		// this item was already added by ape before submit_response 
		console.log("replace ape version with submit response version")
		// give div the sibling class of the node
		div.addClass( node.hasClass('top_sibling') ? 'top_sibling' : 'sibling');
		console.log("insert 1 - replace")
		console.log("Before replace node has size of " + node.size() )
		
		console.log("replace ape with submit response in each loop");
		node.each( 
			function(){
				var com = div.clone(true);
				new_coms.push(com)
				console.log("replace node with new com")
				$(this).replaceWith(com)
			} 
		)

	}else if(item.mode == 'add'){
		if(item.sib_id){
			//var par = $('div#i' + item.sib_id)
			var par = $('div.item[item_id=' + item.sib_id + ']')
		}else{
			//var par = $('div#i' + item.par_id + ' div.question_discussion')
			//var par = $('div#i' + item.par_id);
			var par = $('div.item[item_id=' + item.par_id + ']')
		}
		console.log("Before insert par has size of " + par.size() )
		
		var has_sibling = par.children('.sibling').size() > 0
		// must have a sibling before it could have a top_sibling
		if(has_sibling){
			console.log("has sibling")
			// insert form after the last child of target
			var last_child = par.children('.top_sibling:last');
			if (last_child.size() > 0){
				console.log("has child with top sibling (a new child thread) insert com after last child")
				// indent this since it is a child
				console.log("insert 2 - after last child, size: " + last_child.size())
				div.addClass('top_sibling')
				
				par.each( 
					function(){
						var com = div.clone(true);
						new_coms.push(com)
						console.log("replace node with new com")
						$(this).children('.top_sibling:last').after(com)
					} 
				)
			}else{
				console.log("append com to par, no existing  child threads")
				div.addClass('top_sibling')
				console.log("insert 3 - before next sibling, size: " + par.size() )
				
				par.each( 
					function(){
						var com = div.clone(true);
						new_coms.push(com)
						console.log("insert 3 - before first sibling")
						$(this).children('.sibling:first').before(com)
					} 
				)
			}
		}else{
			div.addClass( item.sib_id ? 'sibling' : 'top_sibling')
			if(item.item.item.target_id){
				console.log("4 item has target_id: " + item.item.item.target_id)
				//if(par.hasClass('Question')) par = $('div.inner_question_discussion',par);
				var com = div.clone(true);
				new_coms.push(com)
				console.log("insert com as last child of question")
				par.find('div.inner_question_discussion:first form.add_comment_form').before( com );
				
		  	par = $('#target_discussion_' + item.item.item.target_type + '_' + item.item.item.target_id );
		  	// now place at end, before form, in parent
		  	console.log("insert com as last child of idea discussion, par.size(): " + par.size() )
		  	com = div.clone(true);
		  	com.find('a.view_target').hide();
		  	new_coms.push(com)
		  	par.find('form.add_comment_form').before( com );

			}else if(item.sib_id){
				console.log("5 item is a sibling to a parent with no siblings - append to parent as 1st sibling");
				par.each( 
					function(){
						var com = div.clone(true);
						new_coms.push(com)
						console.log("insert new com as 1st sibling of the parent")
						$(this).append( com );
					} 
				)
				
			}else if(par.hasClass('qa')){
				console.log("6 parent is a Question- append to parent above the comment form");
				//if(!par.hasClass('discussion')) par = $('div.inner_question_discussion',par);
				par = $('div.inner_question_discussion',par);
				par.each( 
					function(){
						var com = div.clone(true);
						new_coms.push(com);
						console.log("insert new com as sibling of the last sibling");
						$(this).append(com);
						//$(this).find('form.add_comment_form:last').before( com );
					} 
				)
			}else{
					console.log("Default: item doesn't have target_id, and parent doesn't have siblings - append to parent as a sibling");
					if(par.hasClass('Question')) par = $('div.inner_question_discussion',par);
					par.each( 
						function(){
							var com = div.clone(true);
							new_coms.push(com)
							console.log("insert new com as sibling of the last sibling")
							$(this).append( com );
						} 
					)
				}
		}
		
		//div.effect("highlight", {}, 3000)
		//div.hide().show(2000, function(){
		//	div.effect("highlight", {}, 4000)
		//})
	}else{
		console.log("8 dispatchComment - this else shouldn't be used except for edit")
		//var par = $('div#i' + item.item_id);
		var par = $('div.item[item_id=' + item.item_id + ']')
		par.attr('uid',item.uid);
		par = par.children('.Comment_entry');
		par.each( 
			function(){
				var com = div.clone(true).children('.Comment_entry');
				com.hide();
				new_coms.push(com)
				console.log("replace existing par with div")
				$(this).hide(1000,
					function(){
						$(this).replaceWith(com);
						com.show(1000);
					}
				);
			} 
		)
		//div.effect("highlight", {}, 4000)
	}
// adjust the thumbs up/down
	
	temp.new_coms = new_coms;
	//console.log("manipulate the coms, length: " + new_coms.length)
	$.each(new_coms, 
		function() {
			console.log("process com, item.my_vote: " + item.my_vote)
			$('abbr.timeago',this).timeago();
			//$('div.comment',this).css('width','auto');
			console.log("check my_vote")
			if(item.my_vote > 0){
				console.log("vote > 0")
				$('input.vote_down',this).addClass('other_selected');
			}else if(item.my_vote < 0){
				console.log("vote < 0 ")
				$('input.vote_up',this).addClass('other_selected');				
			}
			$('div.comment_links',this).hide();
		}
	);

}


function dispatchRating(rating,submit_response){
	console.log("dispatchRating");
	temp.rating = rating
	// rating.data.type = 'answer' | 'bs_idea'
	// rating.data = {type: , average: , count: , id: }
	switch (rating.data.type) {
		case 'answer': var id = '#ans_'; break;
		case 'bs_idea': var id = '#bs_'; break;
		default: console.log("dispatchRating type unknown: " + rating.data.type); return;
	}
	id += rating.data.id;
	console.log("id: " + id);
	//var s = $(id).closest('div.answer_section').find('div.bs_rating_red_bg');
	var results = $(id).closest('div.answer_section').find('div.rating');
	if(results.attr('uid') == rating.data.uid){
		//console.log("exit dispatchRating, already updated")
		return; // don't update this 2x
	}
	if(results.size() == 0){
		if(!submit_response) return; // if this has not been rated, only update for the user's own submit
		//console.log("replace please rate with the rating graphic");
		results = $(id).closest('tr').find('span.please_rate');
		if(s.size() == 0 || s.attr('uid') == rating.data.uid){
			//console.log("exit dispatchRating, replace please rate has started")
			return; // don't update this 2x
		}
		// temporarily mark this 
		s.attr('uid',rating.data.uid)
		s.fadeTo(2000,.01, 
			function insert_team_rating(){
				var bgr = $('<div class="bs_rating_red_bg"></div>');
				var bgg = $('<div class="bs_rating_grey_bg"></div>');
				var cnt = $('<div class="cnt"></div>');
				var votes = (rating.data.count + ' team vote') + (rating.data.count == 1 ? '' : 's');
				$(this).before(bgg).before( bgr.css('width', 85 * rating.data.average / 5 ) ).before( cnt.html( votes ) ).remove();
				bgr.attr('uid',rating.data.uid)
				$.merge(bgr,bgg,cnt	).fadeTo(1,.01).fadeTo(2000,1)
			}
		)
	}else{
		console.log("update rating")
		results.attr('uid',rating.data.uid)
		//results.css({opacity: 0})
		results.fadeTo(100,.01, 
			function(){
				//results.find('div.updating').remove();
				results.find('div.bs_rating_red_bg').css('width', 17 * rating.data.average );
				var votes = '(' + (rating.data.count + ' vote') + (rating.data.count == 1 ? '' : 's') + ')'
				results.find('div.cnt').html(votes);
				//results.show();
				results.parent().find('form span.star_hover').html('Saved')
				$(this).fadeTo(1000,1);
				
			}
		)
	}
}	

function dispatchComRating(rating,submit_response){
	//console.log("dispatchComRating");
	temp.com_rating = rating

	var form = $('#com_' + rating.data.com_id + ' form.mini_thumbs_up');
	
	if(!submit_response &&  $('input.other_selected',form).size() == 0 ) return; // if this has not been rated, only update for the user's own submit
	$('span.votes_up', form).html( ( rating.data.up > 0 ? rating.data.up : '' ) )
	$('span.votes_down', form).html( ( rating.data.down > 0 ? rating.data.down : '' ) )

	//$('input.vote_up', form).css('background-position-y', ( rating.data.my_vote < 0 ? '-48px' : '') );
	//$('input.vote_up', form).addClass('selected');
	//$('input.vote_down', form).css('background-position-y', ( rating.data.my_vote > 0 ? '-48px' : '') );
	if(rating.data.my_vote>0){
		$('input.vote_up', form).removeClass('other_selected');
		$('input.vote_down', form).addClass('other_selected');
	}else{
		$('input.vote_up', form).addClass('other_selected');
		$('input.vote_down', form).removeClass('other_selected');
	}
	
}	

function dispatchBsIdeaFavorite(rating,submit_response){
	console.log("dispatchBsIdeaFavorite");
	
	temp.dispatchBsIdeaFavorite = rating
	
	return;

	var form = $('#com_' + rating.data.com_id + ' form.mini_thumbs_up');
	
	if(!submit_response &&  $('input.other_selected',form).size() == 0 ) return; // if this has not been rated, only update for the user's own submit
	$('span.votes_up', form).html( ( rating.data.up > 0 ? rating.data.up : '' ) )
	$('span.votes_down', form).html( ( rating.data.down > 0 ? rating.data.down : '' ) )

	//$('input.vote_up', form).css('background-position-y', ( rating.data.my_vote < 0 ? '-48px' : '') );
	//$('input.vote_up', form).addClass('selected');
	//$('input.vote_down', form).css('background-position-y', ( rating.data.my_vote > 0 ? '-48px' : '') );
	if(rating.data.my_vote>0){
		$('input.vote_up', form).removeClass('other_selected');
		$('input.vote_down', form).addClass('other_selected');
	}else{
		$('input.vote_up', form).addClass('other_selected');
		$('input.vote_down', form).removeClass('other_selected');
	}
	
}	


function dispatchPageChatMessage(chat){
	temp.chat = chat
	//console.log("v3 dispatchPageChatMessage text: " + unescape(chat.data.text));
	
	var item_id = chat.data.item_id
	temp.chat_data = chat.data

	var chat_window = $('div#page_chat_' + item_id);
	
	// only insert the message one time, it will come from ape and submit if made by this user
	if( $('#chat_' + temp.chat.data.chat_msg_id, chat_window).size() > 0)return
	
	NOTIFIER.inform( { type: 'chat', page_id: 
	 	Number( $('div#page_chat_' + item_id).closest('.nav_chat').attr('id').match(/\d+/)) })
	
	var cw = $('.shoutbox_msg',chat_window)[0];
	var maxScroll = cw.scrollHeight - cw.offsetHeight + 2;
	var stick_to_bottom = (cw.scrollTop == maxScroll) ? true : false;
	var tr = $('tr:last-child',chat_window);
	var html = jsonFn['chat_message']( chat.data );
	//console.log('chat html: ' + html)
	if(tr.size()>0){
		var new_tr = $(html).insertAfter(tr);
		if(!tr.attr('class').match(/shade/)) new_tr.addClass('shade');
	}else{
		var chat_table = $('table',chat_window);
		var new_tr = $(html).appendTo(chat_table)
	}
	// determine if I should keep the div locked to the bottom 
	if(stick_to_bottom) cw.scrollTop = cw.scrollHeight - cw.offsetHeight + 2;
}

function insert_update_list_item_json(item){
	//console.log("insert_update_item: item.data.data: " + item.data.data)
	//console.log("insert_update_list_item_json v1");

	if(item.data.mode == 'delete_full' || item.data.mode == 'delete_partial'){
		// always do a partial that leaves a note "...has been removed by author"
		//console.log("do partial delete, entry only")
		var li = $('li#li' + item.data.id);
		$.each(li, function(){
			// this refers to each li in the collection
			jli = $(this)
			//console.log("delete " + jli)
			var newDiv = $('<li><p class="deleted_item">This ' + 
				item.data.item_type +
				' has been deleted by the author</p></li>').hide();
			newDiv.insertAfter(jli)
			jli.hide(1000, function () { 			
					//console.log("inside div hide function")
					newDiv.show(1000, function(){
						//console.log("inside newDiv show function")
					newDiv.effect("highlight", {}, 4000)
					//div.remove();
				});
			})
		})
			
		return;
	}

	json_test_data = item;
	
	for (x in json_test_data.data.data) var item_type = x;
	//console.log("item_type: " + item_type)

	var html = jsonFn[item_type](item.data);
	//console.log(html)
	if(item.data.mode == 'add'){
		var par = $('ul#li' + item.data.list_id)
		//console.log("add list item # " + par.size() + ' id: ' + item.data.list_id )
		$.each(par, function(){		
			jpar = $(this)
			var li = $(html).hide().addClass('test_insert')
			jpar.append(li)
			//li.closest('div.list').find('ul').scrollTo(li,800)
			li.show(2000, function(){
				li.closest('div.list').find('ul').scrollTo(li,800)
				li.effect("highlight", {}, 4000)
			})
		});
	}else{
		var par = $('li#li' + item.data.data.list_item.id)
		//par.replaceWith(li);
		//li.effect("highlight", {}, 4000)
		$.each(par, function(){	
			jpar = $(this)
			var li = $(html).hide().addClass('test_insert')
			li.hide();
			li.insertAfter(jpar);
			jpar.hide(1000, function () { 			
				li.show(1000, function(){
					li.closest('div.list').find('ul').scrollTo(li,800)
					li.effect("highlight", {}, 4000)
					//par.remove();
				})
			});
			K
		});
	}
}


function reorder_list_item_json(item){
	//console.log("reorder_list_item_json v1");

	// get the list
	var ul = $('ul#li' + item.data.id)
	
	$.each(ul, function() {
		jul = $(ul)
		// get the li into a hash
		var lis = {};
		$.each( $('li',jul), function(){
			var li = this.parentNode.removeChild(this);
			lis[ li.id.match(/(\d+)/)[1] ] = li
		});

		// iterate through the array and re append the li
		$.each( item.data.item_ids, function(){
			//console.log("item_ids this: " + this)
			jul.append(lis[this]);
		})
		
	})

	
}

