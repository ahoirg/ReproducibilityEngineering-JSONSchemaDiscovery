# Use official Debian LTS version
FROM debian:bullseye-slim

# Set workspace
WORKDIR /usr/src

# To ensure stability, some commands were run with more than one RUN command # 

# Install required software
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release wget git unzip build-essential make 

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

# Install texlive to make report
RUN apt-get update && apt-get install -y texlive 
RUN apt-get update && apt-get install -y texlive-latex-extra texlive-latex-recommended
RUN apt-get update && apt-get install -y texlive-fonts-extra

# Pull JSON files from GitHub repo and unzip the students.zip
RUN git clone https://github.com/ahoirg/Ordered-and-Unordered-Json-Data.git /usr/src/json-data \
    && ls -la /usr/src/json-data/ \
    && unzip /usr/src/json-data/students.zip -d /usr/src/json-data/

# Clone JSONSchemaDiscovery and ReproducibilityEngineering-JSONSchemaDiscovery
RUN git clone https://github.com/ahoirg/ReproducibilityEngineering-JSONSchemaDiscovery.git /usr/src/temp \
    && git clone https://github.com/feekosta/JSONSchemaDiscovery.git /usr/src/app
    
# apply patches and run npm install
WORKDIR /usr/src/app
RUN patch package.json < /usr/src/temp/patches/local-access-setup-for-container-and-mongodb.patch
RUN patch .env < /usr/src/temp/patches/set_default_dbport.patch
RUN patch ./client/app/_components/discovery/discovery.component.ts < /usr/src/temp/patches/set_default_db_information.patch
RUN patch ./server/controllers/rawSchema/rawSchemaUnorderedResult.ts < /usr/src/temp/patches/bug_fix_rawSchemaUnorderedResult.patch
RUN npm install
WORKDIR /usr/src

# Create directory for the report and pull report
RUN mkdir -p /usr/src/report \ 
    && git clone https://github.com/ahoirg/LatexCode-RepEng-Project.git /usr/src/report

# Open required ports for application and MongoDB
EXPOSE 27017 4200

# Prepare script to run
RUN mv /usr/src/temp/scripts /usr/src/scripts
WORKDIR /usr/src/scripts
RUN chmod +x start.sh \
    && chmod +x smoke.sh
WORKDIR /usr/src

# Temp files are deleted for a simpler container
RUN rm -rf /usr/src/temp

# Set start.sh script as launch command
ENTRYPOINT ["./scripts/start.sh"]