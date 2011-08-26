// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs

//console.log("Loading application.js");

temp = {};

$(function(){
		
		size_talking_point_entries();
		$(document).ajaxSend(function(e, xhr, options) {
		  var token = $("meta[name='csrf-token']").attr("content");
		  xhr.setRequestHeader("X-CSRF-Token", token);
		});	
		$('textarea').autoGrow({ minHeight  : 120, maxHeight : 500 })
		
});


function size_talking_point_entries(){
	$('div.talking_point_entry').not('.header').each( 
		function(){
			var el = $(this)
			var b = el.children('div.talking_point_body').height('auto');
			var cr = el.find('div.talking_point_acceptable > div.community_rating').height('auto');
			var p = el.children('div.talking_point_preferable').height('auto');
			var max = Math.max.apply( Math, [b.height(), (cr.height() + 26), p.height()] );
			//console.log("max height: " + max)
			b.height(max);
			cr.height(max-20);
			p.height(max-20);
		}
	)	
}

$('form.what_do_you_think a.clear').die('click').live('click',
	function(){
		$(this).closest('form').find('textarea').val('');
		return false;
	}
);


$('form#what_do_you_think_form').bind('ajax:before', 
	function(){
		if( $(this).find('input:radio:checked').size() == 0 ){
			alert("Please select Add a comment, or Add a talking point")
			return false
		}
	}
);


$('div.my_rating :radio').die('change').live('change',
	function(){
		$.post('/talking_points/' + $(this).closest('div.talking_point_entry').attr('id') + '/rate', {rating: this.value})
	}
);


$('p.my_preference :checkbox').die('change').live('change',
	function(){
		$.post('/talking_points/' + $(this).closest('div.talking_point_entry').attr('id') + '/prefer', {prefer: this.checked})
	}
);

$('a.help_tag').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
		$(this).addClass('mouseover')
  } else {
		$(this).removeClass('mouseover')
  }
});

$('a.request_new').live('click',
	function(){
		//console.log("Show the new content");
		var help = $('div.new_content');
		if(help.size()==0){
			$.get('/plan/' + team_id + '/new_content',
				function(data){
				  var pcs = data.split(/<script/);
					var dialog = $(pcs[0]).dialog( {title : 'New content', modal : false, width: 'auto', closeOnEscape: true } );
					//if(typeof activate_request_help_form == 'undefined') $('head').append('<script' + pcs[1]);
					//activate_request_help_form(dialog.find('form'));
					//dialog.find('select').focus();
				}
			)
		}else{
			var help_dlg = help.closest('div.ui-dialog');
			if(help_dlg.is(":visible")){
				help_dlg.hide();
			}else{
				help_dlg.show();
			}
			
			
		}
		return false;
	}
)

$('a.new_tag').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
		$(this).addClass('mouseover')
  } else {
		$(this).removeClass('mouseover')
  }
});


function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}
var params = getUrlVars();