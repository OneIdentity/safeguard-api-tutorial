# safeguard-bash Hands-on Lab

The safeguard-bash scripts are built on the bash shell and the cURL command
line utility (`curl`). The `curl` command can be used by itself to make HTTP
requests to the Safeguard API, but safeguard-bash simplifies the process of
authentication and uses mechanisms built into the bash shell and the `curl`
command line to hide the details of access tokens from process tables.
The safeguard-bash scripts also make extensive use of a command line utility
called [`jq`](https://stedolan.github.io/jq/). `jq` is like sed for JSON data.
`jq` is written in portable C as a single binary with zero runtime dependencies
which makes it a very low cost prerequiste. Some scripts in safeguard-bash make
an attempt to work without requiring `jq`, but for the purposes of this lab you
ought to just install it.

## 1. Installing safeguard-bash and satisfying prerequisites

Before you can install safeguard-bash you need to have bash! If you are running
on macOs or Linux, there is a really good chance you already have bash. If you
are on Windows, you need to use one of the following options:

- Install [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
- Install [Git BASH](https://gitforwindows.org/) using Git for Windows
- Use Docker with Linux containers (skip to the next section)
- Install [Cygwin](https://cygwin.com/install.html)--all the other options are better than this one

Once you have bash, installing safeguard-bash is not as simple as installing
safeguard-ps, in that there is not a package that you can just pull down with a
simple command line.

The easiest way to get safeguard-bash is to use `git`. To check out the source
code using `git` just type the following command:

```Bash
$ git clone https://github.com/OneIdentity/safeguard-bash.git
```

This will create a `safeguard-bash` directory in your current directory that
contains the entire safeguard-bash source tree.

If you cannot use `git` then you can accomplish the same thing by running this
command line:

```Bash
$ curl -sSLO https://github.com/OneIdentity/safeguard-bash/archive/master.zip; unzip master.zip; rm master.zip; mv safeguard-bash-master safeguard-bash
```

Once you have pulled down the source code, you need to change directory into
the safeguard-bash directory:

```Bash
$ cd safeguard-bash
```

Then, you can use the `install-local.sh` script to install safeguard-bash into
your `$HOME/scripts` directory and setup your bash profile to add it to your
path.

```Bash
$ ./install-local.sh
Copied safeguard-bash scripts into '/home/petrsnd/scripts'
Added '/home/petrsnd/scripts' to PATH, run: '. /home/petrsnd/.profile'
```

A bash script like `install-local.sh` isn't actually allowed to modify the PATH
of the parent process, so you will need to dot source your bash profile again
according to the output of the previous command:

```Bash
$ . /home/petrsnd/.profile
```

Now, to be sure that you actually have safeguard-bash in your PATH, you should
run the following command and make sure you get help output:

```Bash
$ connect-safeguard.sh -h
```

You should make sure that you have `jq` installed to get the most out of
safeguard-bash.

Check to see if you have `jq` by running:

```Bash
$ which jq
/usr/bin/jq
```

If you do not have any output then you do not have `jq`.

Get `jq` from your operating system package manager, such `apt` or `yum`. i.e.

```Bash
$ apt install jq
```

Or, you can download the binary from the
[jq website](https://stedolan.github.io/jq/)
and rename it to `jq` and put it in your path somewhere like `/usr/bin` or
`/usr/local/bin`.

## 2. Get started quickly with safeguard-bash using Docker

Using Docker is definitely the quickest way to get up running with
safeguard-bash, but installing Docker is outside the scope of this lab. If you
already have Docker on your system, then you can start using safeguard-bash
by just running a container.

If you are on Windows then your Docker environment needs to be configured for
Linux containers.

To launch safeguard-bash from a docker container, run:

```Bash
$ docker run -it oneidentity/safeguard-bash
```

You will immediately be prompted for a network address for a SPP appliance.
This is because the entrypoint for the docker container is
`connect-safeguard.sh`. This is described in the next step.

When running from the safeguard-bash Docker container, your host operating
system will be left unchanged and no tools will need to be installed. Docker
can be a very clean and safe way to try out software.

## 3. Connecting to the Safeguard API

The `connect-safeguard.sh` script is used to connect to the Safeguard API. It
follows very similar semantics to `Connect-Safeguard` in safeguard-ps. For
example, by default it connects to the Safeguard API and creates a session;
however, the session is stored in a file instead of in a variable.
`connect-safeguard.sh` also provides an option to return a raw token for
storage in a variable. When you don't give `connect-safeguard.sh` enough
information, it will try to prompt you for things that are missing.

Start by running `connect-safeguard.sh` with no arguments:

```Bash
$ connect-safeguard.sh
Appliance Network Address: <your server>
Identity Provider: local
Username: billybob
Password:
A login file has been created.
```

That last line stating that a login file has been created means that your
session is ready to go and you can call the Safeguard API.

To disconnect just run the `disconnec-safeguard.sh` script:

```Bash
$ disconnect-safeguard.sh
Removing current login file.
Calling logout service on appliance.
```

If you don't want to be prompted, then you can supply all of the arguments you
need on the command line. Passing arguments to safeguard-bash is a little
different from safeguard-ps. safeguard-bash doesn't support positional
arguments. Everything is done using `getopts`, so you will need to look at the
usage for different scripts to make sure see how they work. Every script in
safeguard-bash supports the `-h` option that will print out the usage.

To call `connect-safeguard.sh` without it prompts (other than the password) you
can run the following:

```Bash
$ connect-safeguard.sh -a <your server> -i local -u billybob
Password:
A login file has been created.
```

If you want to even avoid a password prompt you can use the `-p` option to tell
the `connect-safeguard.sh` script to read the password from stdin.

Then, you can call the script like this:

```Bash
$ connect-safeguard.sh -a sg-vm1.dan.vas -i local -u billybob -p <<<BillyBob123
```

It works equally well if the password is stored in a variable:

```Bash
$ connect-safeguard.sh -a sg-vm1.dan.vas -i local -u billybob -p <<<$password
```

You can use the `-X` option to tell `connect-safeguard.sh` to just return the
raw token rather than creating the login file. You can capture the raw token in
a variable using either the backtick or subshell syntax.

```Bash
$ tok=`connect-safeguard.sh -a sg-vm1.dan.vas -i local -u billybob -X -p <<<BillyBob123`
$ echo $tok
$ tok=$(connect-safeguard.sh -a sg-vm1.dan.vas -i local -u billybob -X -p <<<BillyBob123)
$ echo $tok
```

Once you are logged in, you can call a purpose-built script or use
`invoke-safeguard-method.sh` to call any endpoint in the Safeguard API.

One thing you may have noticed is that safeguard-bash doesn't have an
equivalent to the `-Insecure` parameter from safeguard-ps. By default,
safeguard-bash actually has the opposite behavior of ignoring certificate
errors. The reason for this is that on most platform bash doesn't have a
clearly defined store for trusted certificates. If you would like to verify
certificates, you need to pass a trusted certificate bundle on the command line
using the `-B` option. It takes a file as an argument.

safeguard-bash provides a convenience script for downloading a trusted
certificate bundle directly from the Safeguard API that can be used in future
calls. This means you can export the bundle from a secure environment and then
require it in production to be sure that you are talking to the correct
appliance.

To extract a trusted certificate bundle, connect and run:

```Bash
$ get-trusted-ca-bundle.sh
```

The output will tell you the name of the file where the bundle was stored. You
can `cat` the bundle to see what it looks like, but it is just a chain of
certificates in PEM format.

Connecting to the Safeguard API using a directory user is a little more
difficult with safeguard-bash than it is with safeguard-ps. safeguard-bash
won't prompt you with the actual names of domains or LDAP directories. If you
pass in the `-q` option, it will query the provider IDs from the Safeguard API,
and you can specify the right one using the `-i` option.

For example, if you run with the `-q` option and get this prompt:

```Bash
$ ./connect-safeguard.sh -q -a <your server>
Identity Provider (certificate local ad4[company.corp]):
```

And, you wanted to select `company.corp`, then you would type `ad4` at the
prompt.

## 4. A few purpose-built scripts

As of this writing (SPP 2.10) safeguard-bash only has about 25 purpose-built
scripts. You can see what they are by listing the contents of the scripts
directory where they were installed (or in the docker container it is just
`/scripts` from the root). Each one of those scripts includes the `-h` option
to tell you how to call it.

All of the scripts in there are useful, but the majority of the scripts are
specialized to make it easy to use safeguard-bash for event listening and A2A
use cases. Other scripts that are included allow you to use safeguard-bash
to request a password or session via access request.

The `get-event.sh` script produces a grep-able list of all of the events that
can be produced in SPP. This is useful when using the `listen-for-event.sh` and
`handle-event.sh` scripts.

In any script use case where there isn't going to be a human, it is recommended
to use a certificate user rather than a user name and password for
authentication. The `new-certificate-user.sh` script can help you to create a
new certificate user that can be used in an A2A registration or that can be
used to authenticate via `connect-safeguard.sh` and then used for event
handling use cases.

## 5. Calling any endpoint using invoke-safeguard-method.sh

One unique script in safeguard-bash is the `show-safeguard-method.sh` script.
It can be used to get information about the Safeguard API similar to the
information that you would see in Swagger. It only works with a logged in
session that is stored in the file.

Try running:

```Bash
$ show-safeguard-method.sh -s core -U Users
```

This will show a list of all the URLs and methods that you can call that start
with `Users`.

To get specific information, try running:

```Bash
$ show-safeguard-method.sh -s core -U Users -m POST
```

The output shows you everything that you need to know to call this endpoint
using `invoke-safeguard-method.sh`.

You can create a new user this way. Pick a name different than `Pickles` and
use it to create a new user by swapping that out in the body below. You will
need to do that with all of the other examples below as well.

When calling `invoke-safeguard-method.sh` you need to specify the body in JSON,
which can get tricky. You can use a single quote to make it easier or you can
use a heredoc:

```Bash
$ invoke-safeguard-method -s core -m POST -U Users -b '{"UserName":"Pickles","PrimaryAuthenticationProviderId":-1,"AdminRoles":["UserAdmin","PolicyAdmin","ApplianceAdmin","AssetAdmin"]}'
```

The heredoc example might be easier to type:

```Bash
$ invoke-safeguard-method.sh -s core -m POST -U Users -b "$(cat <<EOF
{
"UserName":"Raspberry",
"PrimaryAuthenticationProviderId":-1
}
EOF
)"
```

If you decide to use double quotes, you need to escape the quotes in the JSON:

```Bash
$ invoke-safeguard-method.sh -s core -m POST -U Users -b "{
\"UserName\":\"blueberry\",
\"PrimaryAuthenticationProviderId\":-1
}"
```

Heredocs and double quotes are useful because they allow you to pass variables
into the JSON bodies from your script.

```Bash
$ SomeName=BigBird
$ invoke-safeguard-method.sh -s core -m POST -U Users -b "$(cat <<EOF
{
"UserName":"$SomeName",
"PrimaryAuthenticationProviderId":-1
}
EOF
)"
```

Using the heredoc prevents the need for using backslash to escape every double
quote in the entire JSON body.


## 6. Listening for events



## 7. Handling password changes with A2A events

