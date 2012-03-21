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
AsyncClient *client [AsyncClient new];
[client start];
```

To receive messages, assign a delegate to the server and/or client, and
implement `server:didReceiveObject:`.

```objc
// assign and implement the server delegate
- (void)server:(AsyncServer *)theServer didReceiveObject:(id)object tag:(uint32)tag {
    // respond to incoming messages here
}
````

To send messages, call `sendObject:tag:` on the server and/or client. The
message object is automatically encoded via
[NSCoding](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/Reference/Reference.html).

```objc
[client sendObject:message tag:0];
```

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
[client sendObject:message responseHandler:^(id response, NSError *error) {
    // react to the response here
}];
```

If you do not want to keep your connections alive longer than necessary, you
should use `AsyncRequest` instead of `AsyncClient`. `AsyncRequest` will connect
to a server, send a request, wait for the response, and disconnect in one call.

```objc
AsyncRequest *request = [AsyncRequest requestWithHost:@"192.168.0.1" port:12345];
request.body = myRequestObject;
[request fireWithCompletionBlock:^(id response, NSError *error) {
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


## Installation for Mac OS X

After compiling the Async Network framework, it can be installed as a shared
framework or embedded inside the host application.

### Compiling the Framework

1. Open AsyncNetwork.xcodeproj with Xcode 4
2. Select the AsyncNetwork Scheme
3. Build an Archive: (Menu) Product -> Archive
4. Extract the Product: (Organizer - Archives) Distribute... -> Save Build
   Products
5. Locate AsyncNetwork.framework inside the exported folder under
   `Library/Frameworks`

### Install as Shared Framework

1. Copy `AsyncNetwork.framework` to `/Library/Frameworks/`
2. Add the framework to your project: (Summary of main target) Click "+"" below
   "Linked Frameworks and Libraries" and select `AsyncNetwork.framework` from the
   list.
3. Add `#import <AsyncNetwork/AsyncNetwork.h>` to any file that uses the
   framework.

Note that AsyncNetwork must be installed as a shared framework on all machines
that run your application.

### Install as Embedded Framework

1. Add a "Copy Files" Build Phase to your main target
2. Change Destination to "Frameworks"
3. Drag `AsyncNetwork.framework` into the empty list of files

This method does not rely on an installed version of the framework but instead
copy AsyncNetwork into the application bundle.


## Installation for iOS

The simple way to use AsyncNetwork in an iOS application is to add all source
files, including AsyncSocket, to your iOS project. Note, that your project
cannot use Automatic Reference Counting using this approach.

Alternatively, you can compile AsyncNetwork as a static library and include it
as a static framework embedded in your iOS application.

### Compile as Static Library

1. Open AsyncNetwork.xcodeproj with Xcode 4
2. Select the AsyncNetworkStatic/iOS Device scheme
3. Build
4. Select the AsyncNetworkStatic/iPhone x.x Simulator scheme
5. Build again

This will create two versions of the compiled library (for simulator and for
device use) into the Xcode build folder (default is: 
`~/Library/Developers/Xcode/DerivedData/AsycnNetwork.../Build/Products/`).

### Build Static Framework

1. Open AsyncNetwork.xcodeproj with Xcode 4
2. Select the AsyncNetworkStaticFramework scheme
3. Build
4. Locate the compiled framework inside the Xcode build folder under
   `Release-static`

### Install as Embedded Static Framework

1. Add CFNetwork to your project: (Summary of main target) Click "+"" below
   "Linked Frameworks and Libraries" and select `CFNetwork.framework` from the
   list.
2. Add a "Copy Files" Build Phase to your main target
3. Change Destination to "Frameworks"
4. Drag `AsyncNetwork.framework` from `Release-static` into the empty list


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