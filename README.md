# RaiPlay - Financial Literacy Gamification Platform



## JunctionxTirana Hackathon Project 

RaiPlay is an interactive financial literacy mobile application developed for the JunctionxTirana Hackathon. The platform aims to make financial education engaging and accessible to users of all ages through gamification, personalized learning paths, and an AI-powered financial assistant.

## 🌟 Key Features

- **Interactive Learning Journey**: Guided quest-based progression through financial literacy concepts
- **Mini-Games**: Engaging games that teach budgeting, investing, and financial decision-making
- **Educational Videos**: Curated video content explaining financial concepts
- **AI Financial Assistant**: Chat-based assistant to answer financial questions
- **Gamification**: XP system, levels, achievements, and daily streaks to maintain engagement
- **Social Elements**: Leaderboards to foster friendly competition
- **Personalized Experience**: Content adapts based on user progress and interests

## 🛠️ Technology Stack

### Frontend
- **Framework**: Flutter
- **State Management**: Riverpod
- **UI Components**: Custom widgets following Raiffeisen brand guidelines
- **Storage**: Secure local storage for authentication tokens

### Backend
- **Framework**: FastAPI (Python)
- **Authentication**: JWT-based authentication with Google OAuth support
- **Database**: PostgreSQL
- **API**: RESTful API design with standardized endpoint structure
- **AI Integration**: AI-powered financial assistance chatbot


## 🚀 Getting Started

### Backend Setup
1. Navigate to the `app` directory
2. Install dependencies: `pip install -r requirements.txt`
3. Set up environment variables (see `configuration.py`)
4. Run the application: `python app.py`

### Frontend Setup
1. Navigate to the `Mobile/raiplay` directory
2. Install dependencies: `flutter pub get`
3. Run the application: `flutter run`

## 📊 Learning Journey

The RaiPlay application guides users through a structured financial literacy curriculum:

1. **Financial Basics**: Understanding income, expenses, and savings
2. **Budgeting**: Creating and maintaining personal budgets
3. **Saving Strategies**: Setting goals and saving effectively
4. **Investing Basics**: Introduction to different investment vehicles
5. **Advanced Topics**: Risk management, retirement planning, etc.

Each section contains theory, interactive games, and assessments to reinforce learning.

## 🧩 Gamification Mechanics

- **XP System**: Users earn experience points for completing activities
- **Leveling**: Progress through levels as XP accumulates
- **Badges**: Achievement markers for specific accomplishments
- **Daily Streaks**: Rewards for consistent app usage
- **In-app Currency**: Virtual coins earned through activities
- **Quests**: Daily and weekly challenges to encourage engagement

## 📄 Documentation

Detailed documentation is available in the `Documentation/Code Documentation` directory:

- [System Architecture Overview](Documentation/Code%20Documentation/1_System_Architecture_Overview.md)
- [API Endpoints](Documentation/Code%20Documentation/2_API_Endpoints.md)
- [Frontend Architecture](Documentation/Code%20Documentation/3_Frontend_Architecture.md)
- [Backend Architecture](Documentation/Code%20Documentation/4_Backend_Architecture.md)
- [Visual Component Synopsis](Documentation/Code%20Documentation/5_Visual_Component_Synopsis.md)

## 👥 Hackathon Team

- Artin Rexhepi - Mobile App Engineer
- Daris Dragusha - Data Scientist
- Art Jashari - Embedded Engineer


## 📝 License

This project was created as part of the JunctionxTirana Hackathon and is intended for demonstration purposes.

## 🙏 Acknowledgements

- [Raiffeisen Bank Albania](https://www.raiffeisen.al/) for the challenge inspiration
- [Junction](https://www.hackjunction.com/) for organizing the hackathon
- All open source libraries used in this project
