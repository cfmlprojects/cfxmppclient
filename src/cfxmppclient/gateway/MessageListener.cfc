component {
	public function init() {
		return this;
	}
	
	public function processMessage(chat,message) {
		createObject("java","java.lang.System").out.println("Received message: " & message.getBody());
		// echo back what was said
		chat.sendMessage(message.getBody());
	}

	public function chatCreated(chat,createdLocally) {
		createObject("java","java.lang.System").out.println("Chat created!");
	}

	public function stateChanged(chat,state) {
		createObject("java","java.lang.System").out.println("Changed state!");
	}

	public function fileTransferRequest(req) {
		createObject("java","java.lang.System").out.println("File Transfer Req!");
	}
}