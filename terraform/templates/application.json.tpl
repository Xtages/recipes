[
    {
        "essential": true,
        "memory": 3072,
        "name": "${APP_NAME}",
        "cpu": 2048,
        "image": "${REPOSITORY_URL}:${TAG}",
        "workingDirectory": "/",
        "command": ["node", "/usr/src/app/src/server.js"]
    },
    {
        "name": "nginx",
        "image": "606626603369.dkr.ecr.us-east-1.amazonaws.com/xtages-nginx:1.18.0",
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

