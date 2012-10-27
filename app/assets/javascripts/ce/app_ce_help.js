
$('body').on('click', 'div.tour .next_step', function(){
	console.log("Go to next step");
	$('div.tour ol.tour').animate({left: -2100}, 1000);
})

$('body').on('click', 'div.tour_nav div.btn', function(){
	var step = $(this).closest('div.step');
	console.log("Go to step # " + step.attr('data-step') );
	$('div.tour ol.tour').animate({left: -700 * (step.attr('data-step') - 1)}, 1000);
	$('div.tour_nav div.step').removeClass('current_step');
	step.addClass('current_step');
})
