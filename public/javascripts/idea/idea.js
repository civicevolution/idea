var temp = {}
$(function(){


	$('a.show_bsd').live('click',
		function(){
			$this = $(this);
			$this.hide();
			$this.next('div.show_bsd').html('Loading...')
			$this.next('div.show_bsd').load('/idea/bsd',{id: $this.attr('href').match(/\d+/)[0]}, 
				function(){
					//console.log("activate_comment_form(form);")
					//temp.bsd = this
					activate_comment_form( $('form.add_comment_form', this) );
					activate_idea_form( $('form.add_bs_idea_form', this) );
				}
			)
			
			
			return false;
		}
	);

	$('a.bs_idea_discussion').die('click').live('click',
		function(){
			console.log("show bs_idea_discussion")
			try{
				var $this = $(this);
				var par = $this.closest('.bs_idea');
				var qna_disc = $this.closest('div.bsd').find('div.discussion.qna');
				if(qna_disc.is(':visible')){
					par.addClass('selected')
					par.closest('.brainstorming').find('div.bs_idea').not(par).hide()			
					temp.bs_idea_par = par	
					qna_disc.hide();
					qna_disc.closest('div.gen_discussion').append(par.find('div.bsd_disc').show())
					$this.html('Back to ideas list')
					// scroll page to the question
					var question = qna_disc.closest('div.qa').find('.question:first');
					$('html,body').animate({ scrollTop: question.offset().top }, { duration: 'slow', easing: 'swing'});
				}else{
					par.removeClass('selected');
					var idea = par.closest('.brainstorming').find('div.bs_idea:visible')
					par.closest('.brainstorming').find('div.bs_idea').show();				
					temp.idea = idea
					//debugger 
					par.find('div.discussion').append(qna_disc.closest('div.gen_discussion').find('div.bsd_disc').hide())
					qna_disc.show();
					$this.html('View idea discussion')
					// scroll page to the idea
					setTimeout(function(){$('html,body').animate({ scrollTop: this.offset().top }, { duration: 'slow', easing: 'swing'});}.bind(idea),500)		
				}
				
			}catch(e){console.log("show bs_idea_discussion error: " + e)}
			return false;
		}
	);
	
	$('div.comment_links').hide();

});

$('div.bsd_disc a.bsd').live('click', 
	function(){
		$(this).closest('div.bsd').find('div.bs_idea:visible a.bs_idea_discussion').click();
		return false;
	}
);




$('div.comment').live('mouseover mouseout', function(event) {
  if (event.type == 'mouseover') {
    // do something on mouseover
		$(this).find('div.comment_links').show();
  } else {
    // do something on mouseout
		$(this).find('div.comment_links').hide();
  }
});




$('a.open_all').die('click').live('click',
	function(){
		//console.log("open_all (form.js)")
		try{
			var a = $(this);
			var par = a.closest('div');
			if( a.html().match(/Open/)){
				$('div.Comment_entry',par).addClass('full_comment_display').removeClass('one_line_comment');
				a.html('Close all comments');
			}else{
				$('div.Comment_entry',par).addClass('one_line_comment').removeClass('full_comment_display');
				a.html('Open all comments');
				ellipsis(par)
			}			
		}catch(e){console.log("open_all error: " + e)}
		return false;
	}
);



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



function ellipsis(page){
	//console.log("$('div.comment_text:visible',page).size(): " + $('div.comment_text:visible',page).size())
	$('div.comment_text:visible',page).each(
		function(){
			//console.log("ellipsis v3")
			var $this = $(this);
			if( $this.find('div.one_liner').size() > 0 ) return;
			//if(ie7) $this.closest('div.comment').css('margin',0);
			var d = $('<div class="one_liner"><span class="txt"></span></div>')
			$(this).prepend(d)

			var w = d.width();

			var icon;
			// if the next sibling is class resource upload or resource link, add an icon
			var res = $this.next('.resource')
			if(res.size() > 0){
				if(res.attr('className').match(/hide/)){
					// if hide, don't show an icon
				}else if(res.attr('className').match(/link/)){
					icon = 'link';
					w -= 20;
				}else if(res.attr('className').match(/upload/)){
					icon = 'upload';
					w -= 20;
				}
			}			
			w -= 30; // for the ellipsis

			var s = $('span.txt',d)

			var txt = $('p:first',this).html().replace(/<br[^>]*>/gi,' ');
			var num_chars = w / 6;
			txt = txt.substring(0,num_chars);
			//console.log("num_chars: " + num_chars + " raw txt: " + txt)
			var words = txt.split(/\s+/g);
			var words_cnt = words.length
			//console.log("Start words: " + words)
			var ctr = 6, reducing = false, sizing = true;
//			
			//loopctr = 0;

			do{
				s.html( words.slice(0,ctr).join(' ') );			
				//console.log("loop: " + loopctr + ", ctr: " + ctr + " str: " + words.slice(0,ctr).join(' ') + ", width: " + s.width() + ", w: " + w)
				if(s.width() > w){
						reducing = true;
					--ctr;
					//sizing = false;
				}else if(reducing){
					sizing = false;
				}else{
					//console.log("increase ctr")
					//console.log('words: ' + words)
					++ctr;
				}
				//if( ++loopctr > 10 ) break;
			}while(sizing && ctr <= words_cnt)
			// add ellipsis and icons
			if(words_cnt > ctr){
				s.append('&hellip;')
			}

			if(icon){
				d.append('<img src="/images/icon_' + icon + '12.gif"/>');
			}

		}
	)
}




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
