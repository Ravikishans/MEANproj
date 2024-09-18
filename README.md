# MEANproj
# Use official Node.js image as the base
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the code
COPY . .

# Build TypeScript files
RUN npm run build

# Expose port 4292 for the backend
EXPOSE 4292

# Start the application
CMD ["node", "dist/main/index.js"]
