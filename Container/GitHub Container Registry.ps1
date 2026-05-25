# GitHub Container Registry ghcr.io
#
# https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry

docker images
docker images --filter "reference=bharathshetty4/supermario:latest"
docker images | Select-String '8f0ad4a681d1'

docker tag bharathshetty4/supermario:latest ghcr.io/www42/supermario:latest

docker login ghcr.io  # Username --> www42    
                      # Password --> Token (classic)

docker push ghcr.io/www42/supermario:latest                       