FROM mcr.microsoft.com/azurelinux/base/nodejs:20
WORKDIR /usr/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 8000
CMD [ "node", "dist/index.js" ]