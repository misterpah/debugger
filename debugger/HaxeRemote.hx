/** **************************************************************************
 * HaxeRemote.hx
 *
 * Copyright (c) 2013 by the contributors
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following condition is met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.
 ************************************************************************** **/

package debugger;

import debugger.HaxeProtocol;
import debugger.IController;


/**
 * This class creates a networked command-line debugger that communicates with
 * a peer using Haxe serialization format.  This class should be instantiated
 * int the main() function of any program that wishes to be debugged via a
 * remote interface.
 **/
class HaxeRemote implements IController
{
    /**
     * Creates a debugger which will read input from the interface provided
     * by the given remote host, and emit output to that remote host.
     *
     * If the program was not compiled with debugging support, a String
     * exception is thrown.
     *
     * @param startStopped if true, when the breakpoint starts, all other
     *        threads of the process are stopped until the user instructs the
     *        debugger to continue those threads.  If false, all threads of
     *        the program will continue to run when the debugger is started
     *        and will not stop until a debugger command instructs them to do
     *        so.
     * @param host is the host name of the debugging server to connect to
     * @param port is the port of the debugging server to connect to
     **/
    public function new(startStopped : Bool, host : String, port : Int = 6972)
    {
        mHost = host;
        mPort = port;
        mSocket = null;

        mThread = new DebuggerThread(this, startStopped);
    }

    public function getNextCommand() : Command
    {
        while (true) {
            // Connect on demand ...
            if (mSocket == null) {
                this.connect();
                Sys.println("Connected to debugging server at " + 
                            mHost + ":" + mPort + ".");
            }

            try {
                return HaxeProtocol.readCommand(mSocket.input);
            }
            catch (e : Dynamic) {
                Sys.println("Failed to read command from server at " + 
                            mHost + ":" + mPort + ": " + e);
                Sys.println("Closing connection and trying again.");
                mSocket.close();
                mSocket = null;
            }
        }
    }

    /**
     * Called when the debugger has a message to deliver.  Note that this may
     * be called by multiple threads simultaneously if an asynchronous thread
     * event occurs.  The implementation should probably lock as necessary.
     *
     * @param message is the message
     **/
    public function acceptMessage(message : Message) : Void
    {
        // Write it to the socket
        HaxeProtocol.writeMessage(mSocket.output, message);
    }

    private function connect()
    {
        mSocket = new sys.net.Socket();
        while (true) {
            try {
                var host = new sys.net.Host(mHost);
                if (host.ip == 0) {
                    throw "Name lookup error.";
                }
                mSocket.connect(host, mPort);
                HaxeProtocol.writeClientIdentification(mSocket.output);
                HaxeProtocol.readServerIdentification(mSocket.input);
                return;
            }
            catch (e : Dynamic) {
                Sys.println("Failed to connect to debugging server at " +
                            mHost + ":" + mPort + " : " + e);
            }
            Sys.println("Trying again in 3 seconds.");
            Sys.sleep(3);
        }
    }

    private var mHost : String;
    private var mPort : Int;
    private var mSocket : sys.net.Socket;
    private var mThread : DebuggerThread;
}
