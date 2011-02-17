/***********************************************
 Initialization that needs to happen ASAP
************************************************/

var console_log='';
if(typeof console == 'undefined') console = {log:function(str){console_log += str + '\n' }};

function getUrlParameters() {
	var map = {};
	var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
		map[key] = value;
	});
return map; 
}

var params = getUrlParameters();

var answerHTML
var curPageId;
var targets_array = {};
var target_ctr = 0;
var disable_coms_view = false;
var scroll_temp_disable_mouseenter = false;
var scroll_temp_disable_mouseenter_timer;
var temp_close_com_disable = false;
var temp = {};
var lastWinWidth = lastWinHeight = 0;
var ie7 = false;
	
/***********************************************
	End ASAP initialization
***********************************************/

/***********************************************
	Place all of the application initialization code here
***********************************************/
$(function(){
	console.log("execute jquery on ready")

	if($.browser.msie){
		//alert("MSIE version is " + $.browser.version)
		if($.browser.version.match(/7\./)){
			ie7 = true;
		}
	} 

	var master_debug = false;
	
	var load_ape_client = master_debug ? true : true;
	console.log("load_ape_client = false")
	load_ape_client = false;
	
	var convert_stars = master_debug ? false : true;
	var convert_time = master_debug ? false : true;
	var activate_debug = true;
	var do_load_templates = master_debug ? true : true;
	var allow_resize = master_debug ? true : true;
	var update_css = true;
	
	try{ 
		// this modifies the ajaxSend globally so it will include the auth token with every ajax request
		$(document).ajaxSend(function(event, request, settings) {
		  if (typeof(AUTH_TOKEN) == "undefined") return;
		  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
		  settings.data = settings.data || "";
		  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
		});
		// force resize
		function forceResize(){
			lastWinWidth = lastWinHeight = 0;
			resizeUI()
		}

		if(allow_resize){
			$(window).resize(function(){
		    	resizeUI()
			});
		}	
		if(allow_resize) setTimeout(forceResize,3000)
		if(allow_resize) setTimeout(forceResize,6000)
		if(allow_resize) setTimeout(forceResize,10000)
	
		// call the functions that are stored in activate.js
		
		if(do_load_templates)load_templates()
	
		NOTIFIER.init();
		
		activate_ux_appearance()
	
		activate_ux_pages()
	
		activate_ux_function_calls();
		activate_ux_functions_misc();
		activate_ux_functions_edit();
	
		if (load_ape_client) load_ape(chat_container_name);

		if(activate_debug) activate_debug_functions_extras();
	
	  if(convert_stars) setTimeout(init_rating_stars, 1000);

		if(convert_time) $("abbr.timeago").timeago();
		
		$('span.new').closest('div.Comment_entry').removeClass('one_line_comment').addClass('full_comment_display');
	
		_load_times.everything_initialized = new Date();
		setTimeout(send_load_report, 5000);

		$('div.comment_links').hide();
		$('div.ans_comment_links a').hide();

		activate_endorsement_form();

		$('div#endorsements table abbr.timeago').timeago();

		$('a.edit_in_place').edit_in_place();

		//console.log("Take down the mask and loading message");
		$('div#load_mask').remove();
		$('h2#load_message').remove();
		
		
		//if( !(typeof member_id != 'undefined' && member_id != 0) ) $('form.mini_thumbs_up :submit').attr('disabled','disabled');
		
		
	}catch(e){console.log("idea/idea.js jquery ready function error: " + e.message)}	
	
});
/***********************************************
	End of application initialization code
***********************************************/

$('a.delete_endorsement').live('click', 
	function(){
		console.log("delete_endorsement");
		try{
			
			$.ajax({ 					
			  type: "POST", 
			  url: "/idea/endorse_proposal", 
				data: { team_id: team_id,
					act: 'delete'
				},
				dataType: 'json',
			  success: function(data,status){ 
					//console.log("com_rate submit success, call dispatchComRating"); with submit = true
					temp.delete_endorsement = data
				  dispatchEndorsement( data[0].params.data, true );
			  },
				error : function(xhr,errorString,exceptionObj){
					console.log("Error on set_favorite submit, xhr: " + xhr.responseText)
				}
			});
			
			
		}catch(e){console.log("delete_endorsement e: " + e.message)}
		return false;
	}
);

$('a.2029_guidelines').live('click',
	function(){
		$('<div>Loading...</div>').load("/idea/guidelines", function(){
			$(this).dialog( {title : '2029 and beyond Online Groundrules and Guidelines', modal : true, width: 600, maxHeight: 500 } );
		})
		return false;
	}
)


$('a.update_endorsement').live('click', 
	function(){
		console.log("update_endorsement");
		try{
			var form = $('div#endorsements form');
			form.removeClass('hide');
			var t = $(this).closest('tr').find('td.text').html();
			form.find('textarea').val( strip_white_space(t) )
		}catch(e){console.log("update_endorsement e: " + e.message)}
		return false;
	}
);



$('div.rate').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    // do something on mouseover
		$this = $(this)
		$this.find('div.results').hide();
		$this.find('form').show();
  } else {
    // do something on mouseout
		$this = $(this)
		$this.find('div.results').show();
		$this.find('form').hide();
  }
});

//$('a.show_bsd').live('click',
$('div.q_cta').live('click', 
	function(){
		$this = $(this);
		$this.removeClass('mouseover');
		//$this.hide();
		$this.next('div.show_bsd').html('<p class="loading">Loading...</p>')
		//$this.next('div.show_bsd').load('/idea/bsd',{id: $this.attr('href').match(/\d+/)[0]}, 
		$this.next('div.show_bsd').load('/idea/bsd',{id: $this.attr('id').match(/\d+/)[0]}, 
			function(){
				var $this = $(this);
				$this.hide();
				
				$this.show("blind", { direction: "vertical" }, 2000);
				
				//console.log("activate_comment_form(form);")
				//temp.bsd = this
				$this.find('div.comment_links').hide();
				activate_comment_form( $('form.add_comment_form', this) );
				activate_idea_form( $('form.add_bs_idea_form', this) );
				$('div.list.fav div.list_inner', this).sortable( { update: idea_list_sort_update });
				$this.find('p.idea_lists a').eq(0).click();
				var par = $this.closest('div.qa');
				par.find('div.answer_section').append( par.find('div.bsd_bar.bottom'));
				
				//$('a.edit_answer')
			}
		)
		$this.hide("blind", { direction: "vertical" }, 600);
		return false;
	}
);

$('div.q_cta').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    //' do something on mouseover
		$(this).addClass('mouseover');
  } else {
    // do something on mouseout
		$(this).removeClass('mouseover');
  }
});




$('a.bsd_close').live('click',
	function(){
		console.log("bsd_close");
		$this = $(this);
		var bsd = $this.closest('div.qa').find('div.qa_bsd');
		$this.closest('div.qa').find('div.bsd_bar.bottom').remove();
		bsd.hide("blind", { direction: "vertical" }, 1200,
			function(){
				$this = $(this);
 				$this.closest('div.qa').find('div.q_cta').show("blind", { direction: "vertical" }, 600);
			}
		)
		return false;
	}
);




$('a.report').live('click',
	function(){
		var item_id = Number($(this).attr('href').match(/\d+$/))
		$('<div></div>').load("/idea/report/" + item_id, 
			function(){
				var $this = $(this);
				$this.dialog({modal:true,	title: 'Report this content', width: 'auto', height: 'auto'}); 
				activate_report_form($this.find('form'))
			}
		)
		return false;
	}
)

$('a.pre_review_proposal:first').live('click',
	function(){
		var item_id = Number($(this).attr('href').match(/\d+$/))
		$('<div></div>').load("/idea/submit_proposal/" + team_id + '?act=pre_review', 
			function(){
				var $this = $(this);
				$this.dialog({modal:true,	title: 'Request pre-submission review', width: 'auto', height: 'auto'}); 
				activate_submit_form($this.find('form'))
			}
		)
		return false;
	}
)

$('a.submit_proposal:first').live('click',
	function(){
		var item_id = Number($(this).attr('href').match(/\d+$/))
		$('<div></div>').load("/idea/submit_proposal/" + team_id + '?act=submit', 
			function(){
				var $this = $(this);
				$this.dialog({modal:true,	title: 'Submit for official review', width: 'auto', height: 'auto'}); 
				activate_submit_form($this.find('form'))
			}
		)
		return false;
	}
)



$('div.comment').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    // do something on mouseover
		$(this).find('div.comment_links').show();
  } else {
    // do something on mouseout
		$(this).find('div.comment_links').hide();
  }
});

$('div.answer_section').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    // do something on mouseover
		$(this).find('div.ans_comment_links a').show();
  } else {
    // do something on mouseout
		$(this).find('div.ans_comment_links a').hide();
  }
});



$('div.discussion').delegate( 'div.close_1com, div.one_line', 'click', 
	function(){
		var $this = $(this);
		if( $this.closest('div.Comment_entry').hasClass('full_comment_display') ){
			$this.closest('div.comment').slideUp(500, function(){
				$(this).closest('div.Comment_entry').addClass('one_line_comment').removeClass('full_comment_display');
				$(this).slideDown(200,
					function(){
						ellipsis(this);
					}
				)
			},'easeOutQuart');
			
		}else{
			$this.closest('div.comment').slideUp(500, function(){
				$(this).closest('div.Comment_entry').removeClass('one_line_comment').addClass('full_comment_display');
				$(this).slideDown(200)
			},'easeOutQuart');
		}
	}
);

$('a.show_me_how, a.tell_me_more, a.next_action, a.checklist, a.history, a.com_author').live('click', link_disabled);


Function.prototype.bind = function(bind, args){
	return this.create({bind: bind, arguments: args});
}

// I made need to work with the arguments.slice part
Function.prototype.create = function(options){
	var self = this;
	options = options || {};
	return function(event){
		var args = options.arguments;
		if(args != undefined){
			args = $.makeArray(args);
		}else{
			// options.event would be the first item, so drop it if it exists
			//args = Array.prototype.splice.call(arguments, (options.event) ? 1 : 0);
			args = $.makeArray(arguments);
		}
		var returns = function(){
			return self.apply(options.bind || null, args);
		};
		return returns();
	};
}

//
// create closure
//
;(function($) {
  //
  // plugin definition
  //
	
  $.fn.edit_in_place = function(selector) {
		return this.filter(
			function(index){
				var	element = $(this)
				element.unbind('click').die('click').click( edit_in_place)
				return true;
			}
		)
		
		function edit_in_place(){
			try{
			  var edit_link = $(this);
	      //Read that portion of the class
	      var class_obj = edit_link.attr('class').match(/(\[.*\])/)[0]
	      //Convert it into an object:
	      var opts = eval(class_obj)[0];
				var add_pars_to_str = false;
				temp.selector = 'edit_link' + opts.selector
			  var edit_target = eval('edit_link' + opts.selector);
			temp.edit_target = edit_target
				var form_div = create_form(opts);
				var textarea = $('textarea',form_div);
				var str = edit_target.clone().find('a.edit_in_place').remove().end().html()
				if(str.match(/<p>/i)){
					str = str.replace(/<p>/gi,'').replace(/<\/p>/gi,'\n\n').replace(/\s*$/,'');
					add_pars_to_str = true;
				}
				textarea.val( str )
				if(opts.form_tgt_selector){
					var form_target = eval('edit_link' + opts.form_tgt_selector);
					form_target.after(form_div).hide();
				}else{
					edit_target.after(form_div).hide();
				}
				edit_link.hide();
				//console.log("activate: " + $('textarea',form_div).size() )
				activate_text_counters_grow( textarea )
				form_div.find('form').submit( function(){ 
					submit_edit(this); return false;
					} 
				);
				form_div.find('form :submit').submit( 
					function(){ 
						submit_edit( $(this.form) ); 
						return false;
					} 
				);
				form_div.find('a.cancel').click( cancel_edit );
			}catch(e){console.log("edit_in_place error: " + e.message)}
		  return false;
		
			function cancel_edit(){
				edit_link.show();
				edit_target.show();
				if(form_target) form_target.show();
				form_div.remove();
				return false;
			}
			
			function submit_edit(form){
				//console.log("submit the edit v2");
				form = $(form)
				try{
					var btn = $(':submit',form);
					btn.attr('disabled',true).after('<img src="/images/rotating_arrow.gif"/>')
					$(':input',form).removeClass('form_error_border');
					$('p.form_error_text',form).remove();

					form.ajaxSubmit({ 					
					  type: "POST", 
						url: opts.url,
					  success: function(data,status){ 
							//console.log("inline_edit success data: " + data)
							//if(add_pars_to_str){
							//	edit_target.html('');
							//	$.each( data.split(/\n\n/), 
							//		function(){
							//			edit_target.append( '<p>' + this + '</p>' )
							//		} 
							//	);
							//	edit_target.show();
							//}else{
							//	edit_target.html( data.replace(/\s+/g,' ') ).show();
							//}

							form_div.remove();
							if(form_target) form_target.show();
							edit_link.show();
							
							if(add_pars_to_str){
								var str = '';
								$.each( data.split(/\n\n/), 
									function(){
										str += '<p>' + this + '</p>';
									} 
								);
								edit_target.html( str ).show();
								edit_target.find('p:last').append(' ').append(edit_link);
								$('a.edit_in_place').edit_in_place();
							}else{
								var str = data.replace(/\s+/g,' ')
								edit_target.html( str ).show();
							}
							
					  },
						error : function(xhr,errorString,exceptionObj){
							console.log("Error inline_edit, xhr: " + xhr.responseText)
							try{
								show_form_error(form,xhr.responseText)
								//$("input[name='first_name']",form).before('<p class="form_error_text">' + xhr.responseText + "</p>")
								btn.removeAttr('disabled').next('img').remove();
							}catch(e){
								console.log("inline_edit submit error: " + e)
								$('<div><p>Sorry, we cannot process your edit at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
								btn.removeAttr('disabled').next('img').remove();
							}
						}
					});
				}catch(e){console.log("inline_edit:submit_edit error: " + e.message)}
				return false;
			}
		
		}

		function create_form(opts){
			var form = $([
				'<div class="edit_in_place_form">',
					'<form class="std_form">',
					'<label>' + opts.label + '</label>',
					'<textarea cols="1" rows="2" name="edited_text" style="overflow-x: hidden; overflow-y: hidden; line-height: 16px; "></textarea>',
					'<div class="control_line">',
				  	'<div class="controls">',
				    	'<span class="char_ctr">' + opts.chr_cnt + ' characters left</span>',
				    	'<input type="submit" value="Save" />',
							'<a href="/" class="cancel">Cancel	</a>',
				  	'</div>',
					'</div>',
				'</form>',
			'</div>'].join('') );
			return form;
		}
  };
//
// end of closure
//
})(jQuery);