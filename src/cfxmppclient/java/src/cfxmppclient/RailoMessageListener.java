package cfxmppclient;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.servlet.ServletException;
import javax.servlet.jsp.PageContext;

import org.jivesoftware.smack.Chat;
import org.jivesoftware.smack.packet.Message;

import org.jivesoftware.smack.MessageListener;
import org.jivesoftware.smack.ChatManagerListener;

import org.jivesoftware.smackx.ChatStateListener;
import org.jivesoftware.smackx.ChatState;
import org.jivesoftware.smackx.filetransfer.FileTransferListener;
import org.jivesoftware.smackx.filetransfer.FileTransferRequest;
import org.jivesoftware.smackx.MessageEventNotificationListener;

import railo.runtime.Component;
import railo.runtime.PageContextImpl;
import railo.loader.engine.CFMLEngineFactory;
import railo.loader.engine.CFMLEngine;

public class RailoMessageListener implements MessageListener, ChatManagerListener, ChatStateListener, FileTransferListener {

	Component listener;
	PageContextImpl pc;

    public void setComponent(Component component, PageContextImpl threadContext) {
		System.out.println("Listener set");
    	listener = component;
        pc = threadContext;
    }
	
	public void processMessage(Chat chat, Message message) {
		System.out.println("Listener Called");
    	try{
	    	listener.call( pc, "processMessage", new Object[]{ chat, message});
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
	}
	
	public void chatCreated(Chat chat, boolean createdLocally) {
		System.out.println("chatCreated listener called");
		try{
			listener.call( pc, "chatCreated", new Object[]{ chat, createdLocally});
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void stateChanged(Chat chat, ChatState state)  {
		System.out.println("chatCreated listener called");
		try{
			listener.call( pc, "stateChanged", new Object[]{ chat, state});
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void fileTransferRequest(FileTransferRequest request)  {
		System.out.println("chatCreated listener called");
		try{
			listener.call( pc, "fileTransferRequest", new Object[]{ request });
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
/*
	@Override
	public void deliver(String from, String recipient, InputStream data) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        data = new BufferedInputStream(data);
        // read the data from the stream
        int current;
        while ((current = data.read()) >= 0)
        {
                out.write(current);
        }
        byte[] bytes = out.toByteArray();
		try {
			listener.call( pc, "deliver", new Object[]{ from, recipient, bytes } );
		} catch (PageException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
*/
}
