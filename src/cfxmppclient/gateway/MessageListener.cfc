component {
	public function init() {
		return this;
	}
	
	public function processMessage(chat,message) {
		createObject("java","java.lang.System").out.println("Received message: " & message.getBody());
		// echo back what was said
		chat.sendMessage(message.getBody());
	}
}