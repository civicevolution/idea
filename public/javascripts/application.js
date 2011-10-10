// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs

var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};
temp = {};

console.log("Loading application.js");



$(function(){
		$(document).ajaxSend(function(e, xhr, options) {
		  var token = $("meta[name='csrf-token']").attr("content");
		  xhr.setRequestHeader("X-CSRF-Token", token);
		});	
		init_page();
		if(params['video']=='play'){
			setTimeout(function(){ $('a#play_intro_video').click(); },1000);
		}
});

function ajaxDisableElement(el){
	var element = $(el);
	element.data('ujs:enable_with', element.html()); // store enabled state+      
	element.html( element.attr('disable-with') || 'Loading...' ); // set to disabled state
	element.addClass('loading');
	//element.bind('click.railsDisable', function(e) { // prevent further clicking
	//	return rails.stopEverything(e)
	//});
}

// restore element to its original state which was disabled by 'disableElement' above
function ajaxEnableElement(el){
	var element = $(el);
	if (element.data('ujs:enable_with') !== undefined) {
		element.html(element.data('ujs:enable_with')); // set to old enabled state
		element.removeClass('loading');
		element.removeData('ujs:enable_with'); // clean up cache
	}
	//element.unbind('click.railsDisable'); // enable element
}

$('a[data-remote]').live('ajax:beforeSend', 
	function(){
		//console.log("ajax beforeSend");
		ajaxDisableElement(this);
	}
).live('ajax:complete', 
	function(){
		//console.log("ajax complete")
		ajaxEnableElement(this)	
	}
)


function init_page(){
	//console.log("init_page")
	remove_worksheet_form();
	size_talking_point_entries();
	activate_text_counters_grow($('textarea, input[type="text"]'), 120);
	var worksheet_corners = $('div.worksheet .corner');
	var non_worksheet_corners = $('.corner').not( worksheet_corners );
	if( worksheet_corners.size() > 0 ){
		worksheet_corners.corner( 'cc:#F2E9C3');
	}
	if( non_worksheet_corners.size() > 0 ){
		non_worksheet_corners.corner();
	}
	
	try{
		init_add_this();
		$("a[rel^='prettyPhoto']").prettyPhoto({theme: 'dark_rounded'});
	}catch(e){}
}

function remove_worksheet_form(){
	$('input.submit_ratings').remove();
	var form = $('form.update_worksheet');
	var div = $('<div class="form_replace"></div>').html( form.children().remove() );	
	form.after(div);
	form.remove();
}

function size_talking_point_entries(){
	$('div.my_rating').addClass('js') // arrange for compressed javascript enabled format
	$('div.community_rating').removeClass('no_js');
	//return
	$('div.talking_point_entry').not('.header').each( 
		function(){
			var el = $(this)
			var b = el.children('div.talking_point_body').height('auto');
			var cr = el.find('div.talking_point_acceptable > div.community_rating').height('auto');
			var p = el.children('div.talking_point_preferable').height('auto');
			var max = Math.max.apply( Math, [b.height(), (cr.height() + 26), p.height()] );
			//console.log("max height: " + max)
			b.height(max);
			cr.parent().height(max-20);
			p.height(max-20);
		}
	)	
}

$('form.what_do_you_think a.clear').die('click').live('click',
	function(){
		$(this).closest('form').find('textarea').val('');
		$(this).closest('form').find('div#errorExplanation').remove();
		return false;
	}
);

$('div.my_rating :radio').die('change').live('change',
	function(){
		$.post('/talking_points/' + $(this).closest('.talking_point_entry').attr('id') + '/rate', {rating: this.value}, function(){}, "script");
	}
);

$('div.radios div').live('mouseover mouseout', function(event) {
	var el = $(this);
	var p = el.closest('div.my_rating').find('p.option').removeClass('please_rate')
  if (event.type == 'mouseover') {
		var title = el.find('input').attr('title');
		p.html(title)
  } else {
		p.html(p.attr('title'))
  }
});

$('div.radios label').live('click', function() {
	var el = $(this);
	var p = el.closest('div.my_rating').find('p.option');
	var title = el.find('input').attr('title');
	p.html(title);
	p.attr('title',title);
});


$('p.my_preference :checkbox').die('change').live('change',
	function(){
		$.post('/talking_points/' + $(this).closest('.talking_point_entry').attr('id') + '/prefer', {prefer: this.checked}, function(){}, "script");
	}
);

$('form.what_do_you_think :radio').die('change').live('change',
	function(){
		var el = $(this);
		console.log("radio change");
		var char_ctr = el.closest('form').find('span.char_ctr');
		if(el.val() == 'talking_point'){
			var cnt = 200;
		}else{
			var cnt = 1500;
		}
		el.closest('form').find('textarea').show_char_limit(cnt, {
	    error_element: char_ctr,
			status_element: char_ctr
		})
	}
)

$('div.home_page table.proposal_stats').die('click').live('click',
	function(){
		document.location = '/plan/' + $(this).closest('div.notebook').attr('id')
	}
)

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

function activate_text_counters_grow(els, height){
	height = height? height : 50
	els.each(
		function(){
			var el = $(this);
			var span = el.next().find('span.char_ctr');
			while(span.size() == 0 && !el[0].nodeName.match(/BODY/i) ){
				el = el.parent();
				span = el.find('span.char_ctr');
			}
			if(span.size() == 1){
				el = $(this);
				var cnt = Number(span.html().match(/\d+/));
				el.show_char_limit(cnt, {
			    error_element: span,
					status_element: span
			  });
				if(el[0].nodeName == 'TEXTAREA'){
					// if the el is not displayed, IE gives it a width of 0 and the el cannot be setup to grow
					if(el[0].offsetWidth > 0){
						el.autoGrow({
							minHeight  : height,
							maxHeight : 500
						});
					}
				}
			}
		}
	)
}

function init_add_this(){
	var addthis_config = {"data_track_clickback":true};
	var addthisScript = "http://s7.addthis.com/js/250/addthis_widget.js#username=civicevolution"

	function initAddthis(){ 
		if (window.addthis){ 
			window.addthis.ost = 0; 
			window.addthis.init(); 
		} 
	} 

	$.getScript( addthisScript , function(){
		initAddthis()
	});
	
}