# SPP 1 -- Introduction to the SPP API

Safeguard for Privileged Passwords (SPP) is built as a secure, hardened
appliance to provide protection for passwords and private keys. In addition to
storing these credentials, SPP automates the management of the credentials in
the environment, which helps regulatory compliance and security. To access
passwords, private keys, and sessions, SPP provides a role-based policy model
and access request workflow. SPP maintains an indelible audit log of all
details of credential access, credential management, and configuration changes.

Because it is a secure, hardened appliance, all of the functionality of SPP is
exposed only through the SPP API. There is no direct console access.
There are no backdoors. There are no special internal interfaces that only One
Identity can use. All of the functionality that you see in the SPP UI is
presented based on interactions with the SPP API.

![API Clients](img/api-clients.png)

This means that there is nothing that you cannot do with the SPP API
that you can do in the SPP UI.

## Clusters

SPP is delivered as an appliance, which can cause people to think that the
appliance is the complete product. In reality, SPP is almost never deployed as a single
appliance. In fact, One Identity very much recommends that you only deploy SPP
as a cluster of three or five appliances. The reason for this is that the SPP
application is actually best served as a cluster for maximum efficiency and security.
All of the appliances in the cluster have all of the data. The most critical services 
such as access request workflow, credential management, and auditing are provided from 
every appliance in the cluster. For example, every appliance in the cluster is aware of 
password releases. This is known as active/active clustering rather than active/passive 
clustering. There is a primary appliance that is used for making configuration changes, 
but any appliance in the cluster can be modified to assume the primary role.

![SPP Cluster](img/cluster.png)

When thinking of SPP product functionality, it is important to think of it as
a highly available, redundant, fully consistent cluster solution rather than a
purpose-built appliance sitting in your data center.

SPP clusters are also built to work with Safeguard for Privileged Sessions
(SPS) appliances and clusters. SPP and SPS clusters can be joined together to
allow SPP access request workflow and credentials to be used with SPS sessions.

When joined, the SPP primary appliance is connected to the SPS configuration
master appliance. All nodes in SPP and SPS know about each other. The passwords
are only stored on SPP. When a session is started on SPS, the password is securely
transmitted from SPP without revealing it to the end user.

![Cluster Join](img/cluster-join.png)

SPP and SPS actually do not share a single API. Each product has a
separate API. They differ in authentication, versioning scheme, and
basic API endpoint design. In the future SPP and SPS will share a single
authentication strategy. There will always be differences between SPP and SPS APIs, but over time they will become more alike.

For more information on clusters, see `Disaster recovery and clusters`:
[https://support.oneidentity.com/technical-documents/one-identity-safeguard/administration-guide/99#TOPIC-1269467](https://support.oneidentity.com/technical-documents/one-identity-safeguard/administration-guide/99#TOPIC-1269467)

For more information on the join, see `Appendix C: SPP and SPS join guidance`:
[https://support.oneidentity.com/technical-documents/one-identity-safeguard/administration-guide/128#TOPIC-1269585](https://support.oneidentity.com/technical-documents/one-identity-safeguard/administration-guide/128#TOPIC-1269585)


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

For details, see Using the virtual appliance and web management console:
[https://support.oneidentity.com/technical-documents/one-identity-safeguard/administration-guide/4#TOPIC-1269087](https://support.oneidentity.com/technical-documents/one-identity-safeguard/administration-guide/4#TOPIC-1269087)

![Virtual](img/virtual.png)

Virtual appliances are also available in Azure and AWS.

## Authenticating to the SPP API

SPP includes a secure token service (STS) that is actually a redistributable
component that appears in other One Identity products. This redistributable
secure token service (rSTS) handles the initial authentication to SPP. It
handles a wide variety of identity providers and authentication mechanisms.
SPP supports everything from local authentication using a local SPP user to
Active Directory users to federated IDPs and FIDO2. It supports RADIUS,
smart cards, and also 2FA via multiple mechanisms.

Authenticating to use the SPP API is a two step process. The initial
authentication is against the rSTS which results in an rSTS token (JSON Web Token or JWT). This
rSTS token is then exchanged for a SPP API token to access SPP.

![SPP Auth Process](img/spp-auth-process.png)

Administrators do not have to be experts in rSTS. SPP rSTS authentication uses
OAuth 2.0. Our rSTS supports several different grant
types. For example, the **Authorization code grant** type, with PKCE is used by the the `-Browser`
parameter in safeguard-ps, SafeguardDotNet.BrowserLogin, and SafeguardDotNet.GuiLogin.
That is also what is used by Safeguard's own web UI. The **Resource owners grant** is also an option used by most of our open
source projects such as safeguard-ps, safeguard-bash, SafeguardJava, and
SafeguardDotNet.

Note, as of Safeguard version 7.4, it is possible for an administrator to disable
these OAuth 2.0 grant types. In Safeguard 8.0, for new installations, they are
disabled by default. If you upgrade from 7.x to Safeguard 8.0, the settings are
not modified. That is, they will continue to have the same value prior to the upgrade.

It is recommended that all integration applications authenticate users via the web
browser. Your application should not prompt for and collect a user's credentials on
its own.

For fully automated, unattended application services, it is recommended to use
certificate based authentication so that you do not have to hard code credentials
into your application or application configuration file. Instead, you add the
certificate's private key to the operating system's certificate store, keychain,
or a secure directory that is only accessible by your service application's user
account.

An example of calling the rSTS:

```Bash
curl -k -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' 'https://<your server>/RSTS/oauth2/token' -d '{ "grant_type": "password", "username": "Admin", "password": "Admin123", "scope": "rsts:sts:primaryproviderid:local" }'
```
> Note, ensure that your Safeguard configuration allows the `Resource Owner` grant type,
> found under Appliance Management -> Safeguard Access -> Local Login Control.

The value of the `scope` parameter will vary for an Active Directory
user or other authentication providers. But there are two well-known values for built-in identity providers:

- Local: `rsts:sts:primaryproviderid:local`
- Certificate: `rsts:sts:primaryproviderid:certificate`

The SDKs and open source projects take care of detecting Active Directory and other `scope`
values. However, if needed, you can make the following request programmatically
or even in your web browser to get the complete list of authentication providers
and their associated `scope` value:
```
https://<your server>/service/Core/v4/AuthenticationProviders
```

Continuing on with the example, the resulting HTTP `curl` request looks something like this:

```Text
0000: POST /RSTS/oauth2/token HTTP/2
001e: Host: <your server>
0033: User-Agent: curl/7.58.0
004c: Content-Type: application/json
006c: Accept: application/json
0086:

0000: { "grant_type": "password", "username": "Admin", "password": "Ad
0040: min123", "scope": "rsts:sts:primaryproviderid:local" }
```

You will receive a standard OAuth 2.0 JSON response with one of the key names
equal to `access_token`.
```
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1...",
  "expires_in": 299,
  "scope": "rsts:sts:primaryproviderid:local:pwd",
  "success": true,
  "token_type": "Bearer"
}
```

You must then exchange that token for the SPP API token:

```Bash
curl -k -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' 'https://<your server>/service/core/v4/Token/LoginResponse' -d '{ "StsAccessToken": "<rsts token>" }'
```

The resulting HTTP request looks something like this:

```Text
0000: POST /service/core/v4/Token/LoginResponse HTTP/2
0032: Host: <your server>
0047: User-Agent: curl/7.58.0
0060: Content-Type: application/json
0080: Accept: application/json
009a:

0000: { "StsAccessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI
0040: 6IkQ5VFlzdE9YSGp3WWc1WkJfQ3hxR20tOEJENCJ9.eyJpc3MiOiJodHRwczovLz
0080: BGRDREOEIyRDM5NzFFM0MxODgzOTY0MUZDMkM2QTFBNkZCQzA0M0UiLCJuYmYiOj
00c0: E1Njg3NjAxMTMsImV4cCI6MTU2ODc2MDQxMywiYXV0aG1ldGhvZCI6ImxvY2FsOn
0100: B3ZCIsImF1dGhfdGltZSI6IjIwMTktMDktMTdUMjI6NDE6NTMuNDE3NjQ3M1oiLC
0140: JodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL2FjY2Vzc2NvbnRyb2xzZXJ2aW
0180: NlLzIwMTAvMDcvY2xhaW1zL2lkZW50aXR5cHJvdmlkZXIiOiJodHRwczovLzBGRD
01c0: REOEIyRDM5NzFFM0MxODgzOTY0MUZDMkM2QTFBNkZCQzA0M0UiLCJ1cm46cnN0cy
0200: 9qdGkiOiJmOTU1OTBlMjZmNjY0NDVkOThiNGU3NDk2OTU1ZThjNSIsIm5hbWVpZC
0240: I6ImFkbWluIiwidXBuIjoiYWRtaW4iLCJlbWFpbCI6IiIsInVuaXF1ZV9uYW1lIj
0280: oiQm9vdHN0cmFwIEFkbWluaXN0cmF0b3IiLCJ1cm46cnN0cy9kYXlzVW50aWxQYX
02c0: Nzd29yZEV4cGlyZXMiOiIxMDY3NTE5OS4xMTY3MzAxIiwicnN0czpzdHM6Y2xhaW
0300: 1zOnVzZXI6dXNlcklkIjoiLTIiLCJzdWIiOiJhZG1pbiIsImF6cCI6IjAwMDAwMD
0340: AwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCIsInJzdHM6c3RzOmNsYWltcz
0380: pzY29wZSI6InJzdHM6c3RzOnByaW1hcnlwcm92aWRlcmlkOmxvY2FsOnB3ZCIsIn
03c0: JzdHM6c3RzOmNsYWltczpzbnRubCI6IjAifQ.iyuD4mNElMq8WsnMpnM7pInXzG4
0400: 46dhS2zL9Ylzer58GSlXPwxJVJDrAP5mGzND_ge-52kBbGS6Z2TYe1ji356AgmF2
0440: PV-U1JH54KD7pAQq7E87r7qEsx1qHBKnLEiPZKssJrNnY587Fxx9AVkf5t6OQyFo
0480: HA5eE8nd3oerPahzhshDew7sPekrbvT8387bO5grcLo6h9z2vffNDK05r13rM7Ya
04c0: -gDVAEILhBtHm3dJ_dfqX16S8F4QEhopqOahE3XOXxU0laWO2Dl7nJvZRrkn_MjN
0500: BRhz5MpiIX1Ox6kv0CNGuPKBui5HT2sDikg-QS1dHYRw1YrqeP_CWeIILcg" }
```

The response will be a JSON object with one of the key names equal to `UserToken`.
This is the value you will need to then include in all subsequent SPP API requests.
```
{
  "Status": "Success",
  "UserToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjZFQzY1RDRCNDczMkQyODU...",
  "PrimaryProviderId": null,
  "SecondaryProviderId": null,
  "WebClientInactivityTimeout": 2880,
  "DesktopClientInactivityTimeout": 1440
}
```

SPP API tokens are JWT bearer tokens. These tokens are embedded in the HTTP
Authorization header of the HTTP requests that are sent to the SPP API.

```
Authorization: Bearer <token>
```

## Calling SPP API Services

The SPP API is a REST-based API. SPP API endpoints are called using
HTTP operators and JSON (or XML) requests and responses. The SPP API is
documented using Swagger. You may use the Swagger UI to call the API directly or to
read the documentation about URLs, parameters, and payloads.

To access the Swagger UI use a browser to navigate to:
`https://<address>/service/<service>/swagger/index.html`

- `<address>` = SPP network address
- `<service>` = SPP service to use

The SPP API is made up of multiple services: core, appliance, notification,
event, and a2a.

|Service|Description|
|-|-|
|core|Most product functionality is found here. All cluster-wide operations: access request workflow, asset management, policy management, etc.|
|appliance|Appliance-specific operations, such as setting IP address, maintenance, backups, support bundles, appliance management|
|notification|Anonymous, unauthenticated operations. This service is available even when the appliance isn't fully online|
|event|Specialized endpoint for connecting to SignalR for real-time events|
|a2a|Application integration specific operations. Fetching passwords, making access requests on behalf of users, etc.|

In a REST-based API, the standard HTTP methods are used to manipulate data
resources that are identified by the path in the URL. The HTTP methods, `GET`,
`POST`, `PUT`, and `DELETE`,  correspond with standard data manipulation verbs
(CRUD):

  - `POST` = `create`
  - `GET` = `read`
  - `PUT` = `update`
  - `DELETE` = `delete`

The exception to this rule is that the HTTP `POST` method is overloaded in
several places in the SPP API to perform a `POST` action, when that
particular action does not fit neatly into CRUD semantics. In these cases the
path to that endpoint will end in a verb rather than a noun.

For example, `POST` `service/core/v4/AccessRequests/{id}/Deny` is a `POST`
action that denies an access request, whereas `POST`
`service/core/v4/AccessRequests` is a `create` action.

The SPP API is protected by TLS. SPP ships with a built-in self-signed
certificate that should be replaced with a legitimate TLS certificate that is
trusted in your organization.

With an SPP API token, you can call the SPP API using any HTTP
client. An example using cURL where the `$tok` contains an SPP API token
and `-k` is specified to avoid complaints about a self-signed certificate:

```Bash
curl -k -X GET --header 'Accept: application/json' --header "Authorization: Bearer $tok" 'https://<your server>/service/core/v4/Users'
```

The resulting HTTP request looks like this:

```Text
0000: GET /service/core/v4/Users HTTP/1.1
0025: Host: <your server>
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

The SPP API uses URL versioning. The current version is "v4". The previous
version "v3" is also supported, and in many cases, the endpoints are
equivalent. However, it is recommended that you call the most recent version
of the SPP API where possible. The good news is that since SPP maintains
backwards compatibility of the API where possible, the investments that you
make now in automation will continue to work in the future. Only when it is
impossible to make a previous version of an endpoint work does the SPP team
deprecate and remove an existing API.

The following is another example that uses POST and sends a body:

```Bash
curl -k -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer $tok" -d '{"PrimaryAuthenticationProviderId":-1,"UserName":"Douglass"}' 'https://<your server>/service/core/v4/Users'
```

```Text
0000: POST /service/core/v4/Users HTTP/2
0024: Host: <your server>
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

Although calling the SPP API from cURL works, the open source projects from
the next few tutorials make it much easier--especially the obtaining the
initial SPP API token. The exact cURL commands that could be used to
obtain a SPP API token on your own are beyond the scope of this tutorial.

*The source code of the [safeguard-bash](https://github.com/oneidentity/safeguard-bash)
open source project shows how to get a SPP API token using cURL.*

NEXT: [SPP 2 -- Using Swagger UI to call the SPP API](../spp2-swagger)
