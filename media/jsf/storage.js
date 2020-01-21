import * as Store from 'storage'

//metadata
filter.set_name("JSStorage");
filter.set_desc("JS-based storage filter");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides a very simple javascript inspecter, mostly for test purposes of Javascrip filter bindings");

//exposed arguments
filter.set_arg({ name: "sec", desc: "default section", type: GF_PROP_STRING, def: "testSec"} );
filter.set_arg({ name: "key", desc: "default key", type: GF_PROP_STRING, def: "testKey"} );
filter.set_arg({ name: "value", desc: "default key value", type: GF_PROP_STRING, def: "testVal" } );


filter.initialize = function() {

	let storage = new Store.Storage("TestStore");
	storage.set_option(filter.sec, filter.key, filter.value);
	storage.save();
	storage = null;

	storage = new Store.Storage("TestStore");
	let res = storage.get_option(filter.sec, filter.key);
	if (res == filter.value) return GF_OK;
	return GF_IO_ERR;
}

