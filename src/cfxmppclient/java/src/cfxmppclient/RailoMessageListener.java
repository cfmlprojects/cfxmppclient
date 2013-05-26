package cfxmppclient;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.servlet.ServletException;
import javax.servlet.jsp.PageContext;

import org.jivesoftware.smack.MessageListener;
import org.jivesoftware.smack.Chat;
import org.jivesoftware.smack.packet.Message;

import railo.runtime.Component;
import railo.runtime.PageContextImpl;
import railo.loader.engine.CFMLEngineFactory;
import railo.loader.engine.CFMLEngine;

public class RailoMessageListener implements MessageListener {

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
