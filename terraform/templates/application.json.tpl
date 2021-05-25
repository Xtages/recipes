[
  {
    "essential": true,
    "memory": 3072,
    "name": "${APP_NAME}",
    "cpu": 2048,
    "image": "${REPOSITORY_URL}:${TAG}",
    "workingDirectory": "/",
    "command": ["node", "/usr/src/app/src/server.js"],
    "portMappings": [
        {
            "containerPort": 3000,
            "hostPort": 0
        }
    ]
  }
]

