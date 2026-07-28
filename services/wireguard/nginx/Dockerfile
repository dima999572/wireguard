FROM nginx:1.27-alpine

RUN rm -f /etc/nginx/conf.d/default.conf

COPY conf.d/reverse-proxy.conf /etc/nginx/conf.d/reverse-proxy.conf
