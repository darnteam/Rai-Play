from pydantic import BaseModel, EmailStr, Field

class SignUpDTO(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)

class ConfirmSignUpDTO(BaseModel):
    email: EmailStr
    code: str

class LoginDTO(BaseModel):
    email: EmailStr
    password: str
