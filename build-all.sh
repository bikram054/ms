#!/bin/bash
echo "Building Docker containers..."
docker-compose build
echo "Starting Docker containers..."
docker-compose up