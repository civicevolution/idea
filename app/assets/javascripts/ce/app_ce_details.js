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