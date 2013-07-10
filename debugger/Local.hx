/** **************************************************************************
 * Local.hx
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


/**
 * This class creates a local command-line debugger.  This class should be
 * instantiated in the main() function of any program that wishes to be
 * debugged via the local command line.
 **/
class Local
{
    /**
     * Creates a debugger which will read input from the command line and
     * emit output to the terminal.
     *
     * If the program was not compiled with debugging support, a String
     * exception is thrown.
     *
     * @param startStopped if true, when the debugger starts, all other
     *        threads of the process are stopped until the user instructs the
     *        debugger to continue those threads.  If false, all threads of
     *        the program will continue to run when the debugger is started
     *        and will not stop until a debugger command instructs them to do
     *        so.
     **/
    public function new(startStopped : Bool)
    {
        mController = new CommandLineController();
        mThread = new DebuggerThread(mController, startStopped);
    }

    private var mController : CommandLineController;
    private var mThread : DebuggerThread;
}
