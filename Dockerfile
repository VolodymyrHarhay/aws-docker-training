FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm install && npm cache clean --force
WORKDIR /app
COPY . .
RUN npm run build


# created another application layer from the base layer that have alredy build folder with all necessary files
# in the application layer we just do copy and install dependencies and copy only file from dist folder from the base layer
FROM node:18-alpine AS application
WORKDIR /app
COPY --from=base /app/package*.json ./
RUN npm install --only=production
WORKDIR /app
COPY --from=base /app/dist ./dist
RUN npm install pm2@^5.3.0 -g
USER node
ENV PORT=4000
EXPOSE 4000
CMD [ "pm2-runtime", "dist/main.js" ]