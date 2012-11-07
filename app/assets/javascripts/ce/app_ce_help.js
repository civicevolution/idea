if( $('div.tour').size() != 0 ){
	$('body').bind('keydown', function(evt){
		var curPage = $('div.tour ol.tour li.current_step');
		if(evt.keyCode == 37){ //left
			console.log("left");
			var nextPage = curPage.prev('li.page');
			if(nextPage.size() == 0 ) nextPage = $('div.tour ol.tour li.page:last');
			tour_next_page(nextPage);
		}else if(evt.keyCode == 39){// right
			console.log("right");
			var nextPage = curPage.next('li.page');
			if(nextPage.size() == 0 ) nextPage = $('div.tour ol.tour li.page:first');
			tour_next_page(nextPage);
		}
	});
}
// kill listener when tour closed
//$('body').unbind('keydown');

$('body').on('click', 'ol.tour img.next', function(){
	console.log("Go to next step");
	var curPage = $('div.tour ol.tour li.current_step');
	var nextPage = curPage.next('li.page').eq(0);
	tour_next_page(next_page);
})
function tour_next_page(nextPage){
	$('div.tour ol.tour').animate({left: -(nextPage.position().left)}, 1000);
	$('div.tour ol.tour li.page').removeClass('current_step');
	nextPage.addClass('current_step');
	$('div.tour_nav div.step').removeClass('current_step');
	$('div.tour_nav div.step[id="' + nextPage.attr('id') + '"]').addClass('current_step');	
}
$('body').on('click', 'div.tour_nav div.btn, div.tour_nav div.label', function(){
	var step = $(this).closest('div.step');
	console.log("Go to step # " + step.attr('id') );
	var next_page = $('div.tour ol.tour li.page[id="' + step.attr('id') + '"]');
	tour_next_page(next_page);
})

function resize_tour(){
	var win_height = $(window).height();
	
	var tour_div = $('div.tour');
	if(tour_div.size() == 0 ){ return;}
	$('li.page').width( tour_div.width() );
	
	// height
	$('div.tour').height( win_height );
	var header = $('div.tour_header');
	var footer = $('div.tour_nav');
	//var tour_height = footer.position().top - header.position().top - header.height() - 80;
	var tour_height = win_height - header.position().top - header.height() - 160;
	$('li.page').height( tour_height );
	$('div.tour_container').height( tour_height );
	$('div.tour_body').height( win_height );
	
	// navigation
	var tour_nav = $('div.tour_nav');
	var num_pages = tour_nav.find('div.step').size();
	var tour_nav_width = $('div.tour').width() - 80; // width - 40 padding l/r
	tour_nav.width( tour_nav_width ); // width - 40 padding l/r
	var adj = 0;
	var margin = ( ( tour_nav_width - adj - num_pages * 21 )/(num_pages - 1) /2 );
	
	tour_nav.find('div.step').css('margin','0 ' + margin+'px 0 ' + margin+'px').first().css('margin-left',0);
	tour_nav.find('div.step').last().css('margin-right',0);
}
$(function(){
	resize_tour();
});
$(window).resize(function() {
  resize_tour();
});