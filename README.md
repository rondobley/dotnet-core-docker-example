# .NET Core Docker Example

## The Dockerfile, the basis of all Docker images
This is a basic bare bones `Dockerfile` for a .NET Core App. We will break it
down, part by part. For .NET Core, the process is a two step process. First, we create
a build image that we use to build the project. Them, we will use the results of that build
to build a runtime image that will be used to actually run the project. First, take a look
at the entire file, then we will break it down.

```dockerfile
# build
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /sln

# copy sln and nuget files
COPY ./*.sln ./
#COPY ./src/NuGet.Config ./src/

# Copy csproj and restore as distinct layers
COPY ./src/DockerExample.csproj ./src/
RUN dotnet restore -r linux-x64

# Copy everything else and build
COPY . ./
RUN dotnet build -c Release -r linux-x64

RUN dotnet publish "./src/DockerExample.csproj" -c Release -o "../../out" -r linux-x64 --no-build

# run
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS runtime

WORKDIR /app

COPY --from=build ./out/ ./

ENTRYPOINT ["dotnet", "DockerExample.dll"]
```
The first line

`FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build`
 
is saying to pull that image as the base for us to
build our image on top of and it aliases it as `build` so we can reference it
later when we create the runtime image. This base image has all of the dependencies
we need to build our .NET Core project. The next line

`WORKDIR /sln`

says set the working `dir` to `/sln` (note: we
are tageting an Linux ENV so the paths and commands will be Linux style).

The next thing we want to do is copy our local solution file to the image.

`COPY ./*.sln ./`

The path starts from wherever you are running the `docker` command, and in this case we
assume (you need to be) in the root directory of the project. This command says 'copy all of 
the .sln files in the directory I am running the `docker build` command in to the root `/` dir
of the image/container'. The next line is commented out, but if you had Nuget packages 
(and most project do) this is where you would want to copy them as well. 
This example does not, thus it is commented out.

The next line

`COPY ./src/DockerExample.csproj ./src/`

copies the project file to the image. Next, we want to run `restore` and target a Linux
runtime ENV.

`RUN dotnet restore -r linux-x64`

Now we are ready to copy everything else in the solutions and build it, again, targeting
a Linux runtime ENV.

```
COPY . ./
RUN dotnet build -c Release -r linux-x64
```

Now it is time to create release of our .NET Core project

`RUN dotnet publish "./src/DockerExample.csproj" -c Release -o "../../out" -r linux-x64 --no-build
`

This is the same standard `dotnet publish` command used to publish a .NET Core app. Again,
we are targeting a Linux runtime. (The irony of running Microsoft code in Linux will never
cease to amaze me :D ).

Now, we have created an image and used it to build our project. Next, it is time to create
a runnable image that can be used as a container to to actual run our code. We start, again, 
by pulling in a base image

`FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS runtime`

Next, we will set the working dir to `/app` on the image (i.e., this is where are commands
on the image will be run from).

`WORKDIR /app`

Next, we are goinf to copy the results of our build from the `build` image, to our `runtime`
image.

`COPY --from=build ./out/ ./`

And, finally, we are going to run our code

`ENTRYPOINT ["dotnet", "DockerExample.dll"]`

This final line says run the `dotnet` command and pass it the `DockerExample.dll` as
a parameter, thus runing our code.

This wraps up the basics needed to build and deploy a dockerized .NET Core app. The directory
structure for this is not a requirement, rather, it is one way to structure your .NET Core
apps.

## The Build

Now that we have defined what we want our image to contain, we need to build it. In order 
to do that, we run the following command from the `root` of the project. (Note:
replace `[your-docker-hub-account]` with, well, your Dockerhub account).

`docker build -f build/DockerExample.Dockerfile -t [your-docker-hub-account]/dotnetcoredockerexample .`

What this command says is build an image using the Dockerfile (`-f` specifies the Dockerfile
to use, if you do not specify a file it will use the `Dockerfile` (and it must be named
`Dokerfile`) in the current working directory) `DockerExample.Dockerfile`
that is in the `build` directory and tag is as `[your-docker-hub-account]/dotnetcoredockerexample` and use
the current direcotry `.` as the build context. (Other build contexts are beyond the scope
of this example).

Now, we have built an image. At some point you will want to learn how to version your
images with version tags, but right now we are sticking to the basics.

## Test the Build

To be prudent, we should probably make sure our image runs as expected. To run the image
use the following command:

`docker run -p80:80 [your-docker-hub-account]/dotnetcoredockerexample`

## Push the Image

To push the image and make the world a better place with your awesome app:

`docker push [your-docker-hub-account]/dotnetcoredockerexample`

That's it. Now you have built a .NET Core app, dockerized it, ran it, and pushed it for others
to use. Congratulations! Grab a beer and celebrate. Also, update your Linkedin profile with
your newfound skills.