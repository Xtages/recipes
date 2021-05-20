[
  {
    "essential": true,
    "memory": 4096,
    "name": "${APP_NAME}",
    "cpu": 2048,
    "image": "${REPOSITORY_URL}:${TAG}",
    "workingDirectory": "/",
    "command": ["node", "src/server.js"],
    "portMappings": [
        {
            "containerPort": 3000,
            "hostPort": 0
        }
    ]
  }
]

