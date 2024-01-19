#FROM node:18.18.2
FROM node:18.18.2-alpine

WORKDIR /app

COPY package.json package-lock.json ./

#ENV NODE_ENV production
RUN npm install --maxsockets=1  
#RUN npm ci --maxsockets=1 --production

COPY . .

RUN npm run build

EXPOSE 3000

#CMD npm run dev
CMD ["npm", "start"]
