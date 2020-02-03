# SPP 3 -- Using Postman to call the SPP API

[Postman](https://www.getpostman.com/) is a GUI tool for calling REST-based
APIs. It is targeted at developers and testers, but it also works well
for admins and system integrators. Postman supports Windows, macOS, and Linux
and includes many features and add-ons that go above and beyond what we need
for this tutorial. What we will focus on is the very simple interface for
calling REST-based APIs such as the SPP API.

We will look at
[Postman Collections](https://learning.getpostman.com/docs/postman/collections/intro_to_collections/)
which provide an interface similar to the Swagger UI but with some additional
advantages that improve the user experience. The biggest advantage is that
Postman Collections can be customized to contain routine queries with prepared
bodies saved for convenient use in the future.

We will also look at using
[Postman Scripts](https://learning.getpostman.com/docs/postman/scripts/intro_to_scripts/)
and the
[Postman Environments](https://learning.getpostman.com/docs/postman/environments_and_globals/intro_to_environments_and_globals/)
which make it easy to handle more challenging API interactions, such as
initial authentication to the SPP API. Postman Scripts can contain
dynamic parameters and pass data between requests. They make it possible to
script together a multi-step API interaction such as creating an SPP user and
setting the password, which took two steps in the previous Swagger UI tutorial.

## Exercises

START HERE: [Hands-on Lab](postman-hol.md)

In this lab you will perform the following:

1. Download and install Postman
2. Make a simple unauthenticated request
3. Import directly from SPP OpenAPI file
4. Import a starter collection for authentication
5. Run a simple POST
6. Build and run a saved collection

NEXT: [SPP 4 -- Scripting with safeguard-ps](../spp4-safeguard-ps)