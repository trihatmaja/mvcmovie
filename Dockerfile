FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /inetpub/wwwroot
COPY ./publish/. ./

ENTRYPOINT ["dotnet", "MvcMovie.dll"]