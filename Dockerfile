FROM dart:stable AS build

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.* ./
RUN dart pub get

# Copy the rest of the project and compile
COPY . .
RUN dart build cli --target bin/bot_server.dart -o output

# Use a minimal runtime image
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/output/bundle/ /app/

EXPOSE 8080

CMD ["/app/bin/bot_server"]
