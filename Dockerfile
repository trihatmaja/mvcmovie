FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /App

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -r linux-musl-x64 --self-contained true -o out

# Build runtime image
FROM alpine:latest
WORKDIR /App
COPY --from=build /App/out .
RUN apk update && \
    apk add --no-cache libstdc++ libgcc && \
    addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser && \
    chown -R appuser:appgroup /App

USER appuser
ENTRYPOINT ["./MvcMovie"]