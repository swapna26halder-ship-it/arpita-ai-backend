

from datetime import datetime
from sqlalchemy import Boolean, Column, DateTime, Integer, String
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    username = Column(String(50), unique=True, nullable=False, index=True)

    email = Column(String(100), unique=True, nullable=False, index=True)

    hashed_password = Column(String(255), nullable=False)

    is_active = Column(Boolean, default=True, nullable=False)

    is_admin = Column(Boolean, default=False, nullable=False)

    created_at = Column(DateTime, default=datetime.now, nullable=False)

    last_login = Column(DateTime, nullable=True)
