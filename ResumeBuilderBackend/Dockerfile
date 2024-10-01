# 
# Step 1: Use Node.js base image
FROM node:18-alpine

# Step 2: Set working directory
WORKDIR /app/backend

# Step 3: Clone the backend repository
RUN apk update && apk add git
RUN git clone https://github.com/Ravikishans/MEANproj.git .

# Step 4: List the directory to ensure correct structure
RUN ls -R /app/backend

# Adjust WORKDIR to match the actual path where package.json is located
WORKDIR /app/backend/MEANproj/ResumeBuilderBackend
RUN ls -la
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
