FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1 AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnetmvcapp/*.csproj ./aspnetmvcapp/
COPY aspnetmvcapp/*.config ./aspnetmvcapp/
RUN nuget restore

# copy everything else and build app
COPY aspnetmvcapp/. ./aspnetmvcapp/
WORKDIR /app/aspnetmvcapp
RUN msbuild /p:Configuration=Release -r:False

FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8.1 AS runtime
WORKDIR /inetpub/wwwroot
COPY --from=build /app/aspnetmvcapp/. ./

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0@sha256:b4bea3a52a0a77317fa93c5bbdb076623f81e3e2f201078d89914da71318b5d8
WORKDIR /App
ENTRYPOINT ["dotnet", "MvcMovie.dll"]