FROM ljay/amaz-nginx:linux2-1.18.0

# dev (Development/Local System)
# test (Test/Stage System)
# prod
ARG stage=dev

COPY .docker/nginx/nginx.conf /etc/nginx/
COPY .docker/nginx/cloudflare-real-ip.conf.cf /etc/nginx/conf.d/
COPY .docker/nginx/sample.$stage.conf /etc/nginx/conf.d/
COPY .docker/nginx/upstream.conf /etc/nginx/conf.d/upstream.conf
