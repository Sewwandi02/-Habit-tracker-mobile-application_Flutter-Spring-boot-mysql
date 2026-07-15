Habit Tracker is a Personal Habit Management Platform.

Flutter/Spring Boot-based full-stack application for habit tracking, enabling users to create positive habits, track their daily progress, and ensure sustained consistency over time. The system is built using a modern client-server architecture, offers secure JWT-based authentication, and offers a clean, responsive mobile experience.

## Overview

Habit Tracker is a mobile app that uses a structured approach to tracking and monitoring progress to develop and maintain healthy habits. The project features a secure authentication system, RESTful APIs, persistent data storage, and a seamless mobile app interface, all wrapped up in a comprehensive full-stack application.

## Core Capabilities

- Register and Authenticate users with JWT.
Establish, manage and terminate personal habits.
Ensure that they have checked off what they did daily
- See individualized lists of habits
- Store user information reliably in MySQL
- Connect with the backend via REST service APIs

## Feature Set

### User Features

Registering and logging on to the system.User Registration and Login.
- Secure JWT-based authentication
- Create new habits
- Edit existing habits
- Delete habits
- Mark habits as completed
View their own habit history.
- Responsive Material Design 3 user interface

### Backend Features

- RESTful API architecture
- User authentication and authorization
The following CRUD operations are performed on the habit management:
- Understanding the concept of persistence in a database system.
- Secure password encryption
- JSON-based client-server communication

## Technology Stack

| Layer | Technology |
|------|------------|
| Frontend | Flutter, Dart |
| Backend | Java 21, Spring Boot 3 |
| Database | MySQL |
ORM | Spring Data JPA, Hibernate |
Spring Security, JWT |
| Build Tool | Maven |
Web Services |
| UI Design | Material Design 3 |

## Project Structure

```text
Habit-Tracker/
├── backend/
│   ├── src/main/java/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── entities/
│   │   ├── repositories/
│   │   ├── security/
│   │   └── services/
│   ├── src/test/
│   └── pom.xml
│
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── main.dart
│   └── pubspec.yaml
│
└── README.md
```

## Architecture

It is a client-server application, and the application's front end component is separated from its back end components.

A mobile UI is provided by Flutter.
- RESTful APIs are provided by Spring Boot.
Spring Security is used for handling authentication and authorization.
Spring Data JPA manages database persistence.
Data for the application and users is stored in MySQL.

It is an architecture that has separation of concerns, scalability and maintainability.

## Security Implementation

Modern backend development practices are used to implement security.

- JWT-based authentication
- Password hashing with BCrypt
- Spring Security check for authorization
- Protected API endpoints
- User-specific data access
- Stateless authentication model

## Database Design

The application's key workflow is facilitated by various related entities in the database.

- Users
- Habits
- Habit completion records
- Authentication data

Spring Data JPA and Hibernate are used for managing relationships.

## Setup and Installation

### Requirements

- Java 21
- Flutter SDK
Android Studio or VS Code
- MySQL
- Maven

### Installation Steps

1. Clone the repository.

3. Create the user(s) and grant them access.

3. Make sure that the database connection properties have been updated in the Spring Boot configuration.

5. Run the backend server.

```bash
mvn spring-boot:run
```

6. Go to the Flutter project.

```bash
cd frontend
```

6. Install dependencies.

```bash
flutter pub get
```

7. Run the application.

```bash
flutter run
```

## API Summary

### Authentication

- `POST /api/auth/register`
- `POST /api/auth/login`

### Habits

- `GET /api/habits`
- `POST /api/habits`
- `PUT /api/habits/{id}`
- `DELETE /api/habits/{id}`
- `PATCH /api/habits/{id}/toggle`

## Development Notes

This project incorporates modern practices of software engineering such as:

- Layered application architecture
- RESTful API design
Discriminating between front end and back end.Distinguishing between front end and back end.
Using JPA for ORM.
- JWT-based authentication
- Clean package organization
- Material Design 3 user interface
Learning how to do basic integration testing with MockMvc.


## Project Status

This project is a full stack application that showcases the resultof practicing software engineering skills in the context of a mobile application, backend API design, database manipulation, authentication and client-server architecture. 


