# Use the official Flutter Docker image
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy project files
COPY pubspec.yaml pubspec.lock ./
COPY lib ./lib
COPY web ./web
COPY assets ./assets
COPY analysis_options.yaml ./

# Accept build arguments for environment variables
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG OPENAI_API_KEY
ARG API_URL

# Create .env file from build arguments
RUN echo "SUPABASE_URL=$SUPABASE_URL" > .env && \
    echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env && \
    echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> .env && \
    echo "API_URL=$API_URL" >> .env

# Get dependencies
RUN flutter pub get

# Build the web app
RUN flutter build web --release --web-renderer canvaskit

# Use nginx to serve the built web app
FROM nginx:alpine

# Copy the built web app to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

