![Pod Version](https://img.shields.io/cocoapods/v/AsyncNetwork.svg?style=flat)

Async Network is a framework for socket networking on COCOA or iOS based on
[AsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket).

## Quick Start

### Client-Server Networking

In client-server networking, clients connect to servers to exchange messages.
In AsyncNetwork, every client will automatically connect to every discovered
server with the same service name. Servers are discovered using
[Bonjour](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/NetServices/Articles/about.html).

In the server process, create an AsyncServer instance, define the Bonjour
service name and start the server.

```objc
AsyncServer *server = [AsyncServer new];
server.serviceName = @"MyServer";
[server start];
```

In the client process, create an AsyncClient instance, and start it. It will
automatically connect to any discovered servers.

```objc
AsyncClient *client = [AsyncClient new];
[client start];
```

To receive messages, assign a delegate to the server and/or client, and
implement `server:didReceiveCommand:object:`.

```objc
server.delegate = myController;

// in MyController.m
- (void)server:(AsyncServer *)theServer didReceiveCommand:(AsyncCommand)command object:(id)object {
    // respond to incoming messages here
}
````

To send messages, call `sendCommand:object:` on the server and/or client. The
message object is automatically encoded via
[NSCoding](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/Reference/Reference.html).

```objc
[client sendCommand:command object:message];
```

Command is a 32bit number that can be used to identify the type of message being sent.

### Peer-To-Peer Networking

In peer-to-peer networking, every peer can exchange messages with every other
peer on the network. To implement peer-to-peer networking on AsyncNetwork, you
may either use the `AsyncBroadcaster` or have every peer instantiate an
`AsyncServer` and a `AsyncClient`.

With the `AsyncBroadcaster` messages can be send to all peers on the same
subnet. The broadcaster can only send binary data (NSData) and it is not
guaranteed that the data arrives in order.

```objc
AsyncBroadcaster *broadcaster = [AsyncBroadcaster new];
[broadcaster start];
[broadcaster broadcast:data];
```

If you create many servers and clients on your network to implement
peer-to-peer networking this way, you may benefit from disabling the
automatic connection feature of the client. This way, you can initiate a
network connection only as needed, which is especially beneficial if your
plan to implement request-based peer-to-peer networking.

### Request-Based Networking

In request-based networking, a server listens for requests from clients and
sends a response that is bound to the original request. HTTP servers are
implemented this way.

To send a request call `sendObject:responseHandler:` on a client and provide a
block that is called with the server's response to the request.

```objc
[client sendCommand:command object:message responseHandler:^(id<NSCoding> response) {
    // react to the response here
}];
```

On the server, you must implement the delegate method
`server:didReceiveCommand:object:connection:responseBlock:`

```objc
- (void)server:(AsyncServer *)theServer didReceiveCommand:(AsyncCommand)command object:(id)object connection:(AsyncConnection *)connection responseBlock:(AsyncNetworkResponseBlock)block;
	id<NSCoding> yourResponse = ...;
	block(yourResponse);
}
```

If you do not want to keep your connections alive longer than necessary, you
should use `AsyncRequest` instead of `AsyncClient`. `AsyncRequest` will connect
to a server, send a request, wait for the response, and disconnect in one call.

```objc
[AsyncRequest fireRequestWithHost:@"192.168.0.1" port:12345 command:0 object:message responseBlock:^(id<NSCoding> response, NSError *error) {
    // react to the response here
}];
```

## Examples

Examples are located in `Examples/`. Install AsyncNetwork as a shared framework
before running an example.

### Broadcaster

Broadcaster demonstrates the use of AsyncBroadcaster to broadcast messages to
multiple recipients over the local network.

### ClientServer

ClientServer demonstrates how AsyncClient and AsyncServer are set up to
automatically connect to each other and exchange messages. You can create
more servers with CMD-1 and more clients with CMD-2.

### MobileClient

MobileClient demonstrates how to use AsyncNetwork on iOS. It creates a single
AsyncClient that automatically connects to any servers created from
the ClientServer example.

### Request

Request demonstrates the use of AsyncRequests to implement request-based
networking.

### Notify

Notify demonstrates sending a broadcast from a ruby or node server to an iOS
client. This can be used as a local notification to trigger an update on the
mobile client.


## Installation

Check out the submodules (AsyncSocket):

    git submodule init
    git submodule update

Compile AsyncNetwork (requires Xcode Command Line Tools):

    run `make`

This will compile AsyncNetwork for Mac and iOS.
The compiled AsyncNetwork Framework can be directly imported into your project:

1. Drag `AsyncNetwork.framework` or `AsyncNetworkIOS.framework` to your project
2. Add a "Copy Files" Build Phase to your main target
3. Change Destination to "Frameworks"
4. Drag the included framework into the list of files

### Cocoapods

Add this to your podfile:

    pod 'AsyncNetwork'


## License (MIT)

Copyright (C) 2012 Jonathan Diehl. RWTH Aachen University.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
