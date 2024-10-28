FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 5082
EXPOSE 7200

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["TestWithDocker.csproj", "./"]
RUN dotnet restore "TestWithDocker.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "TestWithDocker.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "TestWithDocker.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Проверяем содержимое каталога out
RUN echo "Содержимое каталога out:" && ls -l /app/publish


FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TestWithDocker.dll"]
