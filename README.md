# Lab Inventory Management and Requisition System

## Frontend - https://github.com/winterDark22/Lab-Inventory-Frontend

### Scope presentation - https://docs.google.com/presentation/d/1F__BGtZW-tX2V_CM84Rmg1KLGbPGV_7GHTZh2FIq5gQ/edit?usp=sharing

### API Documentation - https://docs.google.com/spreadsheets/d/1ulIaOrfKW6-bAyFFJXQff2q_c1-XQN35D6BLFM2HCNw/edit?usp=sharing

## Backend Requirements

- Install Nodejs

- Install PostgreSQL 16 version
    - Windows : https://www.postgresql.org/download/
    - Ubuntu : https://dev.to/rainbowhat/postgresql-16-installation-on-ubuntu-2204-51ia

- In PostgreSQL create a database named labinventory

### `create database labinventory`

- Run the dumpfile

### `psql -U postgres -h localhost -d labinventory -f mydatabase_dump.sql`

- Run the following command to install all the dependencies from package.json

### `npm install`

- Run the following command to start the server

### `npm start`
