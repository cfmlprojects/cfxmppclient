component {

	thisDir = getDirectoryFromPath(getMetaData(this).path);
  	cl = new LibraryLoader(thisDir & "lib/",true).init();
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
	variables.chats = {};
	variables.XMPPConnection = "";
	
	function init() {
		for(var arg in arguments) {
			variables[arg] = arguments[arg];
		}
		variables.connectionhash = "__cfxmppclient" & hash(variables.host & variables.userID & variables.password);
		return this;
	}

	function _disconnect() {
	    variables.XMPPConnection.disconnect();
		variables.authenticated = false;
	}

	function _stop() {
		createObject("java","java.lang.System").out.println("Stopping...");
		_disconnect();
	}

	private function getConnection() {
		if(!structKeyExists(server, variables.connectionhash)) {
			if(variables.authtype == "facebook") {
				initializeFacebook();
			}
			var config = jConnectionConfiguration.init(variables.host, variables.serverport);
			if(variables.authtype == "facebook" || variables.authtype == "sasl") {
				config.setSASLAuthenticationEnabled(true);
			}
			variables.XMPPConnection = jXMPPConnection.init(config);
			//XMPPConnection.DEBUG_ENABLED = true;
			server[variables.connectionhash] = {
				connection = variables.XMPPConnection,
				pc = getPageContext() };
		}
		variables.XMPPConnection = server[variables.connectionhash].connection; 
		return variables.XMPPConnection;
	}

	function _start() {
		createObject("java","java.lang.System").out.println("Starting...");
		variables.XMPPConnection = getConnection();
	}

	function _connect() {
		variables.XMPPConnection = getConnection();
		if(!variables.XMPPConnection.isConnected()) {
			variables.XMPPConnection.connect();
		}
	}

	function _isConnected() {
		variables.XMPPConnection = getConnection();
		return variables.XMPPConnection.isConnected();
	}

	function _isAuthenticated() {
		variables.XMPPConnection = getConnection();
		return variables.XMPPConnection.isAuthenticated();
	}

	function _login(userID=variables.userId, password= variables.password) {
		variables.XMPPConnection = getConnection();
		if(variables.XMPPConnection.isConnected()) {
			_disconnect();
		}
		_connect();
		variables.XMPPConnection.login(userID, password);
	}

	function _getUser() {
		var user = getConnection().getUser();
		return isNull(user) ? "" : user;
	}

	function _getBuddies() {
		var roster = getConnection().getRoster();
		var entries = roster.getEntries().toArray();
		var buddies = [];
		for(var entry in entries) {
			var groups = [];
			for(var groupOb in entry.getGroups().toArray()) {
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
		return buddies;
	}

	function _chat(user, message="") {
		//var listener = createDynamicProxy(new MessageListener(), ["org.jivesoftware.smack.MessageListener"]);
		var chat = getConnection().getChatManager().createChat( user , javacast("null",""));
		var listener = cl.create("cfxmppclient.RailoMessageListener").init();
		listener.setComponent(new MessageListener().init(),server[variables.connectionhash].pc);
		chat.addMessageListener(listener);
		if(len(message)) {
			chat.sendMessage( message );
		}
		//arrayAppend(variables.chats[variables.connectionhash],chat);
		return chat;
	}

	function _randomJavaTests() {
		tl = cl.create("com.googlecode.transloader.Transloader").DEFAULT;
		//tl = createObject("java","com.googlecode.transloader.Transloader").DEFAULT;
		jMessageListener = cl.getLoader().getURLClassLoader().loadClass("org.jivesoftware.smack.MessageListener");
		jCListen = cl.create("org.jivesoftware.smack.MessageListener");
		var pc = getPageContext();
		jRListener = cl.create("cfxmppclient.RailoMessageListener").init(pc,this);
		var railoCL = pc.getConfig().getClassLoader();
		var cfListener = new MessageListener();
		var someObjectWrapped = tl.wrap(jRListener);
		//someObjectWrapped.cloneWith(railoCL);
		//var listener = createDynamicProxy(new MessageListener(), ["org.jivesoftware.smack.MessageListener"]);
		var pc2 = javaCast("railo.runtime.PageContextImpl",pc);
		dump(someObjectWrapped);
		dump(pc.class.getClassLoader());
		someObjectWrapped.getClass("org.jivesoftware.smack.MessageListener",cl.getLoader().getURLClassLoader());

		classUtil = CreateObject("java","railo.commons.lang.ClassUtil");
		caster = CreateObject("java","railo.runtime.op.Caster");
		objStringClass = CreateObject("java","java.lang.Class").GetClass();
		objReflect = CreateObject("java","java.lang.reflect.Array");
		arrJavaValue = objReflect.NewInstance(objStringClass,JavaCast( "int",1 ));
		objReflect.Set(arrJavaValue, JavaCast( "int",0 ), 
			classUtil.loadClass(cl.getLoader().getURLClassLoader(),"org.jivesoftware.smack.MessageListener")
		); 
//dump(caster);
		var JavaProxyFactory = createObject("java","railo.transformer.bytecode.util.JavaProxyFactory");
		
		dump(JavaProxyFactory);
		dump(pc.getConfig());

		//wee = JavaProxyFactory.createProxy(pc2.getConfig(),cfListener, nullValue(), arrJavaValue);
		throw("FUUUUK");
		var listener = createDynamicProxy(new MessageListener(), ["org.jivesoftware.smack.MessageListener"]);
		var chat = variables.XMPPConnection.getChatManager().createChat( userName, listener );
		arrayAppend(variables.chats[variables.connectionhash],chat);
		chat.sendMessage( message );
		return true;
	}

	function _sendMessage(user, message) {
		try {
			return _chat(user,message);
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
				_stop();
			} catch(any err) {}
			jThread.currentThread().setContextClassLoader(cTL);
			throw(e);
		}
		jThread.currentThread().setContextClassLoader(cTL);
	}


}