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
    git clone https://github.com/Ravikishans/MEANproj.git backend
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
    git clone https://github.com/Ravikishans/MEANproj.git frontend
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
    # Step 1: Use Node.js base image
    FROM node:18-alpine

    # Step 2: Set working directory
    WORKDIR /app/backend

    # Step 3: Clone the backend repository
    RUN apk update && apk add git
    RUN git clone https://github.com/Ravikishans/MEANproj.git .

    # Adjust WORKDIR to match the actual path where package.json is located
    WORKDIR /app/backend/MEANproj/ResumeBuilderBackend
    RUN ls -la /app/backend/MEANproj/ResumeBuilderBackend

    # Step 4: Install Node.js dependencies
    RUN npm install --force

    # Step 5: Install Puppeteer dependencies for EC2 (Alpine-based packages)
    RUN apk add --no-cache \
        chromium \
        nss \
        freetype \
        harfbuzz \
        ca-certificates \
        ttf-freefont \
        libx11 \
        libxcomposite \
        libxrender \
        libxdamage \
        libxi \
        libxtst \
        libnss \
        libnspr \
        libatk \
        libdbus \
        libexpat \
        libxrandr \
        libxfixes \
        wget \
        xdg-utils

    # Step 6: Install TypeScript globally and compile the TypeScript code
    RUN npm install -g typescript
    RUN tsc

    # Step 7: Copy .env file (should be added to your local project or passed at runtime)
    COPY .env /app/backend/.env

    # Step 8: Expose backend port 4292
    EXPOSE 4292

    # Step 9: Environment variables for MongoDB (optional if you use .env)
    ENV NODE_ENV=production
    ENV MONGO_URL=mongodb://ravikishan:Cluster0@cluster0.y9zohpu.mongodb.net:27017/
    # Step 10: Command to start the backend server
    CMD ["nohup", "npm", "start", "&"]

    ```

2. **Build the Docker image for the backend**:
    ```bash
    docker build -t backend-image .
    ```

### Frontend Dockerfile

1. **Create a `Dockerfile` in the `frontend` directory**:

    ```Dockerfile
    # Step 1: Build Angular frontend
    FROM node:18-alpine AS build-frontend

    # Install git and bash, required to clone the repository and other basic commands
    RUN apk add --no-cache git bash

    WORKDIR /app/frontend

    # Clone the frontend repository
    RUN git clone https://github.com/Ravikishans/MEANproj.git

    # Adjust WORKDIR to match the actual path where package.json is located
    WORKDIR /app/frontend/MEANproj/ResumeBuilderAngular

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

    ```

2. **Build the Docker image for the frontend**:
    ```bash
    docker build -t frontend-image .
    ```


## Docker Compose

You can use Docker Compose to orchestrate both backend and frontend containers.

### Single Instance Setup

1. Create a `docker-compose.yml` file:

    ```yaml
    version: '3.8'

    services:
    
    backend:
        build:
        context: ./ResumeBuilderBackend
        dockerfile: Dockerfile
        image: ravikishans/meanproj:backend
        ports:
        - "4292:4292"


    angularcli:
        build:
        context: ./ResumeBuilderAngular
        dockerfile: Dockerfile
        image: ravikishans/meanproj:frontend
        ports:
        - "80:80"

        depends_on:
        - backend
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

Here’s how you can extend your README file by adding the steps for deploying your MEAN project to **Amazon EKS (Elastic Kubernetes Service)**.

### Deploying to Amazon EKS

To deploy the Resume Builder application to an Amazon EKS cluster, follow these steps:

---

## Prerequisites

- **AWS CLI** installed and configured ([Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)).
- **kubectl** installed ([Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)).
- **eksctl** installed for managing EKS clusters ([Installation Guide](https://eksctl.io/introduction/#installation)).
- Docker images pushed to Docker Hub (or another registry accessible to EKS).

## Steps for EKS Deployment

### 1. Create an EKS Cluster

Use `eksctl` to create a cluster in your AWS account.

```bash
eksctl create cluster \
--name resume-builder-cluster \
--region <your-aws-region> \
--nodegroup-name resume-builder-nodes \
--node-type t3.medium \
--nodes 2 \
--nodes-min 1 \
--nodes-max 3 \
--managed
```

- Replace `<your-aws-region>` with the AWS region where you want the cluster (e.g., `us-east-1`).
- This command creates a managed EKS cluster with 2 nodes, with auto-scaling enabled.

### 2. Configure kubectl

Once the cluster is created, configure `kubectl` to interact with your EKS cluster.

```bash
aws eks --region <your-aws-region> update-kubeconfig --name resume-builder-cluster
```

Now, you can run `kubectl` commands to manage the cluster.

### 3. Create Kubernetes Resources

1. **Create a namespace** for the application:
   ```bash
   kubectl create namespace frontendrb
   ```

2. **Apply Kubernetes manifests** for your backend and frontend services.

#### Deployment

1. Create a `deployment.yaml` file for deploying the backend service:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    namespace: backendrb
    name: be-deploy-rb
    spec:
    selector:
        matchLabels:
        app: resumebuilder
    template:
        metadata:
        labels:
            app: resumebuilder
        spec:
        containers:
        - name: resumebuilder
            image: ravikishans/resumebuilder:backend
            env:
            - name: MONGO_URI
            valueFrom:
                secretKeyRef:
                name: backend-secret
                key: MONGO_URI
            - name: PORT
            value: "4292"
            # resources:
            #   limits:
            #     memory: "128Mi"
            #     cpu: "500m"
            ports:
            - containerPort: 4292



    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    namespace: frontendrb
    name: fe-deploy-rb
    spec:
    selector:
        matchLabels:
        app: resumebuilder
    template:
        metadata:
        labels:
            app: resumebuilder
        spec:
        containers:
        - name: resumebuilder
            image: ravikishans/resumebuilder:fe_angular
            env:
            - name: REACT_APP_BACKEND_URL
            valueFrom:
                configMapKeyRef:
                name: rb-config
                key: REACT_APP_BACKEND_URL
            # resources:
            #   limits:
            #     memory: "128Mi"
            #     cpu: "500m"
            ports:
            - containerPort: 80




    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    namespace: databaserb
    name: db-deploy-rb
    spec:
    replicas: 1
    selector:
        matchLabels:
        app: resumebuilder
    template:
        metadata:
        labels:
            app: resumebuilder
        spec:
        containers:
        - name: resumebuilder
            image: mongo:latest
            # resources:
            #   limits:
            #     memory: "128Mi"
            #     cpu: "500m"
            ports:
            - containerPort: 27017
            volumeMounts:
            - mountPath: /data/db
            name: mongodb-storage
        volumes:
        - name: mongodb-storage
            persistentVolumeClaim:
            claimName: rb-pvc

    ```

2. Deploy it using:

    ```bash
    kubectl apply -f deployment.yaml
    ```

#### service

1. Create a `service.yaml` file for deploying the frontend service:

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
    namespace: backendrb
    name: be-service-rb
    spec:
    type: LoadBalancer
    selector:
        app: resumebuilder
    ports:
    - port: 4292
        targetPort: 4292



    ---
    apiVersion: v1
    kind: Service
    metadata:
    namespace: frontendrb
    name: fe-service-rb
    spec:
    type: LoadBalancer
    selector:
        app: resumebuilder
    ports:
    - protocol: TCP
        port: 80
        targetPort: 80

    ---
    apiVersion: v1
    kind: Service
    metadata:
    namespace: databaserb
    name: db-service-rb
    spec:
    selector:
        app: resumebuilder
    ports:
    - protocol: TCP
        port: 27017
        targetPort: 27017
    type: LoadBalancer

    ```

2. Deploy it using:

    ```bash
    kubectl apply -f service.yaml
    ```

### 4. Create a ConfigMap for Environment Variables

Create a `configmap.yaml` file to store environment variables, such as the backend URL.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: frontendrb
  name: rb-config
data:
  REACT_APP_BACKEND_URL: "http://be-service-rb:4292"
```

Apply the config map:

```bash
kubectl apply -f configmap.yaml
```

### 5. Access the Application

Once the LoadBalancer is created, you can retrieve the public URL by running:

```bash
kubectl get svc -n frontendrb
```

Access the frontend using the external IP (LoadBalancer's IP), and it should connect to the backend via the internal service (`backend-service`).

### 6. Monitor the Application

You can monitor the status of your deployments and services with these commands:

```bash
kubectl get pods -n frontendrb
kubectl get svc -n frontendrb
kubectl logs <pod-name> -n frontendrb
```

### 7. Scaling the Application

You can scale the number of pods for the frontend or backend deployments if needed:

```bash
kubectl scale deployment fe-deploy-rb --replicas=5 -n frontendrb
kubectl scale deployment be-deploy-rb --replicas=5 -n frontendrb
```

---

These steps provide a basic guide for deploying the Resume Builder application to Amazon EKS.
