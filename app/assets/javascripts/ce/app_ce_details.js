function init_details_popup(details){
	
	// kill any existing detail popups
	$('div.idea_details.popup').dialog('close');
	dialog = details.dialog(  {
		title : '', 
		modal : true, 
		width :'auto',
		height: $(window).height() - 8,
		position: ["center","center"],
		zIndex: 10001,
		open: function(event,ui){
			var dlg = $(this);
			//dlg.hide().slideDown(400)
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
			}else{
				return false;
			}
		}
	 } );
	
	activate_details(details);
	dispatcher.update_discussion_stats( details );
	details.find('input, textarea').placeholder();
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

	init_rating_sliders( details.find("div.theme_slider") );
	
	init_file_uploads( details.find('input.attachment-upload') );
}

$('body').on('click', 'div.ui-dialog a.close_dialog', function(){
	$(this).closest('div.ui-dialog').find('a.ui-dialog-titlebar-close').click();
	return false;
});
	
	
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

$('body').on('click','a.view_results', function(){show_rating_results(this); return false;} );
function show_rating_results(link, force_display){
	try{
		if(typeof force_display == 'undefined'){force_display = false;}
		var link = $(link);
		var results_div = link.closest('div').find('div.results');
		var vote_results_div = results_div.find('div.vote_results');
		if(force_display){
			link.html('Hide results');
		} else if(link.html().match(/View/i)){
			link.html( link.html().replace(/View/, 'Hide') );
		}else{
			link.html( link.html().replace(/Hide/, 'View') );
			results_div.hide(800);
			return false;
		}
		
		var max_height = $('div.vote_results').height();
		var bar_full_width = $('div.vote_results').width() / 10;
		var bar_width = $('div.vote_results').width() / 10 *.75;
		var bar_margin = $('div.vote_results').width() / 10 *.25;

		var idea_votes = $.map(vote_results_div.attr('votes').match(/(\d+)/g), function(el){return Number(el) });
		
		var vote_buckets = [0,0,0,0,0,0,0,0,0,0];
		var max_votes = 0;
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
		results_div.show(800);
	}catch(e){ console.log("Error: " + e);}
	return false;
}

$('body').on('click','div.idea_details a.goto_theming_page', 
	function(){
		var details = $(this).closest('div.idea_details');
		setTimeout(function(){
			this.closest('div.ui-dialog-content').dialog('close');
			show_and_highlight_postit(this.attr('question_id'), this.attr('idea_id') );
		}.bind(details), 100);
		return false;
	}
);


function init_answer_editor( form, idea_id ){
	form.find('input[name="act"]').val('edit_answer_popup');

	var popup = $('div.idea_details.popup[idea_id="' + idea_id + '"]');
	var answer = popup.find('ul.answer');
	//answer.hide(250).after(form);
	answer.before(form.hide());
	form.show(250);
	//console.log("activate_text_counters_grow");
	activate_text_counters_grow( form.find('textarea'), 200);
	form.on('click','a.cancel',function(){
		form.hide(250, function(){$(this).remove()});
		answer.find('div.post-it div.inner').show().end().find('div#wmd-preview').hide( 100, function(){$(this).remove()});
		return false;
	});

	function init_answer_markdown_editor(){
		//console.log("init_markdown_editor answer");
		//console.log("create converter");
		var converter = new Markdown.getSanitizingConverter();
		//console.log("create editor");
		var editor = new Markdown.Editor(converter);
		//console.log("run editor");
		editor.run();
		answer.find('div.post-it div.inner').hide().after( form.find('div#wmd-preview') );
		//console.log("completed");
	}
	
	if(typeof Markdown == 'undefined'){
		//console.log("load Markdown");
		$.getScript('/assets/Markdown.Converter.js',
			function(){
				$.getScript('/assets/Markdown.Editor.js',
				 	function(){
						$.getScript('/assets/Markdown.Sanitizer.js', init_answer_markdown_editor);
					}
				);
			}
		);
	}else{
		init_answer_markdown_editor();
	}
}

function init_summary_editor( form, target ){
	if( target == 'title'){
		form.addClass('edit_title');
		form.find('span.char_ctr').html(255);
		form.find('input[name="target"]').val('title');
		var h2 = $('h2.home_title');
		h2.hide(250).after(form);
		//.find('a.edit_title').hide().end().find('h3.question').after(form).hide();
		activate_text_counters_grow( form.find('textarea').val( h2.find('span').html().trim() ), 80 )
		form.on('click','a.cancel',function(){
			$('h2.home_title').show(250).next('div.edit_form').remove();
			return false;
		});
	}else{
		form.addClass('edit_summary');
		form.find('span.char_ctr').html(1000);
		form.find('input[name="target"]').val('summary');
		var summary = $('div.idea_summary');

		summary.before(form.hide());
		form.show(250);
		
		//console.log("activate_text_counters_grow");
		activate_text_counters_grow( form.find('textarea'), 360);
		form.on('click','a.cancel',function(){
			form.hide(250, function(){$(this).remove()});
			summary.find('div.inner').show().end().find('div#wmd-preview').hide( 100, 
				function(){
					$(this).closest('div.idea_summary').find('h3.prev-label').remove(); 
					$(this).remove();
				});
			return false;
		});

		function init_exec_summary_markdown_editor(){
			//console.log("init_markdown_editor summary");
			//console.log("create converter");
			var converter = new Markdown.getSanitizingConverter();
			//console.log("create editor");
			var editor = new Markdown.Editor(converter);
			//console.log("run editor");
			editor.run();
			summary.find('div.inner').hide().after( $('<h3 class="prev-label">Preview Our Vision</h3>'), form.find('div#wmd-preview').addClass('corner') );
		}

		if(typeof Markdown == 'undefined'){
			//console.log("load Markdown");
			$.getScript('/assets/Markdown.Converter.js',
				function(){
					$.getScript('/assets/Markdown.Editor.js',
					 	function(){
							$.getScript('/assets/Markdown.Sanitizer.js', init_exec_summary_markdown_editor);
						}
					);
				}
			);
		}else{
			init_exec_summary_markdown_editor();
		}
	}
}
