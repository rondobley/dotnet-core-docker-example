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