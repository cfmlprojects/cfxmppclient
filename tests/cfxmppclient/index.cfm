<cfoutput><a href="?">Refresh</a></cfoutput>
<cfscript>
	config = {
		host : "chat.facebook.com",
		serverport : 5222,
		authtype: "facebook",
		userId: "APP_KEY", // facebook api ex: 172813724786420
		password: "APP_SECRET", // facebook app secret ex: d57afc085hefe6828a352e67867b719f
		callbackURL: "http://" & cgi.host & cgi.script_name
	};

	if(!structKeyExists(server,"myth")) {
		thread action="run" name="mythread" config=config {
			setting requesttimeout=999999999999999;
			try{
				thread.xmpp = new cfxmppclient.gateway.XMPPClient(argumentCollection = config);
				thread.xmpp.start();
			} catch (any e) {
				createObject("java","java.lang.System").out.println("ERRRRR");
				e.printStackTrace();
			}
			while(true) {
				sleep(1000);
			}
		}
		server.myth = mythread;
		sleep(2000);
	}
	xmpp = server.myth.xmpp;
	if(!xmpp.isAuthenticated()) {
		password = xmpp.getFacebookToken(config.userId, config.password, config.callbackURL);
		xmpp.login(config.userId,password);
	}
	buddies = xmpp.getBuddies();
	//chat = xmpp.chat("-830364649@chat.facebook.com");
	//xmpp.stop();
	if(structKeyExists(form,"sendmessage")) {
		xmpp.sendMessage(form.toUser,form.message);
		writeoutput("Sent #form.toUser# #form.message#");
	}
</cfscript>
<cfoutput>
<cfparam name="toUser" default="">
<form action="?" method="post">
	To: <select name="toUser">
		<cfloop array="#buddies#" index="bud">
			<option value="#bud.user#"<cfif toUser == bud.user> selected</cfif>>#bud.name#</option>
		</cfloop>
		</select><br />
	Message:<input type="text" name="message" size="148" />
	<input type="submit" value="send message" name="sendmessage" />
</form>
<cfdump var="#buddies#">
WOOHOO!
</cfoutput>