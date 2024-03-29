[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# ReproducibilityEngineering-JSONSchemaDiscovery
The repository provides a container that provides an environment where the JSONSchemaDiscovery project can run smoothly and experiments in the paper "An Approach for Schema Extraction of JSON and Extended JSON Document Collections" can be performed.

> **Important:**
> All commits in this repository are linked to the relevant issues opened for the development. You can track which commit resolves which issue through the Issues tab. Each commit is connected to the corresponding issues either through the commit message or comments made on the commit. **There are no commits that are not linked to an issue. This ensures that all commits in the project are easily traceable and understandable.**

## Docker Container Usage Instructions

1. **Clone the Project**: Begin by cloning the repository using `git clone`, or simply download the Dockerfile directly to your device.

   - Run the following code in your local to clone the project. ([git](https://git-scm.com/downloads) software must be installed)
     ```
       git clone https://github.com/ahoirg/ReproducibilityEngineering-JSONSchemaDiscovery.git
     ```
2. **Initialize Docker**: Ensure that Docker is running on your system. If not, start Docker from your system's applications.

3. **Build the Docker Image**:
   - Navigate to the directory where the Dockerfile is located.
   - Open a terminal in this directory.
   - Execute the command:
     ```
     docker build -t json-schema-extraction-tool .
     ```
     - **Note**: The building process might take some time, particularly due to the installation of the Texlive library, which is necessary for compiling reports written in LaTeX.
4. **Verify the Docker Image**:
   - After building, verify the image with `docker images`
   - You should see something like:
     ```
     REPOSITORY                    TAG       IMAGE ID       CREATED         SIZE
     json-schema-extraction-tool   latest    bacf8e125d34   4 minutes ago   4.47GB
     ```
6. **Run the Docker Container**:
   - Use the command:
     ```
       docker run -m 5g --cpus=3 json-schema-extraction-tool .
     ```
     
     - Optional: To ensure repeatability, I recommend running the container with 5gm ram and 3cpu. However, if you want, you can delete these parameters.
       ```
         docker run json-schema-extraction-tool .
       ```
7. **Expected Output**:
   - After running the command in step 6, many texts appear in the console. Operations such as running the database, preparing the data, importing it into the DB, and running the application are done respectively.
   - Upon successful execution, the Json Schema Discovery application will start in the terminal and you will see the following text in the console:

     ```
     ✔ Compiled successfully.
     ```
8. **Access the Container's Shell**:
    - Avoid closing the terminal running your Docker container.
    - Run the command `docker ps` to list all running containers.
    - Look for the container running the JSON Schema Extraction Tool. You will see an output similar to:
       ```
      CONTAINER ID   IMAGE                         COMMAND                  CREATED              STATUS              PORTS                           NAMES
      f76cc43b32c3   json-schema-extraction-tool   "./scripts/start.sh ."   About a minute ago   Up About a minute   3000/tcp, 4200/tcp, 27017/tcp   amazing_elion
       ```
     - Use the command replacing {container_Id} with your actual container ID (e.g., f76cc43b32c3):
       ```
       docker exec -it {container_Id} /bin/bash 
       ``` 
     - After executing this command, you should be inside the container's shell, indicated by a prompt like root@f76cc43b32c3:/usr/src# .

      This allows you to interact with the Docker container directly through the command line.
9. **Start All Process**:
   - Execute commands sequentially in the Docker container's terminal: 
      ```
      cd /usr/src/scripts
      ```
      ```
      ./doAll.sh
      ```
   - doAll.sh script first runs the smoke.sh script and checks whether there is a problem in the container. It then automatically starts the experiments in the report and writes the results to .csv files. Then it automatically creates the report with the new data.
   - When you see the following output in the console, you can find report.pdf by going to /usr/src/report path.
      ```
      The report has been re-generated with new results.
      You can find the report.pdf in /usr/src/report
      ```
  Note: You can open a terminal on your device and use the following command to copy the report to your device:
  ```
    docker cp {container_id}:/usr/src/report/report.pdf .
  ```
Optional: While you are in the "/usr/src/report";
 - You can use the "make report" command to manually create the report.pdf file. 
  ```
    make report
  ```
 - You can delete the report.pdf file and all intermediate files during report creation with the "make clean" command. 
  ```
    make clean
  ```
 - With the " make clean_without_report " command, you can delete all intermediate files during report creation without deleting the report.pdf file.
  ```
    make clean_without_report
  ```
