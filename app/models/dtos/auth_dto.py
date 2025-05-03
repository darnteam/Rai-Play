from pydantic import BaseModel, EmailStr, Field

from pydantic import BaseModel, EmailStr

class SignUpDTO(BaseModel):
    username: str
    email: EmailStr
    password: str


class ConfirmSignUpDTO(BaseModel):
    email: EmailStr
    code: str

class LoginDTO(BaseModel):
    email: EmailStr
    password: str


