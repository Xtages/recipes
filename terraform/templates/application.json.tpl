[
    {
        "essential": true,
        "memory": 3072,
        "name": "${APP_NAME}",
        "cpu": 2048,
        "image": "${APP_REPOSITORY_URL}:${APP_TAG}",
        "workingDirectory": "/",
        "command": ["node", "/usr/src/app/src/server.js"]
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
    }
]

