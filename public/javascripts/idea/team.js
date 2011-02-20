
	function setFormFocusFade(form){
	  form = $(form);
	  temp.form = form
	  //console.log("set focus opacity on this form v1 #: " +  form.closest('Page').find('form.add_comment_form').size());
	  form.closest('.tab_window').find('form.add_comment_form').not(form).fadeTo(1000,.2);
	  form.fadeTo(1000,1)
	}

	function adjust_page_coms(page){
		if(page.data('adjusted') ) return;		
		//console.log("adjust_page_coms")
		var line_height = 30;
		var fixed_height = 10;
		$('.plus_com',page).each(
			function(){
				//debugger
				var total_coms = $('.Comment_entry', this ).size()
				if( total_coms > 1 ){
					var height = $(this).height();
					var dpy_coms = Math.floor( (height - fixed_height) / line_height);	
					if(dpy_coms > 0){
						//$('.Comment_entry:gt(' + (num_coms - 1) + ')', this ).hide();
						$('.Comment_entry:gt(' + (dpy_coms - 1) + ')', this ).addClass('hidden');
						$('.Comment_entry:lt(' + (dpy_coms) + ')', this ).removeClass('hidden');
					}
				//	if(dpy_coms < total_coms){
						//var str = total_coms - dpy_coms > 1 ? total_coms - dpy_coms + ' more comments' : '1 more comment';
						//var str = "Open all comments";
						//$('.coms_inner',this).prepend('<div class="coms_count"><span>' + str + '</span></div>');
						
				//	}
				}else if (total_coms == 0){
					$('.coms_inner',this).prepend('<div class="coms_empty"></div>');
					$('.coms_inner',this).prepend('<div class="coms_count"><span>No comments yet</span></div>');
					
				}				
			}
		)
//		$('.coms form input',page).obscured('.coms').addClass('hidden')
		page.data('adjusted',true);
		
	}	
	
	function show_all_one_liners(el){
		el.css('z-index',2)
		$('.Comment_entry', el ).removeClass('hidden');
		ellipsis(el)
	}
	
	
	
	
function init_rating_stars(obj){
	//console.log("init_rating_stars, activate star_hover v2");
	try{
		if(!obj || !obj.size || obj.size() == 0 ) obj = $(':radio.star');
		//console.log("obj.size(): " + obj.size() );
		obj.rating({
			callback: function (value, link){
				//$(this.form).ajaxSubmit( {beforeSubmit: showUpdatingMsg, dataType: 'script'});
				var form = $(this.form)
				form.find('span.star_hover').html('Updating')
				
				form.ajaxSubmit({ 
					type: "POST",
					dataType: 'json',
					success: function(data,status){ 
						//console.log("rating submit success, call dispatchRating");
						temp.rating_submit = data;
					  dispatchRating( data[0].params, true );
				  },
					error : function(xhr,errorString,exceptionObj){
						console.log("Error on answer rating submit, xhr: " + xhr.responseText)
						try{
							var form_errors = eval(xhr.responseText)[0];	
							if(form_errors[0][0] == 'Sign in required'){
								console.log("show the sign in form");
								show_signin_form('rate an answer');
							}else{
								console.log("answer rating error, not sign in required")
							}
						}catch(e){
							console.log("answer rating submit browser error in server error handling: " + e)
							$('<div><p>Sorry, we cannot process your answer rating at this time</p><p>We have been notified of this error and we will look into it soon.</p></div>').dialog( {title : 'Warning', modal : true } )
						}
					}
				});
			}, 
			focus: function(value, link){
		    var tip = $('.star_hover',this.form.parentElement);
		    tip[0].data = tip[0].data || tip.html();
		    tip.html( link.title || 'value: '+value );
				$('.rating_results',this.form).hide();
		  },
		  blur: function(value, link){
		    var tip = $('.star_hover',this.form.parentElement);
		    $('.star_hover',this.form).html(tip[0].data || '');
				$('.rating_results',this.form).show();
		  },
			required: true
		});	
	}catch(e){console.log("init_rating_stars error: " + e)}
	$('form.item_rater :submit').hide()
}

function showUpdatingMsg(){
	var jForm = arguments[1]
	//alert(jForm[0])
	$('.rating_results > span',jForm).html("Updating, please wait...")
}

	function view_history(){
		//console.log("view_history")
		try{
			var a = $(this);
			var id = Number(a.attr('href').match(/\d+$/))
			var url = '/idea' + a.attr('href').match(/\/[^\/]*item_history/)

			//console.log('view_history url: ' + url + ' id: ' + id)

			$.get(url, 'id=' + id, function(html) {
				//console.log("html: " + html)
				var dlg = $(html).dialog( {title : 'Answer history', width: '500px'} );
				dlg.css('border','1px solid black');
			}, 'html');

		}catch(err){
			console.log("view_history error: " + err)
		}
		return false;
	}


	//
	// create closure
	//
	(function($) {
	  //
	  // plugin definition
	  //
	  $.fn.obscured = function(parent_selector) {

			return this.filter(
				function(index){
					var	element = $(this),
						elementOffset,
						parent = element.closest(parent_selector),
						parentOffset;

					if (element.is(":visible")){
						elementOffset = element.offset();
						parentOffset = parent.offset();

						return (parentOffset.top  > elementOffset.top  || // top obscured
								parentOffset.left > elementOffset.left || // left obscured
								parentOffset.top  + parent.height() < elementOffset.top  + element.height() || // bottom obscured
								parentOffset.left + parent.width()  < elementOffset.left + element.width());   // right obscured
					}
					return false;				
				}
			)
	  };
	//
	// end of closure
	//
	})(jQuery);
	

$('a.how').die('click').live('click',
	function(){
		var el = link = $(this)
		// find the first div.how below this
		//console.log("open how")
		while( el && ( el = el.parent() ) ){
			var div = el.find('div.how:first');
			//console.log("div.size(): " + div.size())
			if(div.size() > 0){
				if(div.is(':visible')){
					//console.log("hide")
					div.hide()
					var title = link.attr('title');
					link.html(title || 'How')
				}else{
					//console.log("show")
					div.show();
					var title = link.html()
					link.html('Close').attr('title',title)
				}
				return false;
			}
		}
		return false;
	}
)
