# build environment
FROM node:18.18.2-alpine as build
WORKDIR /app
COPY . .

RUN npm install --maxsockets=1
RUN npm run build

# production environment
FROM nginx:1.25.3-alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
