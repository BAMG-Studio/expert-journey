# Docker Commands

## Docker Compose
```bash
docker-compose up -d
docker-compose down
docker-compose down -v
docker-compose logs -f localstack
```

## LocalStack
```bash
curl http://localhost:4566/_localstack/health | jq
awslocal s3 ls
awslocal lambda list-functions
awslocal kinesis list-streams
```

## OpenSearch
```bash
curl http://localhost:9200/_cluster/health?pretty
curl http://localhost:9200/_cat/indices?v
curl -X GET http://localhost:9200/security-events/_search?pretty
```

## Containers
```bash
docker ps
docker exec -it siem-localstack bash
docker logs siem-opensearch -f
```

## Cleanup
```bash
docker container prune
docker image prune
docker system prune -a --volumes
```
