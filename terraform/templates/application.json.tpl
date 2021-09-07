[
    {
        "essential": true,
        "memory": ${APP_VCPU},
        "name": "${APP_NAME}",
        "cpu": ${APP_MEM},
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
        "name": "nginx",
        "image": "${NGINX_REPOSITORY_URL}:${NGINX_TAG}",
        "memory": ${NGINX_MEM},
        "cpu": ${NGINX_VCPU},
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

