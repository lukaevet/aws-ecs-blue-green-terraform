# Use the official Node.js 10 image.
# https://hub.docker.com/_/node
FROM node:16

# Create and change to the app directory.
WORKDIR /pages

# Copy the package.json and package-lock.json files.
# A wildcard is used to ensure both package files are copied.
# Copying these files first allows Docker to cache installed dependencies
# between builds, reducing build time.
COPY package*.json ./

# Install production dependencies.
RUN npm install --only=production

# Copy local code to the container image.
COPY . .

RUN npx browserslist@latest --update-db -y

# Build the Next.js app for production.
RUN npm run build

# Run the web service on container startup.
CMD [ "npm", "start" ]
