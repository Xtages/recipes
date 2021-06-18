[
    {
        "essential": true,
        "memory": 3072,
        "name": "${APP_NAME}",
        "cpu": 1792,
        "image": "${APP_REPOSITORY_URL}:${APP_TAG}",
        "workingDirectory": "/",
        "command": ["node", "/usr/src/app/src/server.js"]
        "logConfiguration": {
            "logDriver": "awslogs"
            "options": {
                "awslogs-group" : "/ecs/${APP_NAME}-task-definition",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "ecs"
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
            }
        ],
        "links": [
            "${APP_NAME}"
        ]
        "logConfiguration": {
            "logDriver": "awslogs"
            "options": {
                "awslogs-group" : "/ecs/nginx-task-definition",
                "awslogs-region": "us-east-1",
                "awslogs-stream-prefix": "ecs"
            }
         }
    }
]

