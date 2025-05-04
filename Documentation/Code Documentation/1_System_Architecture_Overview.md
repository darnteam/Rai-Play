# RaiPlay System Architecture Overview

## Introduction

RaiPlay is a financial literacy application designed to help users learn about financial concepts through interactive games, videos, and a personalized learning journey. The system consists of two main components:

1. **Backend API**: A FastAPI-based RESTful service that handles authentication, user management, game progression tracking, video content delivery, and an AI-powered chatbot.

2. **Mobile Application**: A Flutter-based mobile app that provides an engaging user interface for interacting with the financial literacy content.

## System Components

### Backend (FastAPI)

The backend is structured as a modular FastAPI application with the following key components:

- **Authentication System**: Handles user registration, login, and OAuth integration with Google
- **User Management**: Manages user profiles, progression, achievements, and leaderboards
- **Games Service**: Delivers game content, tracks completion, and awards XP and coins
- **Video Service**: Provides educational video content with saving/bookmarking capabilities
- **Chat Service**: An AI-powered assistant that answers financial questions

### Frontend (Flutter)

The mobile application is built with Flutter and follows a structured architecture:

- **Presentation Layer**: Screens, widgets, and themes for the user interface
- **Business Logic**: State management using Riverpod
- **Services Layer**: API communication with the backend
- **Models**: Data structures representing the domain objects

## Communication Flow

The frontend and backend communicate through RESTful API endpoints secured with JWT authentication. The main flows are:

1. **Authentication**: The mobile app authenticates users through the `/auth` endpoints
2. **Content Delivery**: The app fetches games, videos, and user data through respective endpoints
3. **Progress Tracking**: The app sends completion data to the backend to track user progress
4. **Real-time Chat**: The app communicates with the financial chatbot for Q&A interactions

## Data Flow Diagram

```
┌─────────────────┐      HTTP/REST      ┌─────────────────┐
│                 │<─────────────────── │                 │
│  Mobile App     │                     │   FastAPI       │
│  (Flutter)      │ ──────────────────> │   Backend       │
│                 │                     │                 │
└─────────────────┘                     └─────────────────┘
        │                                       │
        │                                       │
        v                                       v
┌─────────────────┐                     ┌─────────────────┐
│  Local Storage  │                     │   PostgreSQL    │
│  (User session) │                     │   Database      │
└─────────────────┘                     └─────────────────┘
```

## Security Architecture

- **Authentication**: JWT tokens with limited lifespan
- **OAuth Integration**: Secure authentication with Google
- **HTTPS**: All API communication is secured with HTTPS
- **Password Management**: Passwords are hashed with bcrypt