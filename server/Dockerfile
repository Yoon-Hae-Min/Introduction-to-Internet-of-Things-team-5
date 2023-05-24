# Base image
FROM node:16

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose a port (if your Node.js application listens on a specific port)
EXPOSE 8080

# Start the Node.js application
CMD [ "npm", "start" ]