# CS131-Project

## Requirements
* Docker
* MongoDB

This assumes you have docker installed and running as well as MongoDB running locally on port 27017 (default)

## To Build:

`docker build -t <name for container> .`

## To Run:

`docker run -d -p 3001:5000 <name>`

Now endpoints are exposed at `http://localhost:3001/<endpoint>`
