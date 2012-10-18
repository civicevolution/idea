$('body').on('click', 'a.show_projects', function(){
	console.log('show projects');
	$('body').animate( {scrollTop: $('h1#list_of_proposed_projects').offset().top}, 800);
	return false;
});