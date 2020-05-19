# IAM Concepts and Entities

Identity and access management service.

## Concepts

### ServiceProduct

A **ServiceProduct** is designed for a whole service which depended on IAM
service.

### Client

A **Client** is a class of program which relies on IAM service. A Product can
have multiple clients.

There are two types of client: user-facing clients (user agent) and service
clients. By default, each has its own set of operations allowed based on
the services.

The information about the type of client is encoded in the Client ID.

#### User-facing Clients

A user-facing client is an agent of a user.

A client instance receives authorization from the user by authenticating the
user to the service.

#### Service Clients

A service client is designed for applications which need to perform
inter-service operations.

A service client instance authenticates directily to IAM service by showing
Client ID and Client Secret.

### Terminal

A **Terminal** is a bound client installation (instance). Each time a client
instance starts up, it must first authenticate to the IAM service before it
can make most of API calls. Upon sucessful authentication, the client instance
will receive credentials, in form of Terminal ID and Terminal Secret, which
can be exchanged for Access Tokens.

Each time a client instance authenticates, IAM service will generate new
Terminal ID for the client instance.

A terminal will be associated to an user account if the client was
designed for user-facing usage. For service clients, there won't
be user associations.

To authenticate a client, it'll be depended on the client types: for
user-facing client, it requires the user to provide their credentials which
has been previously shared with the IAM service. Service clients will use
static credentials provided by IAM service.

Terminal credentials are long lived. They won't expire (TODO: they should
have expiration, probably 2 or 3 months). They can be revoked either
directly, e.g., remote logout from another terminal, or as an effect of other
operations, e.g., the account which terminal was associated to was deleted.

### Access Token

An **Access Token** is a token which is used as authorization context for most
of API calls.

An access token is short lived. Its expiration time is within hours of minutes
after issued. When an access token is about to expire, the client must
obtain a new access token by using terminal credentials.
