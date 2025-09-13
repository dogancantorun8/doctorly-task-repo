# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY *.sln ./
COPY DemoApi/*.csproj DemoApi/
RUN dotnet restore

COPY DemoApi/ DemoApi/
WORKDIR /src/DemoApi
RUN dotnet publish -c Release -o /out

# Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /out .
EXPOSE 8080
ENTRYPOINT [ "dotnet", "DemoApi.dll" ]
