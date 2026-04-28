knowledge_base = {
    "cs_majors": ["Alice", "Bob", "Charlie", "David"],
    "math_majors": ["Eve", "Frank"],
    "paid_tuition": ["Alice", "Bob", "Eve", "Frank"],
    "academic_probation": ["Charlie"],
    "completed_courses": {
        "Alice": ["CS101", "CS102", "MATH101", "AI_401"],
        "Bob": ["CS101", "MATH101"],
        "Charlie": ["CS101", "CS102"],
        "David": ["CS101", "CS102", "MATH101", "AI_401"],
        "Eve": ["MATH101", "MATH102", "MATH201"],
        "Frank": ["MATH101"]
    },
    "prerequisites": {
        "AI_401": ["CS101", "CS102", "MATH101"],
        "CS102": ["CS101"],
        "MATH201": ["MATH101", "MATH102"]
    }
}

def is_cs_major(student):
    return student in knowledge_base["cs_majors"]

def has_paid(student):
    return student in knowledge_base["paid_tuition"]

def on_probation(student):
    return student in knowledge_base["academic_probation"]

def has_completed(student, course):
    return course in knowledge_base["completed_courses"].get(student, [])

def get_prereqs(course):
    return knowledge_base["prerequisites"].get(course, [])

def can_take_course(student, course):
    if on_probation(student):
        return False
        
    prereqs = get_prereqs(course)
    return all(has_completed(student, p) for p in prereqs)

def is_eligible_for_cs_graduation(student):
    core_requirements = ["CS101", "CS102", "AI_401"]
    
    if not is_cs_major(student) or not has_paid(student) or on_probation(student):
        return False
        
    return all(has_completed(student, c) for c in core_requirements)

def needs_advising_intervention(student):
    if on_probation(student):
        return True
        
    courses_taken = knowledge_base["completed_courses"].get(student, [])
    return len(courses_taken) == 0

all_students = ["Alice", "Bob", "Charlie", "David", "Eve", "Frank", "GhostStudent"]

for student in all_students:
    print(student)
    
    if is_eligible_for_cs_graduation(student):
        print("Graduation Eligible")
    else:
        print("Not Graduation Eligible")
        
    target_course = "AI_401"
    if can_take_course(student, target_course):
        print("Can enroll in", target_course)
    else:
        print("Cannot enroll in", target_course)
        
    if needs_advising_intervention(student):
        print("Needs advising intervention")
        
    print("")