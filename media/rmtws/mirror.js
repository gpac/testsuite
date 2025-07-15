import { Sys as sys } from 'gpaccore'

sys.enable_rmtws();

sys.rmt_on_new_client = function(client) {

	client.on_data = (msg) =>  {
		client.send(msg);
	}

	client.on_close = function() {
        session.abort();
	}
}