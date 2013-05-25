component {

    variables.state="stopped";

    public void function init(String id, Struct config, Component listener){
    	variables.id=id;
        variables.config=config;
        variables.listener=listener;
        if(!structKeyExists(server,"cfxmppclient")) {
			server.cfxmppclient = new XMPPClient();
			server.queue = config.queue;
        }
		server.polltime = structKeyExists(config,"polltime") ? config.polltime : 0;
		variables.polltime = server.polltime;
		variables.queue = server.queue;
		variables.cfxmppclient = server.cfxmppclient;
        writelog(text="XMPP Client Gateway [#arguments.id#] initialized", type="information", file="cfxmppclient");
    }

	public void function start() {
		writelog(text = "Starting cfxmppclient queue #variables.config.queue#", type = "information", file = "cfxmppclient");
		sys = createObject("java","java.lang.System");
		try {
			variables.state = "starting";
			cfxmppclient.start();
			writelog(text = "Started cfxmppclient queue #variables.config.queue#", type = "information", file = "cfxmppclient");
			state = "running";
			cfxmppclient.createQueue(queue);
			while (state eq 'running') {
				//request.debug("waiting #variables.polltime#");
				// 0 timeout listens forever, prolly miss shutdown/etc?
				var message = variables.cfxmppclient.receiveMessage(queue,variables.polltime);
				//request.debug("gotmessage:");
				//request.debug(message);
				if(isStruct(message)) {
					//request.debug("fired onmessage!");
					listener.onMessage(message);
				}
				sleep(variables.polltime);
			}
		}
		catch (Any e) {
			variables.state = "failed";
			writelog(text = "#e.message#", type = "fatal", file = "cfxmppclient");
			rethrow;
		}
	}

	public void function stop() {
		writelog(text = "Stopping cfxmppclient queue #variables.config.queue#", type = "information", file = "cfxmppclient");
		try {
			variables.state = "stopping";
			variables.cfxmppclient.stop();
			structDelete(server,"cfxmppclient");
			variables.state = "stopped";
			writelog(text = "Stopped cfxmppclient queue #variables.config.queue#", type = "information", file = "cfxmppclient");
		}
		catch (Any e) {
			variables.state = "failed";
			writelog(text = "#e.message#", type = "fatal", file = "cfxmppclient");
			rethrow;
		}
	}

	public void function restart() {
		writelog(text = "Restarting cfxmppclient queue #variables.config.queue#", type = "information", file = "cfxmppclient");
		if (variables.state EQ "running") {
			stop();
		}
		start();
	}

	public any function getHelper(){
	}

	public String function getState(){
	    return variables.state;
	}

	public any function getServer(){
	    return variables.server;
	}

	function sendMessage(message) {
		variables.cfxmppclient.sendMessage(queue,message);
	}

}