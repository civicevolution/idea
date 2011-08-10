/// <reference path="jquery-1.4.2.min.js"/>
/*
@author Dan Gidman
released under GNU General Public License v3
http://www.gnu.org/licenses/gpl.html
version 1.1
Updated to be called inView
September 2, 2010
*/
(function ($) {
    j = jQuery;
    $.fn.inView = function () {
        /// <summary>Filter that checks if the item(s) is visible within the page. Returns set of visible elements</summary>
        /// <returns type="jQuery" />
        // sanity check aborts when no elements visible
        return this.filter(":visible").filter(function () {
            var add = true, 
                elem = this, 
                p = $(this).parents().filter(function () {
                    return (this.scrollHeight > this.offsetHeight || this.scrollWidth > this.offsetWidth);
                }); // select only scrollable parents
            // loop through the parent elements checking that each 
            // scrollable element is visible in parent.
            for (var i = 0; i < p.length; ++i) {
                var vp = j(p[i]), v = { 
                    t: vp.scrollTop(),
                    b: vp.scrollTop() + vp.height(),
                    l: vp.scrollLeft(),
                    r: vp.scrollLeft() + vp.width()
                }, el = j(elem), e = {
                    t: elem.offsetTop,
                    b: elem.offsetTop + el.height(),
                    l: elem.offsetLeft,
                    r: elem.offsetLeft + el.width()
                };
                elem = p[i];
                if (!(add = add && ( v.t < e.b && v.b > e.t && v.l < e.r && v.r > e.l ))) break;
            }
            return add;
        });
    };
    $.extend($.expr[':'], { "in-view": function(a, i, m) { return $(a).visible().length > 0; } });
})(jQuery);