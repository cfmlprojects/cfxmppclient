<cfoutput><a href="?">Refresh</a></cfoutput>
<cfscript>
	config = {
		host : "chat.facebook.com",
		serverport : 5222,
		authtype: "facebook",
		userId: "APIKEY",
		password: "APISECRET",
		callbackURL: "http://" & cgi.host & cgi.script_name
	};
	xmpp = new cfxmppclient.gateway.XMPPClient(argumentCollection = config);
	xmpp.start();

	dump(xmpp.getBuddies());
	//xmpp.sendMessage(xmpp.getBuddies()[1].user,"WOOHOO");
</cfscript>
WOOHOO!