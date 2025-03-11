**Goal of the repos is to reproduce a runtime error with the AppDynamics PHP agent in an Alpine container.**

This is related to a question on Splunk Community:
https://community.splunk.com/t5/Splunk-AppDynamics/Install-AppDynamics-in-the-context-of-an-alpine-container-for-a/m-p/741330

AppDynamics Agent for PHP with Alpine Image
===========================================

Prerequisites
-------------

First step is to copy in the root of this project the following files downloaded from appdynamics:

- `appdynamics-php-agent-x64-linux-24.11.0.1340.tar.bz2`
- `appdynamics-php-proxy-x64-alpine-linux-24.11.0.1340.tar.bz2` (not really used for now as troubleshooting the agent first)

The repository should look as follows
   
```shell
$> ls -l
agent-install.sh
appdynamics-php-agent-x64-linux-24.11.0.1340.tar.bz2
appdynamics-php-proxy-x64-alpine-linux-24.11.0.1340.tar.bz2
Dockerfile
README.md
```

Build
-----

For the sake of the example, we are using podman as the container runtime.
Build the image with the following command. Notice that `--network host` is optional.

```shell
podman build -t appdynamics-php --network host .
```

```shell
podman run -it --rm appdynamics-php php -m
```

You will see among the output

```
Warning: PHP Startup: Unable to load dynamic library 'appdynamics_agent.so' (tried: /usr/local/lib/php/extensions/no-debug-non-zts-20220829/appdynamics_agent.so 
(Error loading shared library libstdc++.so.6: No such file or directory (needed by /usr/local/lib/php/extensions/no-debug-non-zts-20220829/appdynamics_agent.so)), 
/usr/local/lib/php/extensions/no-debug-non-zts-20220829/appdynamics_agent.so.so 
(Error loading shared library /usr/local/lib/php/extensions/no-debug-non-zts-20220829/appdynamics_agent.so.so: No such file or directory)) in Unknown on line 0
```

Troubleshooting
---------------

It looks we are missing libstdc. As a random guess, we could add the compatibility package `gcompat` and `libstdc++` to the image.

```shell
RUN apk add --no-cache \
    gcompat \
    libstdc++
```

We then get

```shell
podman run -it --rm appdynamics-php php -m
```

```
Warning: PHP Startup: Unable to load dynamic library 'appdynamics_agent.so' (tried: /usr/local/lib/php/extensions/no-debug-non-zts-20220829/appdynamics_agent.so 
(Error relocating /usr/local/lib/php/extensions/no-debug-non-zts-20220829/appdynamics_agent.so: __vsnprintf_chk: symbol not found), 
/usr/local/lib/php/extensions/no-debug-non-zts-20220829/appdynamics_agent.so.so 
(Error loading shared library /usr/local/lib/php/extensions/no-debug-non-zts-20220829/appdynamics_agent.so.so: No such file or directory)) in Unknown on line 0
```