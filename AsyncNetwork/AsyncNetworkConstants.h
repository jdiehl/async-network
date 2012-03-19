/// The standard network response block
typedef void (^AsyncNetworkResponseBlock)(id response, NSError *error);

/// The local loopback address
extern NSString *const AsyncNetworkLocalHost;

/// Default net service type for the AsyncServer
extern NSString *const AsyncNetworkDefaultServiceType;

/// Default net service domain for the AsyncServer
extern NSString *const AsyncNetworkDefaultServiceDomain;

/// Default connection timeout for the AsyncConnection
#define AsyncNetworkDefaultConnectionTimeout -1.0

/// Default net service resolve timeout for the AsyncConnection
#define AsyncNetworkDefaultResolveTimeout -1.0

/// Default broadcasting address for the AsyncBroadcaster
extern NSString *const AsyncNetworkBroadcastDefaultSubnet;

/// Default broadcasting timeout for the AsyncBroadcaster
#define AsyncNetworkBroadcastDefaultTimeout -1.0

/// Default timeout for the AsyncRequest
#define AsyncRequestDefaultTimeout -1.0
