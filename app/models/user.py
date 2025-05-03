from sqlalchemy.orm import relationship
from database.connection import Base

class User(Base):
    # ...existing code...
    
    # Add this relationship
    quests = relationship("UserQuest", back_populates="user")
    
    # ...existing code...
