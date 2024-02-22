# Use official Debian LTS version
FROM debian:bullseye-slim

# Set workspace
WORKDIR /usr/src

# Install required software
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release wget git \ 
    build-essential make python3 python3-pip && pip3 install requests

# Add texlive for generate report
RUN apt-get update && apt-get install -y texlive texlive-latex-extra texlive-latex-recommended texlive-fonts-extra
    
# Install Node.js LTS
RUN apt-get update \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Add MongoDB repository and prepare to use
RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add - \
    && echo "deb http://repo.mongodb.org/apt/debian bullseye/mongodb-org/5.0 main" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list \
    && apt-get update \
    && apt-get install -y mongodb-org \
    # Create the MongoDB data directory
    && mkdir -p /data/db \
    # Create and set MongoDB configuration file
    && echo "net:" > /etc/mongod.conf \
    && echo "  bindIp: 0.0.0.0" >> /etc/mongod.conf

# Create directory for the report and pull report
RUN mkdir -p /usr/src/report \ 
    && git clone https://github.com/ahoirg/LatexCode-RepEng-Project.git /usr/src/report

# Clone JSONSchemaDiscovery and ReproducibilityEngineering-JSONSchemaDiscovery
RUN git clone https://github.com/ahoirg/ReproducibilityEngineering-JSONSchemaDiscovery.git /usr/src/temp \
    && git clone https://github.com/feekosta/JSONSchemaDiscovery.git /usr/src/app

# Clone and prepare the data for experiments
RUN git clone https://github.com/feekosta/datasets.git /usr/src/json-data &&\
    tar -xvjf /usr/src/json-data/companies/dbpedia_companies1.json.tar.bz2 -C /usr/src/json-data/ && \
    mv /usr/src/json-data/dbpedia_companies1.json /usr/src/json-data/companies.json && \
    tar -xvjf /usr/src/json-data/drugs/dbpedia-drugs1.json.tar.bz2 -C /usr/src/json-data/ && \
    mv /usr/src/json-data/dbpedia-drugs1.json /usr/src/json-data/drugs.json && \
    tar -xvjf /usr/src/json-data/movies/dbpedia_movies1.json.tar.bz2 -C /usr/src/json-data/ && \
    mv /usr/src/json-data/dbpedia_movies1.json /usr/src/json-data/movies.json && \
    # Delete all files and folders except .json files
    find /usr/src/json-data/ ! -name '*.json' -type f -exec rm -f {} + && \
    find /usr/src/json-data/ -mindepth 1 -type d -exec rm -rf {} +

# Apply patches and run npm install
WORKDIR /usr/src/app
RUN patch package.json < /usr/src/temp/patches/local-access-setup-for-container-and-mongodb.patch
RUN patch .env < /usr/src/temp/patches/set_default_dbport.patch
RUN patch ./client/app/_components/discovery/discovery.component.ts < /usr/src/temp/patches/set_default_db_information.patch
RUN patch ./server/controllers/rawSchema/rawSchemaUnorderedResult.ts < /usr/src/temp/patches/bug_fix_rawSchemaUnorderedResult.patch
RUN npm install
WORKDIR /usr/src

# Open required ports for application and MongoDB
EXPOSE 27017 4200 3000

# Prepare script to run
RUN mv /usr/src/temp/scripts /usr/src/scripts
WORKDIR /usr/src/scripts
RUN chmod +x start.sh \
    && chmod +x doAll.sh \
    && chmod +x exp.py \
    && chmod +x smoke.sh

WORKDIR /usr/src

# Temp files are deleted for a simpler container
RUN rm -rf /usr/src/temp

# Set start.sh script as launch command
ENTRYPOINT ["./scripts/start.sh"]