# .net 5 Custom Aws Lambda Runtime
build a sample dotnet 5 bootstrap executable for a amazon custom lambda runtime

- execute `build -win` to test-build on windows
- execute `build -container` to startup an interactive docker container in which a linux ready 2 run assebly can be built
- execute `build` within the docker container to build the bootstrap assembly and a zip containing the assembly ready to upload it to your aws lambda

## Linux Dev Env
the project was build on and with windows and powershell. it shouldn't be hard to make it work on linux though.

when you have powershell installed, you can simply try to run `build.ps1` without arguments
