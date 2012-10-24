function init_details_popup(details){
	
	// kill any existing detail popups
	$('div.idea_details.popup').closest('div.ui-dialog').dialog('destroy').end().remove();
	dialog = details.dialog(  {
		title : '', 
		modal : true, 
		width :'auto',
		height: $(window).height() - 8,
		position: ["center","top"],
		open: function(event,ui){
			var dlg = $(this);
			dlg.hide().slideDown(400)
			dlg.find('a').blur();
			dlg.parent().find('span.ui-dialog-title').remove()
		},
		beforeClose: function(event,ui){
			var dialog = $(this).parent();
			var deleteNow = false;                                       	
			if(dialog.find('textarea').val() == ''){           	
				deleteNow = true                                           	
			}else{                                                       	
				deleteNow = confirm("Do you want to close this form?")	
			}                                                            	
			if(deleteNow){                                               	
				dialog.slideUp(400, function () { 
					dialog.dialog('destroy').remove();
			  });                                                        	
			}
			return false;
		}
	 } );
	
	activate_details(details);
}
function activate_details(details){
	
	activate_text_counters_grow(details.find('textarea'), 120);
	//details.modal( {escClose: false});
	
	// set the width of the navigation area
	var max_markers = 1;
	details.find('div.navigation > div').each(
		function(){
			var cnt = $(this).find('> a').size();
			if(cnt>max_markers){max_markers = cnt}
		}
	);
	details.find('div.navigation').width( max_markers * 30);
	
	var my_rating = Number(details.find('div.rater div.theme_slider').attr('my_rating'));
	details.find("div.theme_slider").slider({
		stop: function(event, ui) { 
			$.post('/idea/rating', {id: $(ui.handle).parent().attr('id'), rating: ui.value}, function(){}, "script");
			//$(this).closest('div.my_rating').html('<img src="/assets/wait3.gif"/><br/>Saving...')
		},
		value: my_rating,
		range: "min"
	});
	
	details.on('click', 'a.close_details', function(){
		$(this).closest('div.ui-dialog').find('a.ui-dialog-titlebar-close').click();
		return false;
	});
	
	init_file_uploads( details.find('input.attachment-upload') );
	
}
	
$('body').on('click', 'div.idea_details div.navigation a.item', 
	function(event){
		var link = $(this);
		if( !link.hasClass('current') ){
			var par = link.parent();
			if( par.hasClass('themes') || par.hasClass('ideas')){
				console.log("load_ idea details_popup for this.id: " + this.id);
				$.getScript('/idea/' + this.id + '/details');
			}else if(par.hasClass('questions')){
				//console.log("Need Show the question popup for this.id: " + this.id);
				$.getScript('/idea/' + this.id + '/details?act=view_question');
			}else if(par.hasClass('proposal')){
				$.getScript('/idea/' + this.id + '/details?act=view_team');
			}
		}
		return false;
	}
);

$('body').on('click','div.idea_details a.view_results', 
	function(){
		try{
			var link = $(this);
			var vote_results_div = $(this).closest('div.idea_details').find('div.vote_results');
			if(link.html().match(/View/i)){
				link.html( link.html().replace(/View/, 'Hide') );
			}else{
				link.html( link.html().replace(/Hide/, 'View') );
				vote_results_div.hide(800);
				return false;
			}
			
			var max_height = $('div.vote_results').height();
			var bar_full_width = $('div.vote_results').width() / 10;
			var bar_width = $('div.vote_results').width() / 10 *.75;
			var bar_margin = $('div.vote_results').width() / 10 *.25;

			var idea_votes = $.map(vote_results_div.attr('votes').match(/(\d+)/g), function(el){return Number(el) });
			
			var vote_buckets = [0,0,0,0,0,0,0,0,0,0];
			var max_votes = 0
			//console.log("idea_votes: " + idea_votes);
			for(var i=0,vote;(vote=idea_votes[i]);i++){
				//console.log("vote: " + vote);
				++vote_buckets[ Math.floor( (vote - 1)/10 )]
			}
			//console.log("vote_buckets: " + vote_buckets);
			//for(var j=0,num_votes;(num_votes=vote_buckets[j]);j++){
			//	console.log("num_votes: " + num_votes);
			//	//max_votes = (max_votes > num_votes ? max_votes : num_votes);
			//}
			for(var j=0;j < vote_buckets.length;j++){
				var num_votes = vote_buckets[j];
				//console.log("num_votes: " + num_votes);
				max_votes = (max_votes > num_votes ? max_votes : num_votes);
			}
			//console.log("max_votes: " + max_votes);
			var max_height = $('div.vote_results').height();
			//console.log("max_height: " + max_height);
			vote_results_div.find('div.bar').each( 
				function(i,el){
				 	$(el).height( vote_buckets[i]>0 ? vote_buckets[i]  * max_height/max_votes : 1 )
						.css({left: i * bar_full_width, width: bar_width, 'margin-right':  bar_margin })
						.attr('title', vote_buckets[i] + (vote_buckets[i]==1 ? ' vote' : ' votes'));
			 }
			);
			vote_results_div.show(800);
		}catch(e){ console.log("Error: " + e);}
		return false;
	}
);

$('body').on('click','div.idea_details a.goto_theming_page', 
	function(){
		var details = $(this).closest('div.idea_details');
		setTimeout(function(){
			show_and_highlight_postit(this.attr('question_id'), this.attr('idea_id') );
			var dialog = this.closest('div.ui-dialog');
			dialog.slideUp(400, function(){ 
				dialog.dialog('destroy').remove();
			});
		}.bind(details), 100);
		return false;
	}
);