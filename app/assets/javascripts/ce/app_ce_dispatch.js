dispatcher = {
	_registry: {},
	register_listener: function(data_type, callback){
		if(!this._registry[data_type]) this._registry[data_type] = [];
		this._registry[data_type].push(callback)
	},
	dispatch: function(data_type,data){
		var callbacks = this._registry[data_type];
		$.each(callbacks,
			function(){
				this.call(dispatcher, data);
			}
		);
	}
}

function dispatcher_test(data){
	//debugger
	console.log("dispatcher_test " + data);
}

//dispatcher.register_listener('color', dispatcher_test);
//
//dispatcher.dispatch('color', 'red');
//
//dispatcher.register_listener('color', function(data){
//	console.log("the data is " +  data);
//});
//