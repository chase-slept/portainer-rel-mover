<h1 align="center">
  Hello! 👋
</h1>

This repository contains a script for use in my homelab. Its purpose was to move data from one location to another. More info below.

## Table of Contents

- [About the Project](#about)
- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [Notes](#notes)

## About the Project

When I first started working with Docker containers, I set up Portainer to manage them from a UI for ease-of-access when working remotely. I wasn't very experienced with Docker at the time and made quite a few mistakes and problems for myself to solve later in the future. This project aims to solve one of those problems.

## The Problem

When initially configuring many of my containers, storage was usually an afterthought. As long as it was persistent, *where* the container data was stored wasn't really important. As such, I let Portainer 'decide' by setting the container storage paths to something like this:

    ```
    service-name:
      image: image.io/example-container:latest
      volumes: 
        - ./config:/config
        - ./data:/data 
    ```

The problem here are those last few lines, where I told Portainer to use relative paths, `./config` or `./data`. If you're like me several years ago, that's fine. Portainer reads the Docker Compose file, creates the Stack and starts the container using its own data folder as the relative path. As such, the container data lives within Portainer's own data path, wherever that may be. On my system that's `/data/compose`. Portainer does something a bit unexpected here, however. It has its own internal file system and when resolving relative paths, places each container in its own folder using an internal numerical Stack ID rather than container name. The actual paths for 'Example Container' were `/data/compose/12/config` and `/data/compose/12/data`. 

This was all well and good until much later down the road, when I needed to migrate a container or two... or all of them. Suddenly this is a really cumbersome set of files to identify and move without some work. At some point I made the decision to migrate but continued putting it on the backburner, knowing that I'd have to sort through a mess of files.

## The Solution 

This project attempts to solve this problem via a script which automates the identification and file operation functions. It matches the internal Portainer stack identifier to its Docker container, captures the container's path, then performs a copy to move the Portainer data to its new destination with proper naming conventions.  

## Notes

Bugs:
- The included `systemctl` commands sometimes don't restart the containers within the context of the script due to limits in how quickly the service can be restarted. Using `reset-failed` should fix this but the issue persists 