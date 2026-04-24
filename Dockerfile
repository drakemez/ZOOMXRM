FROM nginx:1.27-alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy static site
COPY index.html /usr/share/nginx/html/index.html
COPY assets /usr/share/nginx/html/assets

# Custom nginx config (listens on 8080 to match fly.toml internal_port)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
