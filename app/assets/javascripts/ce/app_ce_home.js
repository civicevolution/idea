$('body').on('click', 'a.show_projects', function(){
	console.log('show projects');
	$('html,body').animate( {scrollTop: $('h1#list_of_proposed_projects').offset().top}, 800);
	return false;
});


$(function () {
		//console.log("init fileupload");
    $('#fileupload').fileupload({
        dataType: 'json',
				forceIframeTransport: false,
				formData: {authenticity_token: AUTH_TOKEN },
				progressall: function (e, data) {
					var progress = parseInt(data.loaded / data.total * 100, 10);
					console.log("progress: " + progress);
					$('#member_photo_upload_progress .bar').css(
					'width',
					progress + '%'
					);
				},
				start: function(e){
					$('#member_photo_upload_progress .bar').css('width','0%');
					$(this).closest('div#edit_profile').find('div.member_info img').attr('src','/assets/wait5.gif');
				},
				always: function(e){
					$('#member_photo_upload_progress .bar').css('width','0%');
				},
				done: function (e, data) {
					$('div.member_info img').attr('src',data.result[0].photo_url);
				}
    });
});
