// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// https://github.com/rails/jquery-ujs
// a. For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
// //= require jquery
// //= require jquery_ujs

var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};
temp = {};

//console.log("Loading application.js");

jQuery(function() {
	//console.log("********** Update support.borderRadius")
	jQuery.support.borderRadius = false;
	jQuery.each(['BorderRadius','borderRadius','MozBorderRadius','WebkitBorderRadius','OBorderRadius','KhtmlBorderRadius'], function() {
		if(document.body.style[this] !== undefined) jQuery.support.borderRadius = true;
		return (!jQuery.support.borderRadius);
	});
});

$(function(){
		$(document).ajaxSend(function(e, xhr, options) {
		  var token = $("meta[name='csrf-token']").attr("content");
		  xhr.setRequestHeader("X-CSRF-Token", token);
		});	
		init_page();
		if(params['video']=='play'){
			setTimeout(function(){ $('a#play_intro_video').click(); },1000);
		}
		if (typeof JSON == 'undefined' || !JSON) { console.log("load json2"); $.getScript('/javascripts/json2-min.js'); }
});

function ajaxDisableElement(el){
	var element = $(el);
	element.data('ujs:enable_with', element.html()); // store enabled state+      
	element.html( element.attr('data-disable-with') || 'Loading...' ); // set to disabled state
	//element.html( element.attr('data-disable-with') || '<img src="/assets/wait5.gif"/>' ); // set to disabled state
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
	element.unbind('click.railsDisable'); // enable element
}

$('a.display_worksheet').live('ajax:beforeSend', 
	function(){
		// if the WS is already open, return false
		var id = Number($(this).attr('href').match(/\d+/));
		var disable_flag = $('div.worksheet[id="' + id + '"]').size() > 0 ? true : false
		console.log("display_worksheet beforeSend disable_flag: " + disable_flag )
		if(disable_flag){
			// make sure the link is restored
			temp.dw_link = this;
			setTimeout(function(){ajaxEnableElement(this)}.bind(this),10);
			return false;
		}else{
			open_question_worksheet(this);
		}
	}
)

$('a.close_worksheet').live('ajax:beforeSend', 
	function(){
		close_question_worksheet(this);
		//return false;
	}
)

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

$('form[data-remote]').live('ajax:beforeSend', 
	function(){
		//console.log("form ajax beforeSend");
		$(this).find(':submit').hide().after('<img src="/assets/wait5.gif"/>');
	}
).live('ajax:complete', 
	function(){
		//console.log("form ajax complete")
		$(this).find(':submit').show().end().find('img').remove();
	}
)


function init_page(){
	//console.log("init_page")
	init_worksheet();
	var q_tabs = $('div.list_tabs');
	if(q_tabs.size()>0){
		var tab_template = q_tabs.find('ul').html();
		q_tabs.find('ul').html(''); // remove the tab model
		tab_template = tab_template.replace('#tab_curated_q1','#{href}').replace('Q1','#{label}');
		$("div.list_tabs").tabs({tabTemplate: tab_template, select: tab_select});
	}
	if(typeof right_panel_init != "undefined"){
		right_panel_init();
	}
	
	if(!$.support.borderRadius){ 
		console.log("load corner support script and activate");
		$.getScript('/javascripts/jquery.corner.js', 
			function(){
				//console.log("corner has been loaded")
				//var non_worksheet_corners = $('.corner');
				//if( non_worksheet_corners.size() > 0 ){
				//	non_worksheet_corners.corner();
				//}
				$('div.right_side div.corner').css('background-color','#eee').corner();
			}
		);
	}else{
		// define dummy corner function
		$.fn.corner = function(){ return this; }
	}
	try{
		init_add_this();
	}catch(e){}
	try{
		$("a[rel^='prettyPhoto']").prettyPhoto({theme: 'dark_rounded'});
		//console.log("pretty photo is okay")
	}catch(e){}
}

function tab_select(event,ui){
	setTimeout(right_panel_resize,100);
}

function init_worksheet(){
	remove_worksheet_form();
	reformat_talking_point_entries();
	activate_text_counters_grow($('textarea, input[type="text"]'), 120);
}

function remove_worksheet_form(){
	$('input.submit_ratings').remove();
	var form = $('form.update_worksheet');
	var div = $('<div class="form_replace"></div>').html( form.children().remove() );	
	form.after(div);
	form.remove();
}

function reformat_talking_point_entries(){
	$('div.my_rating').addClass('js') // arrange for compressed javascript enabled format
	$('div.community_rating').removeClass('no_js');
	$('div.graph.no_js').remove();
}

$('div.my_rating :radio').die('change').live('change',
	function(){
		var id = $(this).closest('.talking_point_post_it').attr('id');
		if(id==0){
			alert('This is an example of a talking point and you cannot act on it.'); 
		}else{
			$.post('/talking_points/' + id + '/rate', {rating: this.value}, function(){}, "script");
			//$(this).closest('div.radios').find('p.option').html('Saving...');
			$(this).closest('div.my_rating').html('<img src="/assets/wait3.gif"/><br/>Saving...')
		}
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

$('div.talking_point_acceptable.rated').live('mouseover mouseout', function(event) {
	var com_rate = $(this).find('div.community_rating');
	var radios = com_rate.next('div.radios');
  if (event.type == 'mouseover') {
		com_rate.addClass('hide');
		radios.removeClass('hide');
  } else {
		com_rate.removeClass('hide');
		radios.addClass('hide');
  }
});

$('div.talking_point_post_it').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
		$(this).addClass('mouseover');
  } else {
  	$(this).removeClass('mouseover');
	}
});

$('div.radios label').live('click', function() {
	var el = $(this);
	var p = el.closest('div.my_rating').find('p.option');
	var title = el.find('input').attr('title');
	p.html(title);
	p.attr('title',title);
});

$('input.fav_button').die('mouseup mousedown')
	.live('mouseout',
		function(){
			$(this).removeClass('mousedown');
		}
	)
	.live('mouseup',
		function(){
			var button = $(this);
			button.removeClass('mousedown');
			var id = button.closest('.talking_point_post_it').attr('id');
			if(id==0){
				alert('This is an example of a talking point and you cannot act on it.'); 
			}else if( !button.hasClass('saving') ) {
				var new_pref = button.hasClass('fav') ? 'false' : 'true';
				//button.addClass('saving');
				button.closest('.favorite').html('<img src="/assets/wait3.gif"/>')
				$.post('/talking_points/' + id + '/prefer', {prefer: new_pref}, function(){}, "script");
			}
		}
	)
	.live('mousedown',
		function(){
			$(this).addClass('mousedown')
		}
	);
	

$('div.home_page table.proposal_stats').die('click').live('click',
	function(){
		document.location = '/plan/' + $(this).closest('div.notebook').attr('id')
	}
)

$('a.endorse_this_proposal').live('click',function(){
	$.scrollTo("div.endorsements",2000);
	return false;
});

$('form#talking_point_form a.clear').live('click',
	function(){
		$(this).closest('form').find('textarea').val('');
		return false;
	}
);

$('form.comment_form a.clear').live('click',
	function(){
		$(this).closest('form').find('textarea').val('');
		return false;
	}
);

$('div.cta1 a.cta').die('click').live('click',
	function(){
		$(this).closest('div.question_summary').find('a.display_worksheet').click();
		return false;
	}
);

$('div.right_side form.signin_form').attr('data-remote','true');
$('form.signin_form').live('ajax:beforeSend', 
	function(){
		$(this).closest('div.member').find('p.error').remove();
	}
);

$('a.tgl_sign_in').die('click').live('click',
	function(){
		var link = $(this);
		//console.log("change form to " + link.attr('id') );
	  switch(link.attr('id')){
	  	case 'reset':
	  		link.closest('table').find('tr').hide().end().find('tr.reset').show();
	  		link.closest('table').find('tr :submit').attr('disabled','disabled').end().find('tr.reset :submit').removeAttr('disabled');
	  		break;
	  	case 'signin':
	  		link.closest('table').find('tr').hide().end().find('tr.signin').show();
	  		link.closest('table').find('tr :submit').attr('disabled','disabled').end().find('tr.signin :submit').removeAttr('disabled');
	  		break;
	  	case 'signup':
	  		link.closest('table').find('tr').hide().end().find('tr.signup').show();
	  		link.closest('table').find('tr :submit').attr('disabled','disabled').end().find('tr.signup :submit').removeAttr('disabled');
	  		break;
  		case 'signup_error_link':
	  		link.closest('div').find('table tr').hide().end().find('tr.signup').show();
	  		link.closest('div').find('table tr :submit').attr('disabled','disabled').end().find('tr.signup :submit').removeAttr('disabled');
	  		break;
	  }
	  link.closest('div.member').find('p.error').remove();
		return false;
	}
);

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
	if(!$('body').autoGrow) return;
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
				try{
				var cnt = Number(span.html().match(/\d+/));
				el.show_char_limit(cnt, {
			    error_element: span,
					status_element: span
			  });
			}catch(e){}
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
	if( typeof _atd != 'undefined' ) return 
	
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

function open_question_worksheet(el){
	var question_id = $(el).closest('div.question_summary').attr('id');
	$.scrollTo($('div.question_summary[id="' + question_id + '"] p.question'), 600)
}


function close_question_worksheet(el){
	el = $(el);
	var worksheet = el.closest('div.worksheet');
	var question_id = worksheet.attr('id');
	//$('div.question_summary[id="' + question_id +'"]').append('<h4 class="loading">Loading...</h4>')
	$('div.question_summary[id="' + question_id +'"]').append('<img src="/assets/wait3.gif"/>');
	worksheet.slideUp(800, function(){$(this).remove();});
	
	return false;
}

$('table#new_content tr').die('click').live('click',
	function(){
		var tr = $(this);
		var tp_id = tr.attr('tp_id');
		var com_id;
		var url;
		if(tr.hasClass('talking_point')){
			var url = '/talking_points/' + tp_id + '/comments';
			//console.log("show talking point with id: " + tp_id + " with url: " + url);
		}else if(tr.hasClass('comment')){
			var com_id = tr.attr('com_id');
			var url = '/talking_points/' + tp_id + '/comments?com_id=' + com_id;
			//console.log("show comment with id: " + com_id + " in talking_point with id: " + tp_id + " with url: " + url);
		}else if(tr.hasClass('question')){
			var ques_id = tr.attr('id');
			var url = '/questions/' + ques_id + '/worksheet'
			//console.log("show question with id: " + ques_id + " with url: " + url);
		}
		if(url){
		  // check if the page is already loaded before I request it
		  if( $('div.talking_point_comments[id="' + tp_id + '"]').size() > 0 ){
        if(com_id){
  				var com = $('div.Comment[id="' + com_id + '"]');
  				$('div.discussion[id="' + tp_id + '"]').scrollTo(com,600);
  				com.effect('highlight', {color: '#EAF8D0'},3000);				
  				tr.fadeTo(0,.4);
  			}
		  }else{
		    // load the page now
  		  tr.find('td').append('<img src="/assets/wait3.gif"/>');
  			$.ajax({
  			  url: url, 
  			  complete: function(){
  			    //console.log("display new content complete callback");
  			    tr.find('img').remove();
  			    tr.find('td').fadeTo(0,.4);
          }, 
  			  dataType: 'script'
  			});
        
  			$('div.talking_point_comments').each(
  			  function(){
  			    var popup = $(this);
  			    if(popup.find('textarea').val()==''){
  			      popup.slideUp(800,function(){ $(this).remove()});
  			    }
  			  }
  			);  
  		}
		}
	}
);
$('table#new_content tr:odd').addClass('striped');

$('div.Comment a.reply').die('click').live('click',
	function(){
		console.log("add a reply to this comment");
		var com = $(this).closest('div.Comment');
		var text = com.find('div.comment_text').clone();
		var author = text.find('a.com_author').remove().html();
		text.find('span.new').remove();
		text = text.html().replace(/<p>/ig,'').replace(/<\/p>/ig,'\n').trim();
		text = '[quote="' + author + '"]' + text+ '[/quote]';
		var form = $('form.comment_form:last');
		if(form.find('textarea').val().trim() != ''){
		  var new_form = form.clone();
		  new_form.find('input[name="form_id"]').val(Math.random()*1e16);
		  form.before(new_form);
		  activate_text_counters_grow(new_form.find('textarea'), 120);
		  form = new_form;
		}
		form.find('textarea').val(text);
		form.find('h4').html('Comment reply');
		form.closest('div.discussion').scrollTo(form,600);
		form.effect('highlight', {color: '#EAF8D0'},3000);				
		return false;
	}
);

function reformat_comment_quote(com){
	var txt = com.find('div.comment_text').html();
	if(!txt.match(/\[quote=/)) return;
	var pcs = txt.match(/^(.*)\[quote="([^"]*)"\]([\s\S]*)\[\/quote\]([\s\S]*)$/m);
	var author = pcs[1] + '</p>';
	//console.log("author: " + author);
	var quote = '<div class="quote corner"><p class="quote">' + pcs[2] + ' said:</p><p>' + pcs[3] + '</p></div>	'
	pcs[4] = pcs[4].replace(/\n/m,'').replace(/<br\/*>/gim,'\n').replace(/^\s*/,'').replace(/\n/gm,'<br/>');
	//console.log("quote: " + quote);
	var com_body = '<p>' + pcs[4];
	//console.log("com_body: " + com_body);
	var new_html = (author + quote + com_body);
	//console.log("pre new_html: " + new_html);
	var new_html = new_html.replace(/&lt;/img,'<').replace(/&gt;/img,'>');
	//console.log("post new_html: " + new_html)
	
	com.find('div.comment_text').html( new_html);
}

$('a.add_talking_point').die('click').live('click',
  function(){
    console.log("add a new talking point");
    var worksheet = $(this).closest('div.worksheet');
    var form_post_it = worksheet.find('div.talking_point_post_it.form');
  	worksheet.find('div.talking_point_matrix').scrollTo(form_post_it,1000, 
  	  function(){
  	    form_post_it.effect('highlight', {color: '#AD89BE'},3000);				
    		form_post_it.find('textarea').effect('highlight', {color: '#D8F1AB'},3000);				
  	  }
  	);
    return false;
  }
);

