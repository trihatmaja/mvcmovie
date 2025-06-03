FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.sln .
COPY *.csproj ./aspnetmvcapp/
COPY *.config ./aspnetmvcapp/
RUN dotnet restore

# copy everything else and build app
COPY . ./aspnetmvcapp/
WORKDIR /app/aspnetmvcapp
RUN dotnet publish -c Release -r win-x64 --self-contained false -o ./publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /inetpub/wwwroot
COPY --from=build /app/aspnetmvcapp/publish/. ./