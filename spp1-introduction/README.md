# SPP 1 -- Introduction to the Safeguard API

Safeguard for Privileged Passwords (SPP) is built as a secure, hardened
appliance to provide protection for passwords and private keys. In addition to
storing these credentials, SPP automates the management of the credentials in
the environment, which helps regulatory compliance and security. To access
passwords, private keys, and sessions, SPP provides a role-bashed policy model
and access request workflow. SPP maintains and indelible audit log of all
details of credential access, credential management, and configuration changes.

Because it is a secure, hardened appliance, all of the functionality of SPP is
exposed only through the Safeguard API. There is no direct console access.
There are no backdoors. There no special internal interfaces that only One
Identity can use. All of the functionality that you see in the SPP UI is
presented based on interactions with the Safeguard API.

![API Clients](api-clients.png)

This means that there is nothing that you cannot do with the Safeguard API
that you can do in the SPP UI.

## Clusters

SPP is delivered as an appliance, which can cause people to think that the
appliance is the product. In reality, SPP is almost never deployed as a single
appliance. In fact, One Identity very much recommends that you only deploy SPP
as a cluster of three or five appliances. The reason for this is that the SPP
application is actually served as a cluster. All of the appliances is in the
cluster have all of the data. The most critical services such as access request
workflow, credential management, and auditing are provided from every appliance
in the cluster. There is a primary appliance that is used for making
configuration changes, but any appliance in the cluster can be modified to
assume the primary role.

![SPP Cluster](cluster.png)

When thinking of SPP product functionality, it is important to think of it as
a highly available, redundant, fully consistent cluster solution rather than a
purpose-built 1U appliance sitting in your data center.

SPP clusters are also built to work with Safeguard for Privileged Sessions
(SPS) appliances and clusters. SPP and SPS clusters can be joined together to
allow SPP access request workflow and credentials to be used with SPS sessions.

![Cluster Join](cluster-join.png)

SPP and SPS actually do not share a single Safeguard API. Each product has a
separate Safeguard API. They differ in authentication, versioning scheme, and
API basic endpoint design. In the future SPP and SPS will share a single
authentication strategy. There will always be differences between SPP and SPS
Safeguard APIs, but over time they will become more alike.

## Virtual Appliances

SPP provides hardware and virtual appliances. SPP hardware appliances and SPP
virtual appliances do not cluster together. The reason for this is that the
hardware version of SPP is the most secure embodiment of SPP. It is secured in
such a way that it isn't even vulnerable to the administrators who install it.
Not even One Identity can break into a hardened SPP hardware appliance. The
same is not true of SPP virtual appliances. It is not possible to completely
secure SPP virtual appliances from the administrators who control the
hypervisor where it is deployed. These hypervisor administrators have direct
access to the virtual disks and virtual memory of a running SPP virtual
appliance. However, there are some best practices for securing an SPP virtual
appliance cluster.

![Virtual](virtual.png)

## Authenticating to the Safeguard API

SPP includes a secure token service (STS) that is actually a redistributable
component that appears in other One Identity products. This redistributable
secure token service (rSTS) handles the initial authentication to SPP. It
handles a wide variety of identity providers and authentication mechanisms.
SPP supports everything from local authentication using a local SPP user to
Active Directory users to federated IDPs and FIDO2. It supports RADIUS,
smart cards, and also 2FA via multiple mechanisms.

Authenticating to use the Safeguard API is a two step process. The initial
authentication is against the rSTS which results in an rSTS token (JWT). This
rSTS token is then exchanged for a Safeguard API token.

![SPP Auth Process](spp-auth-process.png)

rSTS authentication uses OAuth 2.0. Our rSTS supports several different grant
types. **Authorization code grant** is used by the SPP desktop UI, the `-Gui`
parameter in safeguard-ps, and SafeguardDotNet.GuiLogin. **Implicit grant** is
used by the SPP web UI. **Resource owners grant** is used by most of our open
source projects such as safeguard-ps, safeguard-bash, SafeguardJava, and
SafeguardDotNet.

rSTS tokens and Safeguard API tokens are JWT bearer tokens. These tokens are
embedded in the HTTP Authorization header of the HTTP requests that are sent
to the Safeguard API.

```
Authorization: Bearer <token>
```

## Calling Safeguard API Services

The Safeguard API is a REST-based API. Safeguard API endpoints are called using
HTTP operators and JSON (or XML) requests and responses. The Safeguard API is
documented using Swagger. You may use Swagger UI to call the API directly or to
read the documentation about URLs, parameters, and payloads.

To access the Swagger UI use a browser to navigate to:
`https://<address>/service/<service>/swagger`

- `<address>` = Safeguard network address
- `<service>` = Safeguard service to use

The Safeguard API is made up of multiple services: core, appliance, notification,
event, and a2a.  E

|Service|Description|
|-|-|
|core|Most product functionality is found here. All cluster-wide operations: access request workflow, asset management, policy management, etc.|
|appliance|Appliance-specific operations, such as setting IP address, maintenance, backups, support bundles, appliance management|
|notification|Anonymous, unauthenticated operations. This service is available even when the appliance isn't fully online|
|event|Specialized endpoint for connecting to SignalR for real-time events|
|a2a|Application integration specific operations. Fetching passwords, making access requests on behalf of users, etc.|

The Safeguard API is protected by TLS. SPP ships with a built-in self-signed
certificate that should be replaced with a legitimate TLS certificate that is
trusted in your organization.

Given a Safeguard API token, you can call the Safeguard API using any HTTP
client. An example using cURL where the `$tok` contains a Safeguard API token
and `-k` is specified to avoid complaints about a self-signed certificate:

```Bash
curl -k -X GET --header 'Accept: application/json' --header "Authorization: Bearer $tok" 'https://sps1.petrsnd.org/service/core/v3/Users'
```

The resulting HTTP request looks like this:

```Text
0000: GET /service/core/v2/Users HTTP/1.1
0025: Host: sg-vm1.dan.vas
003b: User-Agent: curl/7.55.1
0054: Accept: application/json
006e: Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjBGRDREOEIyRD
00ae: M5NzFFM0MxODgzOTY0MUZDMkM2QTFBNkZCQzA0M0UiLCJ0eXAiOiJKV1QiLCJ4NX
00ee: QiOiJEOVRZc3RPWEhqd1lnNVpCX0N4cUdtLThCRDQifQ.eyJBY3R1YWxVc2VySWQ
012e: iOiIxIiwiQXV0aFRva2VuSWQiOiIxYTlkODI2Yy02MGEwLTQ4NTktODQ5Zi1lNzF
016e: lYTdjZjgzZjEiLCJyc3RzOnN0czpjbGFpbXM6dXNlcjp1c2VySWQiOiIxIiwidXB
01ae: uIjoiR3ViZXIiLCJhdXRobWV0aG9kIjoibG9jYWw6cHdkIiwibmFtZWlkIjoiR3V
01ee: iZXIiLCJuYmYiOjE1Njk0MzAyNzEsImV4cCI6MTU2OTUxNjY3MSwiaWF0IjoxNTY
022e: 5NDMwMjcxLCJpc3MiOiJ1cm46dG9rZW5hdXRoZW50aWNhdGlvbnByb3ZpZGVyOlN
026e: BRkVHVUFSRF9BUFBMSUFOQ0UifQ.TBwWszbKxc4AKSM9Z-bErqkXe_x84-xd-fng
02ae: v-GIp4KbschbUuEuxFmB_LItcJBIXbk402KaZx4lTBjeO-qSlRdwurAlzWyp0QFo
02ee: Vg11GVN7zbTAkfO-H3IIws9usXkTdoYFNGkmhot4NqmTGtHGx1bHSEbpbryWTzzi
032e: 2SWxe0QP7L8cHRAH9ZJL77n3dqR8CHQX_JM4uMWmh-rgnqyJlhetMZ-Af0M_a_KA
036e: 8IzZdGmCFd-NC8YgIW48_w0gJpM5qZCHG5rt1yOuqP6cbRB6hfOKko74Tkj63MuH
03ae: tnKHGK9oLzZ9z03bZJyB1UHQTjQmj2naftwhjmiiX7TOg-CE3Q
03e2: 
```

Safeguard API uses URL versioning. The current version is "v3". The previous
version "v2" is also supported, and in many cases, the endpoints are
equivalent. However, it is recommended that you call the most recent version
of the Safeguard API where possible. The good news is that since SPP maintains
backwards compatibility of the API where possible, the investments that you
make now in automation will continue to work in the future. Only when it is
impossible to make a previous version of an endpoint work does the SPP team
deprecate an existing API.

The following is another example that uses POST and sends a body:

```Bash
curl -k -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer $tok" -d '{"PrimaryAuthenticationProviderId":-1,"UserName":"Douglass"}' 'https://sps1.petrsnd.org/service/core/v3/Users'
```

```Text
0000: POST /service/core/v2/Users HTTP/2
0024: Host: sg-vm1.dan.vas
003a: User-Agent: curl/7.58.0
0053: Content-Type: application/json
0073: Accept: application/json
008d: Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjBGRDREOEIyRD
00cd: M5NzFFM0MxODgzOTY0MUZDMkM2QTFBNkZCQzA0M0UiLCJ0eXAiOiJKV1QiLCJ4NX
010d: QiOiJEOVRZc3RPWEhqd1lnNVpCX0N4cUdtLThCRDQifQ.eyJBY3R1YWxVc2VySWQ
014d: iOiIxIiwiQXV0aFRva2VuSWQiOiJlM2QxMmM5NC02YWU3LTQxZTgtYWE2OS1mMWQ
018d: 0ZThjNjU3YjUiLCJyc3RzOnN0czpjbGFpbXM6dXNlcjp1c2VySWQiOiIxIiwidXB
01cd: uIjoiR3ViZXIiLCJhdXRobWV0aG9kIjoibG9jYWw6cHdkIiwibmFtZWlkIjoiR3V
020d: iZXIiLCJuYmYiOjE1Njk0NDA1ODAsImV4cCI6MTU2OTUyNjk4MCwiaWF0IjoxNTY
024d: 5NDQwNTgwLCJpc3MiOiJ1cm46dG9rZW5hdXRoZW50aWNhdGlvbnByb3ZpZGVyOlN
028d: BRkVHVUFSRF9BUFBMSUFOQ0UifQ.L6GanWlv7nExUJiSLyXprvK3bvuo9eaiIQCA
02cd: c_HRjfU-HMP9kWvIy9mqaqxxqqvdJWMnXWxDbh6XLrtH8rVcDdIvFee9rQDRA5LR
030d: Hwi7Zk_doh3T0Blx-r_w3xZy4sx4oCWFvm9AWEU71ITS5e2P2zAjSNSdn-79U0Ak
034d: A4LgfipUm9trzcZDgGIyymKrA-R1dfBEoi1qpQj9NiwmIbxCnSZSXRR3mIZOn0Ie
038d: d3KwQ9S3CLt5U4x_yDp-3c7H9p4YDwpD0sYfNZOw7dEeZr-Irpn3mSkq-Ar7Q0jh
03cd: A32bN0fEzaz8kSn88uASj7dIYDAnxghkOl4W-mKhmgqu1cMiPw
0401: Content-Length: 58
0415: 

0000: {"PrimaryAuthenticationProviderId":-1,"UserName":"Doogie"}
```

While calling the Safeguard API from cURL works, the open source projects from
the next few tutorials make it much easier--especially the obtaining the
initial Safeguard API token.
