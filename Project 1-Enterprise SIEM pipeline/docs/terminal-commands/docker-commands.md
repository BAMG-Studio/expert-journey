# Docker Commands for SIEM Pipeline

## LocalStack Container
```bash
# Start LocalStack (mock AWS)
docker-compose up -d

# Check LocalStack health
curl http://localhost:4566/_localstack/health

# Stop and remove containers
docker-compose down

# View LocalStack logs
docker-compose logs -f localstack
```

## OpenSearch Container
```bash
# Start OpenSearch for local testing
docker run -d --name opensearch -p 9200:9200 -p 9600:9600 \
  -e discovery.type=single-node \
  -e OPENSEARCH_INITIAL_ADMIN_PASSWORD=Admin123! \
  opensearchproject/opensearch:latest

# Check OpenSearch health
curl -k https://localhost:9200 -u admin:Admin123!

# Stop OpenSearch
docker stop opensearch && docker rm opensearch
```

## Useful Docker Commands
```bash
# List running containers
docker ps

# View all container logs
docker logs <container_id>

# Clean up unused images/containers
docker system prune -f
```
