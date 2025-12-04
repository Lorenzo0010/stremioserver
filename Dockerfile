FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 12470

CMD ["nginx", "-g", "daemon off;"]
