//// Inspired by base2 and Prototype
(function(){
  var initializing = false, fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;
  // The base Class implementation (does nothing)
  this.Class = function(){};
  
  // Create a new Class that inherits from this class
  Class.extend = function(prop) {
    var _super = this.prototype;
    
    // Instantiate a base class (but only create the instance,
    // don't run the init constructor)
    initializing = true;
    var prototype = new this();
    initializing = false;
    
    // Copy the properties over onto the new prototype
    for (var name in prop) {
      // Check if we're overwriting an existing function
      prototype[name] = typeof prop[name] == "function" && 
        typeof _super[name] == "function" && fnTest.test(prop[name]) ?
        (function(name, fn){
          return function() {
            var tmp = this._super;
            
            // Add a new ._super() method that is the same method
            // but on the super-class
            this._super = _super[name];
            
            // The method only need to be bound temporarily, so we
            // remove it when we're done executing
            var ret = fn.apply(this, arguments);        
            this._super = tmp;
            
            return ret;
          };
        })(name, prop[name]) :
        prop[name];
    }
    
    // The dummy class constructor
    function Class() {
      // All construction is actually done in the init method
      if ( !initializing && this.initialize )
        this.initialize.apply(this, arguments);
    }
    
    // Populate our constructed prototype object
    Class.prototype = prototype;
    
    // Enforce the constructor to be what we expect
    Class.constructor = Class;

    // And make this class extendable
    Class.extend = arguments.callee;
    
    return Class;
  };
})();

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

/***
 * APE JSF Setup
 */

var APE = {
	Config: {
		identifier: 'ape',
		init: true,
		frequency: 0,
		scripts: [],
		use_compressed: (params['ape'] && params['ape'] == 'uncomp') ?  false : true, //(params['ape'] && params['ape'] == 'comp') ? true : $.browser.msie ?  false : true,
		use_session: true
	}
};

console.log("APE.Config.use_compressed: " + APE.Config.use_compressed)

//APE.Config.baseUrl = 'http://dev-proxy:3000/javascripts/APE-Source/'; //APE JSF 
APE.Config.baseUrl = 'http://' + document.location.host + '/javascripts/APE-Source/'; //APE JSF 
//APE.Config.domain = 'dev-proxy.com'; 
APE.Config.domain = document.location.host; 
//APE.Config.server = 'ape.dev-proxy.com:6969'; //APE server URL
APE.Config.server = 'ape1.civicevolution.org'; //APE server URL
APE.Config.transport = 2;  // 2 is JSONP


if(APE.Config.use_compressed){
	if(APE.Config.use_session){
		APE.Config.scripts = [APE.Config.baseUrl + 'apeCoreSession.comp.js']
	}else{
		// ape without session
		APE.Config.scripts = [APE.Config.baseUrl + 'apeCore.comp.js']
	}
}else{
	if(APE.Config.use_session){
		(function(){
			for (var i = 0; i < arguments.length; i++)
				APE.Config.scripts.push(APE.Config.baseUrl + arguments[i] + '.js?id=' + Math.round(Math.random()*100000000));
		})('mootools-core', 'Core/APE', 'Core/Events', 'Core/Core','Core/Session', 'Pipe/Pipe', 'Pipe/PipeProxy', 'Pipe/PipeMulti', 'Pipe/PipeSingle', 'Request/Request','Request/Request.Stack', 'Request/Request.CycledStack', 'Transport/Transport.longPolling','Transport/Transport.SSE', 'Transport/Transport.XHRStreaming', 'Transport/Transport.JSONP', 'Core/Utility', 'Core/JSON');
	}else{
		(function(){
			for (var i = 0; i < arguments.length; i++)
				APE.Config.scripts.push(APE.Config.baseUrl + arguments[i] + '.js?id=' + Math.round(Math.random()*100000000));
		})('mootools-core', 'Core/APE', 'Core/Events', 'Core/Core','Pipe/Pipe', 'Pipe/PipeProxy', 'Pipe/PipeMulti', 'Pipe/PipeSingle', 'Request/Request','Request/Request.Stack', 'Request/Request.CycledStack', 'Transport/Transport.longPolling','Transport/Transport.SSE', 'Transport/Transport.XHRStreaming', 'Transport/Transport.JSONP', 'Core/Utility', 'Core/JSON');		
	}
}


//APE.Client = new Class({
APE.Client = Class.extend({

	_ver: 'ape client',
		
	eventProxy: [],

	fireEvent: function(type, args, delay){
		return this.core.fireEvent(type, args, delay);
	},

	addEvent: function(type, fn, internal){
		//console.log("client addEvent type: " + type + ", fn: " + fn)
		var newFn = fn.bind(this), ret = this;
		if( this.core == undefined) this.eventProxy.push([type, fn, internal]);
		else {
			ret = this.core.addEvent(type, newFn, internal);
			this.core.$originalEvents[type] = this.core.$originalEvents[type] || [];
			this.core.$originalEvents[type][fn] = newFn;
		}
		return ret;
	},

	onRaw: function(type, fn, internal) {
		return this.addEvent('raw_' + type.toLowerCase(), fn, internal); 
	},

	removeEvent: function(type, fn) {
		return this.core.removeEvent(type, fn);
	},

	onCmd: function(type, fn, internal) {
		return this.addEvent('cmd_' + type.toLowerCase(), fn, internal); 
	},

	onError: function(type, fn, internal) {
		return this.addEvent('error_' + type, fn, internal); 
	},

	load: function(config){	
		config = $.extend({}, APE.Config, config);
		config.init = function(core){
			this.core = core;
			for(var i = 0; i < this.eventProxy.length; i++){
				this.addEvent.apply(this, this.eventProxy[i]);
			}
		}.bind(this);
		
		
		
		//set document.domain
		if (config.transport != 2 && config.domain != 'auto') document.domain = config.domain;
		if (config.domain == 'auto') document.domain = document.domain;

		//var tmp	= JSON.decode(Cookie.read('APE_Cookie'), {'domain': document.domain});
		var tmp = $.cookies.get('APE_Cookie', {'domain': document.domain}); 
		if(tmp && tmp != 'null' && tmp != 'undefined') {	
			if( typeof tmp == 'string') tmp = $.evalJSON( tmp )
			try{
				config.frequency = Number(tmp.frequency) + 1;
			}catch(e){ config.frequency = 0 }
			if(isNaN(config.frequency))config.frequency = 0;
			tmp.frequency = config.frequency;
		} else {
			config.frequency = 0;
			tmp = {'frequency': 0};
		}

		$.cookies.set('APE_Cookie', $.toJSON(tmp), {'domain': document.domain});
				

		
		//console.log("APE-init.load create iframe")
		var i = $('<iframe/>').addClass('ape').attr('id','ape_' + config.identifier)
		$('body').append(i);
		var iframe = i[0]

		$('iframe').load(function () { 
			if (!iframe.contentWindow.APE){
				 setTimeout(iframe.onload, 100);//Sometimes IE fire the onload event, but the iframe is not loaded -_-
			}else{
				iframe.contentWindow.APE.init(config);
			} 
	  });


		//console.log("APE-init.load config.transport: " + config.transport)
		if (config.transport == 2) {//Special case for JSONP
			var doc = iframe.contentDocument;
			if (!doc) doc = iframe.contentWindow.document;

			//If the content of the iframe is created in DOM, the status bar will always load...
			//using document.write() is the only way to avoid status bar loading with JSONP
			doc.open();
			var theHtml = '<html><head>';
			for (var i = 0; i < config.scripts.length; i++) {
				theHtml += '<script src="' + config.scripts[i] + '" type="text/javascript"></script>';
			}
			theHtml += '</head><body></body></html>';
			doc.write(theHtml);
			doc.close();
		} else { 
			iframe.set('src', 'http://' + config.frequency + '.' + config.server + '/?[{"cmd":"script","params":{"domain":"' + document.domain + '","scripts":["' + config.scripts.join('","') + '"]}}]');
			if($.browser.mozilla) {
				// Firefox fix, see bug  #356558 
				// https://bugzilla.mozilla.org/show_bug.cgi?id=356558
				iframe.contentWindow.location.href = iframe.get('src');
			}
		}	

		
	}
	
	
	
});
