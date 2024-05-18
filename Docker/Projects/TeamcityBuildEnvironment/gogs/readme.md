#NEED TO BACKUP GOGS UNZIPPER FOLDER TOO!

App.ini file goes here. need to make the folder custom\conf

C:\gogs\custom\conf\app.ini

This makes use of Powershell EPS to generate template files. It's apain that pwoershell doesnt do this natively.
Install using;

Install-Module -Name EPS -Force

We can then update various files using it, see here - https://github.com/straightdave/eps

 ---------------------------------------------------------------------------
| Item        | Host Location                | Docker Location              |
|-------------|------------------------------|------------------------------|
| Application | e:/project/gogs              | c:\gogsapp\gogs              |
| DB Data     | e:/project/gogs/data         | c:\gogsapp\gogs\data         |
| Git Repos   | e:/project/gogs/repositories | C:\gogsapp\gogs\repositories |
| Gogs Logs   | e:/project/gogs/logs         | C:\gogsapp\gogs\logs         |
 ---------------------------------------------------------------------------

# Z:\Code\svn\devops\Provisioning\docker\Chocolatey-Docker-NoProxy