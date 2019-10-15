# SampleManager Build Tasks
![Logo](images/SampleManager-64.png "Logo")

Repository for creating a Build Task for a propietary Software that need to have an instance created prior to build the Solution

[![Build status](https://dev.azure.com/openelp/BuildTask/_apis/build/status/BuildTask-CI)](https://dev.azure.com/openelp/BuildTask/_build/latest?definitionId=16)

[TOC]

## Create-Instance Task
---
![Build-Instance Task](images/BuildInstance-Task.png)

This task an be used to create a new SampleManager Instance.

![Build-Instance Configuration](images/Build-Instance-Config.png)

By enabling the _Create new Database_ option, the task will create a new SQL Server Database.

![Create-Database Configuration](images/Create-Database-Config.png)

By disabling the _Use trusted Connection_ option, the task will create Instance by using the gven connection informations for the database.

![SQL Server Configuration](images/SQL-Server-Connection.png)



## Delete-Instance Task
---
![Delete-Instance Task](images/DeleteInstance-Task.png)

This task an be used to create a new SampleManager Instance.

![Delete-Instance Configuration](images/Delete-Instance-Config.png)