[
    {
        "essential": true,
        "memory": 1024,
        "name": "${APP_NAME}",
        "cpu": 1024,
        "image": "${APP_REPOSITORY_URL}:${APP_TAG}",
        "workingDirectory": "/",
        "command": ["node", "/usr/src/app/src/server.js"],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group" : "/ecs/${APP_NAME}-${APP_ENV}",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "${APP_ENV}-${APP_BUILD_ID}"
            }
         }
    },
    {
        "essential": true,
        "memory": 512,
        "name": "postgres",
        "cpu": 512,
        "image": "605769209612.dkr.ecr.us-east-1.amazonaws.com/postgresql:13.4.0",
        "environment": [
            {
                "name": "POSTGRESQL_PASSWORD",
                "value": "1234567890"
            }
        ],
        "mountPoints": [
            {
                "sourceVolume": "rexray-vol",
                "containerPath": "/bitnami/postgresql/data"
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group" : "/ecs/${APP_NAME}-${APP_ENV}",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "postgres"
            }
         }
    },
    {
        "name": "nginx",
        "image": "${NGINX_REPOSITORY_URL}:${NGINX_TAG}",
        "memory": 256,
        "cpu": 256,
        "essential": true,
        "portMappings": [
            {
                "containerPort": 1800,
                "hostPort": 0
            }
        ],
        "environment": [
            {
                "name": "APP_NAME",
                "value": "${APP_NAME}"
            },
            {
                "name": "ORGANIZATION_HASH",
                "value": "${APP_ORG_HASH}"
            },
            {
                "name": "APP_ENV",
                "value": "${APP_ENV}"
            }
        ],
        "links": [
            "${APP_NAME}"
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group" : "/ecs/${APP_NAME}-${APP_ENV}",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "ecs-nginx"
            }
         }
    }
]

