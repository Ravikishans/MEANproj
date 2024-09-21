# MEANproj
---

# Resume Builder Application

This is a full-stack application for building resumes, consisting of a Node.js backend (with TypeScript) and an Angular frontend. The frontend interacts with the backend API for generating and managing resumes.

## Table of Contents
- [Project Overview](#project-overview)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Running Locally](#running-locally)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Using Docker](#using-docker)
  - [Backend Dockerfile](#backend-dockerfile)
  - [Frontend Dockerfile](#frontend-dockerfile)
  - [Entrypoint Script for Frontend](#entrypoint-script-for-frontend)
  - [Nginx Configuration Template](#nginx-configuration-template)
- [Docker Compose](#docker-compose)
  - [Single Instance Setup](#single-instance-setup)
  - [Multiple Instances Setup](#multiple-instances-setup)
- [Pushing Docker Images to Docker Hub](#pushing-docker-images-to-docker-hub)
- [Deploying to EC2](#deploying-to-ec2)
  - [Pulling Images from Docker Hub](#pulling-images-from-docker-hub)
- [Additional Configuration](#additional-configuration)

---

## Project Overview

The Resume Builder Application consists of:
- **Backend**: A Node.js server using TypeScript, providing API endpoints for resume generation and management.
- **Frontend**: An Angular application providing the user interface for interacting with the backend.

## Technologies Used

- **Node.js** (Backend)
- **TypeScript** (Backend)
- **Angular** (Frontend)
- **MongoDB** (Database)
- **Docker** (Containerization)
- **Nginx** (For serving frontend and proxying requests to backend)
  
## Prerequisites

- [Node.js](https://nodejs.org/en/) installed (for running locally).
- [Docker](https://docs.docker.com/get-docker/) installed (for containerization).
- [MongoDB](https://www.mongodb.com/) (For running locally or using a cloud provider).
  
## Running Locally

### Backend Setup

1. Clone the backend repository into a folder called `backend`:
    ```bash
    git clone https://github.com/SaiGovardhana/ResumeBuilderBackend.git backend
    ```

2. Move into the directory:
    ```bash
    cd backend
    ```

3. Install npm dependencies:
    ```bash
    npm install
    ```

4. Compile TypeScript code:
    ```bash
    npm run build
    ```

5. Create a `.env` file with the following variables:
    ```bash
    JWT_SECRET_KEY="YOUR_SECRET_KEY"
    MONGO_URL="mongodb://YOUR_MONGO_URL"
    OPENAI_KEY="YOUR_OPENAI_KEY"
    GMAIL_USER="YOUR_GMAIL_EMAIL"
    GMAIL_PASS="YOUR_GMAIL_PASSWORD"
    FRONT_END="http://localhost:80"  # Point this to the frontend URL
    ```

6. Run the backend:
    ```bash
    npm start
    ```

### Frontend Setup

1. Clone the frontend repository into a folder called `frontend`:
    ```bash
    git clone https://github.com/SaiGovardhana/ResumeBuilderFrontend.git frontend
    ```

2. Move into the directory:
    ```bash
    cd frontend
    ```

3. Install npm dependencies:
    ```bash
    npm install
    ```

4. Run the application in development mode:
    ```bash
    npm start
    ```

## Using Docker

### Backend Dockerfile

1. **Create a `Dockerfile` in the `backend` directory**:

    ```Dockerfile
    FROM node:18

    # Set the working directory
    WORKDIR /usr/src/app

    # Copy package.json and install dependencies
    COPY package*.json ./
    RUN npm install

    # Copy the rest of the application
    COPY . .

    # Compile TypeScript code
    RUN npm run build

    # Expose the port
    EXPOSE 4292

    # Command to run the app
    CMD [ "node", "dist/main/index.js" ]
    ```

2. **Build the Docker image for the backend**:
    ```bash
    docker build -t backend-image .
    ```

### Frontend Dockerfile

1. **Create a `Dockerfile` in the `frontend` directory**:

    ```Dockerfile
    FROM node:18 AS build

    # Set the working directory
    WORKDIR /usr/src/app

    # Copy package.json and install dependencies
    COPY package*.json ./
    RUN npm install

    # Copy the application and build it
    COPY . .
    RUN npm run build --prod

    # Use nginx to serve the application
    FROM nginx:alpine
    COPY --from=build /usr/src/app/dist /usr/share/nginx/html

    # Copy nginx configuration template and entrypoint script
    COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh

    # Run entrypoint script
    CMD ["/entrypoint.sh"]
    ```

2. **Build the Docker image for the frontend**:
    ```bash
    docker build -t frontend-image .
    ```

### Entrypoint Script for Frontend

Create an `entrypoint.sh` script for the frontend to substitute environment variables into the Nginx configuration:

```bash
#!/bin/sh

envsubst '${BACKEND_URL}' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/nginx.conf
nginx -g 'daemon off;'
```

### Nginx Configuration Template

Create an `nginx.conf.template` file for the frontend:

```nginx
server {
    listen 80;

    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://$BACKEND_URL;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Docker Compose

You can use Docker Compose to orchestrate both backend and frontend containers.

### Single Instance Setup

1. Create a `docker-compose.yml` file:

    ```yaml
    version: '3'
    services:
      backend:
        image: backend-image
        ports:
          - "4292:4292"
        environment:
          - JWT_SECRET_KEY=${JWT_SECRET_KEY}
          - MONGO_URL=${MONGO_URL}
          - OPENAI_KEY=${OPENAI_KEY}
          - GMAIL_USER=${GMAIL_USER}
          - GMAIL_PASS=${GMAIL_PASS}
          - FRONT_END=http://localhost:80
      frontend:
        image: frontend-image
        ports:
          - "80:80"
        environment:
          - BACKEND_URL=http://backend:3001
    ```

2. Run Docker Compose:
    ```bash
    docker-compose up
    ```

### Multiple Instances Setup

For multiple instances (e.g., separate EC2 instances for backend and frontend), you'll need to pull the images from Docker Hub and configure environment variables accordingly.

## Pushing Docker Images to Docker Hub

1. Tag your images:
    ```bash
    docker tag backend-image <your_dockerhub_username>/backend-image
    docker tag frontend-image <your_dockerhub_username>/frontend-image
    ```

2. Push the images:
    ```bash
    docker push <your_dockerhub_username>/backend-image
    docker push <your_dockerhub_username>/frontend-image
    ```

## Deploying to EC2

Once your images are on Docker Hub, you can pull them onto your EC2 instances and run them.

### Pulling Images from Docker Hub

1. SSH into your EC2 instance.
2. Pull the Docker images:
    ```bash
    docker pull <your_dockerhub_username>/backend-image
    docker pull <your_dockerhub_username>/frontend-image
    ```

3. Run the backend container:
    ```bash
    docker run -d -p 4292:4292 backend-image
    ```

4. Run the frontend container with the correct backend URL:
    ```bash
    docker run -d -p 80:80 -e BACKEND_URL=http://<backend_instance_ip>:3001 frontend-image
    ```

## Additional Configuration

- Ensure that your security groups in AWS EC2 allow traffic on the necessary ports (80 for HTTP, 4292 for backend API).
- Use an environment variable (`BACKEND_URL`) in Nginx configuration to dynamically set the backend API URL.

---
