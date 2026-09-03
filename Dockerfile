FROM mcr.microsoft.com/playwright:v1.39.0-jammy
# netlify-cli >=18 requires Node 20.10+ for "import ... with { type: 'json' }"; base image ships Node 18
RUN npm install -g netlify-cli@17 node-jq
# For ubuntu
#RUN npm install -g netlify-cli@17
#RUN apt update apt install -y jq