function init_details_popup(details){
	
	// kill any existing detail popups
	$('div.idea_details.popup').dialog('close');
	dialog = details.dialog(  {
		title : '', 
		modal : true, 
		width :'auto',
		height: $(window).height() - 8,
		position: ["center","center"],
		zIndex: 101,
		open: function(event,ui){
			var dlg = $(this);
			//dlg.hide().slideDown(400)
			dlg.find('a').blur();
			dlg.parent().find('span.ui-dialog-title').remove()
		},
		beforeClose: function(event,ui){
			var dialog = $(this).parent();
			var deleteNow = false;                                       	
			if(dialog.find('textarea').size() == 0 || dialog.find('textarea').val() == ''){           	
				deleteNow = true                                           	
			}else{                                                       	
				deleteNow = confirm("Do you want to close this form?")	
			}                                                            	
			if(deleteNow){  
				dialog.slideUp(400, function () { 
					dialog.find('div.idea_details.popup').remove();
					dialog.dialog('destroy').remove();
			  });                                                        	
			}else{
				return false;
			}
		}
	 } );
	
	activate_details(details);
	//dispatcher.update_discussion_stats( details );
	//details.find('input, textarea').placeholder();
}
function activate_details(details){
	
	activate_text_counters_grow(details.find('textarea'), 120);
	//details.modal( {escClose: false});
	
	//// set the width of the navigation area
	//var max_markers = 1;
	//details.find('div.navigation > div').each(
	//	function(){
	//		var cnt = $(this).find('> a').size();
	//		if(cnt>max_markers){max_markers = cnt}
	//	}
	//);
	//details.find('div.navigation').width( max_markers * 30);
  //
	//init_rating_sliders( details.find("div.theme_slider") );
	//
	//init_file_uploads( details.find('input.attachment-upload') );
}

$('body').on('click', 'div.ui-dialog a.close_dialog', function(){
	$(this).closest('div.ui-dialog').find('a.ui-dialog-titlebar-close').click();
	return false;
});
	



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


function init_theme_editor( form, idea_id, version ){

	if(idea_id > 0){
		form.find('input[name="act"]').val('edit_answer_popup');
	}else{
		form.find('input[name="act"]').val('add_answer_popup');
	}

	if(version==0){
		form.find('textarea').val('');
	}
	var popup = $('div.idea_details.popup[theme_id="' + idea_id + '"]');
	popup.find('a.edit_answer').hide();
	var answer = popup.find('ul.answer');
	//answer.hide(250).after(form);
	answer.before(form.hide());
	form.show(250);
	//console.log("activate_text_counters_grow");
	//activate_text_counters_grow( form.find('textarea'), 200);
	form.on('click','a.cancel',function(){
		form.hide(250, function(){$(this).remove()});
		form.closest('div.popup').find('a.edit_answer').show();
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

