# Use the official Nginx image as the base
FROM nginx:latest

# Remove the default Nginx configuration
RUN rm -rf /usr/share/nginx/html/*

# Copy the Tetris game files to the Nginx HTML directory
COPY . /usr/share/nginx/html

# Expose the port Nginx will listen on
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]