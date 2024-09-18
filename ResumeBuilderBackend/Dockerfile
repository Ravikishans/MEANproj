# Use the official Node.js image.
# https://hub.docker.com/_/node
FROM node:18

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Compile TypeScript code
RUN npm run build

#install dependencies
COPY dependencies.sh /dependencies.sh
RUN bash dependencies.sh

# Expose the port
EXPOSE 4292

# Run the application
CMD [ "./dependencies.sh" ]
