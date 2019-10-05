# SPP 4 -- Scripting with safeguard-ps

Swagger UI and Postman are fairly difficult methods to use to call the
Safeguard API, but they are helpful to teach how REST-based APIs actually work,
and information in Swagger UI is very important even when using the open source
projects and SDKs. Swagger UI is the official documentation for the Safeguard
API.

In this portion of the tutorial you will learn to use safeguard-ps, which is a
PowerShell module that adds cmdlets for connecting to and calling the Safeguard
API.

PowerShell is the primary scripting language on Windows platforms, but it is
also available on macOs and Linux as well. safeguard-ps is intended to support
every platform that PowerShell supports with very few caveats. The very few
cmdlets or cmdlet parameters that are not supported on non-Windows platforms
should display a not supported message. Any other non-Windows failures should
be reported as issues on the OneIdentity/safeguard-ps GitHub page, and they
will be fixed.

The safeguard-ps PowerShell module is published to and distributed from
[PowerShell Gallery](https://www.powershellgallery.com/) which is supported by
Microsoft. As of this writing, safeguard-ps is written entirely in PowerShell
scripts which increases its portability; however, One Identity may add some C#
code to add support for SignalR event listening.

As an open source project, members of the community are encouraged to engage in
the safeguard-ps project. You can install safeguard-ps after cloning from the
GitHub repository. You can fork the repository and propose GitHub pull
requests. You can file issues and expect to hear a prompt response from
safeguard-ps developers.

## Exercises

START HERE: [Hands-on Lab](safeguard-ps-hol.md)

1. Install safeguard-ps from the PowerShell Gallery
2. Check out safeguard-ps using git command line
3. Install safeguard-ps from GitHub by downloading a zip
4. Connecting to the Safeguard API
5. Finding a cmdlet and getting help to call it
6. Calling any endpoint using Invoke-SafeguardMethod
7. Creating assets and running management tasks
8. Creating a policy using a script
9. Checking out passwords and launching sessions
10. Getting a support bundle
11. Setting up certificates and calling A2A

NEXT: [SPP 5 -- Scripting with safeguard-bash](../spp5-safeguard-bash)
