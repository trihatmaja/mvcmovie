FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /App

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0-noble-chiseled-extra-amd64
WORKDIR /App
RUN apt-get update && apt-get install -y --only-upgrade libc6
COPY --from=build /App/out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "MvcMovie.dll"]