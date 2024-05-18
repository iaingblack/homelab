v1.01
-----
Puppet installs. Need to provision and split up a bit now

v1.0
----
Completely working. Now to break up a bit, test a puppet copy, install and provision.

v0.13
-----
# Just need to fix provisioners now
# * unknown error Post https://simpledemo.northeurope.cloudapp.azure.com:10000/wsman: dial tcp 52.169.66.55:10000: connectex: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond

v0.12
-----
Almost. Wont copy a file as thinks it's ssh. Need to fix.
* dial tcp :22: connectex: The requested address is not valid in its context

v0.11
-----
Initial Working machine! Still needs an IP address reigstered on it and an NSG setup to point to RDP port of machine. Also, test puppet install etc...

v0.1
----
Testing with a windows image, got this error;

 azurerm_virtual_machine.demo: compute.VirtualMachinesClient#CreateOrUpdate: Failure responding to request: StatusCode=
00 -- Original Error: autorest/azure: Service returned an error. Status=400 Code="InvalidParameter" Message="The value
f parameter linuxConfiguration is invalid."