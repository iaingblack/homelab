# DOCKERFILES

See here for the ultimate Docker reference (https://docs.docker.com/engine/reference/builder/)

## Items
A general idea of how a dockerfile is constructed is below. The trickiest part is the CMD/ENTRYPOINT concepts;

https://docs.docker.com/engine/reference/builder/#/understand-how-cmd-and-entrypoint-interact

It's quite simple otherwise.

The following options are available;
* FROM  (image name) - The image to use as a starting point for your own image
* MAINTAINER (email address)- Person who maintains the dockerfile
* ENV (variable name) - A variable we can insert later into our commands below. Useful for customisable specific things or DRY principle for repeated items (lke a folder referred to often)
* COPY (source dest) - Copy a file from the host into the container
* WORKDIR (folder) - Change location inside the container
* EXPOSE (port numbers) - Automatically *expose* ports when container starts without user having to specify manually
* SHELL (type) - Change from a shell like ["cmd /c"] or [powershell]
* RUN (command) - A shell command like you would run on a command prompt
* 



### RUN
Use this like a normal command to do something during the build. It CAN take parameters but likely this wont be useful.
Any RUN command will be permanently added to the image. There can be multiple RUN commands in a dockerfile.

### CMD
This is *almost* like the RUN command. But, there can only be a single CMD per dockerfile others are ignored, the last one executes.
Generally, 

## Gotchas
If you just just put `["cmd"]` then commands will NOT run, it just displays a prompt per RUN step. Use `["cmd /c /s"]`

Or, if you need to run one command in a specific shell run something like this;

`RUN ["powershell.exe", "Install-WindowsFeature NET-Framework-45-ASPNET"]`

# Images

## Saving and Loading Images
Given this type of image

`REPOSITORY                                    TAG                                IMAGE ID            CREATED             SIZE`
`microsoft/mssql-server-windows                latest                             6fb5a1dbd3c8        3 weeks ago         14.6 GB`

We need OsVersion as Windows tends to use this ot track the image

`docker inspect microsoft/windowsservercore | findstr OsVersion`
`"OsVersion": "10.0.14393.321",`

To save images run this type of command (this is uncompressed). Note the detail on SHA and OSVersion so we can find this exact image easily later

`docker save -o y:\images\microsoft_mssql-server-windows_6fb5a1dbd3c8_10.0.14393.321.dockerimage 6fb5a1dbd3c8`

To load images load this type of command

`docker load -i microsoft_mssql-server-windows_6fb5a1dbd3c8_10.0.14393.321.dockerimage`

#CMD EXAMPLES

`&    seperates commands on a line.`

`&&    executes this command only if previous command's errorlevel is 0.`

`||    (not used above) executes this command only if previous command's errorlevel is NOT 0`

`>    output to a file`

`>>    append output to a file`

`<    input from a file`

|`    output of one command into the input of another command`

`^    escapes any of the above, including itself, if needed to be passed to a program`

`"    parameters with spaces must be enclosed in quotes`

`+ used with copy to concatinate files. E.G. copy file1+file2 newfile`

`, used with copy to indicate missing parameters. This updates the files modified date. E.G. copy /b file1,,`

`%variablename% a inbuilt or user set environmental variable`

`!variablename! a user set environmental variable expanded at execution time, turned with SelLocal EnableDelayedExpansion command`

`%<number> (%1) the nth command line parameter passed to a batch file. %0 is the batchfile's name.`

`%* (%*) the entire command line.`

`%<a letter> or %%<a letter> (%A or %%A) the variable in a for loop. Single % sign at command prompt and double % sign in a batch file.`

# Docker Compose

`ERROR: client version 1.22 is too old. Minimum supported API version is 1.24, please upgrade your client to a newer version`

http://www.jeffreyfritz.com/2017/01/docker-compose-api-too-old-for-windows/
