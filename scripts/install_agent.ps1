# This script is meant to be run inside Azure VM to configure build agent. Don't
# forget to provide Personal Access Token as the first argument. This PAT only
# needs "Agent Pools (Read & manage); Code (Read); Code (Status)" access rights.

# IMPORTANT: Disable Server Manager to start automatically at logon.

cd \
wget https://vstsagentpackage.azureedge.net/agent/2.144.0/vsts-agent-win-x64-2.144.0.zip -OutFile agent.zip
#rm -r a
mkdir a
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\agent.zip", "$PWD\a")
rm agent.zip
cd a
.\config.cmd --unattended --url https://jjones.visualstudio.com --auth pat --token $args[0] --runAsService --runAsAutoLogon --pool Default --agent AzureVmAgent --replace

# Install `docker-compose`. Inspired by
# <https://docs.docker.com/compose/install/#install-compose>.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $Env:ProgramFiles\docker\docker-compose.exe

# Make `VSTSAgent` service depends on `docker`.
cmd /c sc config vstsagent.jjones.AzureVmAgent depend=docker

# IMPORTANT: Change Docker and VSTS Agent services to run Automatically, for Local System account and to restart on failures.
# IMPORTANT: Copy file `./scripts/daemon.json` into `%programdata%/docker/config/daemon.json`.

# Install Git LFS.
cd \
wget https://github.com/git-lfs/git-lfs/releases/download/v2.7.1/git-lfs-windows-v2.7.1.exe -OutFile git-lfs.exe
.\git-lfs.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
rm git-lfs.exe

# Install CMake.
wget https://github.com/Kitware/CMake/releases/download/v3.14.3/cmake-3.14.3-win64-x64.msi -OutFile cmake.msi
msiexec /quiet /passive /qn /i cmake.msi
rm cmake.msi
$env:PATH += ";C:\Program Files\CMake\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

# Install Ninja.
wget https://github.com/ninja-build/ninja/releases/download/v1.9.0/ninja-win.zip -OutFile ninja.zip
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\ninja.zip", "$PWD")
rm ninja.zip
mv ninja.exe "C:\Program Files\CMake\bin"
