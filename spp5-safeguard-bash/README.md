# SPP 5 -- Scripting with safeguard-bash

There are pros and cons between using safeguard-ps and safeguard-bash. Both
safeguard-ps and safeguard-bash can be used on Windows, macOs, and Linux, so
the decision of which to use should not be made entirely upon which operating
system you are using. That being said, there are a handful of things with
safeguard-ps that only work on Windows, like the `-Gui` parameter for logging
in with a web browser and opening CSV reports automatically in Excel.

For the most part it is safe to say that safeguard-ps is optimized for the
interactive command line experience in that it provides more purpose-built
cmdlets than safeguard-bash provides purpose-built scripts. Both safeguard-ps
and safeguard-bash are built for scripting and automation, and both of them
include low-level components for invoking any method in the SPP API. The
strength of safeguard-bash is in event listening and resilient long-running
scripts.

As an open source project, safeguard-bash is available for free to anyone who
would like to use it. Members of the community are encourage to contribute back
to the project and to provide feedback by filing issues on GitHub. Developers
will respond promptly to any problem that is uncovered and will give feedback
on enhancement requests.

In this portion of the tutorial you will learn to use safeguard-bash which is a
collection of scripts written in Bash using cURL and jq to interact with the
SPP API.

## Exercises

START HERE: [Hands-on Lab](safeguard-bash-hol.md)

1. Installing safeguard-bash and satisfying prerequisites
2. Get started quickly with safeguard-bash using Docker
3. Connecting to the SPP API
4. A few purpose-built scripts
5. Calling any endpoint using invoke-safeguard-method.sh
6. Listening for events
7. Handling password changes with A2A events

NEXT: [SPP 6 -- SPP integration using SafeguardDotNet](../spp6-safeguarddotnet)
