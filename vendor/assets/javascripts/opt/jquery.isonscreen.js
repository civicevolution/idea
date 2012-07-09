/* Copyright (c) 2010 
 * @author Laurence Wheway
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * @version 1.1.0
 */
(function($) {
	jQuery.extend({
		isOnScreen: function( box ) {
			//ensure numbers come in as intgers (not strings) and remove 'px' is it's there
			box.left = parseFloat(box.left);
			box.top = parseFloat(box.top);
			box.width = parseFloat(box.width);
			box.height = parseFloat(box.height);

			if(	box.left+box.width-$(window).scrollLeft() > 0 && 
				box.left < $(window).width()+$(window).scrollLeft() && 
				box.top+box.height-$(window).scrollTop() > 0 &&
				box.top < $(window).height()+$(window).scrollTop()
			) return true;			
			return false;
		}
	})


	jQuery.fn.isOnScreen = function () {		
		if(	$(this).offset().left+$(this).width()-$(window).scrollLeft() > 0 && 
			$(this).offset().left < $(window).width()+$(window).scrollLeft() && 
			$(this).offset().top+$(this).height()-$(window).scrollTop() > 0 &&
			$(this).offset().top < $(window).height()+$(window).scrollTop()
		) return true;
		return false;
	}
})(jQuery);
