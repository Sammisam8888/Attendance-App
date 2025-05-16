from passlib.hash import pbkdf2_sha256 as sha256
from database import db


class User:
    def __init__(self, name, email, password):
        self.name = name
        self.email = email
        self.password = sha256.hash(password)
        # self.user_id = str(uuid.uuid4())
        # self.face_encoding = None  # Initialize face data as None
        
    def save_to_db(self,collection_name,unique_id):
        collection=getattr(db, collection_name)
        unique_value = getattr(self, unique_id)
        existing_user=collection.find_one({unique_id: unique_value})
        if existing_user:
            return {"message": f"{collection_name[:-1].capitalize()} already exists"}, 409
        #collection_name is a string -students or teachers
        result=collection.insert_one(self.__dict__)
        return {"message": f"{collection_name[:-1].capitalize()} inserted","Reg_no": str(unique_value)}, 201
        #result is an object which does not have a unique_id but has inserted_id attribute in which mongodb _id is assigned to inserted document
        
    
    @staticmethod
    def find_by_id(collection_name, unique_id, unique_value):
        collection=getattr(db, collection_name)
        return collection.find_one({unique_id: unique_value})
    
    @staticmethod
    def verify_password(password, hashed_password):
        return sha256.verify(password, hashed_password)

class Student(User):
    def __init__(self, name, email, password, reg_no):
        super().__init__(name, email, password)
        self.reg_no = reg_no 
        # self.face_encoding = None  # Initialize face data as None

    def save_to_db(self):
        return super().save_to_db("students", "reg_no")
    
    @staticmethod
    def find_by_id(reg_no):
        return Student.find_by_id("students","reg_no",reg_no)
    # @staticmethod
    # def get_face_encoding(roll_no):
    #     """Fetches the stored face encoding for a student by roll number."""
    #     student = db.students.find_one({"roll_no": roll_no}, {"_id": 0, "face_encoding": 1})
    #     return np.array(student["face_encoding"]) if student and "face_encoding" in student else None
    

    # def store_face_encoding(self, encoding):
    #     """Stores the student's face encoding directly in the students table."""
    #     encoding_list = encoding.tolist()  # Convert NumPy array to list before storing

    #     db.students.update_one(
    #         {"roll_no": self.roll_no},
    #         {"$set": {"face_encoding": encoding_list}}
    #     )
    #     return {"message": "Face data saved successfully"}, 200




class Teacher(User):
    def __init__(self, name, email, password, teacher_id):
        super().__init__(name, email, password)
        self.teacher_id = teacher_id

    
    def save_to_db(self):
        return super().save_to_db("teachers", "teacher_id")
 
    @staticmethod
    def find_by_id(teacher_id):
        return Teacher.find_by_id("teachers","teacher_id",teacher_id)
