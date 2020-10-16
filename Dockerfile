## This Dockerfile is used by Jenkins to build the release image
# Using Microsoft .net core image
FROM mcr.microsoft.com/dotnet/core/sdk:3.1
EXPOSE 80
EXPOSE 8080
# Maintainer
LABEL maintainer "support@ffm.vic.gov.au"
# Set an internal health check for diagnostics
HEALTHCHECK --interval=5s --timeout=5s CMD curl -f http://127.0.0.1:80 || exit 1
# Install node
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs
RUN npm install
# Set the dir where the app should be located
WORKDIR /app
# Copy the application from the APP_PATH env var to .
ARG APP_PATH
RUN echo $APP_PATH
COPY $APP_PATH .
RUN mkdir -p /var/baget
RUN chmod 755 /var/baget
# Set the entrypoint for the container
ENTRYPOINT ["dotnet", "BaGet.dll"]
