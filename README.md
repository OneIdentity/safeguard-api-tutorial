# safeguard-api-tutorial

One Identity Safeguard is built to integrate with your existing systems.
It is built for automation to facilitate your initial deployment and your
on-going administration of the product. The key to automating and integrating
with Safeguard is to become comfortable using the APIs, the
open source SDKs, and the scripting libraries created to support those APIs.

## Safeguard for Privileged Passwords (SPP)

Safeguard for Privileged Passwords (SPP) is built with an API-first design.
This means that all product functionality is initially exposed as a public API
before it is added to any user interface. All SPP functionality (100%) is
available via the SPP API. There are even a few things that can ONLY be
done via the SPP API.

The SPP UI is built for day to day operations, but some administrative tasks
are actually more effectively performed via the SPP API. For example, an
administrator can import assets, accounts, or users using the SPP UI, but
using the SPP API or one of our open source scripting frameworks, such a
safeguard-ps, is the best way to bulk import objects.

The following tutorials will help you to understand the SPP product design and
how to manipulate SPP via the SPP API. Each tutorial includes some
instruction and hands-on lab exercises to help you get familiar with new
technologies and techniques. Upon completing these tutorials, you will find
that using the Safeguard API and open source tools to deploy, automate,
monitor, and support your Safeguard installation is easy and effective.

- [SPP 1 -- Introduction to the Safeguard API](spp1-introduction)
- [SPP 2 -- Using Swagger UI to call the Safeguard API](spp2-swagger)
- [SPP 3 -- Using Postman to call the Safeguard API](spp3-postman)
- [SPP 4 -- Scripting with safeguard-ps](spp4-safeguard-ps)
- [SPP 5 -- Scripting with safeguard-bash](spp5-safeguard-bash)
- [SPP 6 -- SPP integration using SafeguardDotNet](spp6-safeguarddotnet)

For additional information following the tutorial, please visit our open source
projects also hosted on GitHub:

- [safeguard-ps](https://github.com/OneIdentity/safeguard-ps)
- [safegaurd-bash](https://github.com/OneIdentity/safeguard-bash)
- [SafeguardDotNet](https://github.com/OneIdentity/SafeguardDotNet)
- [SafeguardJava](https://github.com/OneIdentity/SafeguardJava)
