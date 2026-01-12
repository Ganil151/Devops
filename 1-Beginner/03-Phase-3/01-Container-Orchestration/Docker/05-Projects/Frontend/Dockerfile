FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy website files
COPY html/ /usr/share/nginx/html/

# No need to specify EXPOSE or CMD as nginx:alpine already does
