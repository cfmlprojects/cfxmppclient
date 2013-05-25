component {

	thisDir = getDirectoryFromPath(getMetaData(this).path);
  	cl = new LibraryLoader(thisDir & "lib/").init();
	jThread = cl.create("java.lang.Thread");
	jSASLAuthentication = cl.create("org.jivesoftware.smack.SASLAuthentication");
	jConnectionConfiguration = cl.create("org.jivesoftware.smack.ConnectionConfiguration");
	jXMPPConnection = cl.create("org.jivesoftware.smack.XMPPConnection");
	jSASLMechanism = cl.create("org.jivesoftware.smack.sasl.SASLMechanism");
	jBase64 = cl.create("org.jivesoftware.smack.util.Base64");
	
	variables.host = "";
	variables.serverport = "";
	variables.userID = "";
	variables.password = "";
	variables.authtype = "";
	variables.secureprotocol = "";
	variables.securerequirement = "";
	variables.callbackURL = "";
	variables.retries = "";
	variables.retryinterval = "";
	variables.onClientOpen = "";
	variables.authenticated = false;
	variables.verbose = "";
	variables.onMessage = "";
	variables.onAddBuddyRequest = "";
	variables.onAddBuddyRequest = "";
	variables.onAddBuddyResponse = "";
	variables.XMPPConnection = "";
	
	function init() {
		variables.host = arguments.host;
		variables.serverport = arguments.serverport;
		variables.userID = arguments.userID;
		variables.password = arguments.password;
		variables.authtype = arguments.authtype;
		variables.callbackURL = arguments.callbackURL;
		variables.connectionhash = "__cfxmppclient" & hash(variables.host & variables.userID & variables.password); 
		return this;
	}

	function _stop() {
	    variables.XMPPConnection.disconnect();
	}

	function _start() {
		if(!structKeyExists(server, variables.connectionhash)) {
			if(variables.authtype == "facebook") {
				initializeFacebook();
			}
			var config = jConnectionConfiguration.init(variables.host, variables.serverport);
			if(variables.authtype == "facebook" || variables.authtype == "sasl") {
				config.setSASLAuthenticationEnabled(true);
			}
			XMPPConnection = jXMPPConnection.init(config);
			//XMPPConnection.DEBUG_ENABLED = true;
			//systemOutput(XMPPConnection.isConnected());
			//systemOutput(XMPPConnection.isAuthenticated());
			server["__cfxmppclient"] = XMPPConnection;
			server["__cfxmppclient"].connect();
		}
		variables.XMPPConnection = server["__cfxmppclient"];
		variables.XMPPConnection.login(variables.userID, variables.password);
	}

	function _getBuddies() {
		var roster = variables.XMPPConnection.getRoster();
		var entries = roster.getEntries().iterator();
		var buddies = [];
		dump(roster);
		while(entries.hasNext()) {
			var entry = entries.next();
			var groupsIt = entry.getGroups().iterator();
			var groups = [];
			while(groupsIt.hasNext()) {
				var groupOb = groupsIt.next();
				var group = {
						name:groupOb.getName(),
						type:groupOb.getEntryCount()
					};
				arrayAppend(groups,group);
			}
			var buddy = {
					name:entry.getName(),
					type:entry.getType().name(),
					status:entry.getStatus(),
					user:entry.getUser(),
					groups:groups 
				};
			arrayAppend(buddies,buddy);
		}
		dump(buddies);
		abort;
	}

	function _sendMessage(userName, message) {
		try {
			chat = variables.XMPPConnection.getChatManager().createChat( userName, null );
			chat.sendMessage( message );
			return true;
		}
		catch (any e) {
			return false;
			e.printStackTrace();
		}
	}

	function _receiveMessage(queueName = "queue.exampleQueue",timeout=1000) {
		var hqsession = "";
		try {
			var hqsession = sf.createSession();
			var messageConsumer = hqsession.createConsumer(queueName);
			var messageReceived = "";
			var started = getTickCount();
			hqsession.start();
			//request.debug("polltime: #timeout#");
			if(timeout > 0) {
				messageReceived = messageConsumer.receive(timeout);
			} else {
				messageReceived = messageConsumer.receive();
			}
			//request.debug("receive took " & getTickCount() - started & "ms");
			if(!isNull(messageReceived)) {
				var cfObject = evaluate(messageReceived.getObjectProperty(CFOBJECT_PROP).toString());
				messageReceived.acknowledge();
				hqsession.close();
				return cfObject;
			} else {
				hqsession.close();
				return false;
			}
		}
		catch (any e) {
			try{ hqsession.close(); } catch(any e) {};
			e.printStackTrace();
		}
	}

	function getFacebookToken(app_id, app_secret, my_url) {
		var dialog_url = "https://www.facebook.com/dialog/oauth?scope=xmpp_login" &
						 "&client_id=" & app_id & "&redirect_uri=" & urlencode(my_url);
		if(!structKeyExists(url,"code") && !variables.authenticated) {
			location(dialog_url);
		} else if (!variables.authenticated) {
			code = url.code;
		}
		var token_url = "https://graph.facebook.com/oauth/access_token?client_id="
			& app_id & "&redirect_uri=" & urlencode(my_url)
			& "&client_secret=" & app_secret
			& "&code=" & code;
		http url=token_url{};
		if(findNoCase("error", cfhttp.filecontent)) {
			var err = deserializeJSON(cfhttp.filecontent);
			throw(message=err.error.message,type="fbcfxmppclient." & err.error.type);
		}
		var token = rereplace(cfhttp.filecontent,".*?access_token=(.*)?&expires.*","\1");
		return token;
	}

	function initializeFacebook() {
		jSASLXFacebookPlatformMechanism = cl.create("cfxmppclient.SASLXFacebookPlatformMechanism");
		if(!jSASLAuthentication.getRegisterSASLMechanisms().contains(jSASLXFacebookPlatformMechanism.getClass())) {
			jSASLAuthentication.registerSASLMechanism("X-FACEBOOK-PLATFORM", jSASLXFacebookPlatformMechanism.getClass());
			jSASLAuthentication.supportSASLMechanism("X-FACEBOOK-PLATFORM",0);
		}
		variables.password = getFacebookToken(variables.userID, variables.password, variables.callbackURL);
	}


	/**
	 * Access point for this component.  Used for thread context loader wrapping.
	 **/

	function onMissingMethod(missingMethodName,missingMethodArguments){
		return callMethod("_"&missingMethodName,missingMethodArguments);
	}

	function callMethod(methodName, args) {
		jThread = cl.create("java.lang.Thread");
		cTL = jThread.currentThread().getContextClassLoader();
		if(findNoCase("railo",server.coldfusion.productname)) {
			jThread.currentThread().setContextClassLoader(cl.GETLOADER().getURLClassLoader());
		}
		variables.switchThreadContextClassLoader = cl.getLoader().switchThreadContextClassLoader;
		return switchThreadContextClassLoader(this.runInThreadContext,arguments,cl.getLoader().getURLClassLoader());
    }
	function runInThreadContext(methodName,  args) {
		try{
			var theMethod = this[methodName];
			return theMethod(argumentCollection=args);
		} catch (any e) {
			try{
				stopServer();
			} catch(any err) {}
			jThread.currentThread().setContextClassLoader(cTL);
			throw(e);
		}
		jThread.currentThread().setContextClassLoader(cTL);
	}


}