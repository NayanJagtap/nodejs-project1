#node js alpine image
from node:alpine
#setting up workdirectory
WORKDIR /app
#copying package.json and package.lock.json
COPY package*.json ./
#installing only production dependencies
RUN npm install --only=production
#copying other files
COPY . .
#exposing port 
EXPOSE 3000
#running the app
CMD ["npm","start"]


