# IDS Semester Project

Semester project that was part of the Database Systems course of the Brno University of Technology, Faculty of Informational Technologies.

## Description

The aim of the project was to create a database script for creation of an Oracle SQL database. Furthermore the database was filled with data controlled by triggers and demonstrated various other features of the Oracle SQL language, such as views, procedures and user access controls.

This project is a collaborative work and it is published here with full acknowledgement of all authors.

It was created by a team consisting of me and Matouš Jemelka.

## Project File Structure

* src
  * _script.sql_

#### `script.sql`

The file contains the entire database script and is the only file in the project. It consists of
* `DROP TABLE` calls to ensure removal of any lingering tables
* `CREATE TABLE` calls to build up the database with `CONSTRAINT` attributes to create all primary and foreign keys
* `CREATE SEQUENCE` calls to create sequences for automated ID assignments
* `CREATE TRIGGER` calls to create triggers validating crucial data during inputs
* `CREATE PROCEDURE` calls to create example procedures implementing possibly useful functionality
* `CREATE VIEW` calls to create example views
* `CREATE EXPLAIN PLAN` call to create an explain plan for index optimization demonstration
* `GRANT [ALL|EXECUTE] ON` calls to grant proper access level to an example user
* `INSERT INTO TABLE` calls to fill up tables with example data
* `SELECT` calls to select data from tables and views using variably complex elements as specified by the assignment
