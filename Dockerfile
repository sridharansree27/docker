# 1. FROM – base image
# Sets the base image for your Docker image. It’s always the first instruction
# We can also use FROM scratch for starting from empty
FROM python:3.10-slim

# 2. LABEL – metadata
LABEL maintainer="sridharan@example.com"
LABEL version="1.0.0"

# 3. ARG – build-time variable
# ARG variables are available only during the image build phase (within Dockerfile instructions like RUN)
# They are not accessible in the running container and are not persisted in the final image like ENV variables are
ARG NODE_ENV=dev
RUN echo "Build environment is $NODE_ENV"

# 4. ENV – runtime environment variable
# Sets an environment variable named APP_ENV inside the container
ENV APP_ENV=production
ENV MONGO_HOST=mongodb

# 5. SHELL – use bash shell
# This sets the default shell used for running all subsequent RUN commands in the Dockerfile
# By default docker uses SHELL ["/bin/sh", "-c"]
SHELL ["/bin/bash", "-c"]

# 6. RUN – install packages (git is sample)
# Runs a shell command during the image build process
# Each RUN creates a new layer
RUN apt-get update && apt-get install -y curl

# 7. RUN – create a non-root user
RUN useradd -ms /bin/bash sridharan

# 8. WORKDIR – working directory
# Sets the working directory inside the image
# All the following commands will run from here
# Similar to cd in shell
WORKDIR /app

# 9. COPY --chown – copy with ownership
# Copies files or folders from host(local machine) into the image
# Source is local and destination is inside image
COPY --chown=sridharan:sridharan app/requirements.txt .

# 10. RUN – install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 11. COPY --chown – copy full app
COPY --chown=sridharan:sridharan app/ .

# 12. ADD – used to copy local files, remote URLs, or unpack compressed archives
# ADD https://example.com/file.txt /app/file.txt     # Downloads a remote file and places it inside the container
# ADD my-app.tar.gz /app     # Automatically extracts the archive into /app

# 13. VOLUME – declare volume
VOLUME ["/data"]

# 14. EXPOSE – document port
# The container is advertising that it listens on port 80 and port 5000 internally
# It does not open the ports to the host by itself
EXPOSE 80
EXPOSE 5000

# 15. HEALTHCHECK – sample health check
# Defines how to check if the container is healthy
HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1

# 16. STOPSIGNAL – graceful shutdown
# This instruction tells Docker what signal to send to the container’s main process when you stop or remove the container
STOPSIGNAL SIGTERM

# 17. ONBUILD – used in child builds (optional here)
#  When someone uses this image in their own Dockerfile, it will copy their code (current dir) to /app inside the image
ONBUILD COPY . /app
# Then it will install Python dependencies from requirements.txt in that /app folder
ONBUILD RUN pip install -r /app/requirements.txt

# 18. USER – switch to non-root user
# All subsequent RUN, CMD, ENTRYPOINT, COPY, and ADD instructions will run as the user sridharan instead of root
# When the container starts, it will run under the user sridharan by default
USER sridharan

# 19. ENTRYPOINT + CMD – run app
# This sets the main executable that will always run when the container starts
# In this case, it tells Docker
  # Always run the python command when the container starts
#Think of ENTRYPOINT as the fixed base command
ENTRYPOINT ["python"]

# This provides default arguments to the ENTRYPOINT
# It appends to the ENTRYPOINT unless overridden at runtime(docker run image <command>)
CMD ["app.py"]

# so the container will execute python app.py