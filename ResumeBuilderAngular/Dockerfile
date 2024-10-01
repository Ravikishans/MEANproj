# Step 1: Build Angular frontend
FROM node:18-alpine AS build-frontend

# Install git and bash, required to clone the repository and other basic commands
RUN apk add --no-cache git bash

WORKDIR /app/frontend

# Clone the frontend repository
RUN git clone https://github.com/Ravikishans/MEANproj.git

# Adjust WORKDIR to match the actual path where package.json is located
# WORKDIR /app/frontend/MEANproj/ResumeBuilderAngular
RUN cd /app/frontend/MEANproj/ResumeBuilderAngular
RUN ls -al

# Install dependencies
RUN npm install --force

# Install Angular CLI globally
RUN npm install -g @angular/cli

# Build the Angular project for production
RUN ng build --configuration production

# Step 2: Serve Angular using angular-http-server
FROM node:18-alpine AS serve-frontend

WORKDIR /app

# Copy the Angular build from the previous stage
COPY --from=build-frontend /app/frontend/MEANproj/ResumeBuilderAngular/dist /app

# Install angular-http-server globally
RUN npm install -g angular-http-server

# Create proxy.js file for API requests forwarding to the backend
RUN echo "module.exports = { \
    proxy: [{ \
        forward: ['api/'], \
        target: 'http://backend:4292', \
        protocol: 'http', \
    }], \
};" > /app/proxy.js

# Expose port 80
EXPOSE 80

# Serve the Angular app with proxy configuration
CMD ["angular-http-server", "-p", "80", "--path", "/app/resumebuilder"]
