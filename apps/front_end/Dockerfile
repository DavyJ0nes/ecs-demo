FROM prom/busybox
MAINTAINER DavyJ0nes <davy.jones@me.com>

RUN mkdir -p /templates/static
ADD templates/index.html /templates/index.html
COPY templates/static/* /templates/static/
ADD davyj-ao-training-frontend /
EXPOSE 8080
CMD ["./davyj-ao-training-frontend"]
